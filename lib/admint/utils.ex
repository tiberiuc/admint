defmodule Admint.Utils do
  @moduledoc false

  @doc """
  Returns the router helper module from the configs. Raises if the router isn't specified.
  """
  @spec router() :: atom()
  def router() do
    case env(:router) do
      nil ->
        case Mix.env() do
          :test ->
            nil

          :dev ->
            nil

          _ ->
            raise "The :router config must be specified: config :admint, router: MyAppWeb.Router"
        end

      r ->
        r
    end
    |> Module.concat(Helpers)
  end

  #   # modules -> list of {module, fun}
  #   def try_apply_first(modules, args) do
  #     modules
  #     |> Enum.reduce_while({:error}, fn {module, function}, _acc ->
  #       with {:ok, result} <-
  #              try_apply(module, function, args) do
  #         {:halt, {:ok, result}}
  #       else
  #         _ -> {:cont, {:not_found}}
  #       end
  #     end)
  #   end

  #   def try_apply(module, function, args) do
  #     arity = Enum.count(args)

  #     cond do
  #       function_exported?(module, function, arity) == true ->
  #         {:ok, apply(module, function, args)}

  #       true ->
  #         {:not_found}
  #     end
  #   end

  @spec str_as_existing_atom(String.t()) :: {:ok, atom()} | {:not_found}
  def str_as_existing_atom(str) do
    try do
      {:ok, String.to_existing_atom(str)}
    rescue
      ArgumentError -> {:not_found}
    end
  end

  @spec repo() :: atom()
  def repo() do
    case env(:ecto_repo) do
      nil ->
        raise "The :ecto_repo config must be specified: config :admin, ecto_config: MyApp.Repo"

      repo ->
        repo
    end
  end

  @spec humanize(atom) :: String.t()
  def humanize(val) when is_atom(val) do
    Atom.to_string(val)
    |> humanize()
  end

  @spec humanize(String.t()) :: String.t()
  def humanize(val) when is_bitstring(val) do
    val
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp env(key, default \\ nil) do
    Application.get_env(:admint, key, default)
  end
end
