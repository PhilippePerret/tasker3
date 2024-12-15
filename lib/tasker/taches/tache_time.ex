defmodule Tasker.Taches.TacheTime do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tache_times" do
    field :due_at, :naive_datetime
    field :due_every, :string # crontab, p.e. "0 10 3 * *"
    field :expected_end_at, :naive_datetime
    field :start_at, :naive_datetime
    field :end_at, :naive_datetime
    field :expected_time, :integer
    field :duration, :integer # quand on connait la durée exacte
    field :elapsed_time, :integer
    field :urgence, :integer
    field :priority, :integer
    field :imperative, :boolean, default: false # si true, rien ne peut passer avant
  
    belongs_to :tache, Tasker.Tache

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tache_time, attrs) do
    tache_time
    |> cast(attrs, [:due_at, :expected_end_at, :start_at, :end_at, :expected_time, :elapsed_time, :urgence, :priority])
    |> assoc_constraint(:tache) # => la tâche doit obligatoirement exister
  end

end
