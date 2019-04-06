defmodule Uprobot.Repo do
  use Ecto.Repo,
    otp_app: :uprobot,
    adapter: Ecto.Adapters.Postgres
end
