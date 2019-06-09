defmodule Uprobot.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password_digest, :string
      add :confirmed_at, :naive_datetime
      add :locked_at, :naive_datetime
      add :reset_password_token_sent_at, :naive_datetime

      timestamps()
    end

  end
end
