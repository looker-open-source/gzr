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
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"
	"testing"

	"github.com/looker-open-source/sdk-codegen/go/rtl"
	v4 "github.com/looker-open-source/sdk-codegen/go/sdk/v4"
)

type mockDoer struct {
	t              *testing.T
	folder801Looks []v4.LookWithQuery
}

func (m *mockDoer) Do(result interface{}, method, ver, path string, reqPars map[string]interface{}, body interface{}, options *rtl.ApiSettings) error {
	if strings.HasPrefix(path, "/user") {
		me := v4.User{
			Id:        ptr("1234"),
			Email:     ptr("jsmith@mycompany.com"),
			FirstName: ptr("John"),
			LastName:  ptr("Smith"),
			HomeFolderId: ptr("709"),
			PersonalFolderId: ptr("1132"),
		}
		b, _ := json.Marshal(me)
		return json.Unmarshal(b, result)
	}
	if strings.HasPrefix(path, "/folders/709/children") {
		ch := []v4.Folder{
			{Id: ptr("801"), Name: "SubShared", ParentId: ptr("709")},
		}
		b, _ := json.Marshal(ch)
		return json.Unmarshal(b, result)
	}
	if strings.HasPrefix(path, "/folders/709") {
		f := v4.Folder{
			Id:   ptr("709"),
			Name: "Shared",
			Looks: &[]v4.LookWithDashboards{
				{Id: ptr("857"), Title: ptr("Daily Profit")},
			},
			Dashboards: &[]v4.DashboardBase{
				{Id: ptr("192"), Title: ptr("Daily Profit Dashboard")},
			},
		}
		b, _ := json.Marshal(f)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/connections/my_conn" {
		conn := v4.DBConnection{
			Name: ptr("my_conn"),
			DialectName: ptr("mysql"),
			Host: ptr("localhost"),
		}
		b, _ := json.Marshal(conn)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/connections/my_new_conn" {
		return fmt.Errorf("not found")
	}
	if method == "POST" && path == "/connections" {
		conn := v4.DBConnection{
			Name: ptr("my_new_conn"),
			DialectName: ptr("postgres"),
		}
		b, _ := json.Marshal(conn)
		return json.Unmarshal(b, result)
	}
	if method == "DELETE" && path == "/connections/my_conn" {
		b, _ := json.Marshal("")
		return json.Unmarshal(b, result)
	}
	if method == "PUT" && path == "/connections/my_conn/test" {
		res := []v4.DBConnectionTestResult{
			{Name: ptr("connect"), Status: ptr("success"), Message: ptr("connected successfully")},
		}
		b, _ := json.Marshal(res)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/dashboards/192" {
		dash := v4.Dashboard{Id: ptr("192"), Title: ptr("Daily Profit Dashboard")}
		b, _ := json.Marshal(dash)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/dashboards/lookml_dash_1" {
		dash := v4.Dashboard{Id: ptr("lookml_dash_1"), Title: ptr("LookML Dash 1")}
		b, _ := json.Marshal(dash)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/dashboards/search" {
		var dashes []v4.Dashboard
		b, _ := json.Marshal(dashes)
		return json.Unmarshal(b, result)
	}
	if method == "PATCH" && path == "/dashboards/192" {
		dash := v4.Dashboard{Id: ptr("192"), Title: ptr("Daily Profit Dashboard"), FolderId: ptr("801")}
		b, _ := json.Marshal(dash)
		return json.Unmarshal(b, result)
	}
	if method == "POST" && path == "/dashboards/lookml_dash_1/import/801" {
		dash := v4.Dashboard{Id: ptr("new_udd_1"), Title: ptr("LookML Dash 1"), FolderId: ptr("801")}
		b, _ := json.Marshal(dash)
		return json.Unmarshal(b, result)
	}
	if method == "PATCH" && path == "/dashboards/lookml_dash_1/sync" {
		res := []int64{101, 102}
		b, _ := json.Marshal(res)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/looks/857" {
		look := v4.Look{Id: ptr("857"), Title: ptr("Daily Profit")}
		b, _ := json.Marshal(look)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/folders/801/looks" {
		b, _ := json.Marshal(m.folder801Looks)
		return json.Unmarshal(b, result)
	}
	if method == "PATCH" && path == "/looks/857" {
		look := v4.Look{Id: ptr("857"), Title: ptr("Daily Profit"), FolderId: ptr("801")}
		b, _ := json.Marshal(look)
		return json.Unmarshal(b, result)
	}
	if method == "DELETE" && path == "/looks/999" {
		b, _ := json.Marshal("")
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/lookml_models" {
		models := []v4.LookmlModel{
			{Name: ptr("my_model"), Label: ptr("My Model"), ProjectName: ptr("my_project")},
		}
		b, _ := json.Marshal(models)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/lookml_models/my_model" {
		model := v4.LookmlModel{Name: ptr("my_model"), Label: ptr("My Model"), ProjectName: ptr("my_project")}
		b, _ := json.Marshal(model)
		return json.Unmarshal(b, result)
	}
	if method == "POST" && path == "/lookml_models" {
		model := v4.LookmlModel{Name: ptr("my_model"), Label: ptr("My Model"), ProjectName: ptr("my_project")}
		b, _ := json.Marshal(model)
		return json.Unmarshal(b, result)
	}
	if method == "PATCH" && path == "/lookml_models/my_model" {
		model := v4.LookmlModel{Name: ptr("my_model"), Label: ptr("My Model"), ProjectName: ptr("my_project")}
		b, _ := json.Marshal(model)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/model_sets" {
		sets := []v4.ModelSet{
			{Id: ptr("5"), Name: ptr("my_model_set"), Models: &[]string{"my_model"}},
		}
		b, _ := json.Marshal(sets)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/model_sets/5" {
		set := v4.ModelSet{Id: ptr("5"), Name: ptr("my_model_set"), Models: &[]string{"my_model"}}
		b, _ := json.Marshal(set)
		return json.Unmarshal(b, result)
	}
	if method == "POST" && path == "/model_sets" {
		set := v4.ModelSet{Id: ptr("5"), Name: ptr("my_model_set"), Models: &[]string{"my_model"}}
		b, _ := json.Marshal(set)
		return json.Unmarshal(b, result)
	}
	if method == "PATCH" && path == "/model_sets/5" {
		set := v4.ModelSet{Id: ptr("5"), Name: ptr("my_model_set"), Models: &[]string{"my_model"}}
		b, _ := json.Marshal(set)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/permissions" {
		perms := []v4.Permission{
			{Permission: ptr("access_data"), Parent: nil},
			{Permission: ptr("see_looks"), Parent: ptr("access_data")},
			{Permission: ptr("see_user_dashboards"), Parent: ptr("see_looks")},
			{Permission: ptr("admin"), Parent: nil},
		}
		b, _ := json.Marshal(perms)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/permission_sets" {
		sets := []v4.PermissionSet{
			{Id: ptr("3"), Name: ptr("my_permission_set"), Permissions: &[]string{"access_data"}},
		}
		b, _ := json.Marshal(sets)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/roles/search" {
		m.t.Logf("mockDoer GET /roles/search called with reqPars: %v", reqPars)
		var id string
		if idPtr, ok := reqPars["id"].(*string); ok && idPtr != nil {
			id = *idPtr
		}
		if id == "1" {
			role := v4.Role{
				Id:            ptr("1"),
				Name:          ptr("my_role"),
				PermissionSet: &v4.PermissionSet{Id: ptr("2"), Name: ptr("my_perm_set")},
				ModelSet:      &v4.ModelSet{Id: ptr("3"), Name: ptr("my_model_set")},
			}
			
			var fields string
			if fieldsPtr, ok := reqPars["fields"].(*string); ok && fieldsPtr != nil {
				fields = *fieldsPtr
			}
			
			if fields != "" {
				filteredRole := v4.Role{}
				if strings.Contains(fields, "name") {
					filteredRole.Name = role.Name
				}
				if strings.Contains(fields, "id") {
					filteredRole.Id = role.Id
				}
				if strings.Contains(fields, "permission_set") {
					filteredRole.PermissionSet = role.PermissionSet
				}
				if strings.Contains(fields, "model_set") {
					filteredRole.ModelSet = role.ModelSet
				}
				roles := []v4.Role{filteredRole}
				b, _ := json.Marshal(roles)
				return json.Unmarshal(b, result)
			}
			
			roles := []v4.Role{role}
			b, _ := json.Marshal(roles)
			return json.Unmarshal(b, result)
		}
		roles := []v4.Role{}
		b, _ := json.Marshal(roles)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/permission_sets/3" {
		m.t.Logf("mockDoer GET /permission_sets/3 called with reqPars: %v", reqPars)
		if fields, ok := reqPars["fields"].(string); ok && fields != "" {
			set := v4.PermissionSet{}
			if strings.Contains(fields, "name") {
				set.Name = ptr("my_permission_set")
			}
			if strings.Contains(fields, "id") {
				set.Id = ptr("3")
			}
			b, _ := json.Marshal(set)
			return json.Unmarshal(b, result)
		}
		set := v4.PermissionSet{Id: ptr("3"), Name: ptr("my_permission_set"), Permissions: &[]string{"access_data"}}
		b, _ := json.Marshal(set)
		return json.Unmarshal(b, result)
	}
	if method == "POST" && path == "/permission_sets" {
		set := v4.PermissionSet{Id: ptr("3"), Name: ptr("my_permission_set"), Permissions: &[]string{"access_data"}}
		b, _ := json.Marshal(set)
		return json.Unmarshal(b, result)
	}
	if method == "PATCH" && path == "/permission_sets/3" {
		set := v4.PermissionSet{Id: ptr("3"), Name: ptr("my_permission_set"), Permissions: &[]string{"access_data"}}
		b, _ := json.Marshal(set)
		return json.Unmarshal(b, result)
	}
	if method == "DELETE" && path == "/permission_sets/3" {
		b, _ := json.Marshal("")
		return json.Unmarshal(b, result)
	}
	if method == "DELETE" && path == "/model_sets/5" {
		b, _ := json.Marshal("")
		return json.Unmarshal(b, result)
	}
	if method == "GET" && path == "/folders" {
		folders := []v4.FolderBase{
			{Id: ptr("1"), Name: "Shared Root", IsSharedRoot: ptrBool(true)},
			{Id: ptr("2"), Name: "Users Root", IsUsersRoot: ptrBool(true)},
			{Id: ptr("3"), Name: "Personal Space", IsPersonal: ptrBool(true)},
		}
		b, _ := json.Marshal(folders)
		return json.Unmarshal(b, result)
	}
	if method == "GET" && strings.HasPrefix(path, "/queries/slug/") {
		slug := strings.TrimPrefix(path, "/queries/slug/")
		slug = strings.Split(slug, "?")[0]
		if slug == "my_slug" {
			q := v4.Query{Id: ptr("9999")}
			b, _ := json.Marshal(q)
			return json.Unmarshal(b, result)
		}
		return fmt.Errorf("query for slug %s not found", slug)
	}
	if method == "GET" && strings.HasPrefix(path, "/queries/") && strings.Contains(path, "/run/") {
		parts := strings.Split(path, "/")
		if len(parts) >= 5 && parts[1] == "queries" && parts[3] == "run" {
			qID := parts[2]
			format := parts[4]
			format = strings.Split(format, "?")[0]
			resStr := fmt.Sprintf(`{"query_id": "%s", "format": "%s", "result": "mocked_data"}`, qID, format)
			if target, ok := result.(*string); ok {
				*target = resStr
				return nil
			}
			b, _ := json.Marshal(resStr)
			return json.Unmarshal(b, result)
		}
	}
	if method == "POST" && strings.HasPrefix(path, "/queries/run/") {
		parts := strings.Split(path, "/")
		if len(parts) >= 4 && parts[1] == "queries" && parts[2] == "run" {
			format := parts[3]
			format = strings.Split(format, "?")[0]
			bodyBytes, _ := json.Marshal(body)
			resStr := fmt.Sprintf(`{"format": "%s", "query_body": %s, "result": "mocked_inline_data"}`, format, string(bodyBytes))
			if target, ok := result.(*string); ok {
				*target = resStr
				return nil
			}
			b, _ := json.Marshal(resStr)
			return json.Unmarshal(b, result)
		}
	}

	return fmt.Errorf("mock path not found: %s", path)
}

func TestUserMeCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"user", "me", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "1234") || !strings.Contains(out, "jsmith@mycompany.com") {
		t.Errorf("expected 1234 and jsmith, got %s", out)
	}
}

func TestFolderLsCommand(t *testing.T) {
	tests := []struct {
		name string
		cmd  string
	}{
		{"primary", "folder"},
		{"alias", "space"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
			defer func() { MockSDK = nil }()

			oldStdout := os.Stdout
			r, w, _ := os.Pipe()
			os.Stdout = w

			RootCmd.SetArgs([]string{tt.cmd, "ls", "709", "--plain"})
			err := RootCmd.Execute()
			if err != nil {
				t.Fatalf("Execute failed: %v", err)
			}

			_ = w.Close()
			os.Stdout = oldStdout
			var buf bytes.Buffer
			_, _ = io.Copy(&buf, r)
			out := buf.String()

			if !strings.Contains(out, "Daily Profit") || !strings.Contains(out, "Daily Profit Dashboard") {
				t.Errorf("expected Daily Profit, got %s", out)
			}
		})
	}
}

func TestConnectionCatCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"connection", "cat", "my_conn"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "my_conn") || !strings.Contains(out, "mysql") {
		t.Errorf("expected my_conn and mysql, got %s", out)
	}
}

func TestConnectionRmCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"connection", "rm", "my_conn"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "deleted") {
		t.Errorf("expected deleted message, got %s", out)
	}
}

func TestConnectionImportCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	tmpFile, _ := os.CreateTemp("", "conn*.json")
	defer func() { _ = os.Remove(tmpFile.Name()) }()
	_, _ = tmpFile.WriteString(`{"name":"my_new_conn","dialect_name":"postgres"}`)
	_ = tmpFile.Close()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"connection", "import", tmpFile.Name(), "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := strings.TrimSpace(buf.String())

	if out != "my_new_conn" {
		t.Errorf("expected my_new_conn, got %s", out)
	}
}

func TestConnectionImportCommand_Stdin(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	rStdin, wStdin, err := os.Pipe()
	if err != nil {
		t.Fatalf("failed to create pipe: %v", err)
	}
	oldStdin := os.Stdin
	os.Stdin = rStdin
	defer func() { os.Stdin = oldStdin }()

	go func() {
		defer func() { _ = wStdin.Close() }()
		_, _ = wStdin.WriteString(`{"name":"my_new_conn","dialect_name":"postgres"}`)
	}()

	oldStdout := os.Stdout
	rStdout, wStdout, _ := os.Pipe()
	os.Stdout = wStdout

	RootCmd.SetArgs([]string{"connection", "import", "-", "--plain"})
	err = RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = wStdout.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, rStdout)
	out := strings.TrimSpace(buf.String())

	if out != "my_new_conn" {
		t.Errorf("expected my_new_conn, got %s", out)
	}
}

func TestConnectionTestCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"connection", "test", "my_conn", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "connect") || !strings.Contains(out, "success") || !strings.Contains(out, "connected successfully") {
		t.Errorf("expected test success results, got %s", out)
	}
}

func TestDashboardMvCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"dashboard", "mv", "192", "801", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := strings.TrimSpace(buf.String())

	if out != "" {
		t.Errorf("expected empty output for plain mv, got %s", out)
	}
}

func TestDashboardImportLookmlCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"dashboard", "import", "lookml", "lookml_dash_1", "801", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := strings.TrimSpace(buf.String())

	if out != "new_udd_1" {
		t.Errorf("expected new_udd_1, got %s", out)
	}
}

func TestDashboardSyncLookmlCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"dashboard", "sync", "lookml", "lookml_dash_1"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := strings.TrimSpace(buf.String())

	if !strings.Contains(out, "101") || !strings.Contains(out, "102") {
		t.Errorf("expected synced dashboard ids 101 and 102, got %s", out)
	}
}


func TestLookMvCommand(t *testing.T) {
	t.Run("Success", func(t *testing.T) {
		md := &mockDoer{
			t:              t,
			folder801Looks: []v4.LookWithQuery{},
		}
		MockSDK = v4.NewLookerSDK(md)
		defer func() { MockSDK = nil }()

		oldStdout := os.Stdout
		r, w, _ := os.Pipe()
		os.Stdout = w

		RootCmd.SetArgs([]string{"look", "mv", "857", "801", "--plain"})
		err := RootCmd.Execute()
		if err != nil {
			t.Fatalf("Execute failed: %v", err)
		}

		_ = w.Close()
		os.Stdout = oldStdout
		var buf bytes.Buffer
		_, _ = io.Copy(&buf, r)
		out := strings.TrimSpace(buf.String())

		if out != "" {
			t.Errorf("expected empty output for plain mv, got %q", out)
		}
	})

	t.Run("DuplicateError", func(t *testing.T) {
		md := &mockDoer{
			t: t,
			folder801Looks: []v4.LookWithQuery{
				{Id: ptr("999"), Title: ptr("Daily Profit")},
			},
		}
		MockSDK = v4.NewLookerSDK(md)
		defer func() { MockSDK = nil }()

		RootCmd.SetArgs([]string{"look", "mv", "857", "801"})
		err := RootCmd.Execute()
		if err == nil {
			t.Fatal("expected error due to duplicate title, got nil")
		}
		expectedErr := "already exists in folder 801"
		if !strings.Contains(err.Error(), expectedErr) {
			t.Errorf("expected error containing %q, got %q", expectedErr, err.Error())
		}
	})

	t.Run("ForceOverwrite", func(t *testing.T) {
		md := &mockDoer{
			t: t,
			folder801Looks: []v4.LookWithQuery{
				{Id: ptr("999"), Title: ptr("Daily Profit")},
			},
		}
		MockSDK = v4.NewLookerSDK(md)
		defer func() { MockSDK = nil }()

		oldStdout := os.Stdout
		r, w, _ := os.Pipe()
		os.Stdout = w

		RootCmd.SetArgs([]string{"look", "mv", "857", "801", "--force", "--plain"})
		err := RootCmd.Execute()
		if err != nil {
			t.Fatalf("Execute failed with --force: %v", err)
		}

		_ = w.Close()
		os.Stdout = oldStdout
		var buf bytes.Buffer
		_, _ = io.Copy(&buf, r)
		out := strings.TrimSpace(buf.String())

		if out != "" {
			t.Errorf("expected empty output for plain mv with force, got %q", out)
		}
	})
}

func TestModelCatCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"model", "cat", "my_model"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "my_model") || !strings.Contains(out, "my_project") {
		t.Errorf("expected my_model and my_project, got %s", out)
	}
}

func TestModelImportCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	tmpFile, _ := os.CreateTemp("", "model*.json")
	defer func() { _ = os.Remove(tmpFile.Name()) }()
	_, _ = tmpFile.WriteString(`{"name":"my_model","project_name":"my_project"}`)
	_ = tmpFile.Close()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"model", "import", tmpFile.Name(), "--force", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := strings.TrimSpace(buf.String())

	if out != "my_model" {
		t.Errorf("expected my_model, got %s", out)
	}
}

func TestModelSetLsCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"model", "set", "ls", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "5") || !strings.Contains(out, "my_model_set") {
		t.Errorf("expected 5 and my_model_set, got %s", out)
	}
}

func TestModelSetCatCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"model", "set", "cat", "5"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "5") || !strings.Contains(out, "my_model_set") {
		t.Errorf("expected 5 and my_model_set, got %s", out)
	}
}

func TestModelSetImportCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	tmpFile, _ := os.CreateTemp("", "modelset*.json")
	defer func() { _ = os.Remove(tmpFile.Name()) }()
	_, _ = tmpFile.WriteString(`{"name":"my_model_set","models":["my_model"]}`)
	_ = tmpFile.Close()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"model", "set", "import", tmpFile.Name(), "--force", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := strings.TrimSpace(buf.String())

	if out != "5" {
		t.Errorf("expected 5, got %s", out)
	}
}

func TestModelSetRmCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"model", "set", "rm", "5"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "deleted") {
		t.Errorf("expected deleted message, got %s", out)
	}
}

func TestPermissionTreeCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"permission", "tree"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	// Verify tree formatting:
	// should have access_data as root and see_looks as child
	if !strings.Contains(out, "├── access_data") || !strings.Contains(out, "│   └── see_looks") || !strings.Contains(out, "└── admin") {
		t.Errorf("unexpected tree output structure, got:\n%s", out)
	}
}

func TestPermissionSetLsCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"permission", "set", "ls", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "3") || !strings.Contains(out, "my_permission_set") {
		t.Errorf("expected 3 and my_permission_set, got %s", out)
	}
}

func TestPermissionSetCatCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"permission", "set", "cat", "3"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "3") || !strings.Contains(out, "my_permission_set") {
		t.Errorf("expected 3 and my_permission_set, got %s", out)
	}
}

func TestPermissionSetCatCommandFields(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() {
		MockSDK = nil
		permissionSetCatFields = ""
	}()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"permission", "set", "cat", "3", "--fields", "name"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if strings.Contains(out, "3") {
		t.Errorf("expected NOT to contain '3' (id), got %s", out)
	}
	if !strings.Contains(out, "my_permission_set") {
		t.Errorf("expected to contain my_permission_set, got %s", out)
	}
}

func TestPermissionSetImportCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	tmpFile, _ := os.CreateTemp("", "permsset*.json")
	defer func() { _ = os.Remove(tmpFile.Name()) }()
	_, _ = tmpFile.WriteString(`{"name":"my_permission_set","permissions":["access_data"]}`)
	_ = tmpFile.Close()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"permission", "set", "import", tmpFile.Name(), "--force", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := strings.TrimSpace(buf.String())

	if out != "3" {
		t.Errorf("expected 3, got %s", out)
	}
}

func TestPermissionSetRmCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"permission", "set", "rm", "3"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "deleted") {
		t.Errorf("expected deleted message, got %s", out)
	}
}

func TestFolderTopCommand(t *testing.T) {
	tests := []struct {
		name string
		cmd  string
	}{
		{"primary", "folder"},
		{"alias", "space"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
			defer func() { MockSDK = nil }()

			oldStdout := os.Stdout
			r, w, _ := os.Pipe()
			os.Stdout = w

			RootCmd.SetArgs([]string{tt.cmd, "top", "--plain"})
			err := RootCmd.Execute()
			if err != nil {
				t.Fatalf("Execute failed: %v", err)
			}

			_ = w.Close()
			os.Stdout = oldStdout
			var buf bytes.Buffer
			_, _ = io.Copy(&buf, r)
			out := buf.String()

			// Verify output contains Shared Root and Users Root but not Personal Space
			if !strings.Contains(out, "Shared Root") || !strings.Contains(out, "Users Root") {
				t.Errorf("expected Shared Root and Users Root, got:\n%s", out)
			}
			if strings.Contains(out, "Personal Space") {
				t.Errorf("unexpected Personal Space in top-level folders, got:\n%s", out)
			}
		})
	}
}

func TestInitClient_EnvVars(t *testing.T) {
	// Clean up existing environment variables at end of test
	origBase := os.Getenv("LOOKERSDK_BASE_URL")
	origVerify := os.Getenv("LOOKERSDK_VERIFY_SSL")
	defer func() {
		_ = os.Setenv("LOOKERSDK_BASE_URL", origBase)
		_ = os.Setenv("LOOKERSDK_VERIFY_SSL", origVerify)
	}()

	// Reset flags to their default values
	_ = RootCmd.PersistentFlags().Set("host", "localhost")
	_ = RootCmd.PersistentFlags().Set("port", "19999")
	_ = RootCmd.PersistentFlags().Set("verify-ssl", "true")
	
	// Reset flag "changed" statuses to false by creating a fresh Command instance or modifying manually
	// Cobra doesn't let us easily reset "Changed" without clearing flags, but we can check the behavior
	// by parsing a clean argument list or just executing in isolation.
	// Let's make sure they are considered UNCHANGED. We can do this by resetting the Command state.
	RootCmd.PersistentFlags().Lookup("host").Changed = false
	RootCmd.PersistentFlags().Lookup("port").Changed = false
	RootCmd.PersistentFlags().Lookup("verify-ssl").Changed = false

	t.Run("Environment variables fallbacks when flags are omitted", func(t *testing.T) {
		_ = os.Setenv("LOOKERSDK_BASE_URL", "https://env-host-name.com:8888")
		_ = os.Setenv("LOOKERSDK_VERIFY_SSL", "false")

		// Initialize client wrapper (uses mock since MockSDK is nil, it tries to create a real one,
		// but wait: if MockSDK is nil, client.NewClient will try to read from token file or login,
		// which might error if there is no active login.
		// Let's temporarily set MockSDK to bypass actual login, but wait:
		// if MockSDK != nil, initClient bypasses NewClient completely and returns:
		// &client.ClientWrapper{SDK: MockSDK, Host: cfgHost, SuUser: cfgSuUser}
		// In that case, it doesn't use the parsed env values!
		// So to test NewClient's parsing logic, we must allow client.NewClient to run.
		// To allow client.NewClient to run without actual API calls or file reads, we can mock the token environment.
		// Let's point HOME to a temp dir so it sees no token file, and bypass login since we aren't using oauth.
		// If oauth=false and no client ID is set, client.NewClient will check netrc or env.
		// Let's make sure we set clientID and clientSecret in env so it compiles settings successfully.
		_ = os.Setenv("LOOKERSDK_CLIENT_ID", "dummy")
		_ = os.Setenv("LOOKERSDK_CLIENT_SECRET", "dummy")
		defer func() {
			_ = os.Unsetenv("LOOKERSDK_CLIENT_ID")
			_ = os.Unsetenv("LOOKERSDK_CLIENT_SECRET")
		}()

		wrapper, err := initClient(context.Background(), false)
		if err != nil {
			t.Fatalf("initClient failed: %v", err)
		}

		if wrapper.Host != "env-host-name.com" {
			t.Errorf("expected host 'env-host-name.com' from env, got '%s'", wrapper.Host)
		}
		if wrapper.Session.Config.BaseUrl != "https://env-host-name.com:8888" {
			t.Errorf("expected base URL 'https://env-host-name.com:8888', got '%s'", wrapper.Session.Config.BaseUrl)
		}
		if wrapper.Session.Config.VerifySsl {
			t.Errorf("expected verifySSL to be false from env, got true")
		}
	})

	t.Run("Explicit flags take precedence over environment variables", func(t *testing.T) {
		_ = os.Setenv("LOOKERSDK_BASE_URL", "https://env-host-name.com:8888")
		_ = os.Setenv("LOOKERSDK_VERIFY_SSL", "false")
		_ = os.Setenv("LOOKERSDK_CLIENT_ID", "dummy")
		_ = os.Setenv("LOOKERSDK_CLIENT_SECRET", "dummy")
		defer func() {
			_ = os.Unsetenv("LOOKERSDK_CLIENT_ID")
			_ = os.Unsetenv("LOOKERSDK_CLIENT_SECRET")
		}()

		// Explicitly set flags
		_ = RootCmd.PersistentFlags().Set("host", "flag-host.com")
		_ = RootCmd.PersistentFlags().Set("port", "1111")
		_ = RootCmd.PersistentFlags().Set("verify-ssl", "true")

		wrapper, err := initClient(context.Background(), false)
		if err != nil {
			t.Fatalf("initClient failed: %v", err)
		}

		if wrapper.Host != "flag-host.com" {
			t.Errorf("expected host 'flag-host.com' from flag, got '%s'", wrapper.Host)
		}
		if wrapper.Session.Config.BaseUrl != "https://flag-host.com:1111" {
			t.Errorf("expected base URL 'https://flag-host.com:1111', got '%s'", wrapper.Session.Config.BaseUrl)
		}
		if !wrapper.Session.Config.VerifySsl {
			t.Errorf("expected verifySSL to be true from flag, got false")
		}
	})
}

func TestRoleCatCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"role", "cat", "1"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "my_role") || !strings.Contains(out, "my_perm_set") {
		t.Errorf("expected my_role and my_perm_set, got %s", out)
	}
}

func TestRoleCatCommandFields(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() {
		MockSDK = nil
		roleCatFields = ""
	}()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"role", "cat", "1", "--fields", "name"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	_ = w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "my_role") {
		t.Errorf("expected to contain my_role, got %s", out)
	}
	if strings.Contains(out, "my_perm_set") {
		t.Errorf("expected NOT to contain my_perm_set, got %s", out)
	}
	if strings.Contains(out, `"id"`) {
		t.Errorf("expected NOT to contain 'id', got %s", out)
	}
}

func TestQueryRunQuery(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	captureStdout := func(args []string) (string, error) {
		queryRunInputFile = ""
		queryRunOutputFile = ""
		queryRunFormat = "json"

		oldStdout := os.Stdout
		r, w, _ := os.Pipe()
		os.Stdout = w

		RootCmd.SetArgs(args)
		err := RootCmd.Execute()

		_ = w.Close()
		os.Stdout = oldStdout
		var buf bytes.Buffer
		_, _ = io.Copy(&buf, r)
		return buf.String(), err
	}

	t.Run("Run by ID", func(t *testing.T) {
		out, err := captureStdout([]string{"query", "runquery", "1234"})
		if err != nil {
			t.Fatalf("Execute failed: %v", err)
		}
		if !strings.Contains(out, `"query_id": "1234"`) || !strings.Contains(out, `"format": "json"`) {
			t.Errorf("unexpected output: %s", out)
		}
	})

	t.Run("Run by Slug", func(t *testing.T) {
		out, err := captureStdout([]string{"query", "runquery", "my_slug"})
		if err != nil {
			t.Fatalf("Execute failed: %v", err)
		}
		if !strings.Contains(out, `"query_id": "9999"`) {
			t.Errorf("expected query_id 9999 for slug my_slug, got: %s", out)
		}
	})

	t.Run("Run by JSON inline", func(t *testing.T) {
		out, err := captureStdout([]string{"query", "runquery", `{"model":"test_model","view":"test_view"}`})
		if err != nil {
			t.Fatalf("Execute failed: %v", err)
		}
		if !strings.Contains(out, "mocked_inline_data") || !strings.Contains(out, "test_model") {
			t.Errorf("unexpected output: %s", out)
		}
	})

	t.Run("Run by File", func(t *testing.T) {
		tmpFile, err := os.CreateTemp("", "query*.json")
		if err != nil {
			t.Fatalf("failed to create temp file: %v", err)
		}
		defer func() { _ = os.Remove(tmpFile.Name()) }()

		queryDef := `{"model":"file_model","view":"file_view"}`
		_, _ = tmpFile.WriteString(queryDef)
		_ = tmpFile.Close()

		out, err := captureStdout([]string{"query", "runquery", "--file", tmpFile.Name()})
		if err != nil {
			t.Fatalf("Execute failed: %v", err)
		}
		if !strings.Contains(out, "mocked_inline_data") || !strings.Contains(out, "file_model") {
			t.Errorf("unexpected output: %s", out)
		}
	})

	t.Run("Error both args and file", func(t *testing.T) {
		_, err := captureStdout([]string{"query", "runquery", "1234", "--file", "somefile.json"})
		if err == nil {
			t.Fatal("expected error, got nil")
		}
		if !strings.Contains(err.Error(), "cannot provide both QUERY_DEF argument and --file flag") {
			t.Errorf("unexpected error: %v", err)
		}
	})

	t.Run("Error neither args nor file", func(t *testing.T) {
		_, err := captureStdout([]string{"query", "runquery"})
		if err == nil {
			t.Fatal("expected error, got nil")
		}
		if !strings.Contains(err.Error(), "either QUERY_DEF argument or --file flag must be provided") {
			t.Errorf("unexpected error: %v", err)
		}
	})

	t.Run("Error file not found", func(t *testing.T) {
		_, err := captureStdout([]string{"query", "runquery", "--file", "non_existent_file.json"})
		if err == nil {
			t.Fatal("expected error, got nil")
		}
		if !strings.Contains(err.Error(), "failed to read input file") {
			t.Errorf("unexpected error: %v", err)
		}
	})
}
