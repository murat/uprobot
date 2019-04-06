defmodule Uprobot.Workers.SiteWorker do
  @moduledoc false

  use GenServer

  import Ecto.Query, only: [from: 2]

  alias Uprobot.Repo
  alias Uprobot.Monit.{Site, Status}

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    schedule_work()
    {:ok, nil}
  end

  def handle_info(:perform, state) do
    perform()
    schedule_next_job()
    {:noreply, state}
  end

  defp schedule_work() do
    # In 5 seconds
    Process.send_after(self(), :perform, 5_000)
  end

  defp schedule_next_job() do
    # In 60 seconds
    Process.send_after(self(), :perform, 60_000)
  end

  defp perform do
    Repo.all(from s in Site, where: is_nil(s.verified_at) == false)
    |> Enum.map(&Task.async(fn -> monit(&1) end))
    |> Enum.map(&Task.await/1)
  end

  defp monit(site) do
    case :hackney.get(site.url, [], "", follow_redirect: true) do
      {:ok, 200, _headers, _client_ref} ->
        Repo.insert!(%Status{site_id: site.id, status: 200, body: ""})

      {:error, status, _headers, client_ref} ->
        {:ok, response} = :hackney.body(client_ref)
        Repo.insert!(%Status{site_id: site.id, status: status, body: response})
    end
  end
end
