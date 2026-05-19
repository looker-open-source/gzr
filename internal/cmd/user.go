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
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/spf13/cobra"
	v4 "github.com/looker-open-source/sdk-codegen/go/sdk/v4"
	"gzr.looker.com/gzr/internal/util"
)

var (
	userCatFields    string
	userCatDir       string
	userCatTrim      bool
	userMeFields     string
	userMePlain      bool
	userMeCSV        bool
	userLsFields     string
	userLsLastLogin  bool
	userLsPlain      bool
	userLsCSV        bool
)

var UserCmd = &cobra.Command{
	Use:   "user",
	Short: "Commands pertaining to users",
}

var userEnableCmd = &cobra.Command{
	Use:   "enable [USER_ID]",
	Short: "Enable the user given by user_id",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}
		userID := args[0]
		falseVal := false
		_, err = c.SDK.UpdateUser(userID, v4.WriteUser{IsDisabled: &falseVal}, "", nil)
		if err != nil {
			return fmt.Errorf("failed to enable user %s: %w", userID, err)
		}
		fmt.Printf("User %s enabled.\n", userID)
		return nil
	},
}

var userDisableCmd = &cobra.Command{
	Use:   "disable [USER_ID]",
	Short: "Disable the user given by user_id",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}
		userID := args[0]
		trueVal := true
		_, err = c.SDK.UpdateUser(userID, v4.WriteUser{IsDisabled: &trueVal}, "", nil)
		if err != nil {
			return fmt.Errorf("failed to disable user %s: %w", userID, err)
		}
		fmt.Printf("User %s disabled.\n", userID)
		return nil
	},
}

var userDeleteCmd = &cobra.Command{
	Use:   "delete [USER_ID]",
	Short: "Delete the user given by user_id",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}
		userID := args[0]
		_, err = c.SDK.DeleteUser(userID, nil)
		if err != nil {
			return fmt.Errorf("failed to delete user %s: %w", userID, err)
		}
		fmt.Printf("User %s deleted.\n", userID)
		return nil
	},
}

var userCatCmd = &cobra.Command{
	Use:   "cat [USER_ID]",
	Short: "Output json information about a user to screen or file",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}
		userID := args[0]

		user, err := c.SDK.User(userID, userCatFields, nil)
		if err != nil {
			return fmt.Errorf("failed to get user %s: %w", userID, err)
		}

		dataBytes, _ := json.Marshal(user)
		var dataMap map[string]interface{}
		_ = json.Unmarshal(dataBytes, &dataMap)

		if userCatTrim {
			keep := map[string]bool{
				"id":                   true,
				"credentials_email":    true,
				"first_name":           true,
				"home_folder_id":       true,
				"is_disabled":          true,
				"last_name":            true,
				"locale":               true,
				"models_dir_validated": true,
				"ui_state":             true,
				"can_manage_api3_creds": true,
			}
			for k := range dataMap {
				if !keep[k] {
					delete(dataMap, k)
				}
			}
		}

		outBytes, _ := json.MarshalIndent(dataMap, "", "  ")
		if userCatDir != "" {
			var id int64
			if v, ok := dataMap["id"].(float64); ok {
				id = int64(v)
			}
			fn := fmt.Sprintf("%s/User_%d_%s_%s.json", userCatDir, id, dataMap["first_name"], dataMap["last_name"])
			err = os.WriteFile(fn, outBytes, 0644)
			if err != nil {
				return fmt.Errorf("failed to write file %s: %w", fn, err)
			}
			fmt.Printf("Wrote %s\n", fn)
		} else {
			fmt.Println(string(outBytes))
		}
		return nil
	},
}

func extractFields(item interface{}, fieldsStr string) []string {
	b, _ := json.Marshal(item)
	var m map[string]interface{}
	_ = json.Unmarshal(b, &m)

	fields := strings.Split(fieldsStr, ",")
	row := make([]string, len(fields))
	for i, f := range fields {
		f = strings.TrimSpace(f)
		val, ok := m[f]
		if !ok || val == nil {
			row[i] = ""
		} else {
			switch v := val.(type) {
			case string:
				row[i] = v
			case float64:
				row[i] = strconv.FormatFloat(v, 'f', -1, 64)
			case bool:
				row[i] = strconv.FormatBool(v)
			default:
				vb, _ := json.Marshal(v)
				row[i] = string(vb)
			}
		}
	}
	return row
}

var userMeCmd = &cobra.Command{
	Use:   "me",
	Short: "Show information for the current user",
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}
		me, err := c.SDK.Me(userMeFields, nil)
		if err != nil {
			return fmt.Errorf("failed to get me: %w", err)
		}

		headers := strings.Split(userMeFields, ",")
		for i := range headers {
			headers[i] = strings.TrimSpace(headers[i])
		}
		table := util.NewTable(headers)
		table.Append(extractFields(me, userMeFields))
		table.Render(userMePlain, userMeCSV)
		return nil
	},
}

var userLsCmd = &cobra.Command{
	Use:   "ls",
	Short: "list all users",
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}

		fields := userLsFields
		if userLsLastLogin && !strings.Contains(fields, "credentials_email") {
			fields += ",credentials_email"
		}

		var allUsers []v4.User
		var limit int64 = 64
		var offset int64 = 0

		for {
			req := v4.RequestAllUsers{
				Fields: &fields,
				Limit:  &limit,
				Offset: &offset,
			}
			users, err := c.SDK.AllUsers(req, nil)
			if err != nil {
				return fmt.Errorf("failed to list users: %w", err)
			}
			allUsers = append(allUsers, users...)
			if int64(len(users)) < limit {
				break
			}
			offset += limit
		}

		headers := strings.Split(userLsFields, ",")
		for i := range headers {
			headers[i] = strings.TrimSpace(headers[i])
		}
		if userLsLastLogin {
			headers = append(headers, "last_login")
		}

		table := util.NewTable(headers)
		for _, u := range allUsers {
			row := extractFields(u, userLsFields)
			if userLsLastLogin {
				lastLogin := ""
				if u.CredentialsEmail != nil && u.CredentialsEmail.LoggedInAt != nil {
					lastLogin = *u.CredentialsEmail.LoggedInAt
				}
				row = append(row, lastLogin)
			}
			table.Append(row)
		}

		table.Render(userLsPlain, userLsCSV)
		return nil
	},
}

func init() {
	RootCmd.AddCommand(UserCmd)
	UserCmd.AddCommand(userEnableCmd)
	UserCmd.AddCommand(userDisableCmd)
	UserCmd.AddCommand(userDeleteCmd)
	UserCmd.AddCommand(userCatCmd)
	UserCmd.AddCommand(userMeCmd)
	UserCmd.AddCommand(userLsCmd)

	userCatCmd.Flags().StringVar(&userCatFields, "fields", "", "Fields to display")
	userCatCmd.Flags().StringVar(&userCatDir, "dir", "", "Directory to store output file")
	userCatCmd.Flags().BoolVar(&userCatTrim, "trim", false, "Trim output to minimal set of fields for later import")

	userMeCmd.Flags().StringVar(&userMeFields, "fields", "id,email,last_name,first_name,personal_folder_id,home_folder_id", "Fields to display")
	userMeCmd.Flags().BoolVar(&userMePlain, "plain", false, "print without any extra formatting")
	userMeCmd.Flags().BoolVar(&userMeCSV, "csv", false, "output in csv format")

	userLsCmd.Flags().StringVar(&userLsFields, "fields", "id,email,last_name,first_name,personal_folder_id,home_folder_id", "Fields to display")
	userLsCmd.Flags().BoolVar(&userLsLastLogin, "last-login", false, "Include the time of the most recent login")
	userLsCmd.Flags().BoolVar(&userLsPlain, "plain", false, "print without any extra formatting")
	userLsCmd.Flags().BoolVar(&userLsCSV, "csv", false, "output in csv format")
}
