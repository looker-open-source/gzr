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
	"archive/tar"
	"archive/zip"
	"bytes"
	"compress/gzip"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/spf13/cobra"
	"gzr.looker.com/gzr/internal/client"
	v4 "github.com/looker-open-source/sdk-codegen/go/sdk/v4"
	"gzr.looker.com/gzr/internal/util"
)

var (
	spaceLsFields     string
	spaceLsPlain      bool
	spaceLsCSV        bool
	spaceTopFields    string
	spaceTopPlain     bool
	spaceTopCSV       bool
	spaceTreePlain    bool
	spaceCatFields    string
	spaceCatDir       string
	spaceExportDir    string
	spaceExportTar    string
	spaceExportTgz    string
	spaceExportZip    string
	spaceExportTrim   bool
	spaceRmForce      bool
)

var SpaceCmd = &cobra.Command{
	Use:     "space",
	Aliases: []string{"folder"},
	Short:   "Commands pertaining to spaces/folders",
}

func resolveFolderID(c *client.ClientWrapper, arg string) ([]string, error) {
	if arg == "" {
		me, err := c.SDK.Me("home_folder_id", nil)
		if err != nil || me.HomeFolderId == nil {
			return nil, fmt.Errorf("failed to get home_folder_id: %v", err)
		}
		return []string{*me.HomeFolderId}, nil
	}

	if arg == "lookml" {
		return []string{"lookml"}, nil
	}

	if _, err := strconv.ParseInt(arg, 10, 64); err == nil {
		return []string{arg}, nil
	}

	if arg == "~" {
		me, err := c.SDK.Me("personal_folder_id", nil)
		if err != nil || me.PersonalFolderId == nil {
			return nil, fmt.Errorf("failed to get personal_folder_id: %v", err)
		}
		return []string{*me.PersonalFolderId}, nil
	}

	if strings.HasPrefix(arg, "~") {
		sub := arg[1:]
		if _, err := strconv.ParseInt(sub, 10, 64); err == nil {
			u, err := c.SDK.User(sub, "personal_folder_id", nil)
			if err != nil || u.PersonalFolderId == nil {
				return nil, fmt.Errorf("failed to get personal_folder_id for user %s: %v", sub, err)
			}
			return []string{*u.PersonalFolderId}, nil
		}

		if strings.Contains(sub, "@") {
			users, err := c.SDK.SearchUsers(v4.RequestSearchUsers{Email: &sub, Fields: ptr("personal_folder_id")}, nil)
			if err != nil {
				return nil, err
			}
			var ids []string
			for _, u := range users {
				if u.PersonalFolderId != nil {
					ids = append(ids, *u.PersonalFolderId)
				}
			}
			return ids, nil
		}

		parts := strings.Fields(sub)
		if len(parts) == 2 {
			users, err := c.SDK.SearchUsers(v4.RequestSearchUsers{FirstName: &parts[0], LastName: &parts[1], Fields: ptr("personal_folder_id")}, nil)
			if err != nil {
				return nil, err
			}
			var ids []string
			for _, u := range users {
				if u.PersonalFolderId != nil {
					ids = append(ids, *u.PersonalFolderId)
				}
			}
			return ids, nil
		}
	}

	folders, err := c.SDK.SearchFolders(v4.RequestSearchFolders{Name: &arg, Fields: ptr("id")}, nil)
	if err != nil {
		return nil, err
	}
	var ids []string
	for _, f := range folders {
		if f.Id != nil {
			ids = append(ids, *f.Id)
		}
	}

	if arg == "Shared" {
		homeName := "Home"
		roots, err := c.SDK.SearchFolders(v4.RequestSearchFolders{Name: &homeName, Fields: ptr("id,is_shared_root")}, nil)
		if err == nil {
			for _, r := range roots {
				if r.IsSharedRoot != nil && *r.IsSharedRoot && r.Id != nil {
					ids = append(ids, *r.Id)
				}
			}
		}
	}

	return ids, nil
}

func ptr(s string) *string { return &s }

var spaceLsCmd = &cobra.Command{
	Use:   "ls [FOLDER_ID]",
	Short: "list the contents of a space/folder",
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}
		arg := ""
		if len(args) > 0 {
			arg = args[0]
		}
		fIDs, err := resolveFolderID(c, arg)
		if err != nil {
			return err
		}
		if len(fIDs) == 0 {
			fmt.Printf("No folders match %s\n", arg)
			return nil
		}

		fields := spaceLsFields
		if arg == "lookml" {
			fields = "dashboards(id,title)"
		}

		var rows [][]string
		headers := strings.Split(spaceLsFields, ",")
		for i := range headers {
			headers[i] = strings.TrimSpace(headers[i])
		}

		for _, fID := range fIDs {
			folder, err := c.SDK.Folder(fID, fields, nil)
			if err == nil {
				if folder.Looks != nil {
					for _, l := range *folder.Looks {
						m := map[string]interface{}{
							"parent_id": fID,
							"id":        folder.Id,
							"name":      folder.Name,
							"looks(id)": l.Id,
							"looks(title)": l.Title,
						}
						rows = append(rows, mapToRow(m, headers))
					}
				}
				if folder.Dashboards != nil {
					for _, d := range *folder.Dashboards {
						m := map[string]interface{}{
							"parent_id": fID,
							"id":        folder.Id,
							"name":      folder.Name,
							"dashboards(id)": d.Id,
							"dashboards(title)": d.Title,
						}
						rows = append(rows, mapToRow(m, headers))
					}
				}
				if (folder.Looks == nil || len(*folder.Looks) == 0) && (folder.Dashboards == nil || len(*folder.Dashboards) == 0) {
					m := map[string]interface{}{
						"parent_id": folder.ParentId,
						"id":        folder.Id,
						"name":      folder.Name,
					}
					rows = append(rows, mapToRow(m, headers))
				}
			}

			children, err := c.SDK.FolderChildren(v4.RequestFolderChildren{FolderId: fID, Fields: ptr("id,name,parent_id")}, nil)
			if err == nil {
				for _, ch := range children {
					m := map[string]interface{}{
						"parent_id": ch.ParentId,
						"id":        ch.Id,
						"name":      ch.Name,
					}
					rows = append(rows, mapToRow(m, headers))
				}
			}
		}

		table := util.NewTable(headers)
		table.Rows = rows
		table.Render(spaceLsPlain, spaceLsCSV)
		return nil
	},
}

var spaceTopCmd = &cobra.Command{
	Use:   "top",
	Short: "Retrieve the top level (or root) folders",
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}

		extraFields := []string{"is_shared_root", "is_users_root", "is_embed_shared_root", "is_embed_users_root"}
		queryFieldsSlice := strings.Split(spaceTopFields, ",")
		for i := range queryFieldsSlice {
			queryFieldsSlice[i] = strings.TrimSpace(queryFieldsSlice[i])
		}

		fieldMap := make(map[string]bool)
		for _, f := range queryFieldsSlice {
			fieldMap[f] = true
		}
		for _, f := range extraFields {
			if !fieldMap[f] {
				queryFieldsSlice = append(queryFieldsSlice, f)
			}
		}

		folders, err := c.SDK.AllFolders(strings.Join(queryFieldsSlice, ","), nil)
		if err != nil {
			return fmt.Errorf("failed to get top level folders: %w", err)
		}

		var topFolders []v4.FolderBase
		for _, f := range folders {
			isTop := (f.IsSharedRoot != nil && *f.IsSharedRoot) ||
				(f.IsUsersRoot != nil && *f.IsUsersRoot) ||
				(f.IsEmbedSharedRoot != nil && *f.IsEmbedSharedRoot) ||
				(f.IsEmbedUsersRoot != nil && *f.IsEmbedUsersRoot)
			if isTop {
				topFolders = append(topFolders, f)
			}
		}

		if len(topFolders) == 0 {
			fmt.Println("No top level folders found")
			return nil
		}

		headers := strings.Split(spaceTopFields, ",")
		for i := range headers {
			headers[i] = strings.TrimSpace(headers[i])
		}

		table := util.NewTable(headers)
		for _, f := range topFolders {
			table.Append(extractFields(f, spaceTopFields))
		}

		table.Render(spaceTopPlain, spaceTopCSV)
		return nil
	},
}

func mapToRow(m map[string]interface{}, headers []string) []string {
	row := make([]string, len(headers))
	for i, h := range headers {
		if val, ok := m[h]; ok && val != nil {
			switch v := val.(type) {
			case *string:
				if v != nil { row[i] = *v }
			case string:
				row[i] = v
			case *int64:
				if v != nil { row[i] = strconv.FormatInt(*v, 10) }
			case int64:
				row[i] = strconv.FormatInt(v, 10)
			case *float64:
				if v != nil { row[i] = strconv.FormatFloat(*v, 'f', -1, 64) }
			case float64:
				row[i] = strconv.FormatFloat(v, 'f', -1, 64)
			default:
				b, _ := json.Marshal(v)
				row[i] = string(b)
			}
		}
	}
	return row
}

var spaceTreeCmd = &cobra.Command{
	Use:   "tree [FOLDER_ID]",
	Short: "display child spaces, dashboards, and looks in a tree format",
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}
		arg := ""
		if len(args) > 0 {
			arg = args[0]
		}
		fIDs, err := resolveFolderID(c, arg)
		if err != nil {
			return err
		}
		if len(fIDs) == 0 {
			fmt.Printf("No folders match %s\n", arg)
			return nil
		}

		for _, fID := range fIDs {
			printTree(c, fID, "")
		}
		return nil
	},
}

func printTree(c *client.ClientWrapper, folderID, indent string) {
	folder, err := c.SDK.Folder(folderID, "id,name,looks(id,title),dashboards(id,title)", nil)
	if err != nil {
		return
	}
	name := folder.Name
	if indent == "" {
		fmt.Println(name)
	}

	var items []string
	if folder.Looks != nil {
		for _, l := range *folder.Looks {
			t := ""
			if l.Title != nil { t = *l.Title }
			items = append(items, "(l) "+t)
		}
	}
	if folder.Dashboards != nil {
		for _, d := range *folder.Dashboards {
			t := ""
			if d.Title != nil { t = *d.Title }
			items = append(items, "(d) "+t)
		}
	}
	children, _ := c.SDK.FolderChildren(v4.RequestFolderChildren{FolderId: folderID, Fields: ptr("id,name")}, nil)
	for _, ch := range children {
		items = append(items, ch.Name)
	}

	for i, item := range items {
		isLast := i == len(items)-1
		prefix := "├── "
		childIndent := indent + "│   "
		if isLast {
			prefix = "└── "
			childIndent = indent + "    "
		}
		fmt.Println(indent + prefix + item)

		if i >= len(items)-len(children) {
			ch := children[i-(len(items)-len(children))]
			if ch.Id != nil {
				printTree(c, *ch.Id, childIndent)
			}
		}
	}
}

var spaceCatCmd = &cobra.Command{
	Use:   "cat [FOLDER_ID]",
	Short: "output json describing a folder",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}
		fID := args[0]
		folder, err := c.SDK.Folder(fID, spaceCatFields, nil)
		if err != nil {
			return fmt.Errorf("failed to get folder %s: %w", fID, err)
		}

		bytes, _ := json.MarshalIndent(folder, "", "  ")
		if spaceCatDir != "" {
			fn := fmt.Sprintf("%s/Space_%s_%s.json", spaceCatDir, fID, strings.ReplaceAll(folder.Name, "/", "_"))
			_ = os.WriteFile(fn, bytes, 0644)
			fmt.Printf("Wrote %s\n", fn)
		} else {
			fmt.Println(string(bytes))
		}
		return nil
	},
}

var spaceRmCmd = &cobra.Command{
	Use:   "rm [FOLDER_ID]",
	Short: "delete a folder",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}
		fID := args[0]

		if !spaceRmForce {
			folder, err := c.SDK.Folder(fID, "id,name,looks(id),dashboards(id)", nil)
			if err != nil {
				return fmt.Errorf("folder %s not found: %w", fID, err)
			}
			children, _ := c.SDK.FolderChildren(v4.RequestFolderChildren{FolderId: fID, Fields: ptr("id")}, nil)
			hasLooks := folder.Looks != nil && len(*folder.Looks) > 0
			hasDash := folder.Dashboards != nil && len(*folder.Dashboards) > 0
			hasChild := len(children) > 0
			if hasLooks || hasDash || hasChild {
				return fmt.Errorf("folder '%s' is not empty. Cannot delete unless --force is specified", folder.Name)
			}
		}

		_, err = c.SDK.DeleteFolder(fID, nil)
		if err != nil {
			return fmt.Errorf("failed to delete folder %s: %w", fID, err)
		}
		fmt.Printf("Folder %s deleted.\n", fID)
		return nil
	},
}

var spaceCreateCmd = &cobra.Command{
	Use:   "create [NAME] [PARENT_ID]",
	Short: "create a new subspace/folder",
	Args:  cobra.ExactArgs(2),
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}
		name := args[0]
		parentID := args[1]

		body := v4.CreateFolder{Name: name, ParentId: parentID}
		folder, err := c.SDK.CreateFolder(body, nil)
		if err != nil {
			return fmt.Errorf("failed to create folder %s: %w", name, err)
		}
		id := ""
		if folder.Id != nil { id = *folder.Id }
		fmt.Printf("Folder created with ID %s\n", id)
		return nil
	},
}

var spaceExportCmd = &cobra.Command{
	Use:   "export [FOLDER_ID]",
	Short: "export a space and its subspaces, looks, and dashboards",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		c, err := initClient(cmd.Context(), false)
		if err != nil {
			return err
		}
		fID := args[0]

		if spaceExportTar != "" || spaceExportTgz != "" || spaceExportZip != "" {
			var buf bytes.Buffer
			var archiver interface{}

			if spaceExportZip != "" {
				archiver = zip.NewWriter(&buf)
			} else {
				var w io.Writer = &buf
				if spaceExportTgz != "" {
					gzw := gzip.NewWriter(&buf)
					defer func() { _ = gzw.Close() }()
					w = gzw
				}
				archiver = tar.NewWriter(w)
			}

			err = exportFolderArchive(c, fID, archiver, "")
			if err != nil {
				return err
			}

			if zw, ok := archiver.(*zip.Writer); ok {
				_ = zw.Close()
				fn := spaceExportZip
				_ = os.WriteFile(fn, buf.Bytes(), 0644)
				fmt.Printf("Wrote zip %s\n", fn)
			} else if tw, ok := archiver.(*tar.Writer); ok {
				_ = tw.Close()
				fn := spaceExportTar
				if spaceExportTgz != "" { fn = spaceExportTgz }
				_ = os.WriteFile(fn, buf.Bytes(), 0644)
				fmt.Printf("Wrote archive %s\n", fn)
			}
			return nil
		}

		if spaceExportDir == "" {
			spaceExportDir = "."
		}
		return exportFolderDir(c, fID, spaceExportDir)
	},
}

func exportFolderDir(c *client.ClientWrapper, fID, baseDir string) error {
	folder, err := c.SDK.Folder(fID, "", nil)
	if err != nil {
		return fmt.Errorf("failed to get folder %s: %w", fID, err)
	}
	name := folder.Name
	cleanName := strings.ReplaceAll(name, "/", "_")
	dirName := filepath.Join(baseDir, fmt.Sprintf("Space_%s_%s", fID, cleanName))
	_ = os.MkdirAll(dirName, 0755)

	b, _ := json.Marshal(folder)
	var m map[string]interface{}
	_ = json.Unmarshal(b, &m)
	delete(m, "looks")
	delete(m, "dashboards")
	fb, _ := json.MarshalIndent(m, "", "  ")
	_ = os.WriteFile(filepath.Join(dirName, fmt.Sprintf("Space_%s_%s.json", fID, cleanName)), fb, 0644)

	if folder.Looks != nil {
		for _, l := range *folder.Looks {
			if l.Id != nil {
				look, err := c.SDK.Look(*l.Id, "", nil)
				if err == nil {
					lb, _ := json.MarshalIndent(look, "", "  ")
					lt := ""
					if look.Title != nil { lt = *look.Title }
					_ = os.WriteFile(filepath.Join(dirName, fmt.Sprintf("Look_%s_%s.json", *l.Id, strings.ReplaceAll(lt, "/", "_"))), lb, 0644)
				}
			}
		}
	}
	if folder.Dashboards != nil {
		for _, d := range *folder.Dashboards {
			if d.Id != nil {
				dash, err := c.SDK.Dashboard(*d.Id, "", nil)
				if err == nil {
					db, _ := json.MarshalIndent(dash, "", "  ")
					dt := ""
					if dash.Title != nil { dt = *dash.Title }
					_ = os.WriteFile(filepath.Join(dirName, fmt.Sprintf("Dashboard_%s_%s.json", *d.Id, strings.ReplaceAll(dt, "/", "_"))), db, 0644)
				}
			}
		}
	}

	children, _ := c.SDK.FolderChildren(v4.RequestFolderChildren{FolderId: fID, Fields: ptr("id")}, nil)
	for _, ch := range children {
		if ch.Id != nil {
			_ = exportFolderDir(c, *ch.Id, dirName)
		}
	}
	return nil
}

func exportFolderArchive(c *client.ClientWrapper, fID string, archiver interface{}, pathPrefix string) error {
	folder, err := c.SDK.Folder(fID, "", nil)
	if err != nil {
		return err
	}
	name := folder.Name
	cleanName := strings.ReplaceAll(name, "/", "_")
	dirName := fmt.Sprintf("Space_%s_%s/", fID, cleanName)
	if pathPrefix != "" { dirName = pathPrefix + dirName }

	b, _ := json.Marshal(folder)
	var m map[string]interface{}
	_ = json.Unmarshal(b, &m)
	delete(m, "looks")
	delete(m, "dashboards")
	fb, _ := json.MarshalIndent(m, "", "  ")

	fn := dirName + fmt.Sprintf("Space_%s_%s.json", fID, cleanName)
	writeArchiveFile(archiver, fn, fb)

	if folder.Looks != nil {
		for _, l := range *folder.Looks {
			if l.Id != nil {
				look, err := c.SDK.Look(*l.Id, "", nil)
				if err == nil {
					lb, _ := json.MarshalIndent(look, "", "  ")
					lt := ""
					if look.Title != nil { lt = *look.Title }
					lfn := dirName + fmt.Sprintf("Look_%s_%s.json", *l.Id, strings.ReplaceAll(lt, "/", "_"))
					writeArchiveFile(archiver, lfn, lb)
				}
			}
		}
	}
	if folder.Dashboards != nil {
		for _, d := range *folder.Dashboards {
			if d.Id != nil {
				dash, err := c.SDK.Dashboard(*d.Id, "", nil)
				if err == nil {
					db, _ := json.MarshalIndent(dash, "", "  ")
					dt := ""
					if dash.Title != nil { dt = *dash.Title }
					dfn := dirName + fmt.Sprintf("Dashboard_%s_%s.json", *d.Id, strings.ReplaceAll(dt, "/", "_"))
					writeArchiveFile(archiver, dfn, db)
				}
			}
		}
	}

	children, _ := c.SDK.FolderChildren(v4.RequestFolderChildren{FolderId: fID, Fields: ptr("id")}, nil)
	for _, ch := range children {
		if ch.Id != nil {
			_ = exportFolderArchive(c, *ch.Id, archiver, dirName)
		}
	}
	return nil
}

func writeArchiveFile(archiver interface{}, name string, data []byte) {
	if zw, ok := archiver.(*zip.Writer); ok {
		f, _ := zw.Create(name)
		_, _ = f.Write(data)
	} else if tw, ok := archiver.(*tar.Writer); ok {
		hdr := &tar.Header{
			Name: name,
			Mode: 0644,
			Size: int64(len(data)),
		}
		_ = tw.WriteHeader(hdr)
		_, _ = tw.Write(data)
	}
}

func init() {
	RootCmd.AddCommand(SpaceCmd)
	SpaceCmd.AddCommand(spaceLsCmd)
	SpaceCmd.AddCommand(spaceTopCmd)
	SpaceCmd.AddCommand(spaceTreeCmd)
	SpaceCmd.AddCommand(spaceCatCmd)
	SpaceCmd.AddCommand(spaceRmCmd)
	SpaceCmd.AddCommand(spaceCreateCmd)
	SpaceCmd.AddCommand(spaceExportCmd)

	spaceLsCmd.Flags().StringVar(&spaceLsFields, "fields", "parent_id,id,name,looks(id),looks(title),dashboards(id),dashboards(title)", "Fields to display")
	spaceLsCmd.Flags().BoolVar(&spaceLsPlain, "plain", false, "print without any extra formatting")
	spaceLsCmd.Flags().BoolVar(&spaceLsCSV, "csv", false, "output in csv format")

	spaceTopCmd.Flags().StringVar(&spaceTopFields, "fields", "id,name,parent_id", "Fields to display")
	spaceTopCmd.Flags().BoolVar(&spaceTopPlain, "plain", false, "print without any extra formatting")
	spaceTopCmd.Flags().BoolVar(&spaceTopCSV, "csv", false, "output in csv format")

	spaceTreeCmd.Flags().BoolVar(&spaceTreePlain, "plain", false, "print without any extra formatting")

	spaceCatCmd.Flags().StringVar(&spaceCatFields, "fields", "", "Fields to display")
	spaceCatCmd.Flags().StringVar(&spaceCatDir, "dir", "", "Directory to store output file")

	spaceRmCmd.Flags().BoolVar(&spaceRmForce, "force", false, "Delete folder even if not empty")

	spaceExportCmd.Flags().StringVar(&spaceExportDir, "dir", "", "Directory to store folder tree")
	spaceExportCmd.Flags().StringVar(&spaceExportTar, "tar", "", "Tar file to store folder tree")
	spaceExportCmd.Flags().StringVar(&spaceExportTgz, "tgz", "", "Targz file to store folder tree")
	spaceExportCmd.Flags().StringVar(&spaceExportZip, "zip", "", "Zip file to store folder tree")
	spaceExportCmd.Flags().BoolVar(&spaceExportTrim, "trim", false, "Trim output to minimal set of fields")
}
