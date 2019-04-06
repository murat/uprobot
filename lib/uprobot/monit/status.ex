defmodule Uprobot.Monit.Status do
  use Ecto.Schema
  import Ecto.Changeset

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

  schema "statuses" do
    field :body, :string
    field :status, :string, virtual: true
    field :status_code, :integer
    field :status_text, :string
    field :site_id, :id

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:status_code, :status_text, :body])
    |> validate_required([:status_code, :status_text, :body])
    |> generate_status()
  end

  @doc false
  defp generate_status(%{valid?: false} = changeset), do: changeset

  defp generate_status(%{valid?: true} = changeset) do
    status =
      changeset
      |> get_field(:status)

    status_code =
      if is_integer(status) && 200 < status && status < 600,
        do: status,
        else: String.to_integer(status)

    status_text = Map.get(@statuses, Integer.to_string(status_code), "Unknown")

    changeset
    |> put_change(:status_code, status_code)
    |> put_change(:status_text, status_text)
  end
end
