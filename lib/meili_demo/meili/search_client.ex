defmodule MeiliDemo.Meili.SearchClient do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "#{Application.get_env(:meili_demo, :kleio)[:kleio_endpoint]}/integrations/meilisearch"
  plug Tesla.Middleware.Headers, [{"Authorization", "Bearer #{Application.get_env(:meili_demo, :meilisearch)[:api_key]}"}]
  plug Tesla.Middleware.JSON

  def search(index, term, limit \\ 10, offset \\ 0) do
    post("/indexes/#{index}/search", %{q: term, limit: limit, offset: offset})
  end
end
