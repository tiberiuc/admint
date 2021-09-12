defmodule Admint.Definition do
  @moduledoc """

  """
  import Admint.Definition.Helpers

  @definitions %{
    admin: Admint.Definition.Admin,
    header: Admint.Definition.Header,
    error_page: Admint.Definition.ErrorPage,
    navigation: Admint.Definition.Navigation,
    category: Admint.Definition.Category,
    page: Admint.Definition.Page
  }

  defmacro __using__(_config) do
    definitions = @definitions

    imports =
      for defs <- Map.values(definitions) do
        quote do
          import unquote(defs)
        end
      end

    quote do
      unquote(imports)

      Module.register_attribute(__MODULE__, :__admint__, accumulate: true)

      Module.put_attribute(
        __MODULE__,
        :__admint_imports__,
        quote do
          definitions
        end
      )

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    compiled = Module.get_attribute(env.module, :__admint__)

    compiled =
      @definitions
      |> Map.values()
      |> Enum.reduce(compiled, fn defs, acc -> apply(defs, :__ensure_defined, [acc]) end)
      |> compile_definition()
      |> Map.put(:imports, Module.get_attribute(env.module, :__admint_imports__))

    Module.put_attribute(env.module, :__admint_definition__, compiled)
    Module.delete_attribute(env.module, :__admint_imports__)
    Module.delete_attribute(env.module, :__admint__)

    quote do
      def __admint_definition__() do
        @__admint_definition__
      end
    end
  end

  @spec create_empty_definition() :: map()
  defp create_empty_definition() do
    @definitions
    |> Map.values()
    |> Enum.reduce(%{}, fn defs, acc -> apply(defs, :__empty_definition, [acc]) end)
  end

  @spec compile_definition(list) :: map()
  defp compile_definition(definition) do
    compiled = create_empty_definition()

    definition =
      definition
      |> Enum.reverse()
      |> Enum.zip(0..(Enum.count(definition) - 1))

    definition
    |> Enum.reduce(compiled, fn {entry, index}, acc ->
      path = get_definition_path(definition, index)
      compile_entry(entry.type, definition, path, entry, index, acc)
    end)
  end

  defp compile_entry(type, definition, path, entry, index, acc) do
    type_def = type |> Atom.to_string() |> String.trim_leading("end_") |> String.to_atom()

    type_def = Map.get(@definitions, type_def)

    case type_def do
      nil ->
        raise_compiler_error("Unexpected #{inspect(entry)}", entry.__stacktrace__)

      _ ->
        apply(type_def, :__compile_entry, [type, definition, path, entry, index, acc])
    end
  end
end
