defmodule TaskerWeb.TacheLive.FormComponent do
  use TaskerWeb, :live_component

	# alias Tasker.Tache
	alias Tasker.Taches

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Renseignez ce formulaire pour créer une nouvelle tâche.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="tache-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:titre]} type="text" label="Titre" />
        <.input field={@form[:description]} type="text" label="Description" />

        <!-- Relation avec le chantier -->
        <.input field={@form[:chantier_id]} label="Chantier" type="select" options={chantiers_as_options()} />

        <!-- Relation avec la tache-time -->
          <.inputs_for 
            :let={ftime} 
            field={@form[:tache_time]}
            
          >
            <.input field={ftime[:due_at]} label="[TT] Doit débuter" type="datetime-local" />
            <.input field={ftime[:expected_end_at]} label="[TT] Fin finir" type="datetime-local" />
            <.input field={ftime[:start_at]} label="[TT] commencée le" type="datetime-local" />
            <.input field={ftime[:end_at]} label="[TT] finie le" type="datetime-local" />
            <.input field={ftime[:urgence]} 
              label="Urgence" type="select"
              value={ftime[:urgence].value}
              options={options_urgences()}
            />
            <.input field={ftime[:priority]} 
              label="Priorité" type="select"
              value={ftime[:priority].value}
              options={options_priority()}
            />

          </.inputs_for>

          <:actions>
          <.button phx-disable-with="Enregistrement en cours…">Enregistrer la tâche</.button>
        </:actions>

        </.simple_form>
    </div>
    """
  end

  def options_urgences do
    [
      {"Normale", "2"}, 
      {"Urgente", "3"}, 
      {"Pas urgente", "1"}
    ]
  end

  def options_priority do 
    [
      {"Pas de priorité", "3"}, 
      {"Priorité maximum", "5"}, 
      {"Prioritaire", "4"}, 
      {"Ça peut attendre", "2"}, 
      {"En dernier recours", "1"}
    ]
  end

  # Pour retourner la liste des chantiers actuels
  def chantiers_as_options do
    [{"- Aucune -", nil}] ++
    Enum.map(Tasker.Taches.list_chantiers(), fn chantier -> 
      {chantier.name, chantier.id}
    end)
  end

  @impl true
  def update(%{tache: tache} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Taches.change_tache(tache))
     end)}
  end

  @impl true
  def handle_event("validate", %{"tache" => tache_params}, socket) do
    changeset = Taches.change_tache(socket.assigns.tache, tache_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"tache" => tache_params}, socket) do
    save_tache(socket, socket.assigns.action, tache_params)
  end

  defp save_tache(socket, :edit, tache_params) do
    case Taches.actualise_la_tache(socket.assigns.tache, tache_params) do
      {:ok, tache} ->
        # send(self(), {__MODULE__, {:saved, tache}}) # fait ajouté par ChatGPT
        # notify_parent({:saved, tache}) # de base, mais modifié par ChatGPT
        notify_parent(tache)

        {:noreply,
         socket
         |> put_flash(:info, "Tâche actualisée avec succès")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_tache(socket, :new, tache_params) do
    case Taches.creer_la_tache(tache_params) do
      {:ok, tache} ->
        # notify_parent({:saved, tache}) # modification ChatGPT
        notify_parent(tache) # modification ChatGPT

        {:noreply,
         socket
         |> put_flash(:info, "Tâche créée avec succès")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

end
