defmodule MeiliDemo.Kleio.Client do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "#{Application.get_env(:meili_demo, :kleio)[:kleio_endpoint]}/"
  plug Tesla.Middleware.JSON

  def create_ad(product_id, name, max_bid) do
    post("/api/v1/ads", %{
      product_id: product_id,
      name: name,
      max_bid: max_bid,
    })
  end

  # In this case we are using the products endpoint rather than then
  # ads endpoint (/api/v1/ads/:id) because we only ever create one ad
  # per movie, and hence removing the product (which cascades to a delete
  # of all ads) is safe and saves us from having to look up the ad id first.
  def delete_ad(movie_id) do
    delete("/api/v1/products/#{movie_id}")
  end

  def track_impression(code) do
    post("/api/v1/track/impression/#{code}", %{})
  end

  def track_conversion(code) do
    post("/api/v1/track/conversion/#{code}", %{})
  end
end
