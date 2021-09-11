defmodule Admint.Definition.Category do
  import Admint.Definition.Helpers

  defmacro category(title, config \\ [], do_block)

  defmacro category(title, config, do: block) when is_binary(title) do
    stacktrace = get_stacktrace(__CALLER__)
    # replace with uuid's
    id = ("C" <> UUID.uuid4(:hex)) |> String.to_atom()
    config = config |> Keyword.put(:title, title)

    quote do
      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :category,
        id: unquote(id),
        config: unquote(config),
        __stacktrace__: unquote(stacktrace)
      })

      unquote(block)

      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :end_category,
        id: unquote(id),
        config: unquote(config),
        __stacktrace__: unquote(stacktrace)
      })
    end
  end

  defmacro category(title, _config, do: _block) do
    stacktrace = get_stacktrace(__CALLER__)

    raise_compiler_error(
      """
      Category should have a title as string, got #{inspect(title)}

          Example:
            
            category "Category Title" do
              ...
            end
      """,
      stacktrace
    )
  end

  @doc false
  def __compile_entry(:category, _definition, path, entry, _index, acc) do
    validate_paths(
      path,
      [[:navigation, :admin]],
      """
      Category can only be declared only inside navigation

        Example:

          admin
            navigation
              category "Category Title" do
                page :second_page
              end

            end
          end
      """,
      entry.__stacktrace__
    )

    entry = sanitize_entry(entry)

    category_id = entry.id

    %{
      acc
      | navigation: %{
          acc.navigation
          | entries: acc.navigation.entries ++ [{:category, category_id, []}]
        },
        categories: Map.put(acc.categories, category_id, struct(Admint.Category, entry))
    }
  end

  @doc false
  def __compile_entry(:end_category, _definition, _path, _entry, _index, acc), do: acc

  @doc false
  @spec __ensure_defined(map()) :: map()
  def __ensure_defined(definition), do: definition

  @doc false
  @spec __empty_definition(map()) :: map()
  def __empty_definition(definition), do: definition |> Map.merge(%{categories: %{}})
end
