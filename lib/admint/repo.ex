defmodule Admint.Repo do
  use Ecto.Repo,
    otp_app: :admint,
    adapter: Ecto.Adapters.Postgres
end
