# Gazer - A Looker Content Utility

Gazer can be used to navigate and manges Spaces, Looks, 
and Dashboards via a simple command line tool.

## Status and Support

Gazer is **NOT** supported or warranteed by Looker in any way. Please do not contact Looker support
for issues with Gazer. Issues can be logged via https://github.com/deangelo-llooker/gzr/issues 

## Installation

You can install this gem by simply typing:

    $ gem install gazer

Alternately you can follow the Development setup below, typing `bundle exec rake install` to install it
locally

## Usage

Display help information...

    $ gzr help

### Storing Credentials
Store login information by creating the file `~/.netrc` in your home directory with the api3 credentials

```
machine foo.bar.mycompany.com
  login AbCdEfGhIjKlMnOp
  password QrStUvWxYz1234567890
```

Make sure that the `~/.netrc` file has restricted permissions by running `chmod 600 ~/.netrc`.

### Options that apply to many commands

#### --su option

The `--su` option can be used with a user id to run the command as another user. This options works
with all commands. In order to use the `--su` option the user must provide admin credentials.

For example...

```
$ gzr user me --su 1237 --host foo.bar.mycompany.com
+----+----------+---------+---------------------+
|  id|first_name|last_name|email                |
+----+----------+---------+---------------------+
|1237|Susan     |Gibson   |sgibson@mycompany.com|
+----+----------+---------+---------------------+
````
#### Suppressing Formatted Output

Many commands provide tabular output. For tables the
option `--plain` will suppress the table headers and format lines, making it easier to use tools
like grep, awk, etc. to retrieve values from the output of these commands.

#### CSV Output

Many commands provide tabular output. For tables thehe option `--csv` will output tabular data in
csv format. When combined with `--plain` the header will also be suppressed.

### User Information

The command `gzr user help` will show details about subcommands of the user command.

#### user me

Display information about the current user with the command `gzr user me`.

```
$ gzr user me --host foo.bar.mycompany.com
+----+----------+---------+--------------------+
|  id|first_name|last_name|email               |
+----+----------+---------+--------------------+
|1234|John      |Smith    |jsmith@mycompany.com|
+----+----------+---------+--------------------+
```

#### user ls

Display information about all users with the command `gzr user ls`.

```
$ gzr user ls --host foo.bar.mycompany.com
+----+----------+---------+---------------------+
|  id|first_name|last_name|email                |
+----+----------+---------+---------------------+
|1234|John      |Smith    |jsmith@mycompany.com |
|1235|Frank     |Jones    |fjones@mycompany.com |
|1236|Bill      |Weld     |wweld@mycompany.com  |
|1237|Susan     |Gibson   |sgibson@mycompany.com|
|1238|Anna      |Grace    |agrace@mycompany.com |
|1239|Mike      |Arthur   |marthur@mycompany.com|
+----+----------+---------+---------------------+
```

Different fields can be returned using the `--fields` option. For example the option
`--fields id,first_name,last_name,email,personal_space_id,home_space_id`.

### Group Information

The command `gzr group help` will show details about subcommands of the group command.

#### group ls

The command `gzr group ls` will list the groups defined on a particular Looker instance.

```
gzr  group ls  --host foo.bar.mycompany.com
+--+------------------------------------+----------+---------------------+------------------+-----------------+
|id|name                                |user_count|contains_current_user|externally_managed|external_group_id|
+--+------------------------------------+----------+---------------------+------------------+-----------------+
| 4|Ecommerce Dashboard-only User       |         2|false                |                  |                 |
| 5|Marketing                           |         3|false                |                  |                 |
| 6|Developer (no deploy)               |         6|false                |                  |                 |
| 9|dashboard_only                      |         7|false                |                  |                 |
|24|Finance Team                        |         2|false                |                  |                 |
|25|Marketing Team                      |         1|false                |                  |                 |
|36|Embed Shared Group Engineering      |         0|false                |                  |Engineering      |
|37|Embed Shared Group ecomm_only_users |         1|false                |                  |ecomm_only_users |
|38|Embed Shared Group awesome_engineers|         1|false                |                  |awesome_engineers|
|39|sub finance                         |         1|false                |                  |                 |
|49|All Users                           |       570|true                 |true              |                 |
+--+------------------------------------+----------+---------------------+------------------+-----------------+
```

#### group member_groups

The command `gzr group member_group GROUP_ID` will list the group that have been added as
as members of the given group id.

```
$ gzr  group member_group 24  --host foo.bar.mycompany.com
+--+-----------+----------+---------------------+------------------+-----------------+
|id|name       |user_count|contains_current_user|externally_managed|external_group_id|
+--+-----------+----------+---------------------+------------------+-----------------+
|39|sub finance|         1|                     |                  |                 |
+--+-----------+----------+---------------------+------------------+-----------------+
```

#### group member_users

The command `gzr group member_users GROUP_ID` will list the users that have been added as
as members of the given group id.

```
$ gzr  group member_users 39  --host foo.bar.mycompany.com
+----+---------------------+---------+----------+-----------------+-------------+
|  id|email                |last_name|first_name|personal_space_id|home_space_id|
+----+---------------------+---------+----------+-----------------+-------------+
|1237|sgibson@mycompany.com|Gibson   |Susan     |              758|          758|
+----+---------------------+---------+----------+-----------------+-------------+
```

### Space Information

The command `gzr space help` will show details about subcommands of the space command.

#### space ls

The command `gzr space ls` will list the contents of a space, including subspaces, looks, and dashboards.

Without any arguments, the command will list the contents of the user's "home" space.

```
$ gzr space ls --host foo.bar.mycompany.com
+---------+---+------+---------+----------------------------+--------------+--------------------------------+
|parent_id|id |  name|looks(id)|looks(title)                |dashboards(id)|dashboards(title)               |
+---------+---+------+---------+----------------------------+--------------+--------------------------------+
|         |801|Shared|         |                            |              |                                |
|         |801|Shared|857      |Daily Profit                |              |                                |
|         |801|Shared|1479     |totals                      |              |                                |
|         |801|Shared|1486     |Test look2                  |              |                                |
|         |801|Shared|1509     |Aircraft Production by Year |              |                                |
|         |801|Shared|         |                            |192           |Daily Profit Dashboard          |
|         |801|Shared|         |                            |261           |New Test Dashboard              |
|         |801|Shared|         |                            |383           |Sales Dashboard                 |
|         |801|Shared|         |                            |463           |Customer Dashboard              |
+---------+---+------+---------+----------------------------+--------------+--------------------------------+
```

With the argument "~" the command will list the content of the calling user's "personal" space.

```
$ gzr space ls "~" --host foo.bar.mycompany.com
+---------+----+----------+---------+-----------------+--------------+-------------------------------------+
|parent_id|id  |      name|looks(id)|looks(title)     |dashboards(id)|dashboards(title)                    |
+---------+----+----------+---------+-----------------+--------------+-------------------------------------+
|      709|1132|John Smith|         |                 |              |                                     |
|      709|1132|John Smith|1570     |test             |              |                                     |
|      709|1132|John Smith|1726     |you can delete me|              |                                     |
|      709|1132|John Smith|1737     |My First Look    |              |                                     |
|      709|1132|John Smith|         |                 |410           |Indicator Dashboard                  |
|      709|1132|John Smith|         |                 |413           |Accidents Dashboard 2011             |
+---------+----+----------+---------+-----------------+--------------+-------------------------------------+
```

With a simple numeric argument the command will list the content of the space with the given space id.

```
$ gzr space ls 103 --host foo.bar.mycompany.com
```

With a tilde plus a simple numeric argument the command will list the content of the personal space
of the given user id.

```
$ gzr space ls "~1237" --host foo.bar.mycompany.com
```

The user can be identified by name as well.

```
$ gzr space ls "~Susan Gibson" --host foo.bar.mycompany.com
```
Finally, the space can be searched by name.

```
$ gzr space ls "Marketing" --host foo.bar.mycompany.com
```

#### space tree

The command `gzr space tree` will display the child spaces, dashboards, and looks in a tree format.

```
$ gzr space tree "~" --host foo.bar.mycompany.com
John Smith
├── Trace Data
│   ├── (l) All-Time Visits
│   └── (l) Sessions by Week
├── (l) test
├── (l) you can delete me
├── (l) My First Look
├── (d) Indicator Dashboard
└── (d) Indicator Dashboard 2011
```

The same arguments are accepted as by `space ls`.

#### space cat

The `space cat` command is used to output the json that describes the space.

```
$ gzr space cat 758 --host foo.bar.mycompany.com
{
  "id": 758,
  "creator_id": 1237,
  "name": "Susan Gibson",
  "content_metadata_id": 734,
  "is_personal": true,
  "is_shared_root": false,
  "is_users_root": false,
  "is_personal_descendant": false,
  "is_embed": false,
  "is_embed_shared_root": false,
  "is_embed_users_root": false,
  "external_id": null,
  "parent_id": 709,
  "is_user_root": false,
  "is_root": false,
  "looks": [
  ],
  "dashboards": [
  ],
  "can": {
    "index": true,
    "show": true,
    "create": true,
    "see_admin_spaces": true,
    "update": false,
    "destroy": false,
    "move_content": true,
    "edit_content": true
  }
}
```

The output document can be very long. Usually one will use the switch `--dir DIRECTORY` to
save to a file. The file will be named `Space_{SPACE_ID}_{SPACE_NAME}.json`.

#### space export

The `space export SPACE_ID` command is used to export a space and its subspaces, looks, and dashboards.
The structure of spaces and subspaces will be mirrored in directories and subdirectories in the file system
under the directory given by the `--dir DIRECTORY` switch. The directories will be named like
`Space_{SPACE_ID}_{SPACE_NAME}` and the metadata for each space will be stored in a
file with the name `Space_{SPACE_ID}_{SPACE_NAME}.json` within its corresponding directory.

The JSON information for the Looks and Dashboards in a space are usually part of the space
json data. When using the export command, this information would be redundant and so it is not
included in the `Space_{SPACE_ID}_{SPACE_NAME}.json` file.

Looks and Dashboards will be located in the space directories in files named like
`Look_{LOOK_ID}_{LOOK_TITLE}.json` and `Dashboard_{DASHBOARD_ID}_{DASHBOARD_TITLE}.json`.

```
$ gzr space export 758 --host foo.bar.mycompany.com --dir .
```

One interesting use of exporting a space into a directory tree is that it can be placed under version control
using a tool like git. In that way user defined content changes can be tracked over time, and older versions
of content can be restored if desired.

Alternately, the space can be exported into a `tar` style archive file with the switch `--tar FILENAME`.

```
$ gzr space export 758 --host foo.bar.mycompany.com --tar export.tar
```

That tar file can also be automatically compressed with `gzip` compression by using the switch
`--tgz FILENAME`.

```
$ gzr space export 758 --host foo.bar.mycompany.com --tgz export.tar.gz
```

#### space rm

The `space rm SPACE_ID` command is used to delete a space. If the space is not empty
this command will refuse to perform the delete. By adding the `--force` switch the command
will also delete the subspaces, looks, and dashboards contained in the space.

```
$ gzr space rm 758 --host foo.bar.mycompany.com --force
```

#### space create

The `space create NAME PARENT_SPACE_ID` command is used to create a new subspace.

```
$ gzr space create "My New Space" 758 --host foo.bar.mycompany.com
```

### Look Information

The command `gzr look help` will show details about subcommands of the look command.

#### look cat

The `look cat` command is used to output the json that describes the look.

```
$ gzr look cat 758 --host foo.bar.mycompany.com
JSON data for look
```

The output document can be very long. Usually one will use the switch `--dir DIRECTORY` to
save to a file. The file will be named `Look_{LOOK_ID}_{LOOK_TITLE}.json`.

#### look rm

The `look rm LOOK_ID` command is used to delete a look.

```
$ gzr look rm 758 --host foo.bar.mycompany.com
```

#### look import

The `look import LOOK_FILE SPACE_ID` command is used to import a look from a file. If a look by the same
name exists in that space then the `--force` switch must be used.

Gazer will attempt to update the existing look of the same name, rather than create a new look. In
that way the look id, schedules, permissions, etc. will be preserved.

```
$ gzr look import Path/To/Look_123_My\ Look.json 123 --host foo.bar.mycompany.com --force
```

### Dashboard Information

The command `gzr dashboard help` will show details about subcommands of the dashboard command.

#### dashboard cat

The `dashboard cat` command is used to output the json that describes the dashboard.

```
$ gzr dashboard cat 192 --host foo.bar.mycompany.com
JSON data for dashboard
```

The output document can be very long. Usually one will use the switch `--dir DIRECTORY` to
save to a file. The file will be named `Dashboard_{DASHBOARD_ID}_{DASHBOARD_TITLE}.json`.

#### dashboard rm

The `dashboard rm DASHBOARD_ID` command is used to delete a dashboard.

```
$ gzr dashboard rm 192 --host foo.bar.mycompany.com
```

#### dashboard import

The `dashboard import DASHBAORD_FILE SPACE_ID` command is used to import a dashboard and
its associated looks from a file. If a dashbaord or look by the same
name exists in that space then the `--force` switch must be used.

Gazer will attempt to update the existing dashboard or look of the same name, rather than 
create a new dashboard or look. In
that way the id, schedules, permissions, etc. will be preserved.

```
$ gzr dashboard import Path/To/Dashboard_123_My\ Dash.json 123 --host foo.bar.mycompany.com --force
```

### Connection Information

The command `gzr connection help` will show details about subcommands of the connection command.

#### connection ls

The command `gzr connection ls` will list the connections that have been defined in the Looker instance.

```
$ gzr connection ls --host foo.bar.mycompany.com
+-------------------------+---------------------+-----------------+----+--------------------------+-----------+
|name                     |dialect.name         |host             |port|database                  |schema     |
+-------------------------+---------------------+-----------------+----+--------------------------+-----------+
|thelook                  |mysql                |db1.mycompany.com|3306|demo_db                   |           |
|faa                      |mysql                |db1.mycompany.com|3306|flightstats               |           |
|video_store              |mysql                |db1.mycompany.com|3306|sakila                    |           |
|looker                   |mysql                |                 |    |                          |           |
+-------------------------+---------------------+-----------------+----+--------------------------+-----------+
```

#### connection dialect

The command `gzr connection dialect` will list the dialects that have been defined in the Looker instance.

```
$ gzr connection dialect --host foo.bar.mycompany.com
+---------------------+----------------------------------+
|name                 |label                             |
+---------------------+----------------------------------+
|mysql                |MySQL                             |
|amazonaurora         |Amazon Aurora                     |
|googlecloudsql       |Google Cloud SQL                  |
|memsql               |MemSQL                            |
|mariadb              |MariaDB                           |
|clustrix             |Clustrix                          |
|postgres             |PostgreSQL                        |
|google_cloud_postgres|Google Cloud PostgreSQL           |
|azure_postgres       |Azure PostgreSQL                  |
|presto               |PrestoDB                          |
|athena               |Amazon Athena                     |
|qubole_presto        |Qubole Presto v0.157+             |
|qubole_presto_v142   |Qubole Presto v0.142              |
|xtremedata           |XtremeData                        |
|redshift             |Amazon Redshift                   |
|snowflake            |Snowflake                         |
|greenplum            |Greenplum                         |
|mssql_2008           |Microsoft SQL Server 2008+        |
|msazuresql           |Microsoft Azure SQL Database      |
|mssql                |Microsoft SQL Server 2005         |
|mssqldw              |Microsoft Azure SQL Data Warehouse|
|aster                |Aster Data                        |
|vertica              |Vertica 7.1+                      |
|vertica_v5           |Vertica 6                         |
|bigquery             |Google BigQuery Legacy SQL        |
|bigquery_standard_sql|Google BigQuery Standard SQL      |
|spanner              |Google Cloud Spanner              |
|db2                  |IBM DB2                           |
|datavirtuality       |DataVirtuality                    |
|dashdb               |IBM DashDB                        |
|hana                 |SAP HANA                          |
|oracle               |Oracle                            |
|oracle_dwcs          |Oracle ADWC                       |
|hive2                |Apache Hive2                      |
|impala               |Cloudera Impala                   |
|spark1_5             |Apache Spark 1.5+                 |
|spark2_0             |Apache Spark 2.0                  |
|teradata             |Teradata                          |
|exasol               |Exasol                            |
|denodo               |Denodo                            |
|druid                |Druid                             |
|netezza              |IBM Netezza                       |
|dremio               |Dremio                            |
+---------------------+----------------------------------+
```

### Model Information

The command `gzr model help` will show details about subcommands of the model command.

#### model ls

The command `gzr model ls` will list the models that have been defined in the Looker instance.

```
$ gzr model ls --host foo.bar.mycompany.com
+---------------------------------------------+---------------------------------------------+-------------------------+
|name                                         |label                                        |project_name             |
+---------------------------------------------+---------------------------------------------+-------------------------+
|faa                                          |Faa                                          |faa                      |
|300_daily_active_users                       |300 Daily Active Users                       |lookml_design_patterns   |
|001_hello_world                              |001 Hello World                              |lookml_design_patterns   |
|video_store                                  |Video Store                                  |video_store              |
|looker                                       |Looker                                       |i__looker_dev            |
|faa_redshift                                 |Faa Redshift                                 |faa_redshift             |
+---------------------------------------------+---------------------------------------------+-------------------------+
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/deangelo-llooker/gzr. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Gazer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/deangelo-llooker/gzr/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2018 Mike DeAngelo for Looker Data Sciences. See [MIT License](LICENSE.txt) for further details.
