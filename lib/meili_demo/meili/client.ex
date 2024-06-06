defmodule MeiliDemo.Meili.Client do
  use Tesla

  plug Tesla.Middleware.BaseUrl, Application.get_env(:meili_demo, :meilisearch)[:main_endpoint]
  plug Tesla.Middleware.Headers, [{"Authorization", "Bearer #{Application.get_env(:meili_demo, :meilisearch)[:api_key]}"}]
  plug Tesla.Middleware.JSON

  def indices() do
    get("/indexes")
  end

  def upload_documents(index, documents) do
    post("/indexes/#{index}/documents", documents)
  end
end
