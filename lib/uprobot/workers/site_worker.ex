defmodule Uprobot.Workers.SiteWorker do
  @moduledoc false

  use GenServer

  require Logger
  import Ecto.Query, only: [from: 2]

  alias Uprobot.Repo
  alias Uprobot.Monit.{Site, Status}

  @statuses %{
    "100" => "Continue",
    "101" => "Switching Protocols",
    "102" => "Processing",
    "200" => "OK",
    "201" => "Created",
    "202" => "Accepted",
    "203" => "Non-Authoritative Information",
    "204" => "No Content",
    "205" => "Reset Content",
    "206" => "Partial Content",
    "300" => "Multiple Choices",
    "301" => "Moved Permanently",
    "302" => "Found",
    "303" => "See Other",
    "304" => "Not Modified",
    "305" => "Use Proxy",
    "306" => "Unused",
    "307" => "Temporary Redirect",
    "308" => "Permanent Redirect",
    "400" => "Bad Request",
    "401" => "Unauthorized",
    "402" => "Payment Required",
    "403" => "Forbidden",
    "404" => "Not Found",
    "405" => "Method Not Allowed",
    "406" => "Not Acceptable",
    "407" => "Proxy Authentication Required",
    "408" => "Request Timeout",
    "409" => "Conflict",
    "410" => "Gone",
    "411" => "Length Required",
    "412" => "Precondition Failed",
    "413" => "Request Entity Too Large",
    "414" => "Request-URI Too Long",
    "415" => "Unsupported Media Type",
    "416" => "Requested Range Not Satisfiable",
    "417" => "Expectation Failed",
    "418" => "I\'m a teapot",
    "421" => "Misdirected Request",
    "422" => "Unprocessable Entity",
    "428" => "Precondition Required",
    "429" => "Too Many Requests",
    "431" => "Request Header Fields Too Large",
    "451" => "Unavailable For Legal Reasons",
    "500" => "Internal Server Error",
    "501" => "Not Implemented",
    "502" => "Bad Gateway",
    "503" => "Service Unavailable",
    "504" => "Gateway Timeout",
    "505" => "HTTP Version Not Supported",
    "511" => "Network Authentication Required",
    "520" => "Web server is returning an unknown error",
    "522" => "Connection timed out",
    "524" => "A timeout occurred"
  }

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(_), do: GenServer.start_link(__MODULE__, [])

  def init(state) do
    schedule()
    {:ok, state}
  end

  def schedule, do: Process.send_after(self(), :perform, 5_000)

  def handle_info(:perform, state) do
    perform()
    {:noreply, state}
  end

  defp perform do
    Repo.all(from s in Site, where: is_nil(s.verified_at) == false)
    |> Enum.map(&Task.async(fn -> monit(&1) end))
    |> Enum.map(&Task.await/1)

    schedule()
  end

  defp monit(site) do
    case HTTPoison.get(site.url) do
      {:ok, %HTTPoison.Response{status_code: status}} ->
        status_code =
          if 100 < status && status < 599 do
            status
          else
            String.to_integer(status)
          end

        status_text = Map.get(@statuses, Integer.to_string(status_code), "Unknown")

        Repo.insert!(%Status{
          site: site,
          status_code: status_code,
          status_text: status_text
        })

        treshold = NaiveDateTime.add(NaiveDateTime.utc_now(), -172_000)

        Repo.delete_all(
          from(s in Status, where: s.site_id == ^site.id and s.inserted_at < ^treshold)
        )

      {:error, error} ->
        Repo.insert!(%Status{
          site: site,
          status_code: 520,
          status_text: "Unknown"
        })

        Logger.error(error.reason)
    end
  end
end
