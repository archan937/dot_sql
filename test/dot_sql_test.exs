defmodule DotSqlTest do
  use ExUnit.Case
  doctest DotSql

  test "greets the world" do
    assert DotSql.hello() == :world
  end
end
