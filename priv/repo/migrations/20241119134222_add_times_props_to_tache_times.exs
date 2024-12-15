defmodule Tasker.Repo.Migrations.AddTimesPropsToTacheTimes do
  use Ecto.Migration

  def change do
    alter table(:tache_times) do

      add :expected_time, :integer
      add :elapsed_time, :integer
      add :urgence, :integer
      add :priority, :integer
      add :due_every, :string
      add :imperative, :boolean, default: false
      add :duration, :integer

    end
  end
end
