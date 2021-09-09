defmodule Admint.Definition.Navigation do
  import Admint.Definition.Helpers

  @doc """
  Navigation defines all the pages inside admin. Pages can be in navigation or inside a category

  Example:
    
    admin do
      navigation do
        page :dashboard, render: MyApp.Dashboard
        category "Blog"" do
          page :post, schema: MyApp.Post
          page :comments, schema: MyAp.comments
        end
        page :mycustompage, title: "Custom Page",  render MyAppWeb.CustomPage 
      end
    end
  """
  defmacro navigation(config \\ [], do: block) do
    stacktrace = get_stacktrace(__CALLER__)

    quote do
      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :navigation,
        __stacktrace__: unquote(stacktrace),
        config: unquote(config)
      })

      unquote(block)

      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :end_navigation,
        __stacktrace__: unquote(stacktrace)
      })
    end
  end

  @spec ensure_defined(map()) :: map()
  def ensure_defined(definition) do
    found =
      definition
      |> Enum.map(fn entry -> entry.node end)
      |> Enum.member?(:navigation)

    if !found do
      [admin | rest] =
        definition
        |> Enum.reverse()

      ([admin] ++
         [
           %{__stacktrace__: admin.__stacktrace__, node: :navigation, config: []},
           %{__stacktrace__: admin.__stacktrace__, node: :end_navigation}
         ] ++ rest)
      |> Enum.reverse()
    else
      definition
    end
  end

  @spec empty_definition(map()) :: map()
  def empty_definition(definition) do
    definition
    |> Map.merge(%{
      navigation: %Admint.Navigation{
        __stacktrace__: empty_stacktrace(),
        entries: [],
        config: %{module: nil}
      }
    })
  end

  def compile_entry(:navigation, definition, path, entry, index, acc) do
    validate_paths(
      path,
      [[:admin]],
      """
      Navigation must be declared only inside admin",

        Example:

          admin
            navigation do
              page :first_page
              
              category "Category Title" do
                page :second_page
              end

            end
          end
      """,
      entry.__stacktrace__
    )

    validate_once(definition, entry, index)

    entry = sanitize_entry(entry)

    config =
      set_default_config(entry.config, [
        {:module, get_default_module(acc, :navigation)}
      ])

    config = run_config_processing(config, entry)

    %{
      acc
      | navigation: %{acc.navigation | __stacktrace__: entry.__stacktrace__, config: config}
    }
  end

  def compile_entry(:end_navigation, _definition, _path, _entry, _index, acc), do: acc
end
