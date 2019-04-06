defmodule Uprobot.MonitTest do
  use Uprobot.DataCase

  alias Uprobot.Monit

  describe "sites" do
    alias Uprobot.Monit.Site

    @valid_attrs %{is_active: true, name: "some name", url: "some url", verified_at: ~N[2010-04-17 14:00:00]}
    @update_attrs %{is_active: false, name: "some updated name", url: "some updated url", verified_at: ~N[2011-05-18 15:01:01]}
    @invalid_attrs %{is_active: nil, name: nil, url: nil, verified_at: nil}

    def site_fixture(attrs \\ %{}) do
      {:ok, site} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Monit.create_site()

      site
    end

    test "list_sites/0 returns all sites" do
      site = site_fixture()
      assert Monit.list_sites() == [site]
    end

    test "get_site!/1 returns the site with given id" do
      site = site_fixture()
      assert Monit.get_site!(site.id) == site
    end

    test "create_site/1 with valid data creates a site" do
      assert {:ok, %Site{} = site} = Monit.create_site(@valid_attrs)
      assert site.is_active == true
      assert site.name == "some name"
      assert site.url == "some url"
      assert site.verified_at == ~N[2010-04-17 14:00:00]
    end

    test "create_site/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Monit.create_site(@invalid_attrs)
    end

    test "update_site/2 with valid data updates the site" do
      site = site_fixture()
      assert {:ok, %Site{} = site} = Monit.update_site(site, @update_attrs)
      assert site.is_active == false
      assert site.name == "some updated name"
      assert site.url == "some updated url"
      assert site.verified_at == ~N[2011-05-18 15:01:01]
    end

    test "update_site/2 with invalid data returns error changeset" do
      site = site_fixture()
      assert {:error, %Ecto.Changeset{}} = Monit.update_site(site, @invalid_attrs)
      assert site == Monit.get_site!(site.id)
    end

    test "delete_site/1 deletes the site" do
      site = site_fixture()
      assert {:ok, %Site{}} = Monit.delete_site(site)
      assert_raise Ecto.NoResultsError, fn -> Monit.get_site!(site.id) end
    end

    test "change_site/1 returns a site changeset" do
      site = site_fixture()
      assert %Ecto.Changeset{} = Monit.change_site(site)
    end
  end
end
