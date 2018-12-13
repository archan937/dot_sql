defmodule DotSql do
  alias __MODULE__.Config

  @moduledoc """
  Provides convenience functions for dumping and loading SQL data.
  """

  @doc """
  Dump SQL data into a SQL file.
  """
  def dump([]), do: Config.all() |> dump()
  def dump(names) when is_list(names), do: Enum.each(names, &dump/1)

  def dump(name) do
    case get_config(name) do
      nil -> nil
      config -> mysql_dump(config)
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

  defp mysql_dump(config) do
    ensure_dir!()

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

      exec("mysqldump", [
        "-u",
        config["user"],
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
  end

  defp mysql_load(config, opts) do
    database_exists =
      exec("mysql", [
        "-u",
        config["user"],
        "-e",
        inspect("SHOW DATABASES LIKE '#{config["to"]}'")
      ]) != []

    if database_exists do
      if Keyword.get(opts, :force) do
        exec("mysql", [
          "-u",
          config["user"],
          "-e",
          inspect("DROP DATABASE #{config["to"]}")
        ])

        mysql_load(config)
      end
    else
      mysql_load(config)
    end
  end

  defp mysql_load(config) do
    exec("mysql", [
      "-u",
      config["user"],
      "-e",
      inspect("CREATE DATABASE #{config["to"]} CHARACTER SET utf8 COLLATE utf8_general_ci")
    ])

    exec("mysql", [
      "-u",
      config["user"],
      config["to"],
      "<",
      config["file"]
    ])
  end

  defp ensure_dir!, do: Config.dir() |> File.mkdir_p!()

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
end
