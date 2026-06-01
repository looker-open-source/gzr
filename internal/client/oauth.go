// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package client

import (
	"bytes"
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"

	"github.com/pkg/browser"
)

const (
	redirectPort = "8080"
	redirectURI  = "http://localhost:" + redirectPort + "/callback"
)

type tokenResponse struct {
	AccessToken string `json:"access_token"`
	TokenType   string `json:"token_type"`
	ExpiresIn   int64  `json:"expires_in"`
	RefreshToken string `json:"refresh_token"`
}

func generatePKCE() (verifier, challenge string, err error) {
	verifierBytes := make([]byte, 32)
	if _, err := rand.Read(verifierBytes); err != nil {
		return "", "", err
	}
	verifier = base64.RawURLEncoding.EncodeToString(verifierBytes)

	hasher := sha256.New()
	hasher.Write([]byte(verifier))
	challenge = base64.RawURLEncoding.EncodeToString(hasher.Sum(nil))

	return verifier, challenge, nil
}

// PerformOAuthLogin initiates PKCE flow, opens browser, waits for callback, and exchanges code for token.
func PerformOAuthLogin(ctx context.Context, host, port, clientID string, ssl bool) (string, string, time.Time, error) {
	verifier, challenge, err := generatePKCE()
	if err != nil {
		return "", "", time.Time{}, fmt.Errorf("failed to generate PKCE: %w", err)
	}

	scheme := "https"
	if !ssl {
		scheme = "http"
	}

	// UI host for /auth
	uiHost := host
	uiURL := fmt.Sprintf("%s://%s/auth", scheme, uiHost)

	authURL, err := url.Parse(uiURL)
	if err != nil {
		return "", "", time.Time{}, fmt.Errorf("invalid auth URL: %w", err)
	}

	q := authURL.Query()
	q.Set("client_id", clientID)
	q.Set("redirect_uri", redirectURI)
	q.Set("response_type", "code")
	q.Set("scope", "cors_api") // Looker API scope
	q.Set("code_challenge", challenge)
	q.Set("code_challenge_method", "S256")
	authURL.RawQuery = q.Encode()

	codeChan := make(chan string, 1)
	errChan := make(chan error, 1)

	mux := http.NewServeMux()
	srv := &http.Server{
		Addr:    ":" + redirectPort,
		Handler: mux,
	}

	mux.HandleFunc("/callback", func(w http.ResponseWriter, r *http.Request) {
		code := r.URL.Query().Get("code")
		if code == "" {
			errDesc := r.URL.Query().Get("error_description")
			http.Error(w, "Authorization failed: "+errDesc, http.StatusBadRequest)
			errChan <- fmt.Errorf("oauth error: %s", errDesc)
			return
		}

		w.Header().Set("Content-Type", "text/html")
		_, _ = fmt.Fprintf(w, "<html><body><h1>Authorization Successful!</h1><p>You can close this window and return to the CLI.</p></body></html>")
		codeChan <- code
	})

	go func() {
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			errChan <- fmt.Errorf("local server error: %w", err)
		}
	}()
	defer func() { _ = srv.Shutdown(context.Background()) }()

	fmt.Printf("Opening browser to URL: %s\n", authURL.String())
	if err := browser.OpenURL(authURL.String()); err != nil {
		fmt.Printf("Failed to open browser automatically. Please visit the URL above.\n")
	}

	select {
	case <-ctx.Done():
		return "", "", time.Time{}, ctx.Err()
	case err := <-errChan:
		return "", "", time.Time{}, err
	case code := <-codeChan:
		// Exchange code for token
		apiHost := host
		if port != "" {
			apiHost = host + ":" + port
		}
		tokenURL := fmt.Sprintf("%s://%s/api/token", scheme, apiHost)

		body := map[string]string{
			"grant_type":    "authorization_code",
			"client_id":     clientID,
			"redirect_uri":  redirectURI,
			"code":          code,
			"code_verifier": verifier,
		}
		bodyBytes, _ := json.Marshal(body)

		req, err := http.NewRequestWithContext(ctx, http.MethodPost, tokenURL, bytes.NewReader(bodyBytes))
		if err != nil {
			return "", "", time.Time{}, fmt.Errorf("create token request failed: %w", err)
		}
		req.Header.Set("Content-Type", "application/json")

		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			return "", "", time.Time{}, fmt.Errorf("token request failed: %w", err)
		}
		defer func() { _ = resp.Body.Close() }()

		if resp.StatusCode != http.StatusOK {
			bodyStr, _ := io.ReadAll(resp.Body)
			return "", "", time.Time{}, fmt.Errorf("token request returned status %d: %s", resp.StatusCode, string(bodyStr))
		}

		var tokResp tokenResponse
		if err := json.NewDecoder(resp.Body).Decode(&tokResp); err != nil {
			return "", "", time.Time{}, fmt.Errorf("failed to decode token response: %w", err)
		}

		expiration := time.Now().Add(time.Duration(tokResp.ExpiresIn) * time.Second)
		return tokResp.AccessToken, tokResp.RefreshToken, expiration, nil
	}
}

// RefreshOAuthToken performs explicit OAuth2 refresh token grant to get a new short-lived access token.
func RefreshOAuthToken(ctx context.Context, host, port, clientID, refreshToken string, ssl bool) (string, string, time.Time, error) {
	scheme := "https"
	if !ssl {
		scheme = "http"
	}

	apiHost := host
	if port != "" {
		apiHost = host + ":" + port
	}
	tokenURL := fmt.Sprintf("%s://%s/api/token", scheme, apiHost)

	body := map[string]string{
		"grant_type":    "refresh_token",
		"client_id":     clientID,
		"refresh_token": refreshToken,
	}
	bodyBytes, _ := json.Marshal(body)

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, tokenURL, bytes.NewReader(bodyBytes))
	if err != nil {
		return "", "", time.Time{}, fmt.Errorf("create refresh token request failed: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", "", time.Time{}, fmt.Errorf("refresh token request failed: %w", err)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode != http.StatusOK {
		bodyStr, _ := io.ReadAll(resp.Body)
		return "", "", time.Time{}, fmt.Errorf("refresh token request returned status %d: %s", resp.StatusCode, string(bodyStr))
	}

	var tokResp tokenResponse
	if err := json.NewDecoder(resp.Body).Decode(&tokResp); err != nil {
		return "", "", time.Time{}, fmt.Errorf("failed to decode token response: %w", err)
	}

	expiration := time.Now().Add(time.Duration(tokResp.ExpiresIn) * time.Second)

	// Fallback to old refresh token if server did not issue a new one
	newRefreshToken := tokResp.RefreshToken
	if newRefreshToken == "" {
		newRefreshToken = refreshToken
	}

	return tokResp.AccessToken, newRefreshToken, expiration, nil
}
