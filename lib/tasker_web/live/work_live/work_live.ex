defmodule TaskerWeb.WorkLive do

  use TaskerWeb, :live_view

	# alias TaskerWeb.Router
	# alias Tasker.{Comptes, Tache, Taches}
  alias Tasker.Repo
	alias Tasker.{Comptes, Taches}
	# alias Tasker.Taches.Chantier

	# Ça ne fonctionne pas, ci-dessous, si user n'est pas identifié.
	@impl true
	def mount(_params, %{"user_token" => utoken} = _session, socket) do
		case Comptes.get_user_by_session_token(utoken) do
			nil -> 
				# {:ok, socket} # ou gérer le cas de l'utilisateur non trouvé
				# TODO: Mettre une redirection vers l'identification
				{:noreply, socket |> put_flash(:info, "Je ne devrais pas passer par là sans être identifié…")}
			user -> 
				{:ok, assign(socket, %{
					current_user: user, 
					counter: 0, 
					tache: fetch_current_tache(user),
					travail_on: false,
					description_shown: false
					})}
		end
	end

	def	fetch_current_tache(user) do
		Taches.fetch_current_tache(user)
	end
	

	@impl true
	def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, 
    	socket.assigns.live_action, params)
		}
	end

	@impl true
	def handle_event("toggle-work", params, socket) do
		travail_on = params["state"]
		# IO.inspect(socket, label: "Le socket dans handle_event toggle-work")
		tache = socket.assigns.tache # une Map, pas une Tache
		tache =
			if travail_on do
				# mise en pause du travail
				stop_travail_on_tache(tache)
			else
				# mise en route du travail
				Map.merge(tache, %{start_time: NaiveDateTime.utc_now(), message: nil})
			end
			|> IO.inspect(label: "Map de tâche #{travail_on && "arrêtée" || "démarrée"}")
		socket = 
			socket
			|> put_flash(:info, tache.message)
			|> assign(%{travail_on: !travail_on, tache: tache})
		{:noreply, socket}
	end

	defp stop_travail_on_tache(mtache) do
		end_time  = NaiveDateTime.utc_now()
		worked_time = ceil(NaiveDateTime.diff(NaiveDateTime.utc_now(), mtache.start_time) / 60)
		# On enregistre la tache_time modifiée
		tachetime = mtache.tache_time
		tachetime_change = Ecto.Changeset.change(tachetime, %{elapsed_time: (tachetime.elapsed_time || 0) + worked_time})
		tachetime = Repo.insert_or_update!(tachetime_change)
		# |> IO.inspect(label: "\nRetour de Repo.insert_or_update")
		mtache
		|> Map.merge(%{tache_time: tachetime, work_time: worked_time, end_time: end_time, message: "Temps de travail : #{worked_time} mn"})
	end

	@impl true
	def handle_event("stop", _params, socket) do
		socket = 
			socket
			|> put_flash(:info, "Je dois apprendre à stopper la tâche")
		{:noreply, socket}
	end

	@impl true
	def handle_event("pause", _params, socket) do
		socket = 
			socket
			|> put_flash(:info, "Je dois apprendre à pauser")
		{:noreply, socket}
	end

	def handle_event("set-done", _params, socket) do
		mtache = socket.assigns.tache # une Map, pas une Tache
		case set_tache_done(mtache) do
			{:ok, _resultat} ->
				# TODO: Mais ici, il faudrait gérer l'affichage pour retirer la 
				# tache courante et passer à la suivante. Comment faire ça ?
				socket = 
					socket
					|> put_flash(:info, "Je dois apprendre à actualiser la liste")
					|> put_flash(:info, "J'ai marqué la tâche finie et je l'ai archivée")
				{:noreply, socket}
			nil ->
				{:noreply, socket |> put_flash(:warn, "Impossible d'enregistrer la tâche.")}
		end
	end

	def set_tache_done(mtache) do
		tachetime = mtache.tache_time # une Struct %TacheTime{}
		# Pour marquer une tâche finie (ou abandonnée), il faut définir
		# le end_at de son tache_time		
		# Mais pour ne pas la prendre pour une tâche abandonnée (qu'on reconnait
		# au fait que son elapsed_time est défini, mais il ne peut l'être que si
		# l'utilisateur met en route le chronomètre), on regarde la valeur du 
		# tache_time.elapsed_time et s'il est nil, on le met à 10 (minutes)
		elapsed_time = 
			if mtache.start_time do
				worked_time = ceil(NaiveDateTime.diff(NaiveDateTime.utc_now(), mtache.start_time) / 60)
				(tachetime.elapsed_time || 0) + worked_time
			else
				10 
			end

		# On enregistre le tachetime dans la base
		tachetime_change = Ecto.Changeset.change(tachetime, %{
			end_at: 			NaiveDateTime.utc_now(),
			elapsed_time: elapsed_time
		})
		Repo.insert_or_update!(tachetime_change)
		# tachetime = Repo.insert_or_update!(tachetime_change)
		# {:ok, nil}
	end


	# def handle_event("set-just-after", _params, socket) do
	# 	socket = 
	# 		socket
	# 		|> put_flash(:info, "Je dois apprendre à mettre juste après")
	# 	{:noreply, socket}
	# end

	def handle_event("set-after-alea", _params, socket) do
		socket = 
			socket
			|> put_flash(:info, "Je dois apprendre à mettre après aléatoirement")
		{:noreply, socket}
	end

	def handle_event("set-last", _params, socket) do
		socket = 
			socket
			|> put_flash(:info, "Je dois apprendre à mettre en dernier")
		{:noreply, socket}
	end

	def handle_event("set-very-last", _params, socket) do
		socket = 
			socket
			|> put_flash(:info, "Je dois apprendre à repousser vraiment loin")
		{:noreply, socket}
	end

	def handle_event("edit", _params, socket) do
		socket = 
			socket
			|> put_flash(:info, "Je dois apprendre à éditer")
		{:noreply, socket}
	end

	def handle_event("remove", _params, socket) do
		socket = 
			socket
			|> put_flash(:info, "Je dois apprendre à détruire")
		{:noreply, socket}
	end

	def handle_event("toggle-description", params, socket) do
		socket = 
			socket
			|> assign(description_shown: !params["state"])
		{:noreply, socket}
	end


	defp apply_action(socket, :current, _params) do
		IO.puts "Je passe par :current."
    socket
	end


	
end