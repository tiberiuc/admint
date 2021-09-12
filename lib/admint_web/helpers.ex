defmodule Admint.Web.Helpers do
  @spec get_current_page_id(map()) :: atom() | nil
  def get_current_page_id(definition) do
    case definition.current_page do
      {:page, id} -> id
      _ -> nil
    end
  end

  @spec get_page_route(map(), atom()) :: String.t()
  def get_page_route(admint, page_id) do
    "#{admint.base_path}/#{Atom.to_string(page_id)}"
  end
end
