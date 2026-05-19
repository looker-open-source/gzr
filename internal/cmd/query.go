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
	"io"
	"os"
	"strconv"
	"strings"

	"github.com/spf13/cobra"
	v4 "github.com/looker-open-source/sdk-codegen/go/sdk/v4"
)

var (
	queryRunFile   string
	queryRunFormat string
)

var QueryCmd = &cobra.Command{
	Use:   "query",
	Short: "Commands to retrieve and run queries",
}

var queryRunCmd = &cobra.Command{
	Use:   "runquery [QUERY_DEF]",
	Short: "Run query_id, query_slug, or json_query_desc",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil { return err }

		qDef := args[0]
		format := queryRunFormat

		switch format {
		case "png", "jpg", "xlsx":
			if queryRunFile == "" {
				return fmt.Errorf("output file must be specified with '--file' when using format %s", format)
			}
		case "json", "json_detail", "csv", "txt", "html", "md", "sql":
			// valid
		default:
			return fmt.Errorf("unknown format %s", format)
		}

		var qID string
		var qSlug string
		var qHash map[string]interface{}

		if _, err := strconv.ParseInt(qDef, 10, 64); err == nil {
			qID = qDef
		} else if qDef != "" && !strings.Contains(qDef, "{") {
			qSlug = qDef
		} else {
			if err := json.Unmarshal([]byte(qDef), &qHash); err != nil {
				return fmt.Errorf("query def is not a valid id, slug, or json document: %w", err)
			}
		}

		var outWriter io.Writer = os.Stdout
		var file *os.File
		if queryRunFile != "" {
			file, err = os.Create(queryRunFile)
			if err != nil { return err }
			defer file.Close()
			outWriter = file
		}

		if qID != "" || qSlug != "" {
			if qSlug != "" {
				q, err := c.SDK.QueryForSlug(qSlug, "id", nil)
				if err != nil || q.Id == nil {
					return fmt.Errorf("query for slug %s not found: %v", qSlug, err)
				}
				qID = *q.Id
			}

			// RunQuery
			req := v4.RequestRunQuery{
				QueryId:      qID,
				ResultFormat: format,
			}
			res, err := c.SDK.RunQuery(req, nil)
			if err != nil { return err }
			_, _ = outWriter.Write([]byte(res))
		} else {
			// RunInlineQuery
			qb, _ := json.Marshal(qHash)
			var wq v4.WriteQuery
			_ = json.Unmarshal(qb, &wq)

			req := v4.RequestRunInlineQuery{
				ResultFormat: format,
				Body:         wq,
			}
			res, err := c.SDK.RunInlineQuery(req, nil)
			if err != nil { return err }
			_, _ = outWriter.Write([]byte(res))
		}

		if queryRunFile != "" {
			fmt.Printf("Wrote %s\n", queryRunFile)
		}
		return nil
	},
}

func init() {
	RootCmd.AddCommand(QueryCmd)
	QueryCmd.AddCommand(queryRunCmd)

	queryRunCmd.Flags().StringVar(&queryRunFile, "file", "", "Filename for saved data")
	queryRunCmd.Flags().StringVar(&queryRunFormat, "format", "json", "One of json,json_detail,csv,txt,html,md,xlsx,sql,png,jpg")
}
