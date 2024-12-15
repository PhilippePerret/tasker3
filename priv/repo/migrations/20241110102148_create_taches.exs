defmodule Tasker.Repo.Migrations.CreateTaches do
  use Ecto.Migration

  def change do
    create table(:taches) do
      add :titre, :string
      add :description, :string
      add :tache_before_id, references(:taches, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
