defmodule DotSql.CLI do
  alias __MODULE__.{Dump, Load}

  def main([command | args]) do
    case command do
      "dump" -> Dump.run(args)
      "load" -> Load.run(args)
    end
  end
end
