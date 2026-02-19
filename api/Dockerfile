# ===== Étape 1 : Builder - Installation des dépendances =====
FROM python:3.11-slim AS builder

WORKDIR /app

# Copier uniquement requirements.txt pour profiter du cache Docker
COPY requirements.txt .

# Installer les dépendances dans un répertoire temporaire
RUN pip install --no-cache-dir --user -r requirements.txt

# ===== Étape 2 : Runtime - Image finale légère =====
FROM python:3.11-slim

WORKDIR /app

# Créer un utilisateur non-root
RUN useradd -m -u 1000 app && \
    chown -R app:app /app

# Copier les dépendances installées depuis l'étape builder
COPY --from=builder /root/.local /home/app/.local

# Copier le code source de l'application
COPY --chown=app:app main.py .

# Ajouter les binaires Python au PATH
ENV PATH=/home/app/.local/bin:$PATH

# Passer à l'utilisateur non-root
USER app

# Exposer le port 8000
EXPOSE 8000

# Healthcheck intégré
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/status')"

# Lancer l'application avec uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
