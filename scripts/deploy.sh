#!/usr/bin/env bash
set -euo pipefail

# Script d'automatisation complet : build, test, scan, signature, push, déploiement
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "========================================"
echo "  🚀 Script d'automatisation de déploiement"
echo "========================================"

# Variables de configuration
REGISTRY="${DOCKER_REGISTRY:-docker.io}"
REGISTRY_USER="${DOCKER_USER:-votre-username}"
PROJECT_NAME="tp-docker"

echo ""
echo "📦 Étape 1 : Build des images..."
docker compose build

echo ""
echo "✅ Étape 2 : Vérification de la configuration docker-compose..."
docker compose config --quiet

echo ""
echo "🧪 Étape 3 : Tests unitaires (placeholder)..."
# Ajoutez ici vos tests unitaires si vous en avez
# Exemple : docker compose run --rm api pytest
echo "   → Tests non implémentés (à ajouter selon votre projet)"

echo ""
echo "🔍 Étape 4 : Scan de sécurité des images..."
if command -v docker >/dev/null 2>&1; then
  echo "   → Scan de l'image API..."
  # Docker scan (nécessite Docker Desktop ou Snyk)
  docker compose images | grep api | awk '{print $1":"$2}' | xargs -I {} sh -c 'docker scan {} || echo "⚠️  Docker scan non disponible ou erreurs trouvées"' || true
  
  echo "   → Scan de l'image Front..."
  docker compose images | grep front | awk '{print $1":"$2}' | xargs -I {} sh -c 'docker scan {} || echo "⚠️  Docker scan non disponible ou erreurs trouvées"' || true
  
  echo ""
  echo "   💡 Interprétation :"
  echo "      - Severité CRITICAL/HIGH : À corriger avant production"
  echo "      - Severité MEDIUM : À planifier dans les prochaines itérations"
  echo "      - Severité LOW : À surveiller"
else
  echo "⚠️  Docker scan non disponible. Installez Docker Desktop ou Snyk CLI."
fi

echo ""
echo "🔐 Étape 5 : Signature des images (Docker Content Trust)..."
if [ -n "${DOCKER_CONTENT_TRUST_ROOT_PASSPHRASE:-}" ] && [ -n "${DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE:-}" ]; then
  export DOCKER_CONTENT_TRUST=1
  echo "   → Docker Content Trust activé"
  
  # Tag et push des images signées
  echo "   → Tag et push de l'image API..."
  docker tag "${PROJECT_NAME}-api:latest" "${REGISTRY}/${REGISTRY_USER}/${PROJECT_NAME}-api:latest"
  docker push "${REGISTRY}/${REGISTRY_USER}/${PROJECT_NAME}-api:latest"
  
  echo "   → Tag et push de l'image Front..."
  docker tag "${PROJECT_NAME}-front:latest" "${REGISTRY}/${REGISTRY_USER}/${PROJECT_NAME}-front:latest"
  docker push "${REGISTRY}/${REGISTRY_USER}/${PROJECT_NAME}-front:latest"
  
  export DOCKER_CONTENT_TRUST=0
  echo "   ✅ Images signées et poussées vers le registre"
else
  echo "⚠️  Signature désactivée : variables DOCKER_CONTENT_TRUST_*_PASSPHRASE non définies"
  echo "   Pour activer la signature :"
  echo "   export DOCKER_CONTENT_TRUST_ROOT_PASSPHRASE='votre-passphrase'"
  echo "   export DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE='votre-passphrase'"
  echo ""
  echo "   💡 Les images peuvent être taguées et poussées manuellement :"
  echo "   docker tag ${PROJECT_NAME}-api:latest ${REGISTRY}/${REGISTRY_USER}/${PROJECT_NAME}-api:latest"
  echo "   docker push ${REGISTRY}/${REGISTRY_USER}/${PROJECT_NAME}-api:latest"
fi

echo ""
echo "🚀 Étape 6 : Déploiement de la stack..."
docker compose up -d

echo ""
echo "⏳ Attente du démarrage des services (30s)..."
sleep 30

echo ""
echo "🏥 Étape 7 : Vérification de la santé des services..."
docker compose ps

echo ""
echo "✅ Déploiement terminé !"
echo ""
echo "📊 Services disponibles :"
echo "   • Front : http://localhost:8080"
echo "   • API : http://localhost:8000"
echo "   • Docs API : http://localhost:8000/docs"
echo "   • Métriques : http://localhost:8000/metrics"
echo ""
echo "📝 Commandes utiles :"
echo "   • Voir les logs : docker compose logs -f"
echo "   • Arrêter : docker compose down"
echo "   • Redémarrer : docker compose restart"
echo ""
