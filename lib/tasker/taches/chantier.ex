defmodule Tasker.Taches.Chantier do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tasker.Comptes.User

  schema "chantiers" do
    field :name, :string
    field :description, :string
    field :started_at, :naive_datetime
    field :ended_at, :naive_datetime
    has_many :taches, Tasker.Tache

    many_to_many :users, User, 
      join_through: "users_chantiers", 
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chantier, attrs) do
    chantier
    |> cast(attrs, [:name, :description, :started_at, :ended_at])
    |> validate_required([:name])
  end
end
