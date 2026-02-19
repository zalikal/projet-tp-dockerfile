# Script de soumission automatique pour le TP Docker
# Ce script vérifie, commit et pousse vers GitHub et Docker Hub

param(
    [Parameter(Mandatory=$true)]
    [string]$DockerHubUsername,
    
    [switch]$SkipDockerHub,
    
    [string]$GitBranch = "main"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  🚀 Script de soumission TP Docker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition | Split-Path -Parent

# Vérifier qu'on est dans le bon dossier
if (-not (Test-Path "$projectRoot\docker-compose.yml")) {
    Write-Host "❌ Erreur : docker-compose.yml introuvable" -ForegroundColor Red
    Write-Host "   Le script doit être dans le dossier scripts/" -ForegroundColor Yellow
    exit 1
}

Set-Location $projectRoot

# ============================================
# 1. VÉRIFICATION DES FICHIERS CRITIQUES
# ============================================

Write-Host "📋 Étape 1 : Vérification des fichiers sources..." -ForegroundColor Yellow

$requiredFiles = @(
    "api/main.py",
    "api/Dockerfile",
    "api/requirements.txt",
    "front/index.html",
    "front/Dockerfile",
    "front/nginx.conf",
    "db/init.sql",
    "docker-compose.yml",
    "README.md",
    "REPORT.md"
)

$allPresent = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "   ❌ MANQUANT : $file" -ForegroundColor Red
        $allPresent = $false
    }
}

if (-not $allPresent) {
    Write-Host ""
    Write-Host "❌ Certains fichiers critiques sont manquants !" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Tous les fichiers sources sont présents" -ForegroundColor Green
Write-Host ""

# ============================================
# 2. GIT - COMMIT ET PUSH
# ============================================

Write-Host "📤 Étape 2 : Préparation Git..." -ForegroundColor Yellow

# Vérifier si Git est initialisé
if (-not (Test-Path ".git")) {
    Write-Host "   ⚠️  Dépôt Git non initialisé" -ForegroundColor Yellow
    Write-Host "   Initialisation..." -ForegroundColor Gray
    git init
    git remote add origin https://github.com/zalikal/projet-tp-dockerfile.git
}

# Afficher le statut
Write-Host "   État du dépôt :" -ForegroundColor Gray
git status --short

Write-Host ""
Write-Host "   Ajout de tous les fichiers..." -ForegroundColor Gray
git add .

Write-Host ""
Write-Host "   Fichiers qui seront commités :" -ForegroundColor Gray
git status --short | ForEach-Object { Write-Host "      $_" -ForegroundColor Cyan }

Write-Host ""
$confirm = Read-Host "Continuer avec le commit et push ? (o/n)"
if ($confirm -ne "o") {
    Write-Host "❌ Opération annulée" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "   Commit..." -ForegroundColor Gray
git commit -m "TP Docker complet - Tous fichiers sources API/Front/DB + Documentation"

Write-Host ""
Write-Host "   Push vers GitHub..." -ForegroundColor Gray
git push origin $GitBranch

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Code source poussé vers GitHub avec succès" -ForegroundColor Green
    Write-Host "   Vérifiez : https://github.com/zalikal/projet-tp-dockerfile" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ Erreur lors du push vers GitHub" -ForegroundColor Red
    Write-Host "   Vérifiez vos credentials et votre connexion" -ForegroundColor Yellow
    exit 1
}

# ============================================
# 3. DOCKER HUB - BUILD ET PUSH
# ============================================

if (-not $SkipDockerHub) {
    Write-Host ""
    Write-Host "🐋 Étape 3 : Build et push vers Docker Hub..." -ForegroundColor Yellow
    
    # Vérifier la connexion Docker
    Write-Host "   Vérification de la connexion Docker..." -ForegroundColor Gray
    docker info > $null 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ❌ Docker n'est pas démarré" -ForegroundColor Red
        Write-Host "   Lancez Docker Desktop et réessayez" -ForegroundColor Yellow
        exit 1
    }
    
    # Login Docker Hub
    Write-Host ""
    Write-Host "   Connexion à Docker Hub..." -ForegroundColor Gray
    docker login
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ❌ Échec de connexion à Docker Hub" -ForegroundColor Red
        exit 1
    }
    
    # Build des images
    Write-Host ""
    Write-Host "   Build des images..." -ForegroundColor Gray
    docker compose build
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ❌ Erreur lors du build" -ForegroundColor Red
        exit 1
    }
    
    # Tag des images
    Write-Host ""
    Write-Host "   Tag des images pour Docker Hub..." -ForegroundColor Gray
    
    docker tag projet-tp-docker-api:latest "${DockerHubUsername}/tp-docker-api:latest"
    docker tag projet-tp-docker-front:latest "${DockerHubUsername}/tp-docker-front:latest"
    
    # Push des images
    Write-Host ""
    Write-Host "   Push de l'image API..." -ForegroundColor Gray
    docker push "${DockerHubUsername}/tp-docker-api:latest"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ❌ Erreur lors du push de l'API" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "   Push de l'image Front..." -ForegroundColor Gray
    docker push "${DockerHubUsername}/tp-docker-front:latest"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ❌ Erreur lors du push du Front" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "✅ Images poussées vers Docker Hub avec succès" -ForegroundColor Green
    Write-Host "   Vérifiez : https://hub.docker.com/u/${DockerHubUsername}" -ForegroundColor Cyan
}

# ============================================
# 4. RÉSUMÉ FINAL
# ============================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✅ SOUMISSION TERMINÉE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Résumé de la soumission :" -ForegroundColor Cyan
Write-Host ""
Write-Host "   GitHub :" -ForegroundColor White
Write-Host "   • URL : https://github.com/zalikal/projet-tp-dockerfile" -ForegroundColor Gray
Write-Host "   • Fichiers poussés : ✅" -ForegroundColor Green
Write-Host ""

if (-not $SkipDockerHub) {
    Write-Host "   Docker Hub :" -ForegroundColor White
    Write-Host "   • URL : https://hub.docker.com/u/${DockerHubUsername}" -ForegroundColor Gray
    Write-Host "   • Image API : ${DockerHubUsername}/tp-docker-api:latest ✅" -ForegroundColor Green
    Write-Host "   • Image Front : ${DockerHubUsername}/tp-docker-front:latest ✅" -ForegroundColor Green
    Write-Host ""
}

Write-Host "📧 Message pour le professeur :" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""
Write-Host "Bonjour M. Parichon," -ForegroundColor White
Write-Host ""
Write-Host "Suite à votre retour, j'ai corrigé mon dépôt." -ForegroundColor White
Write-Host "Tous les fichiers sources sont maintenant présents." -ForegroundColor White
Write-Host ""
Write-Host "• Dépôt GitHub : https://github.com/zalikal/projet-tp-dockerfile" -ForegroundColor White
Write-Host "  → Tous les fichiers sources (api/, front/, db/, scripts/)" -ForegroundColor White
Write-Host "  → Rapport complet dans REPORT.md" -ForegroundColor White
Write-Host ""

if (-not $SkipDockerHub) {
    Write-Host "• Images Docker Hub :" -ForegroundColor White
    Write-Host "  → https://hub.docker.com/r/${DockerHubUsername}/tp-docker-api" -ForegroundColor White
    Write-Host "  → https://hub.docker.com/r/${DockerHubUsername}/tp-docker-front" -ForegroundColor White
    Write-Host ""
}

Write-Host "Le projet est fonctionnel avec : docker compose up -d" -ForegroundColor White
Write-Host ""
Write-Host "Cordialement," -ForegroundColor White
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

Write-Host "💡 Actions recommandées :" -ForegroundColor Yellow
Write-Host "   1. Vérifiez les liens ci-dessus dans votre navigateur" -ForegroundColor White
Write-Host "   2. Copiez le message pour le professeur" -ForegroundColor White
Write-Host "   3. Envoyez-lui un email avec les liens" -ForegroundColor White
Write-Host ""
