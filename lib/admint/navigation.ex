defmodule Admint.NavigationEntry do
  @type page :: {:page, atom}
  @type category :: {:category, [page]}
  @type t :: page | category
end

defmodule Admint.Navigation do
  @callback validate_opts(map()) :: :ok | {:error, String.t()}
  @callback compile_opts(map()) :: {:ok, map()} | {:error, String.t()}
  @callback render(map(), List.t()) :: any()

  @type t :: %__MODULE__{
          __stacktrace__: Admint.Stacktrace.t(),
          entries: [Admint.NavigationEntry.t()],
          opts: map
        }

  @enforce_keys [:__stacktrace__, :entries, :opts]
  defstruct [:__stacktrace__, :entries, :opts]

  alias Admint.Utils

  @mandatory_opts [:module]

  @optional_opts []

  defmacro __using__(_opts) do
    quote do
      @behaviour Admint.Navigation
    end
  end

  @spec validate_opts(map) :: :ok | {:error, String.t()}
  def validate_opts(opts) do
    optionals = @optional_opts |> Enum.map(fn {id, _} -> id end)
    Utils.validate_opts(opts, @mandatory_opts, optionals)
  end

  @spec compile_opts(map) :: {:ok, map} | {:error, String.t()}
  def compile_opts(opts) do
    opts = Utils.set_default_opts(opts, @optional_opts)

    {:ok, opts}
  end

  @spec render(map, List.t()) :: any
  def render(_opts, _path) do
    # should get opts.render and use it for rendering
    """
    Hello world
    """
  end
end
