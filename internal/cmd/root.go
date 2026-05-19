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

package cmd

import (
	"context"
	"fmt"
	"os"

	"github.com/spf13/cobra"
	v4 "github.com/looker-open-source/sdk-codegen/go/sdk/v4"
	"gzr.looker.com/gzr/internal/client"
)

var (
	cfgHost         string
	cfgPort         string
	cfgClientID     string
	cfgClientSecret string
	cfgToken        string
	cfgSuUser       string
	cfgSSL          bool
	cfgVerifySSL    bool
	cfgTokenFile    bool
	cfgDebug        bool
	cfgTimeout      int
	cfgHTTPProxy    string
	cfgForce        bool
	cfgWidth        int
	cfgOAuth        bool // For session login --oauth, but let's put it on session login command or global if needed
)

var RootCmd = &cobra.Command{
	Use:   "gzr",
	Short: "Gazer - A Looker Content Utility",
	Long:  `Gazer can be used to navigate and manage Spaces, Looks, and Dashboards via a simple command line tool.`,
}

func Execute() {
	if err := RootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	RootCmd.PersistentFlags().StringVar(&cfgHost, "host", "localhost", "Looker Host")
	RootCmd.PersistentFlags().StringVar(&cfgPort, "port", "19999", "Looker API Port")
	RootCmd.PersistentFlags().StringVar(&cfgClientID, "client-id", "", "API Client Id")
	RootCmd.PersistentFlags().StringVar(&cfgClientSecret, "client-secret", "", "API Client Secret")
	RootCmd.PersistentFlags().StringVar(&cfgToken, "token", "", "Access token to use for authentication")
	RootCmd.PersistentFlags().StringVar(&cfgSuUser, "su", "", "After connecting, change to user_id given")
	RootCmd.PersistentFlags().BoolVar(&cfgSSL, "ssl", true, "Use ssl to communicate with host")
	RootCmd.PersistentFlags().BoolVar(&cfgVerifySSL, "verify-ssl", true, "Verify the SSL certificate of the host")
	RootCmd.PersistentFlags().BoolVar(&cfgTokenFile, "token-file", false, "Use access token stored in file for authentication")
	RootCmd.PersistentFlags().BoolVar(&cfgDebug, "debug", false, "Run in debug mode")
	RootCmd.PersistentFlags().IntVar(&cfgTimeout, "timeout", 60, "Seconds to wait for a response from the server")
	RootCmd.PersistentFlags().StringVar(&cfgHTTPProxy, "http-proxy", "", "HTTP Proxy for connecting to Looker host")
	RootCmd.PersistentFlags().BoolVar(&cfgForce, "force", false, "Overwrite objects on server")
	RootCmd.PersistentFlags().IntVar(&cfgWidth, "width", 0, "Width of rendering for tables")
}

var MockSDK *v4.LookerSDK

func initClient(ctx context.Context, oauth bool) (*client.ClientWrapper, error) {
	if MockSDK != nil {
		return &client.ClientWrapper{SDK: MockSDK, Host: cfgHost, SuUser: cfgSuUser}, nil
	}
	return client.NewClient(
		ctx,
		cfgHost,
		cfgPort,
		cfgClientID,
		cfgClientSecret,
		cfgToken,
		cfgSuUser,
		cfgSSL,
		cfgVerifySSL,
		oauth,
		cfgTokenFile,
	)
}
