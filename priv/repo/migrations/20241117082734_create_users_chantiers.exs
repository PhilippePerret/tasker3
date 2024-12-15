defmodule Tasker.Repo.Migrations.CreateUsersChantiers do
  use Ecto.Migration

  def change do
    create table(:users_chantiers, primary_key: false) do
      add :user_id, references(:users, 
        on_delete: :delete_all)
      add :chantier_id, references(:chantiers, 
        on_delete: :delete_all)
    end
    
    create index(:users_chantiers, [:chantier_id])
    create unique_index(:users_chantiers, [
      :chantier_id, :user_id
    ])  
  end
end
