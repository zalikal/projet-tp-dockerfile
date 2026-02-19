# ===== Étape 1 : Builder (préparation des fichiers statiques) =====
FROM nginx:1.25-alpine AS builder

# Cette étape pourrait être utilisée pour compiler un front (React, Vue, etc.)
# Pour ce TP, on copie simplement le HTML statique
COPY index.html /tmp/index.html

# ===== Étape 2 : Image finale avec nginx =====
FROM nginx:1.25-alpine

# Supprimer la config nginx par défaut
RUN rm /etc/nginx/conf.d/default.conf

# Copier notre configuration nginx personnalisée
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copier le fichier HTML depuis l'étape builder
COPY --from=builder /tmp/index.html /usr/share/nginx/html/index.html

# Créer un utilisateur non-root
RUN addgroup -S app && adduser -S app -G app

# Créer les répertoires nécessaires et donner les droits
RUN mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp /var/run && \
    chown -R app:app /usr/share/nginx/html /var/cache/nginx /var/run && \
    touch /var/run/nginx.pid && \
    chown app:app /var/run/nginx.pid

# Passer à l'utilisateur non-root
USER app

# Exposer le port 80
EXPOSE 80

# Lancer nginx en mode foreground
CMD ["nginx", "-g", "daemon off;"]
