defmodule Tasker.Repo.Migrations.CreateTacheTimes do
  use Ecto.Migration

  def change do
    create table(:tache_times) do
      add :due_at, :naive_datetime
      add :expected_end_at, :naive_datetime
      add :start_at, :naive_datetime
      add :end_at, :naive_datetime
      add :tache_id, references(:taches, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:tache_times, [:tache_id])
  
  end
end
