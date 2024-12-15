# TODO
#   * Tenir compte de la propriété 'imperative' qui rend prioritaire
#     sans exception une tâche impérative
#   * Deux tâches marquées impératives au même moment apparaissent
#     côte à côte.
#   * Tenir compte de la propriété due_every
#   * Une tâche due_every ne peut être détruite en la marquant finie 
#     lors d'une de ses instances. Sauf si on joue le bouton "détruire"
# 
#
defmodule Tasker.Taches.AlgorithmeTaches do

  alias Tasker.Repo
  alias Tasker.Tache
  # alias Tasker.Taches
  alias Tasker.Taches.{Chantier, TacheTime}
  alias Tasker.Taches.Chantier

  @doc """
  Retourne la tâche courante après les avoir relevées et les avoir triées
  en fonction de leurs caractéristiques.
  """
  def fetch_current_tache(user) do
    taches = fetch_current_taches(user)
    case length(taches) do
      0 -> 
        tache_sans_tache()
      1 -> 
        hd(taches)
      _nombre ->
        hd(classe_les_taches(taches, %{
            now: NaiveDateTime.utc_now(),
            am_end_time: get_user_am_end_time(),
            pm_end_time: get_user_pm_end_time()
          }))
    end
  end

  # Les deux données suivantes permettent de savoir si le temps
  # restant permet de produire une tâche. Le temps restant avant
  # midi ou la fin de journée, doit permettre de réaliser au moins
  # toute la tâche si elle est inférieure à 30 minutes et au moins
  # la moitié si elle fait plus de 30 minutes
  # Par exemple, pour une tâche de 30 minutes et 1 secondes, il faut
  # qu'il reste au moins 15 minutes
  defp get_user_am_end_time() do
    12
  end

  defp get_user_pm_end_time() do
    17
  end

  defp fetch_current_taches(user) do
    dans_une_semaine = NaiveDateTime.add(NaiveDateTime.utc_now(), 7 * 24 * 3600)
    user.taches
    # |> IO.inspect(label: "LISTE TÂCHES AVANT préload")
    |> Repo.preload([:tache_time, :chantier])
    # |> IO.inspect(label: "LISTE TÂCHES APRÈS préload (avant rejets)")
    |> Enum.reject(fn tache ->
      tache.tache_time && tache.tache_time.due_at && tache.tache_time.due_at > dans_une_semaine
    end)
    |> Enum.map(&if &1.tache_time == nil, do: %{&1 | tache_time: %TacheTime{}}, else: &1)
    # |> IO.inspect(label: "LISTE TÂCHES APRÈS")

  end

  def classe_les_taches(taches, options) do
    for tache <- taches do
      tache
      |> Map.from_struct()
      # |> Map.put(:precedence, 0)
      |> Map.merge(%{precedence: 0, calcul: []})
      |> add_precedence(:almost_finished, 5)
      |> add_precedence(:prioritaire, 6)
      |> add_precedence(:outdated, 17, options)
      |> add_precedence(:urgent, 24)
      |> add_precedence(:now, 100)
      |> add_precedence(:finissable, 150, options)
      |> mult_per_100()
      |> add_precedence_per_echeance(options)
      # |> IO.inspect(label: "Map de tâche à la fin")
    end
    # |> IO.inspect(label: "Les tâches avant le classement")
    |> Enum.sort_by(&(&1[:precedence]), :desc)
    # |> IO.inspect(label: "Les tâches après le classement")
  end

  defp mult_per_100(mtache) do
    mtache |> Map.put(:precedence, mtache.precedence * 100)
  end

  defp add_precedence(mtache, prec, ajout, options \\ %{}) do
    ajout_final = 
      case prec do
        :almost_finished ->
          if is_almost_finished?(mtache) do
            precedence_added_for_almost_finished(ajout, mtache)
          end
        :finissable ->
          if is_infinissable?(mtache, options) do
            precedence_added_for_infinissable(ajout, mtache, options)
          end
        :prioritaire ->
          if mtache.tache_time.priority do
            ajout * (mtache.tache_time.priority - 3)
          end
        :now -> 
          if is_now?(mtache), do: ajout
        :urgent ->
          if mtache.tache_time.urgence do # 1, 2 ou 3
            ajout * (mtache.tache_time.urgence - 2)
          end
        :outdated ->
          if is_outdated?(mtache, options), do: ajout
        prop ->
          IO.warn("Propriété inconnue : #{prop}.")
          0
      end || 0
    
    mtache 
    |> Map.put(:precedence, mtache[:precedence] + ajout_final)
    |> Map.put(:calcul, mtache.calcul ++ [%{prec => ajout_final * 100}]) # debug
  end

  defp is_almost_finished?(mtache) do
    ttime = mtache.tache_time
    if ttime && ttime.expected_time do
      moins_de_dix_pourcents = div(ttime.expected_time, 10)
      ttime.expected_time && ttime.elapsed_time && (ttime.expected_time - ttime.elapsed_time < moins_de_dix_pourcents)
    else
      false
    end
  end

  # Retourne le pourcentage de temps restant, en sachant que le
  # nombre ne devrait jamais être supérieur à 10 % puisqu'on ne peut
  # passer par ici que lorsque le temps restant est 10 % ou inférieur
  # Mais, peut-être la méthode sera-t-elle aussi employée pour autre 
  # chose ?…
  defp pourcentage_temps_restant(mtache) do
    ttime = mtache.tache_time
    (ttime.expected_time - ttime.elapsed_time) * (ttime.expected_time / 100)
  end

  def precedence_added_for_almost_finished(ajout, mtache) do
    ajout * (2 - (pourcentage_temps_restant(mtache) / 10))
  end

  # Une tâche n'est pas finissable lorsqu'on est trop près de la fin
  # de la matinée (définie par options.am_end_time) ou trop près de la
  # fin de la journée (définie par options.pm_end_time) et que ce temps
  # restant ne permet pas à la tâche d'être finie (si elle est inférieure 
  # à 30 minutes) ou amorcée sérieusement (si elle est supérieure à 30 mn)
  #
  # Concrètement :
  #   Si la tâche doit être faite en 30 minutes ou moins — ou qu'il lui
  #   reste 30 (ou moins) pour être achevée :
  #     S'il reste + de 30 minutes avant la fin => on la fait
  #     Sinon, on la pénalise (cf. precedence_added_for_infinissable)
  #   Si la tâche doit être faite en plus de 30 minutes — ou qu'il lui
  #   reste plus de 30 mn pour être achevée :
  #     S'il reste + 30 minutes avant la fin, on la fait
  #     Sinon, on la pénalise
  #
  # MAIS ATTENTION  : dans tous les cas, si on a dépassé le temps de
  # fin de la journée, la tâche est finisible
  def is_infinissable?(mtache, options) do
    # IO.inspect(mtache, label: "Tâche en entrée")
    # IO.inspect(options, label: "Options en entrée")
    now = options.now
    ttime = mtache.tache_time
    tmn_now = now.hour * 60 + now.minute
    # |> IO.inspect(label: "tmn now")
    tmn_end_day = options.pm_end_time * 60
    # |> IO.inspect(label: "tmn end day")
    end_day_depassed = tmn_now > tmn_end_day
    pas_de_duree_definie = ttime.expected_time == nil
    cond do
    end_day_depassed ->
      false
    pas_de_duree_definie ->
      false
    true ->
      tmn_fin_am = options.am_end_time * 60
      # |> IO.inspect(label: "tmn_fin_am")
      tmn_fin_pm = options.pm_end_time * 60
      # |> IO.inspect(label: "tmn_fin_pm")
      is_matin = tmn_now <= tmn_fin_am
      # |> IO.inspect(label: "is_matin")
      tmn_fin = if is_matin, do: tmn_fin_am, else: tmn_fin_pm
      # |> IO.inspect(label: "tmn_fin")
      tmn_restant = ttime.expected_time - (ttime.elapsed_time || 0)
      # |> IO.inspect(label: "tmn_restant")
      if tmn_now + tmn_restant > tmn_fin do
        # Quand le temps restant est insuffisant pour terminer
        # la tâche
        tmn_workable = tmn_fin - tmn_now
        # impossible s'il reste moins de 30 minutes et que le temps
        # restant est supérieur à 30 minutes
        if tmn_workable < 30 do
          if tmn_workable >= tmn_restant do
            false
          else
            true
          end
        else
          false
        end
      else
        false
      end
    end
  end

  def precedence_added_for_infinissable(ajout, mtache, _options) do
    ttime = mtache.tache_time
    tmn_restant = ttime.expected_time - (ttime.elapsed_time || 0)
    ajout * -1 * tmn_restant
  end

  defp is_now?(mtache) do
    mtache[:now] && mtache.now == true
  end
  
  defp is_outdated?(mtache, options) do
    (mtache.tache_time.due_at && mtache.tache_time.due_at < options.now) \
    || (mtache.tache_time.expected_end_at && mtache.tache_time.expected_end_at < options.now)
  end

  # Cette fonction permet d'ajouter à la précédence la valeur suivant l'échéance
  # de la tâche.
  # Cette échéance est mise à 30 jours si ni la date de début attendu ni la date
  # de fin attendu n'est définie.
  #
  # On retire à :precedence le nombre d'heures avant l'échéance
  #
  # @param options contient pour le moment :now pour ne pas avoir à le calculer
  # à chaque fois.
  defp add_precedence_per_echeance(mtache, options) do
    ttime = mtache.tache_time
    retrait_heures =
      cond do
      ttime.due_at ->
        NaiveDateTime.diff(ttime.due_at, options.now, :hour)
      ttime.expected_end_at ->
        NaiveDateTime.diff(ttime.expected_end_at, options.now, :hour)
      ttime.urgence > 2 ->
        0
      ttime.priority > 3 ->
        0
      true ->
        31 * 24 # 744 heures (un mois)
      end
    mtache
    |> Map.put(:precedence, mtache.precedence - retrait_heures)
    |> Map.put(:calcul, mtache.calcul ++ [%{echeance: - retrait_heures}]) # debug
  end

	defp tache_sans_tache do
		chantier = %Chantier{name: "Ceci n'est pas un chantier"}
		%Tache{
			titre: "Ceci n'est pas une tâche (vous n'avez rien à faire).", 
			description: "Si vous cherchez du travail, définissez donc un chantier pour vous, et associez-lui des tâches.", 
			chantier: chantier
		}
	end

end