#! /bin/bash

# The MIT License (MIT)

# Copyright (c) 2023 Mike DeAngelo Google, Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

SECRET_GITHUB_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
DATABASE_HOST=XXXXXXXXXXXXX
DATABASE_USERNAME=XXXXXXXXXXXXXX
DATABASE_PASSWORD=XXXXXXXXXXXXXX

echo '***************************************************************'
echo Login persistently
echo '***************************************************************'
gzr session login

echo '***************************************************************'
echo create and test the connection
echo '***************************************************************'
cat > Connection_faa_mysql.json <<HERE
{
  "name": "faa",
  "host": "$DATABASE_HOST",
  "port": "3306",
  "database": "flightstats",
  "db_timezone": "UTC",
  "query_timezone": "UTC",
  "schema": null,
  "max_connections": 30,
  "ssl": false,
  "verify_ssl": false,
  "tmp_db_name": "tmp",
  "pool_timeout": 120,
  "sql_runner_precache_tables": true,
  "sql_writing_with_info_schema": true,
  "uses_tns": false,
  "pdt_concurrency": 1,
  "dialect_name": "mysql",
  "username": "$DATABASE_USERNAME",
  "password": "$DATABASE_PASSWORD"
}
HERE
gzr connection import Connection_faa_mysql.json --token_file
gzr connection test faa --token_file

echo '***************************************************************'
echo Change the session to dev mode
echo '***************************************************************'
gzr session get --token_file
gzr session update dev --token_file

echo '***************************************************************'
echo Import the project
echo '***************************************************************'
cat > Project_faa.json <<HERE
{
  "name": "faa",
  "uses_git": true
}
HERE
gzr project import Project_faa.json --token-file

echo '***************************************************************'
echo Create a deploy key and set it on the github repo for the project
echo '***************************************************************'
DEPLOY_KEY=$(gzr project deploy_key faa --token_file)
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $SECRET_GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/looker-open-source/faa/keys \
  -d "{\"title\":\"test_key $(uuidgen)\",\"key\":\"$DEPLOY_KEY\",\"read_only\":false}"

echo '***************************************************************'
echo Set the project github connection
echo '***************************************************************'
cat > github_repo.json <<HERE
{
  "git_remote_url": "git@github.com:looker-open-source/faa.git",
  "git_service_name": "github"
}
HERE
gzr project update faa github_repo.json --token-file

echo '***************************************************************'
echo Check the project config
echo '***************************************************************'
gzr project cat faa --trim --token-file

echo '***************************************************************'
echo Checkout a shared branch
echo '***************************************************************'
gzr project checkout faa main --token_file

echo '***************************************************************'
echo Deploy to production
echo '***************************************************************'
gzr project deploy faa --token_file

echo '***************************************************************'
echo Configure lookml model
echo '***************************************************************'
cat > Model_faa.json <<HERE
{
  "name": "aviation",
  "project_name": "faa",
  "unlimited_db_connections": false,
  "allowed_db_connection_names": [
    "faa"
  ]
}
HERE
gzr model import Model_faa.json --token_file

echo '***************************************************************'
echo run a query against the model
echo '***************************************************************'
cat > query.json <<HERE
{
  "model": "aviation",
  "view": "aircraft_types",
  "fields": ["aircraft_types.description","aircraft_types.count"],
  "pivots": null,
  "fill_fields": null,
  "filters": null,
  "filter_expression": null,
  "sorts": [
    "aircraft_types.description"
  ],
  "limit": "500"
}
HERE
gzr query runquery "$(cat query.json)"
