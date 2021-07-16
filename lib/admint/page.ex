defmodule Admint.Page do
  import Ecto.Query

  def get_opts(module, page_id) do
    {_, _, _, opts} = Admint.Navigation.get_page_by_id(module, page_id)

    opts |> Map.put(:id, page_id)
  end

  def get_render(:index, opts, current_page) do
    cond do
      Map.get(opts, :render) != nil ->
        {opts.render, nil}

      Map.get(opts, :schema) != nil ->
        {Admint.Web.IndexPage, nil}

      true ->
        {nil,
         "Unable to render page \":#{current_page}\" it must have either \":render\" or \":schema\" defined"}
    end
  end

  def get_render(:view, opts, current_page) do
    cond do
      Map.get(opts, :render) != nil ->
        {opts.render, nil}

      Map.get(opts, :schema) != nil ->
        {Admint.Web.ViewPage, nil}

      true ->
        {nil,
         "Unable to render page \":#{current_page}\" it must have either \":render\" or \":schema\" defined"}
    end
  end

  def get_render(:edit, opts, current_page) do
    cond do
      Map.get(opts, :render) != nil ->
        {opts.render, nil}

      Map.get(opts, :schema) != nil ->
        {Admint.Web.EditPage, nil}

      true ->
        {nil,
         "Unable to render page \":#{current_page}\" it must have either \":render\" or \":schema\" defined"}
    end
  end

  def get_render(action, opts, current_page) do
    cond do
      Map.get(opts, :render) != nil ->
        {opts.render, nil}

      true ->
        {nil,
         "Unable to render page \":#{current_page}\" with action \":#{action}\", action is unknown, please provide a supported action or have \":render\" defined"}
    end
  end

  def index_fields(opts) do
    schema = get_schema(opts)
    Admint.Schema.fields(schema)
  end

  def query(opts) do
    schema = get_schema(opts)
    from(s in schema)
  end

  def page_title(opts) do
    title = Map.get(opts, :title)
    id = Map.get(opts, :id)

    if title == nil do
      Admint.Utils.humanize(id)
    else
      title
    end
  end

  def get_schema(opts) do
    schema = Map.get(opts, :schema, nil)

    case schema do
      nil -> raise "Schema is undefined"
      _ -> schema
    end
  end
end
