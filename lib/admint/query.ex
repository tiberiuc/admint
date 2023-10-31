defmodule Admint.Query do
  import Ecto.Query

  def query(schema, opts \\ %{}) do
    from(s in schema, as: :table)
    |> apply_sort(opts)
  end

  defp apply_sort(query, opts) do
    sort_by = opts[:sort_by]
    sort = opts[:sort] || :asc

    if sort_by do
      query
      |> order_by([table: t], [{^sort, field(t, ^sort_by)}])
    else
      query
    end
  end
end
