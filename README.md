# Looker Content Utility

The Looker Content Utility can be used to navigate and manges Spaces, Looks, 
and Dashboards via a simple command line tool.

## Installation

Once this gem is released to rubygems, you can install this gem by simply typing:

    $ gem install lkr

Prior to that release, you can follow the Development setup below, typing `bundle exec rake install` to install it
locally

## Usage

Display help information...

    $ lkr help

### Storing Credentials
Store login information by creating the file `~/.netrc` in your home directory with the api3 credentials

```
machine foo.bar.mycompany.com
  login AbCdEfGhIjKlMnOp
  password QrStUvWxYz1234567890
```

Make sure that the `~/.netrc` file has restricted permissions by running `chmod 600 ~/.netrc`.

### User Information

The command `lkr user help` will show details about subcommands of the user command.

#### user me

Display information about the current user with the command `lkr user me`.

```
$ lkr user me --host foo.bar.mycompany.com
+----+----------+---------+--------------------+
|  id|first_name|last_name|email               |
+----+----------+---------+--------------------+
|1234|John      |Smith    |jsmith@mycompany.com|
+----+----------+---------+--------------------+
```

#### user ls

Display information about all users with the command `lkr user ls`.

```
$ lkr user ls --host foo.bar.mycompany.com
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

#### --su option

The `--su` option can be used with a user id to run the command as another user. For example...

```
$ lkr user me --su 1237 --host foo.bar.mycompany.com
+----+----------+---------+---------------------+
|  id|first_name|last_name|email                |
+----+----------+---------+---------------------+
|1237|Susan     |Gibson   |sgibson@mycompany.com|
+----+----------+---------+---------------------+
````
#### Suppressing Formatted Output

The option `--plain` will suppress the table headers and format lines, making it easier to use tools
like grep, awk, etc. to retrieve values from the output of these commands.

### Space Information

The command `lkr space help` will show details about subcommands of the space command.

#### space ls

The command `lkr space ls` will list the contents of a space, including subspaces, looks, and dashboards.

Without any arguments, the command will list the contents of the user's "home" space.

```
$ lkr space ls --host foo.bar.mycompany.com
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
$ lkr space ls "~" --host foo.bar.mycompany.com
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
$ lkr space ls 103 --host foo.bar.mycompany.com
```

With a tilde plus a simple numeric argument the command will list the content of the personal space
of the given user id.

```
$ lkr space ls "~1237" --host foo.bar.mycompany.com
```

The user can be identified by name as well.

```
$ lkr space ls "~Susan Gibson" --host foo.bar.mycompany.com
```
Finally, the space can be searched by name.

```
$ lkr space ls "Marketing" --host foo.bar.mycompany.com
```

#### space tree

The command `lkr space tree` will display the child spaces, dashboards, and looks in a tree format.

```
$ lkr space tree "~" --host foo.bar.mycompany.com
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

#### space export

### Look Information

#### look cat

#### look rm

#### look import

### Dashboard Information

#### dashboard cat

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lkr. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Lkr project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/looker/content_util/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2018 Mike DeAngelo for Looker Data Sciences. See [MIT License](LICENSE.txt) for further details.
