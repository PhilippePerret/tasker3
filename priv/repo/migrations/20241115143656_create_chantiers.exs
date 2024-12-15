defmodule Tasker.Repo.Migrations.CreateChantiers do
  use Ecto.Migration

  def change do
    create table(:chantiers) do
      add :name, :string
      add :description, :text
      add :started_at, :naive_datetime
      add :ended_at, :naive_datetime

      timestamps(type: :utc_datetime)
    end

    alter table(:taches) do
      add :chantier_id, references(:chantiers, on_delete: :delete_all)
    end
    create index(:taches, [:chantier_id])

  end
end
