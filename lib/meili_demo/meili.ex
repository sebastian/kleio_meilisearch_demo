defmodule MeiliDemo.Meili do
  @moduledoc """
  The Meili context.
  """
  require Logger

  @index "movies"


  def list_ads do
    []
  end

  def search(term, limit \\ 50, offset \\ 0) do
    GenServer.call(__MODULE__, {:search, term, limit, offset})
  end

  ###################################################################
  # GenServer to cache indices and handle operations done against
  # the Meilisearch endpoint
  ###################################################################

  use GenServer

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    send(self(), :setup)
    {:ok, %{}}
  end

  @impl true
  def handle_call({:search, term, limit, offset}, _from, state) do
    {:ok, result} = MeiliDemo.Meili.SearchClient.search(@index, term, limit, offset)
    {:reply, result.body, state}
  end

  @impl true
  def handle_info(:setup, state) do
    {:ok, indices} = MeiliDemo.Meili.Client.indices()

    movie_index = indices.body["results"]
    |> Enum.find(& &1["uid"] == @index)

    if is_nil movie_index do
      Logger.info("Creating movie index")
      {:ok, movies} = movies_documents()
      {:ok, _} = MeiliDemo.Meili.Client.upload_documents(@index, movies)
      Logger.info("Created movies index. Probably being indexed as we speak")
    end

    {:noreply, state}
  end

  defp movies_documents() do
   file_path = Path.join(:code.priv_dir(:meili_demo), "data/movies.json")
    case File.read(file_path) do
      {:ok, content} ->
        case Jason.decode(content) do
          {:ok, json} -> {:ok, json}
          error -> error
        end
      error -> error
    end
  end
end
