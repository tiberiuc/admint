defmodule Admint.Definition.Helpers do
  def get_stacktrace(caller) do
    [{_, _, _, [file: file, line: line]}] = Macro.Env.stacktrace(caller)
    {file, line}
  end

  def validate_paths(path, valid_paths, message, stacktrace) do
    if !Enum.member?(valid_paths, path) do
      raise_compiler_error(message, stacktrace)
    end
  end

  def validate_once(definition, entry, index) do
    path = definition |> Enum.take(index)

    prev_declaration =
      path |> Enum.find(fn {current_entry, _} -> current_entry.type == entry.type end)

    if prev_declaration != nil do
      {prev_declaration, _} = prev_declaration
      {prev_file, prev_line} = prev_declaration.__stacktrace__

      raise_compiler_error(
        """
        #{Atom.to_string(entry.type) |> String.capitalize()} can be declared only once. Previous declaration was at #{prev_file}:#{prev_line}

        """,
        entry.__stacktrace__
      )
    end
  end

  def validate_unique_id(definition, index) do
    {entry, _} = definition |> Enum.at(index)

    found =
      definition
      |> Enum.take(index - 1)
      |> Enum.find(fn {%{type: type} = current_entry, _} ->
        if entry.type == type, do: entry.id == current_entry.id, else: false
      end)

    if found do
      {%{__stacktrace__: {file, line}, id: id}, _} = found
      type = entry.type |> Atom.to_string() |> String.capitalize()

      raise_compiler_error(
        "#{type} with the same id ':#{id}' was already defined here: #{file} #{line}",
        entry.__stacktrace__
      )
    end
  end

  @spec empty_stacktrace() :: Admint.Stacktrace.t()
  def empty_stacktrace(), do: {"", 0}

  def sanitize_entry(entry) do
    config = entry.config |> Keyword.keys()

    duplicates_config = Enum.uniq(config -- Enum.uniq(config))

    if duplicates_config != [] do
      raise_compiler_error(
        """
        In #{entry.type} following options are duplicate:

            #{duplicates_config |> Enum.map(fn o -> ":#{Atom.to_string(o)}" end) |> Enum.intersperse(", ")}

        Please define them only once to avoid ambiquity
        """,
        entry.__stacktrace__
      )
    end

    config =
      entry.config
      |> Enum.into(%{})

    entry
    |> Map.delete(:type)
    |> Map.delete(:do_block)
    |> Map.put(:config, config)
  end

  # return a list with entry types
  # like [:admin, :navigation, :page, :end_navigation, :end_admin]
  def sanitize_path(definition, index) do
    definition
    |> Enum.take(index)
    |> Enum.map(fn {%{type: type} = entry, _} -> [type, Map.get(entry, :do_block, false)] end)
  end

  # return the tree path of element at position index in definition
  # like [:category, :navigation, :admin]
  def get_definition_path(definition, index) do
    definition
    |> sanitize_path(index)
    |> Enum.filter(fn [type, do_block] ->
      do_block || type |> Atom.to_string() |> String.starts_with?("end_")
    end)
    |> Enum.map(fn [type, _do_block] -> type end)
    |> Enum.reduce([], fn entry, acc ->
      cond do
        Atom.to_string(entry) |> String.starts_with?("end_") -> tl(acc)
        true -> [entry | acc]
      end
    end)
  end

  @spec run_config_processing(map, map) :: map
  def run_config_processing(config, entry) do
    config =
      with :ok <- apply(config.module, :validate_config, [config]),
           {:ok, config} <- apply(config.module, :compile_config, [config]) do
        config
      else
        {:error, message} -> raise_compiler_error(message, entry.__stacktrace__)
      end

    config
  end

  @spec validate_config(map, [atom()], [atom()]) :: :ok | {:error, String.t()}
  def validate_config(config, mandatory, optional) do
    config_keys = Map.keys(config)

    missing_mandatory = mandatory -- config_keys
    unknown_config = config_keys -- (mandatory ++ optional)

    cond do
      missing_mandatory != [] ->
        {:error, "Missing mandatory options #{inspect(missing_mandatory)}"}

      unknown_config != [] ->
        {:error, "Unknown options #{inspect(unknown_config)}"}

      true ->
        :ok
    end
  end

  @spec set_default_config(map(), {atom(), term()}) :: map
  def set_default_config(config, {key, default_value}) do
    {_old, config} =
      config
      |> Map.get_and_update(key, fn current_value ->
        {current_value, if(current_value != nil, do: current_value, else: default_value)}
      end)

    config
  end

  @spec set_default_config(map(), [{atom(), term()}]) :: map
  def set_default_config(config, default_values) do
    default_values
    |> Enum.reduce(config, fn default_value, acc ->
      set_default_config(acc, default_value)
    end)
  end

  @spec get_default_module(map, atom) :: map
  def get_default_module(definition, id) do
    definition.config[id]
  end

  def raise_compiler_error(message, {file, line}) do
    raise CompileError, file: file, line: line, description: message
  end
end
