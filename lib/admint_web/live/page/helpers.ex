defmodule Admint.Web.Page.Helpers do
  import Admint.Web.Helpers

  def get_current_page_path(admint) do
    {:page, page_id} = get_current_page(admint)
    "#{get_page_route(admint, page_id)}"
  end

  def get_current_page_view_path(admint, params) do
    id = params["value"]
    base = get_current_page_path(admint)
  
    "#{base}/#{id}"
  end

  def get_current_page_edit_path(admint,params) do
    base = get_current_page_view_path(admint, params)
  
    "#{base}/edit"
  end
end
