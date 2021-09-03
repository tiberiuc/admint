defmodule Admint.Page do
  @callback validate_opts(map()) :: :ok | {:error, String.t()}
  @callback compile_opts(map()) :: {:ok, map()} | {:error, String.t()}
  @callback render(atom(), map(), List.t()) :: any()

  @type t :: %__MODULE__{
          __stacktrace__: Admint.Stacktrace.t(),
          opts: map
        }

  @enforce_keys [:__stacktrace__, :opts]
  defstruct [:__stacktrace__, :opts]

  defmacro __using__(_opts) do
    quote do
      @behaviour Admint.Page
    end
  end

  alias Admint.Utils

  @mandatory_opts [:module, :id]
  @optional_opts [
    {:schema, nil},
    {:title, nil},
    {:render, nil}
  ]

  @spec validate_opts(map) :: :ok | {:error, String.t()}
  def validate_opts(opts) do
    optionals = @optional_opts |> Enum.map(fn {id, _} -> id end)
    Utils.validate_opts(opts, @mandatory_opts, optionals)
  end

  @spec compile_opts(map) :: {:ok, map} | {:error, String.t()}
  def compile_opts(opts) do
    opts =
      opts
      |> Utils.set_default_opts(@optional_opts)
      |> Utils.set_default_opts({:title, Utils.humanize(opts.id)})

    cond do
      opts.schema == nil and opts.render == nil ->
        {:error, "At least one of :schema or :render must be defined"}

      true ->
        opts = opts |> Utils.set_default_opts({:render, Admint.Page})
        {:ok, opts}
    end
  end

  def render(_page_id, _opts, _path) do
    """
    Hello world
    """
  end
end
