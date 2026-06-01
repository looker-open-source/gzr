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
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/looker-open-source/sdk-codegen/go/rtl"
	v4 "github.com/looker-open-source/sdk-codegen/go/sdk/v4"
	"golang.org/x/oauth2"
)

type ClientWrapper struct {
	SDK     *v4.LookerSDK
	Session *rtl.AuthSession
	Host    string
	SuUser  string
}

// NewClient initializes LookerSDK based on provided flags and auth mechanisms.
func NewClient(ctx context.Context, host, port, clientID, clientSecret, token, suUser string, ssl, verifySSL, oauth, tokenFile bool) (*ClientWrapper, error) {
	scheme := "https"
	if !ssl {
		scheme = "http"
	}

	apiHost := host
	if port != "" {
		apiHost = host + ":" + port
	}
	baseURL := fmt.Sprintf("%s://%s", scheme, apiHost)

	settings := rtl.ApiSettings{
		BaseUrl:   baseURL,
		VerifySsl: verifySSL,
		Timeout:   120,
		AgentTag:  "Gazer 0.3.0",
		Headers:   make(map[string]string),
	}

	var activeToken string

	if token != "" {
		activeToken = token
	} else if tokenFile {
		entry, err := GetTokenEntry(host, suUser)
		if err != nil && suUser != "" {
			entry, err = GetTokenEntry(host, "")
		}
		if err != nil {
			return nil, fmt.Errorf("auth required: no valid token found in file for host %s (%v)", host, err)
		}

		exp, err := time.Parse(TimeFormat, entry.Expiration)
		expired := false
		if err != nil {
			expired = true
		} else if time.Now().After(exp.Add(-5 * time.Minute)) {
			expired = true
		}

		if expired && entry.RefreshToken != "" {
			cID := entry.ClientID
			if cID == "" {
				cID = "gzr"
			}
			tok, refTok, newExp, err := RefreshOAuthToken(ctx, host, port, cID, entry.RefreshToken, ssl)
			if err == nil {
				_ = StoreToken(host, suUser, tok, refTok, cID, newExp)
				activeToken = tok
			} else {
				return nil, fmt.Errorf("token expired and refresh failed: %w", err)
			}
		} else if expired {
			return nil, fmt.Errorf("token expired and cannot be refreshed (no refresh token found)")
		} else {
			activeToken = entry.Token
		}
	} else if oauth {
		if clientID == "" {
			clientID = "gzr"
		}
		tok, refTok, exp, err := PerformOAuthLogin(ctx, host, port, clientID, ssl)
		if err != nil {
			return nil, fmt.Errorf("oauth login failed: %w", err)
		}
		activeToken = tok
		_ = StoreToken(host, suUser, tok, refTok, clientID, exp)
	} else {
		if clientID == "" || clientSecret == "" {
			cID, cSec, err := GetNetrcCredentials(host)
			if err == nil && cID != "" && cSec != "" {
				clientID = cID
				clientSecret = cSec
			} else {
				envSettings, _ := rtl.NewSettingsFromEnv()
				if envSettings.ClientId != "" && envSettings.ClientSecret != "" {
					clientID = envSettings.ClientId
					clientSecret = envSettings.ClientSecret
				}
			}
		}

		if clientID != "" && clientSecret != "" {
			settings.ClientId = clientID
			settings.ClientSecret = clientSecret
		} else {
			return nil, fmt.Errorf("auth required: must provide token, oauth, netrc, or client_id/secret")
		}
	}

	if activeToken != "" {
		if !strings.HasPrefix(activeToken, "Bearer ") && !strings.HasPrefix(activeToken, "token ") {
			activeToken = "Bearer " + activeToken
		}
		settings.Headers["Authorization"] = activeToken
	}

	session := rtl.NewAuthSession(settings)

	if activeToken != "" {
		rawToken := activeToken
		if strings.HasPrefix(rawToken, "Bearer ") {
			rawToken = strings.TrimPrefix(rawToken, "Bearer ")
		} else if strings.HasPrefix(rawToken, "token ") {
			rawToken = strings.TrimPrefix(rawToken, "token ")
		}

		if oauth2Trans, ok := session.Client.Transport.(*oauth2.Transport); ok {
			oauth2Trans.Source = oauth2.StaticTokenSource(&oauth2.Token{
				AccessToken: rawToken,
			})
		}
	}

	sdk := v4.NewLookerSDK(session)

	wrapper := &ClientWrapper{
		SDK:     sdk,
		Session: session,
		Host:    host,
		SuUser:  suUser,
	}

	if suUser != "" && (settings.ClientId != "" || settings.Headers["Authorization"] != "") {
		tok, err := GetToken(host, suUser)
		if err != nil || tok == "" || settings.Headers["Authorization"] != "Bearer "+tok {
			suTokResp, err := sdk.LoginUser(suUser, nil)
			if err != nil {
				return nil, fmt.Errorf("failed to su to user %s: %w", suUser, err)
			}
			if suTokResp.AccessToken == nil || suTokResp.ExpiresIn == nil {
				return nil, fmt.Errorf("invalid su token response")
			}

			suTok := "Bearer " + *suTokResp.AccessToken
			session.Config.Headers["Authorization"] = suTok
			exp := time.Now().Add(time.Duration(*suTokResp.ExpiresIn) * time.Second)
			_ = StoreToken(host, suUser, *suTokResp.AccessToken, "", "", exp)
		}
	}

	return wrapper, nil
}

// ExplicitLogin performs explicit API login to get token details for 'session login'.
func (c *ClientWrapper) ExplicitLogin(clientID, clientSecret string) (string, time.Time, error) {
	resp, err := c.SDK.Login(v4.RequestLogin{ClientId: &clientID, ClientSecret: &clientSecret}, nil)
	if err != nil {
		return "", time.Time{}, err
	}
	if resp.AccessToken == nil || resp.ExpiresIn == nil {
		return "", time.Time{}, fmt.Errorf("invalid login response")
	}
	exp := time.Now().Add(time.Duration(*resp.ExpiresIn) * time.Second)
	return *resp.AccessToken, exp, nil
}

// Logout explicitly logs out.
func (c *ClientWrapper) Logout() error {
	_, err := c.SDK.Logout(nil)
	return err
}
