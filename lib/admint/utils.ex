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

          true ->
            raise "The :router config must be specified: config :admint, router: MyAppWeb.Router"
        end

      r ->
        r
    end
    |> Module.concat(Helpers)
  end

  # modules -> list of {module, fun}
  def try_apply_first(modules, args) do
    modules
    |> Enum.reduce_while({:error}, fn {module, function}, _acc ->
      with {:ok, result} <-
             try_apply(module, function, args) do
        {:halt, {:ok, result}}
      else
        _ -> {:cont, {:not_found}}
      end
    end)
  end

  def try_apply(module, function, args) do
    arity = Enum.count(args)

    cond do
      function_exported?(module, function, arity) == true ->
        {:ok, apply(module, function, args)}

      true ->
        {:not_found}
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

  @spec validate_opts(map, map, map) :: :ok | {:error, String.t()}
  def validate_opts(opts, mandatory, optional) do
    opts_keys = Map.keys(opts)

    missing_mandatory = mandatory -- opts_keys
    unknown_opts = opts_keys -- (mandatory ++ optional)

    cond do
      missing_mandatory != [] ->
        {:error, "Missing mandatory options #{inspect(missing_mandatory)}"}

      unknown_opts != [] ->
        {:error, "Unknown options #{inspect(unknown_opts)}"}

      true ->
        :ok
    end
  end

  @spec set_default_opts(map, {atom, any}) :: map
  def set_default_opts(opts, {key, default_value}) do
    {_old, opts} =
      opts
      |> Map.get_and_update(key, fn current_value ->
        {current_value, if(current_value != nil, do: current_value, else: default_value)}
      end)

    opts
  end

  @spec set_default_opts(map, [{atom, any}]) :: map
  def set_default_opts(opts, default_values) do
    default_values
    |> Enum.reduce(opts, fn default_value, acc ->
      set_default_opts(acc, default_value)
    end)
  end

  defp env(key, default \\ nil) do
    Application.get_env(:admint, key, default)
  end
end
