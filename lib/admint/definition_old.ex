defmodule Admint.DefinitionOld do
  @admint_context_stack :__admint_context_stack__
  @admint_definition :__admint_definition_data__

  defmacro __using__(_opts) do
    caller = __CALLER__.module

    quote do
      import Admint.DefinitionOld
      unquote(set_admint_context_stack([], caller))
    end
  end

  @doc """
  Defines an admint configuration 

  An admin have two parts:
    header - ( optional ) define global configuratyoins for the admin
    navigation - define the navigation with all the pages inside the admin

  Example:

    admin do
      navigation do
        page :posts, schema: MyApp.Post
      end
    end
  """
  defmacro admin(_opts \\ [], do: block) do
    caller = __CALLER__.module
    {file, line} = get_stacktrace(__CALLER__)

    quote do
      unquote(
        check_stack_path(
          [[]],
          "\"admin\" can only be declared as root element",
          file,
          line,
          caller
        )
      )

      unquote(set_admint_definition(caller))
      unquote(push_admint_context_stack(:admin, caller))
      unquote(block)
      unquote(pop_admint_context_stack(caller))
      unquote(cleanup_admint_context_stack(caller))

      def __admint_definition__() do
        @__admint_definition_data__
      end
    end
  end

  @doc """
  Navigation defines all the pages inside admin. Pages can be in root or inside a category

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
  defmacro navigation(_opts \\ [], do: block) do
    caller = __CALLER__.module
    {file, line} = get_stacktrace(__CALLER__)

    quote do
      unquote(
        check_stack_path(
          [[:admin]],
          "\"navigation\" can only be declared as direct child of \"admin\"",
          file,
          line,
          caller
        )
      )

      unquote(push_admint_context_stack(:navigation, caller))
      unquote(block)
      unquote(pop_admint_context_stack(caller))
    end
  end

  defmacro category(title, opts \\ [], do: block) do
    caller = __CALLER__.module
    {file, line} = get_stacktrace(__CALLER__)
    id = ("C" <> UUID.uuid4(:hex)) |> String.to_atom()

    quote do
      unquote(
        check_stack_path(
          [[:navigation, :admin]],
          "\"category\" can only be declared as direct child of \"navigation\"",
          file,
          line,
          caller
        )
      )

      unquote(
        check_unique_ids(
          caller,
          id,
          "ids must be unique, \"#{id}\" was already defined",
          file,
          line,
          caller
        )
      )

      unquote(push_admint_context_stack({:category, id}, caller))

      path = unquote(get_admint_context_stack(caller))

      map_opts = Enum.into(unquote(opts), %{}) |> Map.merge(%{title: unquote(title)})
      data = %{type: :category, id: unquote(id), opts: map_opts, entries: []}

      unquote(
        update_admint_definition(
          quote do
            path
          end,
          quote do
            data
          end,
          caller
        )
      )

      unquote(block)
      unquote(pop_admint_context_stack(caller))
    end
  end

  defmacro page(id, opts \\ []) do
    check_valid_schema(__CALLER__, opts)
    caller = __CALLER__.module
    {file, line} = get_stacktrace(__CALLER__)

    quote do
      unquote(
        check_stack_path(
          [[:navigation, :admin], [:category, :navigation, :admin]],
          "\"page\" can only be declared as direct child of \"navigation\" or \"category\"",
          file,
          line,
          caller
        )
      )

      unquote(
        check_unique_ids(
          caller,
          id,
          "ids must be unique, \"#{id}\" was already defined",
          file,
          line,
          caller
        )
      )

      path = [{:page, unquote(id)} | unquote(get_admint_context_stack(caller))]

      map_opts = Enum.into(unquote(opts), %{})
      data = %{type: :page, id: unquote(id), opts: map_opts}

      unquote(
        update_admint_definition(
          quote do
            path
          end,
          quote do
            data
          end,
          caller
        )
      )
    end
  end

  # ---- Private methods
  defp expand_all(macro) do
    macro |> Macro.prewalk(&Macro.expand(&1, __ENV__))
  end

  defp set_admint_context_stack(value \\ [], caller) do
    quote do
      Module.put_attribute(unquote(caller), unquote(@admint_context_stack), unquote(value))
    end
    |> expand_all()
  end

  defp get_admint_context_stack(caller) do
    quote do
      Module.get_attribute(unquote(caller), unquote(@admint_context_stack))
    end
    |> expand_all()
  end

  defp check_unique_ids(caller, id, message, file, line, caller) do
    quote do
      def = Module.get_attribute(unquote(caller), unquote(@admint_definition))

      exists? =
        def.navigation.entries
        |> Enum.flat_map(fn entry ->
          case entry do
            {id, %{type: :page}} ->
              [id]

            {id, %{type: category, entries: entries}} ->
              [id] ++
                Enum.map(entries, fn {id, _} -> id end)
          end
        end)
        |> Enum.find_value(&(&1 == unquote(id)))

      if exists? do
        unquote(raise_compiler_error(message, file, line))
      end
    end
    |> expand_all()
  end

  defp push_admint_context_stack(value, caller) do
    quote do
      stack = unquote(get_admint_context_stack(caller))
      new_stack = [unquote(value) | stack]

      unquote(
        set_admint_context_stack(
          quote do
            new_stack
          end,
          caller
        )
      )
    end
    |> expand_all()
  end

  defp pop_admint_context_stack(caller) do
    quote do
      stack = unquote(get_admint_context_stack(caller))

      with [last | rest] <- stack do
        unquote(
          set_admint_context_stack(
            quote do
              rest
            end,
            caller
          )
        )

        last
      else
        _ -> nil
      end
    end
    |> expand_all()
  end

  defp cleanup_admint_context_stack(caller) do
    quote do
      Module.delete_attribute(unquote(caller), unquote(@admint_context_stack))
    end
    |> expand_all()
  end

  defp check_stack_path(paths, message, file, line, caller) do
    quote do
      stack = unquote(get_admint_context_stack(caller))

      if stack == nil do
        unquote(
          raise_compiler_error(
            "admin  was already defined, all configurations must be defined inside \"admin\"",
            file,
            line
          )
        )
      end

      stack_path =
        stack
        |> Enum.map(fn entry ->
          with {id, _} <- entry do
            id
          else
            _ -> entry
          end
        end)

      valid = unquote(paths) |> Enum.reduce(false, fn path, acc -> acc || path == stack_path end)

      if not valid do
        unquote(raise_compiler_error(message, file, line))
      end
    end
    |> expand_all()
  end

  defp get_stacktrace(caller) do
    [{_, _, _, [file: file, line: line]}] = Macro.Env.stacktrace(caller)
    {file, line}
  end

  defp raise_compiler_error(message, file, line) do
    quote do
      raise CompileError, file: unquote(file), line: unquote(line), description: unquote(message)
    end
    |> expand_all()
  end

  defp check_valid_schema(caller, opts) do
    schema = Keyword.get(opts, :schema)

    with {_, _, _module} <- schema do
      true
    else
      nil ->
        true

      _ ->
        [{_, _, _, [file: file, line: line]}] = Macro.Env.stacktrace(caller)

        raise CompileError,
          file: file,
          line: line,
          description: "Expected module with Ecto schema but got #{inspect(schema)}"
    end
  end

  defp set_admint_definition(caller, value \\ nil) do
    quote do
      value =
        case unquote(value) do
          nil ->
            %{
              header: %{},
              navigation: %{entries: []}
            }

          _ ->
            unquote(value)
        end

      Module.register_attribute(unquote(caller), unquote(@admint_definition), persist: true)
      Module.put_attribute(unquote(caller), unquote(@admint_definition), value)
    end
    |> expand_all()
  end

  defp definition_path_from_stack(path) do
    quote do
      unquote(path)
      |> Enum.reverse()
      |> Enum.flat_map(fn value ->
        case value do
          :admin ->
            []

          :navigation ->
            [:navigation]

          {:category, id} ->
            [:entries, id]

          {:page, id} ->
            [:entries, id]

          _ ->
            [value]
        end
      end)
    end
    |> expand_all()
  end

  defp update_admint_definition(path, value, caller) do
    quote do
      path = unquote(definition_path_from_stack(path))

      definition =
        Module.get_attribute(unquote(caller), unquote(@admint_definition))
        |> put_in(path, unquote(value))

      Module.put_attribute(unquote(caller), unquote(@admint_definition), definition)
    end
    |> expand_all()
  end
end
