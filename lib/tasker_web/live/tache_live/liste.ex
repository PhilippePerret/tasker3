defmodule TaskerWeb.TacheLive.Liste do

	use TaskerWeb, :live_view
	
	alias Tasker.Tache
	alias Tasker.Taches
	alias Tasker.Taches.TacheTime
	
	@impl true
	def mount(_params, _session, socket) do
		{:ok, stream(socket, :taches, Taches.liste_des_taches())}
	end

	@impl true
	def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, 
    	socket.assigns.live_action, params)
		}
	end

	defp apply_action(socket, :liste, _params) do
    socket
    |> assign(:page_title, "Liste des tâches")
    |> assign(:tache, nil)
	end
	
	defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Édition de la tâche")
    |> assign(:tache, Taches.get_tache!(id))
  end

	defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nouvelle tâche")
		|> assign(:tache, %Tache{})
	end

	@impl true
	def handle_info({TaskerWeb.TacheLive.FormComponent, tache}, socket) do
		{:noreply, stream_insert(socket, :taches, tache)}
	end
	
	# Cette fois, je ne passe plus par la confirmation
	# Et j'utilise le stream
  @impl true
  def handle_event("rem", %{"id" => id}, socket) do
    tache = Taches.get_tache!(id)
    {:ok, _} = Taches.detruis_la_tache(tache)
    {:noreply, stream_delete(socket, :taches, tache)}
	end


	@doc """
	Pour valider les champs du tache-time dans le formulaire de la
	tâche.
	"""
	def handle_event("validate", %{"tache_time" => params}, socket) do
		changeset =
			%TacheTime{}
			|> TacheTime.changeset(params)
			|> Map.put(:action, :validate) # Nécessaire pour afficher les erreurs
	
		{:noreply, assign(socket, :form, to_form(changeset))}
	end

end