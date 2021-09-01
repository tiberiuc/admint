defmodule Admint.Layout do
  @callback validate_opts(map()) :: :ok | {:error, String.t()}
  @callback compile_opts(map()) :: {:ok, map()} | {:error, String.t()}
  @callback render(map(), List.t()) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour Admint.Layout
    end
  end

  @spec validate_opts(atom, map) :: :ok | {:error, String.t()}
  def validate_opts(module, opts) do
    apply(module, :validate_opts, [opts])
  end

  @spec compile_opts(atom, map) :: {:ok, map} | {:error, String.t()}
  def compile_opts(module, opts) do
    apply(module, :compile_opts, [opts])
  end

  @spec render(atom, map, List.t()) :: any
  def render(module, opts, path) do
    apply(module, :render, [opts, path])
  end
end
