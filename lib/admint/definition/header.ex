defmodule Admint.Definition.Header do
  import Admint.Definition.Helpers

  defmacro header(config \\ []) do
    stacktrace = get_stacktrace(__CALLER__)

    quote do
      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :header,
        __stacktrace__: unquote(stacktrace),
        config: unquote(config)
      })
    end
  end

  @spec ensure_defined(map()) :: map()
  def ensure_defined(definition) do
    found =
      definition
      |> Enum.map(fn entry -> entry.node end)
      |> Enum.member?(:header)

    if !found do
      [admin | rest] = definition |> Enum.reverse()

      ([admin] ++ [%{__stacktrace__: admin.__stacktrace__, node: :header, config: []}] ++ rest)
      |> Enum.reverse()
    else
      definition
    end
  end

  @spec empty_definition(map()) :: map()
  def empty_definition(definition) do
    definition
    |> Map.merge(%{
      header: %Admint.Header{
        __stacktrace__: empty_stacktrace(),
        config: %{module: nil}
      }
    })
  end

  def compile_entry(:header, definition, path, entry, index, acc) do
    validate_paths(
      path,
      [[:admin]],
      """
      Header must be declared only inside admin

        Example:

          admin
            header render: MyAppWeb.HeaderLive
          end
      """,
      entry.__stacktrace__
    )

    validate_once(definition, entry, index)

    entry = sanitize_entry(entry)

    config = set_default_config(entry.config, [{:module, get_default_module(acc, :header)}])

    config = run_config_processing(config, entry)

    %{acc | header: %{acc.header | __stacktrace__: entry.__stacktrace__, config: config}}
  end
end