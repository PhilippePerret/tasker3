# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tasker.Repo.insert!(%Tasker.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


alias Tasker.Repo
alias Tasker.Taches.{Chantier, TacheTime}
alias Tasker.Tache
alias Tasker.Comptes.User

defmodule Seeds do

	def create_user(pseudo, email, password) do
	%User{
      pseudo:           pseudo,
      email:            email,
      hashed_password:  Bcrypt.hash_pwd_salt(password),
      confirmed_at:     DateTime.truncate(DateTime.utc_now(), :second)
    }
    |> Repo.insert!()
  end

end


phil = Seeds.create_user("Phil", "philippe.perret@yahoo.fr", "xadcaX-huvdo9-xidkun")
_benoit = Seeds.create_user("Ben", "benoit.ackerman@yahoo.fr", "1234-56748-abcd")
_marion = Seeds.create_user("Marion", "marion.michel31@gmail.com", "abcd-xadcaX-zaerf")

# === AUTOENTREPRISE ===

chantier_autoentreprise = Repo.insert!(%Chantier{
	name: "Autoentreprise",
	description: "Contient toutes les tâches concernant l'autoentreprise",
	users: [phil]
})

# Tâche importante qui doit être fait tous les mois, et qui devient impérative à
# partir d'une certain date
Repo.insert!(%Tache{
	titre: "Déclaration et paiement impôts mensuel",
	description: "À faire tous les mois",
	chantier: chantier_autoentreprise,
	tache_time: %TacheTime{
		due_every: "0 10 5 * *", # tous les 5 du mois à 10 h 00
		duration: 30,
		imperative: {after: 15} # Elle devient impérative 15 jours après son départ
	}
})

# === CLIP ===

chantier_rev_clip = Repo.insert!( %Chantier{
		name: "CLIP : Chantier des révisions",
		description: "Contient toutes les tâches qui concerna la révision des exercices",
		users: [phil]
})

Repo.insert!( %Tache{
		titre: "Séance au pénitencier de Mont-de-Marsan",
		description: "Travail avec les détenus",
		chantier: chantier_rev_clip,
		tache_time: %TacheTime{
			due_every: "30 13 * * 4",
			duration: 180,
			imperative: true
		}
})

Repo.insert!( %Tache{
		titre: "Produire de nouveaux exercices",
		description: ""
})

Repo.insert!( %Tache{
		titre: "Réunion commission pédagogique",
		description: "Voir l'ordre du jour.",
		tache_time: %TacheTime{
			due_at: ~N"2024-12-09 09:00:00",
			end_at: ~N"2024-12-09 12:00:00",
			imperative: true
		}
})


#  === CRAZY ===

chantier_crazy = Repo.insert!( %Chantier{
		name: "Affaire Crazy Horse",
		description: "Toutes les tâches qui concerne la série Ça c'est paris !",
		users: [phil]
})

Repo.insert!( %Tache{
		titre: "Répondre à l'avocate",
		description: "Lui expliquer que je veux attendre la diffusion.",
		chantier: chantier_crazy,
		tache_time: %TacheTime{
			due_at: ~N"2024-11-20 10:00:00",
			urgence: 3,
			priority: 5
		}
})

tache = Repo.insert!(%Tache{
	titre: "Étudier les 6 épisodes en contrefaçon",
	description: "Voir ce qui ressemble ou peut-être tiré de la bible",
	chantier: chantier_crazy,
	tache_time: %TacheTime{
		due_at: ~N"2024-11-15 18:00:00",
		urgence: 3,
		priority: 5
	}
})
Repo.insert!(%Tache{
	titre: "Faire le rapport de contrefaçon à l'avocate",
	description: "En s'appuyant sur la tâche précédente",
	tache_before: tache,
	chantier: chantier_crazy,
	tache_time: %TacheTime{
		urgence: 3,
		priority: 5
	}
})

Repo.insert!(	%Tache{
		titre: "Comparer bible et document Maillé-Defosse",
		description: "Montrer en quoi le document produit par Marina et Maïté est directement inspiré de la bible",
		chantier: chantier_crazy,
		tache_time: %TacheTime{
			due_at: ~N"2024-12-20 10:00:00"
		}		
})

#### CAMA ####

chantier_cama = Repo.insert!( %Chantier{
	name: "CAMA Classe d'Analyse Musicale Appliquée",
	description: "Toutes les tâches concernant l'analyse musicale appliquée",
	users: [phil]
})

Repo.insert!(%Tache{
	titre: "Séance d'analyse avec Bernard Waterlot",
	description: "Analyse par visioconférence",
	chantier: chantier_cama,
	tache_time: %TacheTime{
		due_every: "0 12 * * 3",
		duration: 60,
		imperative: true
	}
})

Repo.insert!(%Tache{
	titre: "Produire et envoyer la facture mensuelle pour Bernard Waterlot",
	description: "Utiliser la commande `iced add` pour ajouter les cours et `iced facture` pour produire la facture",
	chantier: chantier_cama,
	tache_time: %TacheTime{
		due_every: "0 10 2 * *"
	}
})


####### QUATRE POUR DEUX ##########

chantier_4pour2 = Repo.insert!( %Chantier{
	name: "Quatre pour Deux",
	description: "Toutes les tâches qui concerne le quatre pour deux",
	users: [phil]
})

Repo.insert!(%Tache{
	titre: "Faire l'annonce des morceaux 4 pour 2 de la semaine passée",
	description: "Pour les obtenir, on joue la commande `4pour2 annonce` et on colle le résultat dans Facebook.",
	tache_time: %TacheTime{
		due_every: "0 10 * * 4"
	}
})
