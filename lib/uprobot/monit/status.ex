defmodule Uprobot.Monit.Status do
  use Ecto.Schema
  import Ecto.Changeset

  schema "statuses" do
    field :body, :string
    field :status, :string, virtual: true
    field :status_code, :integer
    field :status_text, :string
    belongs_to :site, Uprobot.Monit.Site

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:status_code, :status_text, :body])
    |> cast_assoc(:site)
    |> validate_required([:status_code, :status_text, :body])
  end
end
