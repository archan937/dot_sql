defmodule DotSql.CLI.Dump do
  @options [
    aliases: [
      v: :verbose,
      h: :host,
      u: :user,
      f: :from,
      t: :to
    ],
    switches: [
      verbose: :boolean,
      host: :string,
      user: :string,
      from: :string,
      to: :string
    ]
  ]

  def run(args) do
    case OptionParser.parse(args, @options) do
      {opts, [name], []} ->
        {config, opts} = extract_config(opts)
        DotSql.Config.merge(config, name)
        DotSql.dump(name, opts)

      {opts, names, []} ->
        {_config, opts} = extract_config(opts)
        DotSql.dump(names, opts)

      {_, _, invalid} ->
        invalid
        |> Keyword.keys()
        |> OptionParser.parse_head!(@options)
    end
  end

  def extract_config(opts) do
    {verbose, config} = Keyword.pop(opts, :verbose)
    {config, [verbose: !!verbose]}
  end
end
