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
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"time"
)

const (
	tokenFileName = ".gzr_auth"
	timeFormat    = "2006-01-02 15:04:05 -0700"
)

type TokenEntry struct {
	Token      string `json:"token"`
	Expiration string `json:"expiration"`
}

type HostTokens map[string]TokenEntry

type TokenData map[string]HostTokens

func getTokenFilePath() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", fmt.Errorf("failed to get home dir: %w", err)
	}
	return filepath.Join(home, tokenFileName), nil
}

func ReadTokenData() (TokenData, error) {
	path, err := getTokenFilePath()
	if err != nil {
		return nil, err
	}

	stat, err := os.Stat(path)
	if os.IsNotExist(err) {
		return make(TokenData), nil
	} else if err != nil {
		return nil, fmt.Errorf("failed to stat token file: %w", err)
	}

	// Check permissions (should be 600)
	if stat.Mode().Perm() != 0600 {
		return nil, fmt.Errorf("token file %s has insecure permissions %s, expected 0600", path, stat.Mode().Perm())
	}

	file, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("failed to open token file: %w", err)
	}
	defer func() { _ = file.Close() }()

	var data TokenData
	if err := json.NewDecoder(file).Decode(&data); err != nil {
		return nil, fmt.Errorf("failed to decode token file: %w", err)
	}

	return data, nil
}

func WriteTokenData(data TokenData) error {
	path, err := getTokenFilePath()
	if err != nil {
		return err
	}

	file, err := os.OpenFile(path, os.O_RDWR|os.O_CREATE|os.O_TRUNC, 0600)
	if err != nil {
		return fmt.Errorf("failed to open token file for writing: %w", err)
	}
	defer func() { _ = file.Close() }()

	encoder := json.NewEncoder(file)
	encoder.SetIndent("", "  ")
	if err := encoder.Encode(data); err != nil {
		return fmt.Errorf("failed to encode token data: %w", err)
	}

	return nil
}

func GetToken(host, suUser string) (string, error) {
	data, err := ReadTokenData()
	if err != nil {
		return "", err
	}

	hostTokens, ok := data[host]
	if !ok {
		return "", fmt.Errorf("no tokens found for host %s", host)
	}

	key := "default"
	if suUser != "" {
		key = suUser
	}

	entry, ok := hostTokens[key]
	if !ok {
		return "", fmt.Errorf("no token found for host %s, user %s", host, key)
	}

	exp, err := time.Parse(timeFormat, entry.Expiration)
	if err != nil {
		return "", fmt.Errorf("failed to parse expiration time %s: %w", entry.Expiration, err)
	}

	if time.Now().After(exp.Add(-5 * time.Minute)) {
		return "", fmt.Errorf("token expired or expiring soon (at %s)", entry.Expiration)
	}

	return entry.Token, nil
}

func StoreToken(host, suUser, token string, expiration time.Time) error {
	data, err := ReadTokenData()
	if err != nil {
		// If error is permission error, fail. If it's just decode error or similar, maybe overwrite?
		// ReadTokenData returns empty map if file doesn't exist.
		// If it failed for other reasons, we should probably propagate.
		return err
	}
	if data == nil {
		data = make(TokenData)
	}

	hostTokens, ok := data[host]
	if !ok {
		hostTokens = make(HostTokens)
		data[host] = hostTokens
	}

	key := "default"
	if suUser != "" {
		key = suUser
	}

	hostTokens[key] = TokenEntry{
		Token:      token,
		Expiration: expiration.Format(timeFormat),
	}

	return WriteTokenData(data)
}
