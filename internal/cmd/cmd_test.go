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
	if method == "GET" && path == "/permission_sets/3" {
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

	w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "1234") || !strings.Contains(out, "jsmith@mycompany.com") {
		t.Errorf("expected 1234 and jsmith, got %s", out)
	}
}

func TestSpaceLsCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"space", "ls", "709", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "Daily Profit") || !strings.Contains(out, "Daily Profit Dashboard") {
		t.Errorf("expected Daily Profit, got %s", out)
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

	w.Close()
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

	w.Close()
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
	defer os.Remove(tmpFile.Name())
	_, _ = tmpFile.WriteString(`{"name":"my_new_conn","dialect_name":"postgres"}`)
	tmpFile.Close()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"connection", "import", tmpFile.Name(), "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
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

	w.Close()
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

	w.Close()
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

	RootCmd.SetArgs([]string{"dashboard", "import_lookml", "lookml_dash_1", "801", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	w.Close()
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

	RootCmd.SetArgs([]string{"dashboard", "sync_lookml", "lookml_dash_1"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := strings.TrimSpace(buf.String())

	if !strings.Contains(out, "101") || !strings.Contains(out, "102") {
		t.Errorf("expected synced dashboard ids 101 and 102, got %s", out)
	}
}

func TestVersionCommand(t *testing.T) {
	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"version"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := strings.TrimSpace(buf.String())

	if out != "gzr 0.0.1" {
		t.Errorf("expected gzr 0.0.1, got %s", out)
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

		w.Close()
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

		w.Close()
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

	w.Close()
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
	defer os.Remove(tmpFile.Name())
	_, _ = tmpFile.WriteString(`{"name":"my_model","project_name":"my_project"}`)
	tmpFile.Close()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"model", "import", tmpFile.Name(), "--force", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	w.Close()
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

	w.Close()
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

	w.Close()
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
	defer os.Remove(tmpFile.Name())
	_, _ = tmpFile.WriteString(`{"name":"my_model_set","models":["my_model"]}`)
	tmpFile.Close()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"model", "set", "import", tmpFile.Name(), "--force", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	w.Close()
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

	w.Close()
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

	w.Close()
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

	w.Close()
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

	w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "3") || !strings.Contains(out, "my_permission_set") {
		t.Errorf("expected 3 and my_permission_set, got %s", out)
	}
}

func TestPermissionSetImportCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	tmpFile, _ := os.CreateTemp("", "permsset*.json")
	defer os.Remove(tmpFile.Name())
	_, _ = tmpFile.WriteString(`{"name":"my_permission_set","permissions":["access_data"]}`)
	tmpFile.Close()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"permission", "set", "import", tmpFile.Name(), "--force", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	w.Close()
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

	w.Close()
	os.Stdout = oldStdout
	var buf bytes.Buffer
	_, _ = io.Copy(&buf, r)
	out := buf.String()

	if !strings.Contains(out, "deleted") {
		t.Errorf("expected deleted message, got %s", out)
	}
}

func TestSpaceTopCommand(t *testing.T) {
	MockSDK = v4.NewLookerSDK(&mockDoer{t: t})
	defer func() { MockSDK = nil }()

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	RootCmd.SetArgs([]string{"space", "top", "--plain"})
	err := RootCmd.Execute()
	if err != nil {
		t.Fatalf("Execute failed: %v", err)
	}

	w.Close()
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
}
