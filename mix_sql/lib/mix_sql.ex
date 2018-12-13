defmodule MixSql do
  @name Path.rootname(Mix.Local.name_for(:archive, Mix.Project.config()), ".ez")

  def run(command, args), do: dot_sql(command, args)

  defp dot_sql(command, args) do
    dot_sql =
      [
        Mix.Local.path_for(:archive),
        @name,
        @name,
        "priv",
        "dot_sql"
      ]
      |> Path.join()

    System.cmd("chmod", ["+x", dot_sql])
    System.cmd(dot_sql, [command] ++ args, into: IO.stream(:stdio, :line))
  end
end
