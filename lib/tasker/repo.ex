defmodule Tasker.Repo do
  use Ecto.Repo,
    otp_app: :Tasker,
    adapter: Ecto.Adapters.Postgres
end
