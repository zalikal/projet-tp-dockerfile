# Guide de soumission - TP Docker

Ce guide vous aide à vérifier que tous les fichiers sont bien présents et à pousser votre travail vers GitHub et Docker Hub.

## ✅ 1. Vérification des fichiers sources

### Fichiers qui DOIVENT être dans le dépôt GitHub :

```
projet-tp-docker/
├── .dockerignore
├── .env.example
├── .gitignore
├── README.md
├── REPORT.md
├── docker-compose.yml
├── api/
│   ├── Dockerfile          ← CRITIQUE
│   ├── main.py             ← CRITIQUE
│   └── requirements.txt    ← CRITIQUE
├── front/
│   ├── Dockerfile          ← CRITIQUE
│   ├── index.html          ← CRITIQUE
│   └── nginx.conf          ← CRITIQUE
├── db/
│   └── init.sql            ← CRITIQUE
└── scripts/
    ├── deploy.sh           ← CRITIQUE
    └── start.ps1           ← CRITIQUE
```

### Commande pour vérifier :

```powershell
Get-ChildItem -Recurse -File | Where-Object { $_.Extension -in @('.py','.txt','.html','.sql','.sh','.ps1','.conf','.yml','.md') -or $_.Name -like 'Dockerfile*' } | Select-Object FullName
```

---

## 🔧 2. Correction du .gitignore (DÉJÀ FAIT)

Le `.gitignore` a été corrigé pour ne plus bloquer les fichiers sources.

**Avant** : Bloquait tout par défaut avec `*`  
**Après** : N'ignore que les fichiers inutiles (cache Python, venv, logs, etc.)

---

## 📤 3. Pousser vers GitHub

### Étape 1 : Vérifier le statut Git

```powershell
cd 'C:\Users\SJ\Documents\1.COURS\M.PARICHON\projet-tp-docker'
git status
```

Vous devriez voir tous vos fichiers sources listés.

### Étape 2 : Ajouter tous les fichiers

```powershell
git add .
```

### Étape 3 : Vérifier ce qui sera commité

```powershell
git status
```

**IMPORTANT** : Vérifiez que ces fichiers apparaissent :
- ✅ `api/main.py`
- ✅ `api/Dockerfile`
- ✅ `api/requirements.txt`
- ✅ `front/Dockerfile`
- ✅ `front/index.html`
- ✅ `front/nginx.conf`
- ✅ `db/init.sql`
- ✅ `scripts/deploy.sh` et `scripts/start.ps1`

### Étape 4 : Commit

```powershell
git commit -m "Projet TP Docker complet - API + Front + DB + Documentation"
```

### Étape 5 : Push vers GitHub

```powershell
git push origin main
```

Ou si votre branche s'appelle `master` :

```powershell
git push origin master
```

Si c'est votre premier push :

```powershell
git remote add origin https://github.com/zalikal/projet-tp-dockerfile.git
git branch -M main
git push -u origin main
```

### Étape 6 : Vérifier sur GitHub

Allez sur : https://github.com/zalikal/projet-tp-dockerfile

**Vérifiez que vous voyez ces fichiers** :
- [ ] `api/main.py` avec le code FastAPI
- [ ] `api/Dockerfile` avec le build multi-étages
- [ ] `front/index.html` avec le code HTML
- [ ] `front/Dockerfile`
- [ ] `db/init.sql`
- [ ] Tous les scripts

⚠️ **Si les fichiers n'apparaissent pas**, c'est que le `.gitignore` les bloque encore ou qu'ils n'ont pas été ajoutés.

---

## 🐋 4. Pousser les images vers Docker Hub

### Prérequis

1. Compte Docker Hub : https://hub.docker.com
2. Connexion depuis votre machine

```powershell
docker login
```

Entrez votre username et password Docker Hub.

### Étape 1 : Builder les images localement

```powershell
cd 'C:\Users\SJ\Documents\1.COURS\M.PARICHON\projet-tp-docker'
docker compose build
```

### Étape 2 : Vérifier les images créées

```powershell
docker images | Select-String "projet-tp-docker"
```

Vous devriez voir :
- `projet-tp-docker-api`
- `projet-tp-docker-front`

### Étape 3 : Taguer les images pour Docker Hub

**Remplacez `VOTRE_USERNAME` par votre username Docker Hub** (ex: `zalikal`)

```powershell
$username = "VOTRE_USERNAME"  # Remplacez ici !

docker tag projet-tp-docker-api:latest ${username}/tp-docker-api:latest
docker tag projet-tp-docker-front:latest ${username}/tp-docker-front:latest
```

### Étape 4 : Pousser vers Docker Hub

```powershell
docker push ${username}/tp-docker-api:latest
docker push ${username}/tp-docker-front:latest
```

### Étape 5 : Vérifier sur Docker Hub

Allez sur : https://hub.docker.com/u/VOTRE_USERNAME

Vous devriez voir :
- ✅ `tp-docker-api`
- ✅ `tp-docker-front`

---

## 📋 5. Checklist finale pour le professeur

Avant de soumettre, vérifiez que :

### Sur GitHub (https://github.com/zalikal/projet-tp-dockerfile)
- [ ] Tous les fichiers sources sont visibles (api/, front/, db/, scripts/)
- [ ] Le fichier `REPORT.md` est présent et complet
- [ ] Le README.md explique comment lancer le projet
- [ ] Les Dockerfiles sont visibles et corrects

### Sur Docker Hub (https://hub.docker.com/u/VOTRE_USERNAME)
- [ ] Image `tp-docker-api` est publique
- [ ] Image `tp-docker-front` est publique
- [ ] Les images ont bien été poussées récemment (date)

### Localement (pour tester avant soumission)
- [ ] `docker compose up` fonctionne
- [ ] L'API répond sur http://localhost:8000/status
- [ ] Le front affiche sur http://localhost:8080
- [ ] Les données de la DB sont bien affichées

---

## 🚨 En cas de problème

### "Git n'ajoute pas mes fichiers"

```powershell
# Forcer l'ajout d'un fichier spécifique
git add -f api/main.py
git add -f api/Dockerfile
git add -f front/Dockerfile

# Vérifier ce qui est ignoré
git check-ignore -v api/main.py
```

### "Docker push échoue"

```powershell
# Vérifier que vous êtes connecté
docker login

# Vérifier le tag de l'image
docker images

# Vérifier le nom d'utilisateur
docker push VOTRE_USERNAME/tp-docker-api:latest
```

### "Les fichiers n'apparaissent pas sur GitHub"

1. Vérifiez le .gitignore :
```powershell
cat .gitignore
```

2. Listez ce qui sera commité :
```powershell
git ls-files
```

3. Si un fichier manque, ajoutez-le explicitement :
```powershell
git add api/main.py
git commit -m "Ajout fichier manquant"
git push
```

---

## 📧 Message pour le professeur

Après avoir suivi ce guide, envoyez un email au professeur avec :

**Objet** : Soumission complète TP Docker - [VOTRE NOM]

**Contenu** :
```
Bonjour M. Parichon,

Suite à votre retour, j'ai vérifié et corrigé mon dépôt. 
Tous les fichiers sources sont maintenant présents.

• Dépôt GitHub : https://github.com/zalikal/projet-tp-dockerfile
  → Tous les fichiers sources (api/, front/, db/, scripts/)
  → Rapport complet dans REPORT.md
  → Instructions de déploiement dans README.md

• Images Docker Hub :
  → https://hub.docker.com/r/VOTRE_USERNAME/tp-docker-api
  → https://hub.docker.com/r/VOTRE_USERNAME/tp-docker-front

Le projet est fonctionnel et peut être testé avec :
  docker compose up -d

Cordialement,
[VOTRE NOM]
```

---

## 🎯 Résumé des commandes à exécuter

```powershell
# 1. Vérifier et pousser vers GitHub
cd 'C:\Users\SJ\Documents\1.COURS\M.PARICHON\projet-tp-docker'
git status
git add .
git commit -m "Projet TP Docker complet - tous les fichiers sources"
git push origin main

# 2. Builder et pousser vers Docker Hub
docker login
docker compose build
$username = "VOTRE_USERNAME"  # Remplacez !
docker tag projet-tp-docker-api:latest ${username}/tp-docker-api:latest
docker tag projet-tp-docker-front:latest ${username}/tp-docker-front:latest
docker push ${username}/tp-docker-api:latest
docker push ${username}/tp-docker-front:latest

# 3. Vérifier sur les sites web
# GitHub : https://github.com/zalikal/projet-tp-dockerfile
# Docker Hub : https://hub.docker.com/u/VOTRE_USERNAME
```

---

**Date de dernière mise à jour** : 19 février 2026  
**Auteur** : Assistant de correction TP Docker
