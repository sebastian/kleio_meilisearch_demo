# Integarting Meilisearch and Kleio

This is a demo application showcasing how to integrate the
[Kleio ad-server](https://kle.io) with the [Meilisearch](https://www.meilisearch.com) search engine. Using the two together, you
can quickly add support for sponsored search results to your application.

To see this application running (and demo) running in practice, I recommend spinning up the full suite of containers using docker compose.
Please consult the Kleio quickstart documentation.

## What this repository contains

This application is a very simple web frontend written in Elixir.
It uses the Phoenix web framework.

In addition to the search interface, it also includes some tooling to
ensure the Meilisearch instance it is pointed to has the required 
movies index setup. 

You can start the application directly by running:

- `mix deps.get` to get all dependencies
- `iex -S mix phx.server` to start the application

Do note however that this isn't going to work particularly well
unless you also have Kleio and Meilisearch running.