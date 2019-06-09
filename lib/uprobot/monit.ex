defmodule Uprobot.Monit do
  @moduledoc """
  The Monit context.
  """

  import Ecto.Query, warn: false
  alias Uprobot.Repo

  alias Uprobot.Monit.{Site, Status}

  @doc """
  Returns the list of sites.

  ## Examples

      iex> list_sites()
      [%Site{}, ...]

  """
  def list_sites do
    # `, limit: 1)`
    status_query = from(st in Status, order_by: [desc: :inserted_at])
    # look for why is limit causing lost records problem?
    site_query = from(s in Site, preload: [statuses: ^status_query])

    site_query
    |> Repo.all()
  end

  @doc """
  Gets a single site.

  Raises `Ecto.NoResultsError` if the Site does not exist.

  ## Examples

      iex> get_site!(123)
      %Site{}

      iex> get_site!(456)
      ** (Ecto.NoResultsError)

  """
  def get_site!(id, status_limit \\ 1)

  def get_site!(id, status_limit) do
    status_query = from(st in Status, order_by: [desc: :inserted_at], limit: ^status_limit)
    site_query = from(s in Site, where: s.id == ^id, preload: [statuses: ^status_query])

    site_query
    |> Repo.one!()
  end

  def get_site_with_statuses!(id) do
    stats_query =
      from(
        stat in Status,
        where: stat.site_id == ^id,
        select: [
          fragment(
            "date_trunc('H', inserted_at) + (round(extract('minute' from inserted_at) / 10) * 10) \* '1 minute'::interval as period"
          ),
          count(stat.id)
        ],
        group_by: fragment("period"),
        order_by: fragment("period")
      )

    {
      Repo.get!(Site, id),
      Repo.all(stats_query)
    }
  end

  @doc """
  Creates a site.

  ## Examples

      iex> create_site(%{field: value})
      {:ok, %Site{}}

      iex> create_site(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_site(attrs \\ %{}) do
    %Site{}
    |> Site.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a site.

  ## Examples

      iex> update_site(site, %{field: new_value})
      {:ok, %Site{}}

      iex> update_site(site, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_site(%Site{} = site, attrs) do
    site
    |> Site.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Site.

  ## Examples

      iex> delete_site(site)
      {:ok, %Site{}}

      iex> delete_site(site)
      {:error, %Ecto.Changeset{}}

  """
  def delete_site(%Site{} = site) do
    Repo.delete(site)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking site changes.

  ## Examples

      iex> change_site(site)
      %Ecto.Changeset{source: %Site{}}

  """
  def change_site(%Site{} = site) do
    Site.changeset(site, %{})
  end

  alias Uprobot.Monit.Status

  @doc """
  Returns the list of statuses.

  ## Examples

      iex> list_statuses()
      [%Status{}, ...]

  """
  def list_statuses do
    Repo.all(Status)
  end

  @doc """
  Gets a single status.

  Raises `Ecto.NoResultsError` if the Status does not exist.

  ## Examples

      iex> get_status!(123)
      %Status{}

      iex> get_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_status!(id), do: Repo.get!(Status, id)

  @doc """
  Creates a status.

  ## Examples

      iex> create_status(%{field: value})
      {:ok, %Status{}}

      iex> create_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_status(attrs \\ %{}) do
    %Status{}
    |> Status.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a status.

  ## Examples

      iex> update_status(status, %{field: new_value})
      {:ok, %Status{}}

      iex> update_status(status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_status(%Status{} = status, attrs) do
    status
    |> Status.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Status.

  ## Examples

      iex> delete_status(status)
      {:ok, %Status{}}

      iex> delete_status(status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_status(%Status{} = status) do
    Repo.delete(status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking status changes.

  ## Examples

      iex> change_status(status)
      %Ecto.Changeset{source: %Status{}}

  """
  def change_status(%Status{} = status) do
    Status.changeset(status, %{})
  end
end
