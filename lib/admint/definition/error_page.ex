defmodule Admint.Definition.ErrorPage do
  import Admint.Definition.Helpers

  @doc false
  @spec __ensure_defined(map()) :: map()
  def __ensure_defined(definition) do
    found =
      definition
      |> Enum.map(fn entry -> entry.type end)
      |> Enum.member?(:error_page)

    if !found do
      [admin | rest] = definition |> Enum.reverse()

      ([admin] ++
         [%{__stacktrace__: admin.__stacktrace__, type: :error_page, do_block: false, config: []}] ++
         rest)
      |> Enum.reverse()
    else
      definition
    end
  end

  @doc false
  @spec __empty_definition(map()) :: map()
  def __empty_definition(definition) do
    definition
    |> Map.merge(%{
      error_page: %Admint.ErrorPage{
        config: %{module: nil},
        __stacktrace__: empty_stacktrace()
      }
    })
  end

  @doc false
  def __compile_entry(:error_page, definition, path, entry, index, acc) do
    validate_paths(
      path,
      [[:admin]],
      """
      Error page  must be declared only inside admin

        Example:

          admin
            error_page render: MyAppWeb.ErrorPageLive
          end
      """,
      entry.__stacktrace__
    )

    validate_once(definition, entry, index)

    entry = sanitize_entry(entry)

    config = set_default_config(entry.config, [{:module, get_default_module(acc, :error_page)}])

    config = run_config_processing(config, entry)

    %{acc | error_page: %{acc.error_page | __stacktrace__: entry.__stacktrace__, config: config}}
  end
end
