defmodule Uprobot.Repo.Migrations.CreateStatuses do
  use Ecto.Migration

  def change do
    create table(:statuses) do
      add :status_code, :integer
      add :status_text, :string
      add :body, :text
      add :site_id, references(:sites, on_delete: :nothing)

      timestamps()
    end

    create index(:statuses, [:site_id])
  end
end
