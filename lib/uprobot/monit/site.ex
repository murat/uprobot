defmodule Uprobot.Monit.Site do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "sites" do
    field :name, :string
    field :url, :string
    field :interval, :integer
    field :method, :string
    field :is_active, :boolean, default: false
    field :verified_at, :naive_datetime

    has_many :statuses, Uprobot.Monit.Status

    timestamps()
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(attrs, [:name, :url, :interval, :method, :is_active, :verified_at])
    |> validate_required([:name, :url, :interval, :method, :is_active])
    |> unique_constraint(:url)
  end
end
