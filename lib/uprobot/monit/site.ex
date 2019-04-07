defmodule Uprobot.Monit.Site do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sites" do
    field :is_active, :boolean, default: false
    field :name, :string
    field :url, :string
    field :verified_at, :naive_datetime
    has_many :statuses, Uprobot.Monit.Status

    timestamps()
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(attrs, [:name, :url, :is_active, :verified_at])
    |> validate_required([:name, :url, :is_active, :verified_at])
    |> unique_constraint(:url)
  end
end
