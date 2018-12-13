# DotSql

Provides global Mix tasks to (partially) dump and load Git-friendly MySQL data.

## Installation

### Install Mix tasks

To install the globally available Mix tasks, please execute the following:

```bash
mix archive.install https://raw.githubusercontent.com/archan937/dot_sql/master/mix_sql/mix_sql-0.1.0.ez
```

To use DotSql in your Elixir project, add DotSql to your dependencies:

```elixir
def deps do
  [
    {:dot_sql, "~> 0.1.0"}
  ]
end
```

## Usage

### Within the command line

```bash
mix sql.dump <name> -f <from database> -t <to database>
mix sql.dump
mix sql.dump <name1> <name2>
mix sql.load
mix sql.load <name1>
mix sql.load <name1> -f
```

### Within a project

```elixir
DotSql.dump([<name1>, <name2>])
DotSql.dump()
DotSql.load([<name1>])
DotSql.load()
DotSql.load([<name1>], force: true)
```

(TODO: add more details documentation)

## Configuration

DotSql uses a `.sql` configuration file to known what to do. An example:

```json
{
  "dump_files": "sql",
  "my_first_dot_sql_config": {
    "from": "my_database_to_dump_data_from",
    "to": "the_database_to_load_data_to",
    "tables": {
      "my_table_1": "id < 100",
      "my_table_2": null
    }
  },
  "my_second_dot_sql_config": {
    "user": "root",
    "from": "my_other_database",
    "to": "lorem_ipsum_db"
  }
}
```

(TODO: add more details documentation)

## License

Copyright (c) 2018 Paul Engel, released under the MIT License

http://github.com/archan937 – http://twitter.com/archan937 – pm_engel@icloud.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
