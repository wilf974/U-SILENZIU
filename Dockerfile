# Utiliser l'image Node.js officielle
FROM node:18-alpine AS base

# Installer les dépendances libc6-compat nécessaires pour Alpine
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copier les fichiers de dépendances
COPY package.json package-lock.json* ./

# Installer les dépendances
RUN npm ci --ignore-scripts && npm cache clean --force

# Étape de build
FROM base AS builder

# Copier le code source
COPY . .

# Variables d'environnement Next.js
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV production

# Construire l'application
RUN npm run build

# Image de production
FROM node:18-alpine AS runner

WORKDIR /app

# Variables d'environnement
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

# Créer un utilisateur non-root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Créer le dossier data avec les bonnes permissions
RUN mkdir -p /app/data && chown -R nextjs:nodejs /app/data

# Configuration Next.js standalone
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Changer vers l'utilisateur non-root
USER nextjs

# Exposer le port
EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

# Commande pour démarrer l'application
CMD ["node", "server.js"]