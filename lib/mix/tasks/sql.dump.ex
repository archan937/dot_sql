defmodule Mix.Tasks.Sql.Dump do
  use Mix.Task

  def run(args) do
    "../../../mix_sql/priv/dot_sql"
    |> Path.expand(__DIR__)
    |> List.wrap()
    |> Kernel.++(["dump"])
    |> Kernel.++(args)
    |> Enum.join(" ")
    |> String.to_charlist()
    |> :os.cmd()
  end
end
