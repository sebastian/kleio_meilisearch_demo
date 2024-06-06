defmodule MeiliDemoWeb.SearchLive.Index do
  use MeiliDemoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    term = "godzilla"

    search(term)

    {:ok,
      socket
      |> assign(:search_term, term)
      |> assign(:ad_interface, false)
      |> assign(:create_ad, nil)
      |> assign(:results, %{"estimatedTotalHits" => 0, "hits" => []})
    }
  end

  @impl true
  def handle_event("toggle_ad_interface", _params, socket) do
    {:noreply, assign(socket, :ad_interface, not socket.assigns.ad_interface)}
  end

  def handle_event("search_term_change", %{"search_term" => term}, socket) do
    search(term)
    {:noreply, assign(socket, :search_term, term)}
  end

  def handle_event("track_ad", %{"movie" => id}, socket) do
    ad =
      (socket.assigns.results["hits"] || [])
      |> Enum.find(:not_found, fn el ->
        el["id"] == id && ! is_nil el["kleio"]
      end)

    case ad do
      :not_found -> :ok
      ad ->
        ad_data = ad["kleio"]
        tracking_code = ad_data["tracking_code"]
        MeiliDemo.Kleio.Client.track_conversion(tracking_code)
    end

    {:noreply, socket}
  end

  def handle_event("create_ad", %{"bid" => bid, "movie_id" => movie_id, "title" => title}, socket) do
    {bid, _} = Integer.parse(bid)
    MeiliDemo.Kleio.Client.create_ad(movie_id, "Ad for #{title}", bid)

    # We perform some searches after creating the ad
    # to have the demo interface show it immediately.
    # This, of course, you wouldn't do in a regular setup.
    me = self()
    spawn(fn ->
      for delay <- [10, 100, 1000] do
        :timer.sleep(delay) # 1.5 s
        search(socket.assigns.search_term, me)
      end
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:search_result, result}, socket) do
    {:noreply, assign(socket, :results, result)}
  end

  defp search(term, me \\ self()) do
    spawn(fn ->
      result = MeiliDemo.Meili.search(term, 35)
      send(me, {:search_result, result})
    end)
  end

  def regular_movie(assigns) do
    ~H"""
      <div class="w-full">
        <.modal id={"create-ad-#{@movie["id"]}"}>
          <h1 class="text-xl">
            Create an ad for
            <span class="font-semibold"><%= @movie["title"] %></span>
          </h1>

          <form class="mt-8" phx-submit="create_ad">
            <input type="hidden" name="title" value={@movie["title"]} />
            <input type="hidden" name="movie_id" value={@movie["id"]} />
            <.input class="border" type="number" label="Maximum bid" name="bid" value="100" />
            <div class="mt-4 flex items-center justify-between gap-6">
              <.button phx-click={hide_modal("create-ad-#{@movie["id"]}")}>Create ad</.button>
            </div>
          </form>
        </.modal>

        <div class="rounded-md hover:bg-green-50 transition-colors duration-200 px-2 cursor-pointer flex flex-col justify-between max-w-2xl" phx-click={show_modal("poster-#{@movie["id"]}")}>
          <p class="inline max-w-2xl text-sm overflow-hidden whitespace-nowrap text-ellipsis">
            <span class="inline text-md font-semibold"><%= @movie["title"] %></span>
            • <%= @movie["overview"] %>
          </p>
          <div class="mt-2 flex flex-row w-full items-center justify-between">
            <div class="flex flex-row gap-1 items-start h-5">
              <div
                :for={genre <- @movie["genres"]}
                class="rounded-full shrink-0 text-xs bg-gray-200 p-0.5 px-1.5"
              >
                <%= genre %>
              </div>
            </div>

            <%= if @ad_interface do %>
              <button
                class="transition-all duration-300 hover:bg-green-500 border-green-500 hover:border-white group border rounded-full hover:text-white px-1.5 py-0.5 text-xs -mt-0.5"
                phx-click={show_modal("create-ad-#{@movie["id"]}")}
              >
                <span class="group-hover:hidden inline">Boost</span>
                <span class="group-hover:inline hidden">Boost <%= @movie["title"] %> with an ad</span>
              </button>
            <% end %>
          </div>
        </div>
      </div>
    """
  end

  def ad(assigns) do
    ~H"""
      <div
        class="w-full cursor-pointer bg-green-100/20 hover:bg-green-100/80 transition-all duration-200 border border-green-100 shadow-md shadow-green-200/30 flex flex-row gap-2 items-start aspect-auto px-3 py-2 rounded-md"
        phx-click={
          show_modal("poster-#{@movie["id"]}")
          |> Phoenix.LiveView.JS.push("track_ad", value: %{movie: @movie["id"]})
        }
      >
        <div class="w-16 shrink-0 mt-1">
          <img src={@movie["poster"]} alt={"Poster for movie #{@movie["title"]}"} />
        </div>
        <div class="grow-1">
          <div class="flex flex-row items-center justify-between">
            <h2 class="text-xl font-medium"><%= @movie["title"] %></h2>
            <div class="flex flex-row gap-1 justify-center h-5 ml-2">
              <div
                :for={genre <- @movie["genres"]}
                class="rounded-full shrink-0 text-xs bg-gray-200 p-0.5 px-1.5"
              >
                <%= genre %>
              </div>
            </div>
          </div>
          <p class="text-xs"><%= @movie["overview"] %></p>
          <div class="mt-1"><span class="text-xs rounded-full font-bold bg-blue-500 text-white px-2 py-1">sponsored</span></div>
        </div>
      </div>
    """
  end
end
