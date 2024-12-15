defmodule Tasker.Tache do
  use Ecto.Schema
  import Ecto.Changeset

  schema "taches" do
    field :titre, :string
    field :description, :string
    has_one :tache_time, Tasker.Taches.TacheTime
    belongs_to :chantier, Tasker.Taches.Chantier
    belongs_to :tache_before, Tasker.Tache, foreign_key: :tache_before_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tache, attrs) do
    tache
    |> cast(attrs, [:titre, :description, :chantier_id, :tache_before_id])
    |> assoc_constraint(:chantier)
    |> assoc_constraint(:tache_before)
    |> validate_required([:titre])
    |> cast_assoc(:tache_time, with: &Tasker.Taches.TacheTime.changeset/2) # <=== CA
    |> validate_length(:titre, max: 200)
  end
end
