defmodule Uprobot.AccountsTest do
  use Uprobot.DataCase

  alias Uprobot.Accounts

  describe "users" do
    alias Uprobot.Accounts.User

    @valid_attrs %{confirmed_at: ~N[2010-04-17 14:00:00], email: "some email", locked_at: ~N[2010-04-17 14:00:00], password_digest: "some password_digest", reset_password_token_sent_at: ~N[2010-04-17 14:00:00]}
    @update_attrs %{confirmed_at: ~N[2011-05-18 15:01:01], email: "some updated email", locked_at: ~N[2011-05-18 15:01:01], password_digest: "some updated password_digest", reset_password_token_sent_at: ~N[2011-05-18 15:01:01]}
    @invalid_attrs %{confirmed_at: nil, email: nil, locked_at: nil, password_digest: nil, reset_password_token_sent_at: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.confirmed_at == ~N[2010-04-17 14:00:00]
      assert user.email == "some email"
      assert user.locked_at == ~N[2010-04-17 14:00:00]
      assert user.password_digest == "some password_digest"
      assert user.reset_password_token_sent_at == ~N[2010-04-17 14:00:00]
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.confirmed_at == ~N[2011-05-18 15:01:01]
      assert user.email == "some updated email"
      assert user.locked_at == ~N[2011-05-18 15:01:01]
      assert user.password_digest == "some updated password_digest"
      assert user.reset_password_token_sent_at == ~N[2011-05-18 15:01:01]
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
