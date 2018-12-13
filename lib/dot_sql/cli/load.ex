defmodule DotSql.CLI.Load do
  @options [
    aliases: [
      f: :force
    ],
    switches: [
      force: :boolean
    ]
  ]

  def run(args) do
    case OptionParser.parse(args, @options) do
      {opts, names, []} ->
        DotSql.load(names, opts)

      {_, _, invalid} ->
        invalid
        |> Keyword.keys()
        |> OptionParser.parse_head!(@options)
    end
  end
end
