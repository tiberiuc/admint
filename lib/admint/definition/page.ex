defmodule Admint.Definition.Page do
  import Admint.Definition.Helpers

  defmacro page(id, config \\ [])

  defmacro page(id, config) when is_atom(id) do
    stacktrace = get_stacktrace(__CALLER__)

    quote do
      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :page,
        is_block: false,
        id: unquote(id),
        config: unquote(config),
        __stacktrace__: unquote(stacktrace)
      })
    end
  end

  defmacro page(id, _config) do
    stacktrace = get_stacktrace(__CALLER__)

    raise_compiler_error(
      """
      Page id must be an atom, got #{inspect(id)}

          Example:
            
            page :page_id
      """,
      stacktrace
    )
  end

  @doc false
  def __compile_entry(:page, definition, path, entry, index, acc) do
    validate_paths(
      path,
      [[:navigation, :admin], [:category, :navigation, :admin]],
      """
      Page can only be declared inside navigation or category

        Example:

          admin
            navigation
              page :first_page

              category "Category Title" do
                page :second_page
              end

            end
          end
      """,
      entry.__stacktrace__
    )

    validate_unique_id(definition, index)

    page_id = entry.id

    entry = sanitize_entry(entry)

    config =
      set_default_config(entry.config, [
        {:module, get_default_module(acc, :page)},
        {:id, page_id}
      ])

    config = run_config_processing(config, entry)

    with_pages = %{
      acc
      | pages:
          Map.put(acc.pages, page_id, %Admint.Page{
            __stacktrace__: entry.__stacktrace__,
            config: config
          })
    }

    [last_path | _] = path

    case last_path do
      :category ->
        # get last category
        {%{id: category_id}, _} =
          definition
          |> Enum.take(index)
          |> Enum.reverse()
          |> Enum.find(fn {entry, _} -> entry.node == :category end)

        navigation = %{
          with_pages.navigation
          | entries:
              with_pages.navigation.entries
              |> Enum.map(fn entry ->
                with {:category, id, pages} <- entry do
                  if id == category_id do
                    {:category, category_id, pages ++ [{:page, page_id}]}
                  else
                    entry
                  end
                else
                  _ -> entry
                end
              end)
        }

        %{with_pages | navigation: navigation}

      _ ->
        %{
          with_pages
          | navigation: %{
              with_pages.navigation
              | entries: with_pages.navigation.entries ++ [{:page, page_id}]
            }
        }
    end
  end

  @doc false
  @spec __ensure_defined(map()) :: map()
  def __ensure_defined(definition), do: definition

  @doc false
  @spec __empty_definition(map()) :: map()
  def __empty_definition(definition), do: definition |> Map.merge(%{pages: %{}})
end
