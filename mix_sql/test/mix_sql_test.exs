defmodule MixSqlTest do
  use ExUnit.Case
  doctest MixSql

  test "greets the world" do
    assert MixSql.hello() == :world
  end
end
