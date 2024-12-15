defmodule TaskerWeb.ChantierLive.FormComponent do
  use TaskerWeb, :live_component

  alias Tasker.Taches

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Utiliser ce formulaire pour gérer les chantiers dans l'application.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="chantier-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Nom du chantier" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:started_at]} type="datetime-local" label="Démarré le" />
        <.input field={@form[:ended_at]} type="datetime-local" label="Achevé le" />

        <!-- Pour pouvoir choisir les travailleurs -->
        <.input 
          field={@form[:user_ids]} 
          type="select" multiple={true} 
          options={users_as_options(@form.source)} />


        <:actions>
          <.button phx-disable-with="Enregristrement...">Enregistrer le chantier</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

#         <.input field={@form[:user_ids]} type="select" multiple={true} options={users_as_options(@form.source)} />


  @impl true
  def update(%{chantier: chantier} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Taches.change_chantier(chantier))
     end)}
  end

  @impl true
  def handle_event("validate", %{"chantier" => chantier_params}, socket) do
    changeset = Taches.change_chantier(socket.assigns.chantier, chantier_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"chantier" => chantier_params}, socket) do
    save_chantier(socket, socket.assigns.action, chantier_params)
  end

  defp save_chantier(socket, :edit, chantier_params) do
    case Taches.update_chantier(socket.assigns.chantier, chantier_params) do
      {:ok, chantier} ->
        notify_parent({:saved, chantier})

        {:noreply,
         socket
         |> put_flash(:info, "Chantier actualisé avec succès")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_chantier(socket, :new, chantier_params) do
    case Taches.create_chantier(chantier_params) do
      {:ok, chantier} ->
        notify_parent({:saved, chantier})

        {:noreply,
         socket
         |> put_flash(:info, "Chantier créé avec succès")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})


	def users_as_options(changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:users, [])
      |> Enum.map(& &1.data.id)

    for u <- Tasker.Comptes.liste_des_users() do
      [
      	key: 		u.pseudo,
      	value: 	u.id, 
      	selected: u.id in existing_ids
      ]
    end
	end


end
