# TODO (TESTS À AJOUTER)
#
#   * une tâche marquée imperative passe avant toutes les autres, même avec une
#     priority/urgence faible
#   * deux tâches marquées imperative commençant au même moment sont affichées
#     côte à côte
#   * deux tâches marquées imperative se chevauchant (la deuxième ne commence pas
#     en même temps que la première) sont affichées côte à côte.
#
defmodule Tasker.AlgoTest do

  use ExUnit.Case

  alias Tasker.Tache
  alias Tasker.Taches.{TacheTime, Chantier, AlgorithmeTaches}

  defp options do
    %{
      now: now_naif(),
      am_end_time: 12, # temps de fin de la matinée (ante meridiem)
      pm_end_time: 17  # temps de début de l'après-midi (post meridiem)
    }
  end

  def build_tache(titre, props \\ %{}) do
    %Tache{titre: titre}
    |> add_prop_if_required(:id, props)
    |> add_prop_if_required(:description, props)
    |> add_prop_if_required(:now, props)
    |> add_prop_time_if_required(:urgence, props)
    |> add_prop_time_if_required(:priority, props)
    |> add_prop_time_if_required(:due_at, props)
    |> add_prop_time_if_required(:expected_end_at, props)
    |> add_prop_time_if_required(:expected_time, props)
    |> add_prop_time_if_required(:elapsed_time, props)
    |> add_tache_time_if_required_in()
    |> add_chantier_if_required_in()
  end

  def add_prop_if_required(tache, prop, props) do
    if props[prop] == nil do
      tache
    else
      Map.put(tache, prop, props[prop])
    end
  end

  def add_prop_time_if_required(tache, prop, props) do
    if props[prop] == nil do
      tache
    else
      add_prop_time(tache, prop, props[prop])
    end
  end

  def add_tache_time_if_required_in(sujet) do
    if Ecto.assoc_loaded?(sujet.tache_time) do
      # IO.inspect(sujet, label: "TacheTime est connue dans : ")
      sujet
    else
      # IO.inspect(sujet, label: "TacheTime n'est pas connue dans :")
      %{sujet | tache_time: %TacheTime{}}
      # |> IO.inspect(label: "La tâche après ajout de TacheTime vierge")
    end
  end

  def add_chantier_if_required_in(sujet) do
    if Ecto.assoc_loaded?(sujet.chantier) do
      sujet
    else
      %{sujet | chantier: %Chantier{name: "Un chantier anonyme"}}
    end
  end

  def add_prop_time(sujet, prop, value) do
    sujet = add_tache_time_if_required_in(sujet)
    # IO.inspect(sujet, label: "Tache avant ajout propriété tache_time")
    Map.put(sujet, :tache_time, Map.put(sujet.tache_time, prop, value))
    # |> IO.inspect(label: "Après ajout de la propriété tache_time")
  end

  defp compare_et_return_first(tache1, tache2) do
    sorted = AlgorithmeTaches.classe_les_taches([tache2, tache1], options())
    hd(sorted)
  end
  defp  compare_et_return_first(tache1, tache2, _debug) do
    sorted = AlgorithmeTaches.classe_les_taches([tache2, tache1], options())
    |> IO.inspect(label: "Liste classée")
    hd(sorted)
  end








  describe "Le classement des tâches" do

    test "met une T marquée NOW avant une T neutre" do
      titre_tache_now = "Tâche à faire maintenant"
      tache1 = build_tache(titre_tache_now, %{now: true})
      tache2 = build_tache("Une tâche normale")
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_tache_now
    end

    test "met une T marquée NOW prioritaire avant une T marquée NOW moins prioritaire" do
      titre_tache_now_prioritaire = "Tâche NOW et prioritaire"
      tache1 = build_tache(titre_tache_now_prioritaire, %{now: true, priority: 5})
      tache2 = build_tache("Tâche NOW moins prioritaire", %{now: true, priority: 4})
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_tache_now_prioritaire
    end

    test "met une T marquée NOW urgente avant une T marquée NOW moins urgente" do
      titre_tache_now_urgente = "Tâche NOW et urgente"
      tache1 = build_tache(titre_tache_now_urgente, %{now: true, urgence: 3})
      tache2 = build_tache("Tâche NOW moins urgente", %{now: true, urgence: 1})
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_tache_now_urgente
    end

    test "met une T dépassée avant une T neutre" do 
      titre_premiere = "Tâche dépassée"
      yesterday = NaiveDateTime.add(now_naif(), - 24 * 3600)
      tache1 = build_tache(titre_premiere, %{due_at: yesterday})
      tache2 = build_tache("Tâche neutre")
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_premiere
    end
    
    test "met une T plus dépassée avant un T moins dépassée" do
      titre_premiere = "Tâche dépassée"
      hier = NaiveDateTime.add(now_naif(), - 24 * 3600)
      avant_hier = NaiveDateTime.add(hier, - 24 * 3600)
      tache1 = build_tache(titre_premiere, %{due_at: avant_hier})
      tache2 = build_tache("Tâche neutre", %{due_at: hier})
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_premiere
    end
      
    test "met une T moins lointaine avant un T plus lointaine" do
      titre_premiere = "Tâche moins lointaine"
      demain = NaiveDateTime.add(now_naif(), 24 * 3600)
      apres_demain = NaiveDateTime.add(demain, 24 * 3600)
      tache1 = build_tache(titre_premiere, %{due_at: demain})
      tache2 = build_tache("Tâche plus lointaine", %{due_at: apres_demain})
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_premiere
    end

    test "met une T urgente avant une T dépassé" do
      titre_premiere = "Tâche urgente"
      avant_hier = NaiveDateTime.add(now_naif(), - 2 * 24 * 3600)
      tache1 = build_tache(titre_premiere, %{urgence: 3})
      tache2 = build_tache("Tâche dépassée", %{due_at: avant_hier})
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_premiere
    end


    test "met une T prioritaire avant une T neutre" do
      titre_prioritaire = "Première avec priorité"
      tache1 = build_tache(titre_prioritaire, %{id: 1, priority: 5})
      tache2 = build_tache("Deuxième sans priorité", %{id: 2})
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_prioritaire
    end
 
    test "met une T à priorité forte avant une T avec priorité faible" do
      titre_tache_prioritaire = "Tâche prioritaire"
      tache1 = build_tache(titre_tache_prioritaire, %{priority: 5})    
      tache2 = build_tache("Non prioritaire", %{priority: 4, description: "Description de la tâche non prioritaire"})
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_tache_prioritaire
    end

    test "met une T neutre avant une T à priorité faible" do
      titre_tache_neutre = "Tâche sans priorité"
      tache1 = build_tache(titre_tache_neutre)    
      tache2 = build_tache("Non prioritaire", %{priority: 2, description: "Description de la tâche non prioritaire"})
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_tache_neutre
    end

    test "met T urgente avant une T neutre" do
      titre_tache_urgente = "Tâche avec urgence"
      tache1 = build_tache(titre_tache_urgente, %{urgence: 3})
      tache2 = build_tache("T sans urgence")
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_tache_urgente
    end

    test "met une T neutre avant une T à urgence faible" do
      titre_tache_neutre = "Tâche neutre"
      tache1 = build_tache(titre_tache_neutre)
      tache2 = build_tache("T sans urgence", %{urgence: 1})
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_tache_neutre
    end

    test "met une T à urgence forte avant une T à urgence faible" do
      titre_tache_urgente = "Tâche avec urgence forte"
      tache1 = build_tache(titre_tache_urgente, %{urgence: 3})
      tache2 = build_tache("T à urgence faible", %{urgence: 2})
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_tache_urgente
    end
 
    test "met une T presque finie avant une T neutre" do
      # Une tâche presque finie est une tâche dont il ne reste que
      # moins d'un dizième de temps à faire. Il faut donc :
      # 1) que sa durée attendue soit fixée expected_time
      # 2) qu'elle est déjà été travaillée : elapsed_time
      titre_premiere = "Tâche presque finie"
      tache1 = build_tache(titre_premiere, %{expected_time: 100, elapsed_time: 91})
      tache2 = build_tache("Tâche neutre")
      premiere = compare_et_return_first(tache1, tache2)
      assert premiere.titre == titre_premiere
    end

    @tag :skip
    test "met une T vraiment presque finie avant une T presque finie", do: nil

    @tag :skip
    test "met une T de moins de 30 mn infinissable après" do
      # @infinissable ici veut dire qu'il ne reste pas assez de temps
      # @note
      #   Ici, il faut fixer de force le now_naif dans options()
      now_fictif = ~N"2024-11-01 11:40:00"
      options = %{
        now: now_fictif,
        am_end_time: 12, pm_end_time: 17
      }

    end

    @tag :skip
    test "met une T plus de 30 mn impossible à finir après une tâche de moins de 30 mn" do
      # @infinissable ici veut dire qu'il ne reste pas assez de temps
      # @note
      #   Ici, il faut fixer de force le now_naif dans options()
    end

    @tag :skip
    test "met une T de plus de 30 mn infinissage après une T de moins de 30 mn infinissable" do
      # @infinissable ici veut dire qu'il ne reste pas assez de temps
      # @note
      #   Ici, il faut fixer de force le now_naif dans options()

    end

    @tag :skip
    test "met un T infinissable mais urgent avant si on a dépassé le temps de fin de journée" do
      # @infinissable ici veut dire qu'il ne reste pas assez de temps
      # @note
      #   Ici, il faut fixer de force le now_naif dans options()
      options = %{
        now: ~N"2024-11-10 18:00:00",
        am_end_time: 12,
        pm_end_time: 17.5
      }


    end

    # @tag :skip
    test "met toutes les tâches dans le bon ordre" do
      # L'idée de ce test est de reprendre l'intégralité des possibilités
      # et de faire un test (plusieurs fois, en mélangeant la liste) pour
      # voir si on obtient toujours la même liste.

      add = fn a, b -> [b | a] end

      # Données utiles
      now_fictif = ~N"2024-11-01 11:50:00"
      hier = NaiveDateTime.add(now_fictif, - 24 * 3600)
      quinze_days_ago = NaiveDateTime.add(now_fictif, - 15 * 24 * 3600)
      sept_days_ago   = NaiveDateTime.add(now_fictif, - 7 * 24 * 3600)

      # - Définition des tâches -
      task_list =
      []
      |> add.(build_tache("Tâche neutre"))
      |> add.(build_tache("Tâche infinissable", %{expected_time: 60}))
      |> add.(build_tache("Tâche hyper urgente mais infinissable", %{due_at: sept_days_ago, urgence: 3, prority: 5, expected_time: 60}))
      |> add.(build_tache("Tâche un peu dépassée", %{due_at: hier}))
      |> add.(build_tache("Tâche très dépassée", %{due_at: quinze_days_ago}))
      |> add.(build_tache("Tâche urgente", %{urgence: 3}))
      |> add.(build_tache("Tâche prioritaire", %{priority: 4}))
      |> add.(build_tache("Tâche très prioritaire", %{priority: 5}))
      |> add.(build_tache("Tâche presque finie", %{expected_time: 100, elapsed_time: 91}))
      |> add.(build_tache("Tâche vraiment presque finie", %{expected_time: 100, elapsed_time: 98}))
        

      # La liste bonne des titres qu'on doit trouver :
      # J'aurais bien sûr plein d'autres moyens, mais je préfère que ce
      # soit clair au niveau du code
      titre_classes = [
        "Tâche urgente",
        "Tâche très prioritaire",
        "Tâche vraiment presque finie",
        "Tâche prioritaire",
        "Tâche presque finie",
        "Tâche très dépassée",
        "Tâche un peu dépassée",
        "Tâche neutre",
        "Tâche hyper urgente mais infinissable",
        "Tâche infinissable"
      ]

      options = %{
        now: now_fictif,
        am_end_time: 12, 
        pm_end_time: 17
      }

      # - Boucle pour faire plusieurs fois -
      for _x <- 1..10 do
        # - Mélanger la liste de tâches -
        liste = Enum.shuffle(task_list)

        # - Appeler la fonction de classement (test) -
        sorted = AlgorithmeTaches.classe_les_taches(liste, options)
        
        # - Contrôle de l'ordre -
        nombre_taches = length(titre_classes) - 1
        for ix <- 0..nombre_taches do
          expected_titre = Enum.at(titre_classes, ix)
          tache = Enum.at(sorted, ix)
          # IO.puts "titre = #{expected_titre} / tache.titre = #{tache.titre}"
          assert expected_titre == tache.titre
        end

      end
    end

  end


  #  --- Les sous-méthodes ---


  test "renvoie la bonne précédence ajoutée pour une T presque finie" do
    for [tdata, expected_ajout] <- [
      [%{expected_time: 100, elapsed_time: 50}, -3],
      [%{expected_time: 100, elapsed_time: 90}, 1],
      [%{expected_time: 100, elapsed_time: 95}, 1.5],
    ] do
      actual = AlgorithmeTaches.precedence_added_for_almost_finished(1, %{tache_time: tdata})
      assert actual == expected_ajout
    end
  end

  test "utilise bien la méthode is_infinissable" do

    options = %{
      now: ~N"2021-01-01 11:50:00",
      am_end_time: 12, pm_end_time: 17
    }

    tache = build_tache("Une T finissable")
    |> struct()
    assert false == AlgorithmeTaches.is_infinissable?(tache, options)

    tache = build_tache("T tout juste finissable", %{expected_time: 10})
    |> struct()
    assert false == AlgorithmeTaches.is_infinissable?(tache, options)

    tache = build_tache("Une T infinissable (manque 1 mn)", %{expected_time: 11}) 
    |> struct()
    assert true == AlgorithmeTaches.is_infinissable?(tache, options)

    tache = build_tache("T longue infinissable (pas le temps)", %{expected_time: 120})
    |> struct()
    options = %{
      now: ~N"2021-01-01 11:31:00",
      am_end_time: 12, pm_end_time: 17
    }
    actual = AlgorithmeTaches.is_infinissable?(tache, options)
    assert true == actual

    tache = build_tache("T longue finissable (reste le temps)", %{expected_time: 120})
    |> struct()
    options = %{
      now: ~N"2024-01-01 09:00:00", am_end_time: 12, pm_end_time: 17.5
    }
    actual = AlgorithmeTaches.is_infinissable?(tache, options)
    assert false == actual

    tache = build_tache("T longue finissable (reste 30 minutes)", %{expected_time: 120})
    |> struct()
    options = %{
      now: ~N"2024-01-01 11:29:00", am_end_time: 12, pm_end_time: 17.5
    }
    actual = AlgorithmeTaches.is_infinissable?(tache, options)
    assert false == actual




  end

  def now_naif, do: NaiveDateTime.utc_now()

end