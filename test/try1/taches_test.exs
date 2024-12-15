defmodule Tasker.TachesTest do
  use Tasker.DataCase

  alias Tasker.Taches

  describe "chantiers" do
    alias Tasker.Taches.Chantier

    import Tasker.TachesFixtures

    @invalid_attrs %{name: nil, description: nil, started_at: nil, ended_at: nil}

    test "list_chantiers/0 returns all chantiers" do
      chantier = chantier_fixture()
      assert Taches.list_chantiers() == [chantier]
    end

    test "get_chantier!/1 returns the chantier with given id" do
      chantier = chantier_fixture()
      assert Taches.get_chantier!(chantier.id) == chantier
    end

    test "create_chantier/1 with valid data creates a chantier" do
      valid_attrs = %{name: "some name", description: "some description", started_at: ~N[2024-11-14 14:36:00], ended_at: ~N[2024-11-14 14:36:00]}

      assert {:ok, %Chantier{} = chantier} = Taches.create_chantier(valid_attrs)
      assert chantier.name == "some name"
      assert chantier.description == "some description"
      assert chantier.started_at == ~N[2024-11-14 14:36:00]
      assert chantier.ended_at == ~N[2024-11-14 14:36:00]
    end

    test "create_chantier/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Taches.create_chantier(@invalid_attrs)
    end

    test "update_chantier/2 with valid data updates the chantier" do
      chantier = chantier_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", started_at: ~N[2024-11-15 14:36:00], ended_at: ~N[2024-11-15 14:36:00]}

      assert {:ok, %Chantier{} = chantier} = Taches.update_chantier(chantier, update_attrs)
      assert chantier.name == "some updated name"
      assert chantier.description == "some updated description"
      assert chantier.started_at == ~N[2024-11-15 14:36:00]
      assert chantier.ended_at == ~N[2024-11-15 14:36:00]
    end

    test "update_chantier/2 with invalid data returns error changeset" do
      chantier = chantier_fixture()
      assert {:error, %Ecto.Changeset{}} = Taches.update_chantier(chantier, @invalid_attrs)
      assert chantier == Taches.get_chantier!(chantier.id)
    end

    test "delete_chantier/1 deletes the chantier" do
      chantier = chantier_fixture()
      assert {:ok, %Chantier{}} = Taches.delete_chantier(chantier)
      assert_raise Ecto.NoResultsError, fn -> Taches.get_chantier!(chantier.id) end
    end

    test "change_chantier/1 returns a chantier changeset" do
      chantier = chantier_fixture()
      assert %Ecto.Changeset{} = Taches.change_chantier(chantier)
    end
  end
end
