defmodule Admint.Query do
  import Ecto.Query

  def query(schema) do
    from(s in schema)
  end
end
