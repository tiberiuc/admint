defmodule Admint.Stacktrace do
  @type t :: {String.t(), Integer.t()}
end

defmodule Admint.Category do
  @type t :: %__MODULE__{
          __stacktrace__: Admint.Stacktrace.t(),
          id: String.t(),
          title: String.t(),
          opts: %{}
        }

  @enforce_keys [:__stacktrace__, :id, :title, :opts]
  defstruct [:__stacktrace__, :id, :title, :opts]
end
