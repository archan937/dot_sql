defmodule DotSql.CLI.Dump do
  @options [
    aliases: [
      u: :user,
      f: :from,
      t: :to
    ],
    switches: [
      user: :string,
      from: :string,
      to: :string
    ]
  ]

  def run(args) do
    case OptionParser.parse(args, @options) do
      {[], names, []} ->
        DotSql.dump(names)

      {config, [name], []} ->
        DotSql.Config.merge(config, name)
        DotSql.dump(name)

      {_, _, invalid} ->
        invalid
        |> Keyword.keys()
        |> OptionParser.parse_head!(@options)
    end
  end
end
