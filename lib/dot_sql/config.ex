defmodule DotSql.Config do
  @moduledoc """
  Writes and reads MixSql configuration files.
  """

  @config ".sql"
  @dir "dump_files"

  @default %{
    @dir => "sql"
  }

  def dir(), do: get(@dir)
  def dir(file), do: Path.join(dir(), file)
  def dir!(dir), do: put(@dir, dir)

  def all do
    read()
    |> Map.keys()
    |> Kernel.--([@dir])
  end

  def get(key, default \\ nil) do
    read() |> Map.get(key, default)
  end

  def put(key, value) do
    merge(%{key => value})
  end

  def merge(config, name \\ nil)

  def merge(config, name) when is_list(config) do
    config
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      Map.put(acc, to_string(key), value)
    end)
    |> merge(name)
  end

  def merge(config, name) when is_binary(name) do
    config =
      name
      |> get(%{})
      |> Map.merge(config)

    put(name, config)
  end

  def merge(config, nil) do
    read() |> Map.merge(config) |> write()
  end

  defp read do
    case File.read(@config) do
      {:error, _} -> @default
      {:ok, json} -> Poison.decode!(json)
    end
  end

  defp write(config) when is_map(config) do
    config |> Poison.encode!(pretty: true) |> write()
  end

  defp write(config) do
    File.write(@config, config, [:binary])
  end
end
