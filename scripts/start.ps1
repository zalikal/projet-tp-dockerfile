# Script PowerShell complet pour builder, scanner et lancer le projet
param(
  [switch]$Detached,
  [switch]$Scan,
  [switch]$Push,
  [string]$Registry = "docker.io",
  [string]$RegistryUser = "votre-username"
)

Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition)
Set-Location ..

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  🚀 Script de déploiement Docker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📦 Étape 1 : Build des images..." -ForegroundColor Yellow
docker compose build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors du build des images" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Étape 2 : Vérification de la configuration..." -ForegroundColor Yellow
docker compose config --quiet

if ($Scan) {
    Write-Host ""
    Write-Host "🔍 Étape 3 : Scan de sécurité des images..." -ForegroundColor Yellow
    
    Write-Host "   → Scan de l'image API..." -ForegroundColor Gray
    docker scan projet-tp-docker-api:latest 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Scan API terminé" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Scan non disponible ou erreurs trouvées" -ForegroundColor Yellow
    }
    
    Write-Host "   → Scan de l'image Front..." -ForegroundColor Gray
    docker scan projet-tp-docker-front:latest 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Scan Front terminé" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Scan non disponible ou erreurs trouvées" -ForegroundColor Yellow
    }
}

if ($Push) {
    Write-Host ""
    Write-Host "🔐 Étape 4 : Tag et push des images..." -ForegroundColor Yellow
    
    $images = @("api", "front")
    foreach ($img in $images) {
        $localTag = "projet-tp-docker-$img:latest"
        $remoteTag = "$Registry/$RegistryUser/projet-tp-docker-$img:latest"
        
        Write-Host "   → Tag et push de $img..." -ForegroundColor Gray
        docker tag $localTag $remoteTag
        docker push $remoteTag
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ $img poussée vers le registre" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Erreur lors du push de $img" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "🚀 Étape finale : Démarrage des services..." -ForegroundColor Yellow

if ($Detached) {
  docker compose up -d
} else {
  docker compose up
}

if ($Detached) {
    Write-Host ""
    Write-Host "✅ Services démarrés en arrière-plan !" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Services disponibles :" -ForegroundColor Cyan
    Write-Host "   • Front : http://localhost:8080" -ForegroundColor White
    Write-Host "   • API : http://localhost:8000" -ForegroundColor White
    Write-Host "   • Docs API : http://localhost:8000/docs" -ForegroundColor White
    Write-Host "   • Métriques : http://localhost:8000/metrics" -ForegroundColor White
    Write-Host ""
    Write-Host "📝 Commandes utiles :" -ForegroundColor Cyan
    Write-Host "   • Voir les logs : docker compose logs -f" -ForegroundColor White
    Write-Host "   • Arrêter : docker compose down" -ForegroundColor White
    Write-Host "   • Statut : docker compose ps" -ForegroundColor White
    Write-Host ""
}

