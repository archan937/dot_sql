defmodule DotSql do
  alias __MODULE__.Config

  @moduledoc """
  Provides convenience functions for dumping and loading SQL data.
  """

  @doc """
  Dump SQL data into a SQL file.
  """
  def dump(names, opts \\ [])
  def dump([], opts), do: Config.all() |> dump(opts)

  def dump(names, opts) when is_list(names), do: Enum.each(names, &dump(&1, opts))

  def dump(name, opts) do
    case get_config(name) do
      nil -> nil
      config -> mysql_dump(config, opts)
    end
  end

  @doc """
  Load SQL dump file into MySQL.
  """
  def load(names, opts \\ [])
  def load([], opts), do: Config.all() |> load(opts)

  def load(names, opts) when is_list(names) do
    Enum.each(names, fn name -> load(name, opts) end)
  end

  def load(name, opts) do
    case get_config(name) do
      nil -> nil
      config -> mysql_load(config, opts)
    end
  end

  defp get_config(name) do
    case Config.get(name) do
      nil ->
        nil

      config ->
        Map.merge(
          %{
            "host" => "127.0.0.1",
            "user" => "root",
            "ignore" => [],
            "tables" => %{"" => nil},
            "file" => Path.join(Config.dir(), "#{name}.sql"),
            "from" => name,
            "to" => name
          },
          config
        )
    end
  end

  defp mysql_dump(config, opts) do
    ensure_dir!(opts)

    ignore =
      config["ignore"]
      |> Enum.map(fn ignored ->
        "--ignore-table=#{config["database"]}.#{ignored}"
      end)
      |> Enum.join(" ")

    Enum.reduce(config["tables"], 0, fn {table, where}, passes ->
      where =
        case where do
          nil -> nil
          where -> "--where=#{inspect(where)}"
        end

      redirect = if passes == 0, do: ">", else: ">>"
      postfix = if to_string(table) == "", do: "", else: ".#{table}"

      puts("Dumping #{config["from"]}#{postfix} ...", opts)

      exec("mysqldump", [
        "-u",
        config["user"],
        "-h",
        config["host"],
        "--compact --order-by-primary",
        ignore,
        where,
        config["from"],
        table,
        "|",
        sanitize(),
        redirect,
        config["file"]
      ])

      passes + 1
    end)

    puts("Done.", opts)
  end

  defp mysql_load(config, opts) do
    puts("Checking for #{config["to"]} database ...", opts)

    database_exists =
      exec("mysql", [
        "-u",
        config["user"],
        "-h",
        config["host"],
        "-e",
        inspect("SHOW DATABASES LIKE '#{config["to"]}'")
      ]) != []

    if database_exists do
      if Keyword.get(opts, :force) do
        puts("Dropping #{config["to"]} ...", opts)

        exec("mysql", [
          "-u",
          config["user"],
          "-h",
          config["host"],
          "-e",
          inspect("DROP DATABASE #{config["to"]}")
        ])

        do_mysql_load(config, opts)
      end
    else
      do_mysql_load(config, opts)
    end

    puts("Done.", opts)
  end

  defp do_mysql_load(config, opts) do
    puts("Creating #{config["to"]} database ...", opts)

    exec("mysql", [
      "-u",
      config["user"],
      "-h",
      config["host"],
      "-e",
      inspect("CREATE DATABASE #{config["to"]} CHARACTER SET utf8 COLLATE utf8_general_ci")
    ])

    puts("Loading #{config["file"]} ...", opts)

    exec("mysql", [
      "-u",
      config["user"],
      "-h",
      config["host"],
      config["to"],
      "<",
      config["file"]
    ])
  end

  defp ensure_dir!(opts) do
    dir = Config.dir()
    puts("Checking for #{dir} directory ...", opts)

    unless File.exists?(dir) do
      puts("Creating #{dir} ...", opts)
      File.mkdir_p!(dir)
    end
  end

  defp sanitize do
    [
      "sed '/\\/\\*!.*/d'",
      "sed '/CREATE TABLE/{N;s/^/\\n/}'",
      "sed '/INSERT INTO/{N;s/^/\\n/}'",
      "sed 's$VALUES ($VALUES\\n($g'",
      "sed 's$),($),\\n($g'"
    ]
    |> Enum.join(" | ")
  end

  defp exec(command, args) do
    args =
      args
      |> Enum.reject(fn arg ->
        to_string(arg) == ""
      end)

    command
    |> List.wrap()
    |> Kernel.++(args)
    |> Enum.join(" ")
    |> String.to_charlist()
    |> :os.cmd()
  end

  defp puts(message, opts) do
    if Keyword.get(opts, :verbose) do
      IO.puts(message)
    end
  end
end
