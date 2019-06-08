defmodule Uprobot.Repo.Migrations.AddIntervalAndMethodToSites do
  use Ecto.Migration

  def change do
    alter table("sites") do
      add :interval, :integer, default: 100
      add :method, :string, default: "http"
    end
  end
end
