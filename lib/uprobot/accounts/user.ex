defmodule Uprobot.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string

    field :confirmed_at, :naive_datetime
    field :locked_at, :naive_datetime
    field :reset_password_token_sent_at, :naive_datetime

    field :password_digest, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :password,
      :password_confirmation,
      :confirmed_at,
      :locked_at,
      :reset_password_token_sent_at
    ])
    |> validate_required([
      :email,
      :password,
      :password_confirmation
    ])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/([\w-\.]+)@((?:[\w]+\.)+)([a-zA-Z]{2,4})/)
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> put_password_digest()
  end

  defp put_password_digest(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password_digest: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_digest(changeset), do: changeset
end
