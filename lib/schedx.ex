defmodule Schedx do
  @moduledoc """
  Documentation for `Schedx`.
  """
  use Application

  @impl true
  def start(_type, _args) do
    children = []

    opts = [
      name: Schedx.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, opts)
  end
end
