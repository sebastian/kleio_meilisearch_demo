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

  def delete_ad(ad_id) do
    delete("/api/v1/ads/#{ad_id}", %{})
  end

  def track_impression(code) do
    post("/api/v1/track/impression/#{code}", %{})
  end

  def track_conversion(code) do
    post("/api/v1/track/conversion/#{code}", %{})
  end
end
