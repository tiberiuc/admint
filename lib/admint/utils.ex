defmodule Admint.Utils do
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

  defp env(key, default \\ nil) do
    Application.get_env(:admint, key, default)
  end
end
