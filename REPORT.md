# Rapport de synthèse — TP Conception d'une application conteneurisée

Résumé rapide
- Services présents dans le dépôt : `db` (Postgres), `api` (FastAPI), `front` (site statique).

Conformité avec le TD
- Routes demandées : `/status` et `/items` — implémentées dans `api/main.py` (OK).
- Base de données : `db/init.sql` initialise la table `items` et insère des échantillons (OK).
- Front : `front/index.html` interroge l'API et affiche la liste (OK).
- Orchestration : `docker-compose.yml` présent avec services `db`, `api`, `front` (OK).

Éléments ajoutés pour répondre au TD et bonnes pratiques
- `.env.example` fourni pour externaliser variables d'environnement.
- `.dockerignore` ajouté pour réduire le contexte de build.
- Dockerfiles multi-étapes :
  - `api/Dockerfile` est multi-étapes et installe les dépendances dans une étape builder puis exécute en utilisateur non-root `app`.
  - `front/Dockerfile` multi-étapes (builder + nginx) pour permettre compilation si nécessaire.
- Sécurité : dans `docker-compose.yml` les services `api` et `front` ont `user: "1000:1000"` et `cap_drop: [ALL]` pour réduire privilèges.
- Healthchecks : définis pour `db`, `api` et `front`.
- Supervision : endpoint `/metrics` exposé par l'API via `prometheus-client`.
- Scripts d'automatisation : `scripts/start.ps1` (PowerShell) et `scripts/deploy.sh` (bash) pour builder/déployer.

Ce qui manque ou pourrait être amélioré
- Dockerfile API : l'image finale utilise `python:3.11-slim` — on pourrait réduire davantage (distroless/minimal) pour gagner taille.
- Front : actuellement une page statique minimale; pour mesurer les gains multi-étapes il faudrait un vrai processus de build (webpack, vite). Image finale reste petite.
- Signature des images & scan : scripts incluent un emplacement pour `docker scan`, mais il manque la configuration d'un registre et la signature automatisée (nécessite accès à un registre et secrets).
- Migrations DB : actuellement on utilise `db/init.sql` qui s'exécute au premier démarrage ; l'utilisation d'un moteur de migrations (Alembic) serait plus propre.
- Tests unitaires / CI : pas de tests automatiques ni pipeline CI fourni (le script `deploy.sh` peut être intégré dans un pipeline).

Commandes clés utilisées
- `docker compose build`
- `docker compose up` ou `docker compose up -d`
- `docker compose down -v` pour réinitialiser la DB
- `docker compose logs -f`

Conclusion
Le projet contient la plupart des éléments demandés par le TD : API, DB initialisée, front, orchestrations, Dockerfiles multi-étapes basiques, healthchecks et métriques. Il manque surtout l'automatisation complète de la signature/push d'images vers un registre, des tests CI, et des optimisations d'image supplémentaires (distroless, tailles encore plus réduites). Pour finir le TD à 100% : ajouter pipeline CI (GitHub Actions / GitLab CI), config de registre et signature, et migrations DB.
