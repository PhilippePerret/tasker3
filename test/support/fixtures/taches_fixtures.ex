defmodule Tasker.TachesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tasker.Taches` context.
  """

  @doc """
  Generate a chantier.
  """
  def chantier_fixture(attrs \\ %{}) do
    {:ok, chantier} =
      attrs
      |> Enum.into(%{
        description: "some description",
        ended_at: ~N[2024-11-14 14:36:00],
        name: "some name",
        started_at: ~N[2024-11-14 14:36:00]
      })
      |> Tasker.Taches.create_chantier()

    chantier
  end
end
