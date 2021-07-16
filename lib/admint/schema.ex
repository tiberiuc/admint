defmodule Admint.Schema do
  def primary_key(schema) do
    schema.__schema__(:primary_key)
  end

  def fields(schema) do
    schema
    |> get_all_fields()
    |> reorder_fields(schema)
  end

  def default_field_options(schema, field) do
    type = field_type(schema, field)
    label = Admint.Utils.humanize(field)
    %{label: label, type: type}
  end

  def field_type(_schema, {_, type}), do: type
  def field_type(schema, field), do: schema.__changeset__() |> Map.get(field, :string)

  def get_primary_key_value(schema, row) do
    # TODO fix for multiple keys 
    key = primary_key(schema) |> List.first()
    Map.get(row, key)
  end

  defp get_all_fields(schema) do
    schema.__changeset__()
    |> Enum.map(fn {k, _} -> {k, default_field_options(schema, k)} end)
  end

  defp reorder_fields(fields_list, schema) do
    [_id, first_field | _fields] = schema.__schema__(:fields)

    # this is a "nice" feature to re-order the default fields to put the specified fields at the top/bottom of the form
    fields_list
    |> reorder_field(first_field, :first)
    |> reorder_field(:email, :first)
    |> reorder_field(:name, :first)
    |> reorder_field(:title, :first)
    |> reorder_field(:id, :first)
    |> reorder_field(:inserted_at, :last)
    |> reorder_field(:updated_at, :last)
  end

  defp reorder_field(fields_list, [], _), do: fields_list

  defp reorder_field(fields_list, [field | rest], position) do
    fields_list = reorder_field(fields_list, field, position)
    reorder_field(fields_list, rest, position)
  end

  defp reorder_field(fields_list, field_name, position) do
    if field_name in Keyword.keys(fields_list) do
      {field_options, fields_list} = Keyword.pop(fields_list, field_name)

      case position do
        :first -> [{field_name, field_options}] ++ fields_list
        :last -> fields_list ++ [{field_name, field_options}]
      end
    else
      fields_list
    end
  end
end
