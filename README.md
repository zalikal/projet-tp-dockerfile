Fiche d'utilisation 

But : lancer rapidement le TP avec Docker (Postgres + API FastAPI + front statique).

Prérequis
- Avoir Docker Desktop installé et lancé.
- Ouvrir PowerShell.
- Se placer dans le dossier racine du projet (celui qui contient `docker-compose.yml`).

Étapes (rapides)

1) Aller dans le dossier du projet :

```powershell
cd 'C:\Users\SJ\Documents\1.COURS\M.PARICHON\projet-tp-docker'
```

2) (Optionnel la 1re fois) Construire les images :

```powershell
docker compose build
```

3) Lancer les services :

```powershell
docker compose up
```

Pour lancer en arrière-plan :

```powershell
docker compose up -d
```

Accès après démarrage
- Front (site) : http://localhost:8080
- API : http://localhost:8000
- Swagger (docs) : http://localhost:8000/docs
- Endpoint santé : http://localhost:8000/status
- Récupérer items : http://localhost:8000/items

Commandes utiles
- Voir les logs (suivre) :

```powershell
docker compose logs -f
```

- Arrêter les services (sans supprimer les volumes) :

```powershell
docker compose down
```

- Arrêter et supprimer les volumes (réinitialiser la DB) :

```powershell
docker compose down -v
```

- Rebuild complet :

```powershell
docker compose build --no-cache
docker compose up -d
```

Dépannage rapide (comme je le ferais en TP)
- L'API ne se connecte pas à la DB :
	- Vérifie que le container `db` est démarré : `docker ps`.
	- Regarde les logs du service DB : `docker compose logs db`.
	- Si l'init SQL a planté, check `db/init.sql` pour une erreur.
- Le front affiche une erreur pour la requête fetch :
	- Ouvre la console du navigateur (F12) pour voir l'erreur (CORS, 404...).
	- L'API autorise par défaut CORS, mais si tu as modifié des variables d'env, vérifie `FRONT_ORIGIN` dans `docker-compose.yml`.
- Docker ne démarre pas / erreurs Docker :
	- Assure-toi que Docker Desktop est lancé.
	- Relance Docker Desktop puis réessaye `docker compose up`.

Réinitialiser la DB (si tu veux tout recommencer)

```powershell
docker compose down -v
docker compose up
```

Astuce rapide
- Tester l'API sans le front :

```powershell
curl http://localhost:8000/items
```

Checklist avant présentation
- [ ] Docker Desktop lancé
- [ ] J'ai fait `docker compose up` et rien de critique n'apparaît dans les logs
- [ ] J'ouvre http://localhost:8080 et http://localhost:8000/status
