defmodule Uprobot.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add :name, :string
      add :url, :string
      add :is_active, :boolean, default: false, null: false
      add :verified_at, :naive_datetime

      timestamps()
    end

    create unique_index(:sites, [:url])
  end
end
