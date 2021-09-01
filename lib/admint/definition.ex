defmodule Admint.Definition do
  @moduledoc """

  """

  defmacro __using__(_opts) do
    quote do
      import Admint.Definition

      Module.register_attribute(__MODULE__, :__admint__, accumulate: true)

      @before_compile unquote(__MODULE__)
    end
  end

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
  defmacro admin(do: block) do
    stacktrace = get_stacktrace(__CALLER__)

    quote do
      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :admin,
        __stacktrace__: unquote(stacktrace)
      })

      unquote(block)

      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :end_admin,
        __stacktrace__: unquote(stacktrace)
      })
    end
  end

  defmacro header(do: block) do
    stacktrace = get_stacktrace(__CALLER__)

    quote do
      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :header,
        __stacktrace__: unquote(stacktrace)
      })

      unquote(block)

      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :end_header,
        __stacktrace__: unquote(stacktrace)
      })
    end
  end

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
  defmacro navigation(do: block) do
    stacktrace = get_stacktrace(__CALLER__)

    quote do
      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :navigation,
        __stacktrace__: unquote(stacktrace)
      })

      unquote(block)

      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :end_navigation,
        __stacktrace__: unquote(stacktrace)
      })
    end
  end

  defmacro page(id, opts \\ [])

  defmacro page(id, opts) when is_atom(id) do
    stacktrace = get_stacktrace(__CALLER__)

    quote do
      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :page,
        id: unquote(id),
        opts: unquote(opts),
        __stacktrace__: unquote(stacktrace)
      })
    end
  end

  defmacro page(id, _opts) do
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

  defmacro category(title, opts \\ [], do_block)

  defmacro category(title, opts, do: block) when is_binary(title) do
    stacktrace = get_stacktrace(__CALLER__)
    # replace with uuid's
    id = ("C" <> UUID.uuid4(:hex)) |> String.to_atom()
    opts = opts |> Keyword.put(:title, title)

    quote do
      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :category,
        id: unquote(id),
        opts: unquote(opts),
        __stacktrace__: unquote(stacktrace)
      })

      unquote(block)

      Module.put_attribute(__MODULE__, :__admint__, %{
        node: :end_category,
        id: unquote(id),
        opts: unquote(opts),
        __stacktrace__: unquote(stacktrace)
      })
    end
  end

  defmacro category(title, _opts, do: _block) do
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

  defmacro __before_compile__(env) do
    compiled =
      Module.get_attribute(env.module, :__admint__)
      |> compile_definition()

    Module.put_attribute(env.module, :__admint_definition__, compiled)
    Module.delete_attribute(env.module, :__admint__)

    quote do
      def __admint_definition__() do
        @__admint_definition__
      end
    end
  end

  # return a list with entry types
  # like [:admin, :navigation, :page, :end_navigation, :end_admin]
  defp sanitize_path(definition, index) do
    definition
    |> Enum.take(index)
    |> Enum.map(fn {%{node: type}, _} -> type end)
  end

  # return the tree path of element at position index in definition
  # like [:category, :navigation, :admin]
  defp get_definition_path(definition, index) do
    definition
    |> sanitize_path(index)
    |> Enum.filter(fn entry -> entry != :page end)
    |> Enum.reduce([], fn entry, acc ->
      cond do
        Atom.to_string(entry) |> String.starts_with?("end_") -> tl(acc)
        true -> [entry | acc]
      end
    end)
  end

  defp validate_paths(path, valid_paths, message, stacktrace) do
    if !Enum.member?(valid_paths, path) do
      raise_compiler_error(message, stacktrace)
    end
  end

  defp validate_once(definition, entry, index) do
    path = definition |> Enum.take(index)

    prev_declaration =
      path |> Enum.find(fn {current_entry, _} -> current_entry.node == entry.node end)

    if prev_declaration != nil do
      {prev_declaration, _} = prev_declaration
      {prev_file, prev_line} = prev_declaration.__stacktrace__

      raise_compiler_error(
        """
        #{Atom.to_string(entry.node) |> String.capitalize()} can be declared only once. Previous declaration was at #{
          prev_file
        }:#{prev_line}

        """,
        entry.__stacktrace__
      )
    end
  end

  defp validate_unique_id(definition, index) do
    {entry, _} = definition |> Enum.at(index)

    found =
      definition
      |> Enum.take(index - 1)
      |> Enum.find(fn {%{node: node} = current_entry, _} ->
        if entry.node == node, do: entry.id == current_entry.id, else: false
      end)

    if found do
      {%{__stacktrace__: {file, line}, id: id}, _} = found
      node = entry.node |> Atom.to_string() |> String.capitalize()

      raise_compiler_error(
        "#{node} with the same id ':#{id}' was already defined here: #{file} #{line}",
        entry.__stacktrace__
      )
    end
  end

  defp compile_definition(definition) do
    compiled = %{pages: %{}, categories: %{}, navigation: []}

    definition =
      definition
      |> Enum.reverse()
      |> Enum.zip(0..(Enum.count(definition) - 1))

    definition
    |> Enum.reduce(compiled, fn {entry, index}, acc ->
      path = get_definition_path(definition, index)
      compile_entry(entry.node, definition, path, entry, index, acc)
    end)
  end

  defp compile_entry(:admin, definition, path, entry, index, acc) do
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

    acc
  end

  defp compile_entry(:end_admin, _definition, _path, _entry, _index, acc), do: acc

  defp compile_entry(:navigation, definition, path, entry, index, acc) do
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

    acc
  end

  defp compile_entry(:end_navigation, _definition, _path, _entry, _index, acc), do: acc

  defp compile_entry(:header, definition, path, entry, index, acc) do
    validate_paths(
      path,
      [[:admin]],
      """
      Header must be declared only inside admin

        Example:

          admin
            header do
              ...
            end
          end
      """,
      entry.__stacktrace__
    )

    validate_once(definition, entry, index)

    acc
  end

  defp compile_entry(:end_header, _definition, _path, _entry, _index, acc), do: acc

  defp compile_entry(:category, _definition, path, entry, _index, acc) do
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
      | navigation: acc.navigation ++ [{:category, category_id, []}],
        categories: Map.put(acc.categories, category_id, entry)
    }
  end

  defp compile_entry(:end_category, _definition, _path, _entry, _index, acc), do: acc

  defp compile_entry(:page, definition, path, entry, index, acc) do
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

    entry = compile_page_opts(entry)

    with_pages = %{acc | pages: Map.put(acc.pages, page_id, entry)}

    [last_path | _] = path

    case last_path do
      :category ->
        # get last category
        {%{id: category_id}, _} =
          definition
          |> Enum.take(index)
          |> Enum.reverse()
          |> Enum.find(fn {entry, _} -> entry.node == :category end)

        navigation =
          with_pages.navigation
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

        %{with_pages | navigation: navigation}

      _ ->
        %{with_pages | navigation: acc.navigation ++ [{:page, page_id}]}
    end
  end

  defp compile_entry(_, _definition, _path, entry, _index, _acc) do
    raise_compiler_error("Unexpected #{inspect(entry)}", entry.__stacktrace__)
  end

  defp compile_page_opts(entry) do
    opts = entry.opts

    module = opts |> Map.get(:module, Admint.PageImpl)
    opts = opts |> Map.put(:module, module) |> Map.put(:id, entry.id)

    if !is_atom(module),
      do: raise_compiler_error("Expected a module in page #{entry.id}", entry.__stacktrace__)

    with {:error, message} <- Admint.Page.validate_opts(module, opts) do
      raise_compiler_error(message, entry.__stacktrace__)
    end

    opts =
      with {:ok, compiled_opts} <- Admint.Page.compile_opts(module, opts) do
        compiled_opts
      else
        {:error, message} -> raise_compiler_error(message, entry.__stacktrace__)
      end

    opts =
      opts
      |> Map.put(:title, Map.get(opts, :title, Admint.Utils.humanize(entry.id)))

    %{entry | opts: opts}
  end

  defp sanitize_entry(entry) do
    opts = entry.opts |> Keyword.keys()

    duplicates_opts = Enum.uniq(opts -- Enum.uniq(opts))

    if duplicates_opts != [] do
      raise_compiler_error(
        """
        In #{entry.node} following options are duplicate:

            #{
          duplicates_opts
          |> Enum.map(fn o -> ":#{Atom.to_string(o)}" end)
          |> Enum.intersperse(", ")
        }

        Please define them only once to avoid ambiquity
        """,
        entry.__stacktrace__
      )
    end

    opts =
      entry.opts
      |> Enum.into(%{})

    entry
    |> Map.delete(:node)
    |> Map.put(:opts, opts)
  end

  defp raise_compiler_error(message, {file, line}) do
    raise CompileError, file: file, line: line, description: message
  end

  defp get_stacktrace(caller) do
    [{_, _, _, [file: file, line: line]}] = Macro.Env.stacktrace(caller)
    {file, line}
  end
end
