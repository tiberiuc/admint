defmodule Admint.Page do
  def get_opts(module, page_id) do
    {_, _, _, opts} = Admint.Navigation.get_page_by_id(module, page_id)

    opts
  end
end
