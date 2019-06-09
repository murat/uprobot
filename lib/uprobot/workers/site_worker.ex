defmodule Uprobot.Workers.SiteWorker do
  @moduledoc false

  use GenServer

  require Logger
  import Ecto.Query, only: [from: 2]

  alias Uprobot.Repo
  alias Uprobot.Monit.{Site, Status}

  @interval 10_000

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

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  def init(state) do
    schedule()
    {:ok, state}
  end

  def schedule, do: Process.send_after(self(), :perform, @interval)

  def handle_info(:perform, state) do
    perform()
    {:noreply, state}
  end

  defp perform do
    active_sites =
      Repo.all(from s in Site, where: s.is_active == true and is_nil(s.verified_at) == false)

    active_sites
    |> Enum.map(&Task.async(fn -> ping(&1) end))
    |> Enum.map(&Task.await/1)

    schedule()
  end

  defp ping(site) do
    case apply(
           HTTPoison,
           if(site.method in ["get", "head", "options"],
             do: String.to_atom(site.method),
             else: :get
           ),
           [site.url]
         ) do
      {:ok, %HTTPoison.Response{status_code: status}} ->
        status_code =
          if status in 100..599 do
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

        Logger.info("#{site.name}'s status was #{status_text} at #{NaiveDateTime.utc_now()}")

        treshold = NaiveDateTime.add(NaiveDateTime.utc_now(), -172_000)

        Repo.delete_all(
          from(s in Status, where: s.site_id == ^site.id and s.inserted_at < ^treshold)
        )

        Logger.info("Old pings deleted for #{site.name}")

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
