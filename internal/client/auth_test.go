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
	"os"
	"path/filepath"
	"testing"
	"time"
)

func TestTokenStorage(t *testing.T) {
	tmpDir, err := os.MkdirTemp("", "gzr_test_*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	origHome := os.Getenv("HOME")
	defer os.Setenv("HOME", origHome)
	os.Setenv("HOME", tmpDir)

	host := "test.looker.com"
	token := "test_token_123"
	exp := time.Now().Add(1 * time.Hour)

	// 1. Store token
	err = StoreToken(host, "", token, exp)
	if err != nil {
		t.Fatalf("StoreToken failed: %v", err)
	}

	// 2. Verify file exists and permissions
	path := filepath.Join(tmpDir, tokenFileName)
	stat, err := os.Stat(path)
	if err != nil {
		t.Fatalf("token file not created: %v", err)
	}
	if stat.Mode().Perm() != 0600 {
		t.Errorf("expected perm 0600, got %v", stat.Mode().Perm())
	}

	// 3. Get token
	gotTok, err := GetToken(host, "")
	if err != nil {
		t.Fatalf("GetToken failed: %v", err)
	}
	if gotTok != token {
		t.Errorf("expected token %s, got %s", token, gotTok)
	}

	// 4. Get token for non-existent host
	_, err = GetToken("unknown.com", "")
	if err == nil {
		t.Errorf("expected error for unknown host")
	}

	// 5. Store su token
	suUser := "1237"
	suToken := "su_token_456"
	err = StoreToken(host, suUser, suToken, exp)
	if err != nil {
		t.Fatalf("StoreToken su failed: %v", err)
	}

	gotSuTok, err := GetToken(host, suUser)
	if err != nil {
		t.Fatalf("GetToken su failed: %v", err)
	}
	if gotSuTok != suToken {
		t.Errorf("expected su token %s, got %s", suToken, gotSuTok)
	}
}

func TestTokenStorage_Expired(t *testing.T) {
	tmpDir, err := os.MkdirTemp("", "gzr_test_*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	origHome := os.Getenv("HOME")
	defer os.Setenv("HOME", origHome)
	os.Setenv("HOME", tmpDir)

	host := "test.looker.com"
	token := "test_token_123"
	// Expired 10 minutes ago
	exp := time.Now().Add(-10 * time.Minute)

	err = StoreToken(host, "", token, exp)
	if err != nil {
		t.Fatalf("StoreToken failed: %v", err)
	}

	_, err = GetToken(host, "")
	if err == nil {
		t.Errorf("expected error for expired token")
	}
}
