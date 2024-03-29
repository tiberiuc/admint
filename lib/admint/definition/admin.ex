defmodule Admint.Definition.Admin do
  import Admint.Definition.Helpers

  @doc """
  Defines an admint configuration 

  Admin macro define the root for all the configurations of an Admint.
  It can be defined only once inside a module. Also you can have different modules 
  implementing different admin entries


  An admin have two parts:
    header - ( optional ) define global configuratyoins for the admin
    navigation - define the navigation with all the pages inside the admin

  ## Example

      defmodule MyAdmin do
        use Admint.Definition

        admin do

          navigation do
            page :posts, schema: MyApp.Post
          end

        end

      end
  """
  defmacro admin(config \\ [], do: block) do
    stacktrace = get_stacktrace(__CALLER__)

    quote do
      Module.put_attribute(__MODULE__, :__admint__, %{
        type: :admin,
        do_block: true,
        config: unquote(config),
        __stacktrace__: unquote(stacktrace)
      })

      unquote(block)

      Module.put_attribute(__MODULE__, :__admint__, %{
        type: :end_admin,
        __stacktrace__: unquote(stacktrace)
      })
    end
  end

  @doc false
  def __compile_entry(:admin, definition, path, entry, index, acc) do
    validate_paths(
      path,
      [[]],
      """
      Admin can only be declared as root level

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
    config = set_default_config(entry.config, [{:module, Admint.Layout}])

    config = run_config_processing(config, entry)

    %{acc | __stacktrace__: entry.__stacktrace__, config: config}
  end

  @doc false
  def __compile_entry(:end_admin, _definition, _path, _entry, _index, acc), do: acc

  @doc false
  @spec __ensure_defined(map()) :: map()
  def __ensure_defined(definition), do: definition

  @doc false
  @spec __empty_definition(map()) :: map()
  def __empty_definition(definition),
    do: definition |> Map.merge(%{__stacktrace__: empty_stacktrace(), config: %{module: nil}})
end
