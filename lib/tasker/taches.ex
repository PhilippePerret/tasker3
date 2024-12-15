defmodule Tasker.Taches do

  import Ecto.Query, warn: false

  alias Tasker.{Repo, Tache}
  alias Tasker.Comptes.User
  alias Tasker.Taches.{TacheTime, Chantier,AlgorithmeTaches}

  def fetch_current_tache(user) do
    AlgorithmeTaches.fetch_current_tache(user)
  end

  def liste_des_taches do
    Repo.all(Tache)
    |> Repo.preload([:chantier, :tache_time])
  end

  def get_tache!(id) do
    Repo.get!(Tache, id) 
    |> Repo.preload([:chantier, :tache_time])
  end

  @doc """
  Pour créer une nouvelle tâche
  """
  def creer_la_tache(attrs \\ %{}) do
    %Tache{}
      |> Tache.changeset(attrs)
      |> Ecto.Changeset.cast_assoc(:tache_time, with: &TacheTime.changeset/2)
      |> Repo.insert()
    end

	@doc """
  Actualise les données d'une tâche.

  ## Exemples

      iex> actualise_la_tache(tache, %{field: new_value})
      {:ok, %Tache{}}

      iex> actualise_la_tache(tache, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def actualise_la_tache(%Tache{} = tache, attrs) do
    tache
    |> Tache.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:tache_time, with: &TacheTime.changeset/2)
    |> Repo.update()
  end

 @doc """
  Détruit une tâche.

  ## Exemples

      iex> detruit_la_tache(tache)
      {:ok, %Tache{}}

      iex> detruit_la_tache(tache)
      {:error, %Ecto.Changeset{}}

  """
  def detruis_la_tache(%Tache{} = tache) do
    Repo.delete(tache)
  end


  def change_tache(%Tache{} = tache, attrs \\ %{}) do
    Tache.changeset(tache, attrs)
  end


  alias Tasker.Taches.Chantier

  @doc """
  Returns the list of chantiers.

  ## Examples

      iex> list_chantiers()
      [%Chantier{}, ...]

  """
  def list_chantiers do
    Repo.all(Chantier)
    |> Repo.preload([:taches])
  end

  @doc """
  Gets a single chantier.

  Raises `Ecto.NoResultsError` if the Chantier does not exist.

  ## Examples

      iex> get_chantier!(123)
      %Chantier{}

      iex> get_chantier!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chantier!(id) do
    Chantier
    |> Repo.get!(id)
    |> Repo.preload(:users)
    |> Repo.preload([:taches])
  end

  @doc """
  Creates a chantier.

  ## Examples

      iex> create_chantier(%{field: value})
      {:ok, %Chantier{}}

      iex> create_chantier(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chantier(attrs \\ %{}) do
    %Chantier{}
    |> change_chantier(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chantier.

  ## Examples

      iex> update_chantier(chantier, %{field: new_value})
      {:ok, %Chantier{}}

      iex> update_chantier(chantier, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chantier(%Chantier{} = chantier, attrs) do
    chantier
    |> change_chantier(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chantier changes.

  ## Examples

      iex> change_chantier(chantier)
      %Ecto.Changeset{data: %Chantier{}}

  """
  def change_chantier(%Chantier{} = chantier, attrs \\ %{}) do
    users = list_users_by_id(attrs["user_ids"])
    IO.inspect(users, label: "Liste des identifiants")
    chantier
    |> Repo.preload(:users)
    |> Repo.preload([:taches])
    |> Chantier.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:users, users)
  end

  defp list_users_by_id(nil), do: []
  defp list_users_by_id(user_ids) do
    user_ids = Enum.map(user_ids, &String.to_integer/1)  # Convertir chaque ID de string à integer
    Repo.all(from u in User, where: u.id in ^user_ids)  # Charger les utilisateurs par ID
  end

  @doc """
  Deletes a chantier.

  ## Examples

      iex> delete_chantier(chantier)
      {:ok, %Chantier{}}

      iex> delete_chantier(chantier)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chantier(%Chantier{} = chantier) do
    Repo.delete(chantier)
  end

end
