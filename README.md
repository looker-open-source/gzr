# Gazer (gzr) Go Implementation

Gazer (`gzr`) is a robust, fast command-line interface (CLI) tool designed to navigate, manage, and automate Looker resources (Folders/Spaces, Looks, Dashboards, Users, and more) via the Looker API 4.0.

This is a Go-based reimplementation of the original Ruby `gzr` tool, utilizing the official Looker Go SDK for high performance and type safety.

---

## Table of Contents
1. [Installation](#installation)
2. [Authentication Guide](#authentication-guide)
3. [Global Flags](#global-flags)
4. [Complete Command Reference](#complete-command-reference)
   * [alert](#alert)
   * [attribute](#attribute)
   * [connection](#connection)
   * [dashboard](#dashboard)
   * [group](#group)
   * [look](#look)
   * [model](#model)
   * [permission](#permission)
   * [plan](#plan)
   * [project](#project)
   * [query](#query)
   * [role](#role)
   * [session](#session)
   * [space / folder](#space--folder)
   * [user](#user)

---

## Installation

To compile `gzr` from source:

```bash
# Build the binary in the current workspace
go build -o gzr ./cmd/gzr

# Verify the installation
./gzr version
```

---

## Authentication Guide

`gzr` supports several secure and flexible ways to connect to your Looker instance.

### 1. Interactive OAuth PKCE (Recommended for Users)
Log in interactively using a browser-based OAuth PKCE flow. You do not need to supply or save your API keys.

```bash
# Start the interactive OAuth login flow
./gzr session login --oauth --host your-looker-domain.com --port 443
```
This will:
1. Generate a secure PKCE verifier and challenge.
2. Spin up a temporary local callback server on port `8080`.
3. Open your default web browser to authenticate with Looker.
4. Exchange the authentication code for an access token and store it in `~/.gzr_auth`.

#### Setting up the OAuth Client Application in Looker
Before you can use the `--oauth` login, your Looker Administrator must register `gzr` as an **OAuth Client Application** in your Looker instance:

1. Navigate to **Admin** -> **OAuth Client Apps** in the Looker console.
2. Click **Register Application**.
3. Configure the following settings:
   * **Application Client ID**: `gzr` (This must match `gzr`'s default Client ID. If you register a different custom Client ID, you must pass it via the `--client-id` flag when logging in).
   * **Application Name**: `Gazer CLI`
   * **Redirect URIs**: Add `http://localhost:8080/callback` (This is the temporary port spawned locally by `gzr` to retrieve the authorization code).
   * **Enabled**: Must be set to **Enabled / Active** (toggle to `true`).
4. Click **Save**.

Once registered, the `gzr session login --oauth` browser login will work seamlessly.

### 2. Headless Token Authentication (Recommended for Scripts)
Once logged in, you can run automated scripts headlessly by referencing the stored token or passing one directly:

```bash
# Option A: Use the stored token file (~/.gzr_auth)
./gzr user ls --token-file --host your-looker-domain.com --port 443

# Option B: Pass a static token directly via flag
./gzr user ls --token "YOUR_ACCESS_TOKEN" --host your-looker-domain.com
```

### 3. Netrc File (`.netrc`) (Recommended for API Keys)
Store your API Client ID and Client Secret securely in `~/.netrc` to keep them out of your shell history:

```text
machine your-looker-domain.com
login YOUR_API_CLIENT_ID
password YOUR_API_CLIENT_SECRET
```
`gzr` will automatically retrieve these credentials when connecting to `your-looker-domain.com`.

### 4. Environment Variables
```bash
export LOOKERSDK_CLIENT_ID="your_client_id"
export LOOKERSDK_CLIENT_SECRET="your_client_secret"
```

### 5. Direct Flags
```bash
./gzr user ls --client-id "ID" --client-secret "SECRET" --host your-looker-domain.com
```

---

## Global Flags

Every command accepts the following optional global parameters to customize connection and behavior:

| Flag | Description | Default |
| :--- | :--- | :--- |
| `--host` | Looker Hostname | `localhost` |
| `--port` | Looker API Port | `19999` |
| `--ssl` | Use SSL/TLS for communication | `true` |
| `--verify-ssl` | Verify server SSL certificate | `true` |
| `--su` | Act as another user ID (Sudo) | `""` |
| `--timeout` | Seconds to wait for a response | `60` |
| `--token` | Access token to use for authentication | `""` |
| `--token-file` | Use access token stored in `~/.gzr_auth` | `false` |
| `--client-id` | API Client ID | `""` |
| `--client-secret` | API Client Secret | `""` |
| `--width` | Limit table column rendering width | `0` |
| `--debug` | Enable verbose API logging | `false` |

---

## Complete Command Reference

### api
Make raw Looker API calls based on the Looker API 4.0 Swagger specification. 

This command dynamically exposes all endpoints of the Looker API, organized into subcommands by Tag, and operation IDs as sub-subcommands.

*   **List all Categories (Tags)**:
    ```bash
    ./gzr api help
    ```
*   **List operations under a Category**:
    ```bash
    ./gzr api query help
    ```
*   **Get detailed help for an operation** (including parameters and types):
    ```bash
    ./gzr api query create_query_task --help
    ```
*   **Make an API Call with Query Flags**:
    Required path parameters are passed as positional arguments. Optional parameters are passed as flags:
    ```bash
    ./gzr api user user 2456 --fields "id,email,first_name,last_name" --token-file --host your-domain.com
    ```
*   **Make an API Call with JSON Body**:
    If the command takes a JSON request body, it must be passed as a file path or `-` for standard input (stdin):
    ```bash
    ./gzr api query run_inline_query json my_query.json --token-file --host your-domain.com
    ```
*   **Describe JSON Request Body Schema**:
    If a command accepts a JSON request body, you can pass the `--describe-body` flag to output the full JSON schema of the expected body payload (bypassing other positional argument checks) and exit instantly:
    ```bash
    ./gzr api query create_query_task --describe-body
    ```

---

### alert
Commands pertaining to alerts.

*   **`ls`**: List alerts on the server.
    ```bash
    ./gzr alert ls --token-file --host your-domain.com
    ```
*   **`cat <alert_id>`**: Output JSON details about an alert.
    ```bash
    ./gzr alert cat 12 --token-file > alert.json
    ```
*   **`chown <alert_id> <user_id>`**: Change the owner of an alert.
    ```bash
    ./gzr alert chown 12 45 --token-file
    ```
*   **`disable <alert_id>`**: Disable an alert.
    ```bash
    ./gzr alert disable 12 --token-file
    ```
*   **`enable <alert_id>`**: Enable an alert.
    ```bash
    ./gzr alert enable 12 --token-file
    ```
*   **`follow <alert_id>`**: Start following an alert.
    ```bash
    ./gzr alert follow 12 --token-file
    ```
*   **`unfollow <alert_id>`**: Stop following an alert.
    ```bash
    ./gzr alert unfollow 12 --token-file
    ```
*   **`import <file>`**: Import an alert from a JSON file.
    ```bash
    ./gzr alert import alert.json --token-file
    ```
*   **`notifications`**: Retrieve alert notifications.
    ```bash
    ./gzr alert notifications --token-file
    ```
*   **`read <notification_id>`**: Mark a notification as read.
    ```bash
    ./gzr alert read 78 --token-file
    ```
*   **`threshold <alert_id> <value>`**: Change the threshold of an alert.
    ```bash
    ./gzr alert threshold 12 "100.5" --token-file
    ```
*   **`randomize`**: Randomize scheduled alert times on the server (useful for dev environments).
    ```bash
    ./gzr alert randomize --token-file
    ```
*   **`rm <alert_id>`**: Delete an alert.
    ```bash
    ./gzr alert rm 12 --token-file
    ```

---

### attribute
Commands pertaining to User Attributes.

*   **`ls`**: List all defined user attributes.
    ```bash
    ./gzr attribute ls --token-file
    ```
*   **`cat <attribute_id>`**: Output JSON information about an attribute.
    ```bash
    ./gzr attribute cat 5 --token-file
    ```
*   **`create <name> <type>`**: Create or modify a user attribute.
    ```bash
    ./gzr attribute create "my_attribute" "string" --token-file
    ```
*   **`import <file>`**: Import a user attribute from a file.
    ```bash
    ./gzr attribute import attribute.json --token-file
    ```
*   **`get_group_value <attribute_id> <group_id>`**: Retrieve a user attribute value for a specific group.
    ```bash
    ./gzr attribute get_group_value 5 10 --token-file
    ```
*   **`set_group_value <attribute_id> <group_id> <value>`**: Set a user attribute value for a specific group.
    ```bash
    ./gzr attribute set_group_value 5 10 "US-EAST" --token-file
    ```
*   **`rm <attribute_id>`**: Delete a user attribute.
    ```bash
    ./gzr attribute rm 5 --token-file
    ```

---

### connection
Commands pertaining to database connections and dialects.

*   **`ls`**: List all database connections.
    ```bash
    ./gzr connection ls --token-file
    ```
*   **`cat <connection_name>`**: Output the JSON representation of a database connection.
    ```bash
    ./gzr connection cat "my_db" --token-file
    ```
*   **`import <file>`**: Import a database connection from a JSON file.
    ```bash
    ./gzr connection import conn.json --token-file
    ```
*   **`dialects`**: List all supported SQL dialects.
    ```bash
    ./gzr connection dialects --token-file
    ```
*   **`test <connection_name>`**: Test a database connection.
    ```bash
    ./gzr connection test "my_db" --token-file
    ```
*   **`rm <connection_name>`**: Delete a database connection.
    ```bash
    ./gzr connection rm "my_db" --token-file
    ```

---

### dashboard
Commands pertaining to dashboards.

*   **`cat <dashboard_id>`**: Output JSON describing a dashboard.
    ```bash
    ./gzr dashboard cat 2 --token-file > dash.json
    ```
*   **`import <file> <folder_id>`**: Import a dashboard from a JSON file into a folder.
    ```bash
    ./gzr dashboard import dash.json 5 --token-file
    ```
*   **`import_lookml <lookml_dashboard_id> <folder_id>`**: Create a User Defined Dashboard (UDD) from a LookML dashboard.
    ```bash
    ./gzr dashboard import_lookml "model::my_dash" 5 --token-file
    ```
*   **`sync_lookml <lookml_dashboard_id> <folder_id>`**: Sync a UDD from its parent LookML dashboard.
    ```bash
    ./gzr dashboard sync_lookml "model::my_dash" 5 --token-file
    ```
*   **`mv <dashboard_id> <folder_id>`**: Move a dashboard to a different folder.
    ```bash
    ./gzr dashboard mv 2 10 --token-file
    ```
*   **`rm <dashboard_id>`**: Delete a dashboard.
    ```bash
    ./gzr dashboard rm 2 --token-file
    ```

---

### group
Commands pertaining to groups.

*   **`ls`**: List all groups.
    ```bash
    ./gzr group ls --token-file
    ```
*   **`member_groups <group_id>`**: List groups that are members of the given group.
    ```bash
    ./gzr group member_groups 3 --token-file
    ```
*   **`member_users <group_id>`**: List users that are members of the given group.
    ```bash
    ./gzr group member_users 3 --token-file
    ```

---

### look
Commands pertaining to Looks.

*   **`cat <look_id>`**: Output JSON describing a Look.
    ```bash
    ./gzr look cat 14 --token-file > look.json
    ```
*   **`import <file> <folder_id>`**: Import a Look from a JSON file into a folder.
    ```bash
    ./gzr look import look.json 5 --token-file
    ```
*   **`mv <look_id> <folder_id>`**: Move a Look to a different folder.
    ```bash
    ./gzr look mv 14 10 --token-file
    ```
*   **`rm <look_id>`**: Delete a Look.
    ```bash
    ./gzr look rm 14 --token-file
    ```

---

### model
Commands pertaining to LookML Models.

*   **`ls`**: List all models.
    ```bash
    ./gzr model ls --token-file
    ```
*   **`cat <model_name>`**: Output JSON representation of a model.
    ```bash
    ./gzr model cat "my_model" --token-file
    ```
*   **`import <file>`**: Import a LookML model from a JSON file.
    ```bash
    ./gzr model import model.json --token-file
    ```

#### model set
Commands for managing Model Sets (groups of models for user roles).
*   **`ls`**: List all model sets.
    ```bash
    ./gzr model set ls --token-file
    ```
*   **`cat <set_id>`**: Output JSON representation of a model set.
    ```bash
    ./gzr model set cat 2 --token-file
    ```
*   **`import <file>`**: Import a model set from a JSON file.
    ```bash
    ./gzr model set import set.json --token-file
    ```
*   **`rm <set_id>`**: Delete a model set.
    ```bash
    ./gzr model set rm 2 --token-file
    ```

---

### permission
Commands to retrieve permissions and manage Permission Sets.

*   **`ls`**: List all raw available system permissions.
    ```bash
    ./gzr permission ls --token-file
    ```
*   **`tree`**: Display system permissions in a hierarchical tree view.
    ```bash
    ./gzr permission tree --token-file
    ```

#### permission set
Commands for managing Permission Sets (permissions assigned to roles).
*   **`ls`**: List all permission sets.
    ```bash
    ./gzr permission set ls --token-file
    ```
*   **`cat <set_id>`**: Output JSON representation of a permission set.
    ```bash
    ./gzr permission set cat 4 --token-file
    ```
*   **`import <file>`**: Import a permission set from a JSON file.
    ```bash
    ./gzr permission set import perm_set.json --token-file
    ```
*   **`rm <set_id>`**: Delete a permission set.
    ```bash
    ./gzr permission set rm 4 --token-file
    ```

---

### plan
Commands pertaining to Scheduled Plans.

*   **`ls`**: List scheduled plans.
    ```bash
    ./gzr plan ls --token-file
    ```
*   **`cat <plan_id>`**: Output JSON representation of a scheduled plan.
    ```bash
    ./gzr plan cat 8 --token-file > plan.json
    ```
*   **`import <file>`**: Import a scheduled plan from a JSON file.
    ```bash
    ./gzr plan import plan.json --token-file
    ```
*   **`runit <plan_id>`**: Execute a saved scheduled plan immediately.
    ```bash
    ./gzr plan runit 8 --token-file
    ```
*   **`enable <plan_id>`**: Enable a scheduled plan.
    ```bash
    ./gzr plan enable 8 --token-file
    ```
*   **`disable <plan_id>`**: Disable a scheduled plan.
    ```bash
    ./gzr plan disable 8 --token-file
    ```
*   **`failures`**: Report all scheduled plans that failed in their most recent execution attempt.
    ```bash
    ./gzr plan failures --token-file
    ```
*   **`randomize`**: Randomize scheduled plan times (useful for dev instance testing).
    ```bash
    ./gzr plan randomize --token-file
    ```
*   **`rm <plan_id>`**: Delete a scheduled plan.
    ```bash
    ./gzr plan rm 8 --token-file
    ```

---

### project
Commands pertaining to LookML Projects.

*   **`ls`**: List all projects.
    ```bash
    ./gzr project ls --token-file
    ```
*   **`cat <project_id>`**: Output JSON information about a project.
    ```bash
    ./gzr project cat "my_project" --token-file
    ```
*   **`import <file>`**: Import a project from a file.
    ```bash
    ./gzr project import project.json --token-file
    ```
*   **`update <project_id> <file>`**: Update a project from a file definition.
    ```bash
    ./gzr project update "my_project" project_update.json --token-file
    ```
*   **`branch <project_id>`**: List the active Git branch or all branches of a project.
    ```bash
    ./gzr project branch "my_project" --token-file
    ```
*   **`checkout <project_id> <branch_name>`**: Checkout a specific Git branch for a project.
    ```bash
    ./gzr project checkout "my_project" "dev-feature" --token-file
    ```
*   **`deploy <project_id>`**: Deploy the active branch of a project to production.
    ```bash
    ./gzr project deploy "my_project" --token-file
    ```
*   **`deploy_key <project_id>`**: Generate/retrieve the Git deploy public key for the project.
    ```bash
    ./gzr project deploy_key "my_project" --token-file
    ```

#### Managing Project Files (`gzr project file`)
Manage the files inside your Looker project using undocumented Looker API endpoints.

*   **`ls <project_id>`**: List all files in a project:
    ```bash
    ./gzr project file ls "my_project" --token-file
    ```
*   **`cat <project_id> <file_path>`**: Retrieve and print the raw text content of a LookML project file:
    ```bash
    ./gzr project file cat "my_project" "my_model.model.lkml" --token-file
    ```
*   **`create <project_id> <file_path> <content_file_or_->`**: Create a new LookML file inside a project (accepts payload from a local file or `-` for stdin):
    ```bash
    ./gzr project file create "my_project" "views/new_view.view.lkml" new_view.lkml --token-file
    ```
*   **`update <project_id> <file_path> <content_file_or_->`**: Overwrite/update an existing LookML file inside a project:
    ```bash
    ./gzr project file update "my_project" "views/new_view.view.lkml" updated_view.lkml --token-file
    ```
*   **`rm <project_id> <file_path>`**: Delete a file from a project:
    ```bash
    ./gzr project file rm "my_project" "views/new_view.view.lkml" --token-file
    ```

#### Managing Project Directories (`gzr project directory`)
Manage physical directories within your Looker LookML projects.

*   **`ls <project_id>`**: List all subdirectories inside a project:
    ```bash
    ./gzr project directory ls "my_project" --token-file
    ```
*   **`create <project_id> <dir_path>`**: Create a new subdirectory inside a project:
    ```bash
    ./gzr project directory create "my_project" "views/marketing" --token-file
    ```
*   **`rm <project_id> <dir_path>`**: Delete a directory from a project:
    ```bash
    ./gzr project directory rm "my_project" "views/marketing" --token-file
    ```

---

### query
Commands to retrieve and run queries.

*   **`runquery <query_id | slug | json_file>`**: Execute a query and return the results.
    ```bash
    # Run by ID
    ./gzr query runquery 123 --token-file
    
    # Run by slug
    ./gzr query runquery "abc123xyz" --token-file
    
    # Run using a local JSON query definition
    ./gzr query runquery query_definition.json --token-file
    ```

---

### role
Commands pertaining to Roles.

*   **`ls`**: Display all roles.
    ```bash
    ./gzr role ls --token-file
    ```
*   **`cat <role_id>`**: Output the JSON representation of a role.
    ```bash
    ./gzr role cat 3 --token-file
    ```
*   **`create <name> <permission_set_id> <model_set_id>`**: Create a new role.
    ```bash
    ./gzr role create "Analyst" 4 2 --token-file
    ```
*   **`rm <role_id>`**: Delete a role.
    ```bash
    ./gzr role rm 3 --token-file
    ```

#### Managing Role Groups
*   **`group_ls <role_id>`**: List the groups assigned to a role.
    ```bash
    ./gzr role group_ls 3 --token-file
    ```
*   **`group_add <role_id> <group_id1,group_id2...>`**: Add groups to a role.
    ```bash
    ./gzr role group_add 3 10,11 --token-file
    ```
*   **`group_rm <role_id> <group_id1,group_id2...>`**: Remove groups from a role.
    ```bash
    ./gzr role group_rm 3 10 --token-file
    ```

#### Managing Role Users
*   **`user_ls <role_id>`**: List the users assigned to a role.
    ```bash
    ./gzr role user_ls 3 --token-file
    ```
*   **`user_add <role_id> <user_id1,user_id2...>`**: Add users to a role.
    ```bash
    ./gzr role user_add 3 45,46 --token-file
    ```
*   **`user_rm <role_id> <user_id1,user_id2...>`**: Remove users from a role.
    ```bash
    ./gzr role user_rm 3 45 --token-file
    ```

---

### session
Commands pertaining to API connections and workspace sessions.

*   **`login`**: Create a persistent session.
    ```bash
    # Standard login using API keys (prompts/uses config)
    ./gzr session login --host your-domain.com
    
    # OAuth PKCE login
    ./gzr session login --oauth --host your-domain.com --port 443
    ```
*   **`logout`**: End a persistent session and clear the local cached token.
    ```bash
    ./gzr session logout --host your-domain.com
    ```
*   **`get`**: Get data about your current Looker session.
    ```bash
    ./gzr session get --token-file --host your-domain.com
    ```
*   **`update <dev | production>`**: Change the workspace ID of your current session.
    ```bash
    ./gzr session update dev --token-file --host your-domain.com
    ```

---

### space / folder
Commands pertaining to spaces (now known as Folders in Looker). *Supports alias: `folder`.*

*   **`top`**: Retrieve the top-level (root) folders.
    ```bash
    ./gzr space top --token-file
    ```
*   **`ls [space_id]`**: List the looks, dashboards, and folders in the given space (defaults to root/top spaces if omitted).
    ```bash
    ./gzr space ls 5 --token-file
    ```
*   **`cat <space_id>`**: Output JSON describing a folder.
    ```bash
    ./gzr space cat 5 --token-file
    ```
*   **`create <name> [parent_id]`**: Create a new subspace/folder under the specified parent.
    ```bash
    ./gzr space create "Marketing Folders" 1 --token-file
    ```
*   **`tree [space_id]`**: Display child spaces, dashboards, and looks in a tree format.
    ```bash
    ./gzr space tree 1 --token-file
    ```
*   **`export <space_id>`**: Recursively download all looks, dashboards, and folders inside a space to your local filesystem.
    ```bash
    ./gzr space export 5 --token-file
    ```
*   **`rm <space_id>`**: Delete a folder.
    ```bash
    ./gzr space rm 5 --token-file
    ```

---

### user
Commands pertaining to Users.

*   **`me`**: Show information for your currently authenticated user.
    ```bash
    ./gzr user me --token-file --host your-domain.com
    ```
*   **`ls`**: List all users on the system.
    ```bash
    ./gzr user ls --token-file --host your-domain.com
    ```
*   **`ls --last-login`**: List users including their true most recent login timestamp, dynamically resolved across all auth types (SAML, LDAP, Google OAuth, OIDC, Email, etc.):
    ```bash
    ./gzr user ls --last-login --token-file --host your-domain.com
    ```
*   **`cat <user_id>`**: Output JSON details about a user.
    ```bash
    ./gzr user cat 45 --token-file > user_45.json
    ```
*   **`enable <user_id>`**: Enable a user.
    ```bash
    ./gzr user enable 45 --token-file
    ```
*   **`disable <user_id>`**: Disable a user.
    ```bash
    ./gzr user disable 45 --token-file
    ```
*   **`delete <user_id>`**: Delete a user.
    ```bash
    ./gzr user delete 45 --token-file
    ```
