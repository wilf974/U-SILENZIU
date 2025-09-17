# 🐳 Configuration Docker - U Silenziu

## 📋 Vue d'ensemble

Ce projet utilise Docker Compose avec des configurations séparées pour le développement et la production.

## 🚀 Utilisation

### Développement

```bash
# Démarrer l'environnement de développement
docker compose -f docker-compose.dev.yml up -d

# Voir les logs
docker compose -f docker-compose.dev.yml logs -f

# Arrêter l'environnement de développement
docker compose -f docker-compose.dev.yml down
```

### Production

```bash
# Démarrer l'environnement de production
docker compose -f docker-compose.prod.yml up -d

# Voir les logs
docker compose -f docker-compose.prod.yml logs -f

# Arrêter l'environnement de production
docker compose -f docker-compose.prod.yml down
```

### Configuration par défaut

```bash
# Utilise docker-compose.yml (configuration de base)
docker compose up -d
```

## 📁 Fichiers de configuration

### Docker Compose

- `docker-compose.yml` - Configuration par défaut
- `docker-compose.dev.yml` - Configuration pour le développement
- `docker-compose.prod.yml` - Configuration pour la production

### Dockerfiles

- `Dockerfile` - Image de production
- `Dockerfile.dev` - Image de développement

### Variables d'environnement

- `env.dev` - Variables pour le développement
- `env.prod` - Variables pour la production
- `env.example` - Exemple de configuration

## 🔧 Services

### Développement

- **PostgreSQL** : Base de données sur le port 5432
- **Next.js** : Application sur le port 3000 (hot reload activé)
- **Redis** : Cache sur le port 6379 (optionnel)

### Production

- **PostgreSQL** : Base de données optimisée
- **Next.js** : Application optimisée
- **Nginx** : Reverse proxy sur les ports 80/443
- **Redis** : Cache optimisé
- **Backup** : Sauvegarde automatique quotidienne

## 🗄️ Base de données

### Développement

- Base : `usilenzio_dev`
- Utilisateur : `usilenzio_user`
- Mot de passe : `usilenzio_password_dev`

### Production

- Base : `usilenzio`
- Utilisateur : `usilenzio_user`
- Mot de passe : `usilenzio_password_2024`

## 🔐 Sécurité

### Développement

- Secrets par défaut (à changer en production)
- Debug activé
- Logs détaillés

### Production

- ⚠️ **IMPORTANT** : Changez tous les secrets dans `env.prod`
- Debug désactivé
- Logs optimisés
- Limites de ressources
- Sauvegarde automatique

## 📊 Monitoring

### Health Checks

Tous les services incluent des health checks :

```bash
# Vérifier le statut des services
docker compose ps

# Voir les health checks
docker inspect <container_name> | grep -A 10 Health
```

### Logs

```bash
# Logs en temps réel
docker compose logs -f

# Logs d'un service spécifique
docker compose logs -f u-silenziu

# Logs avec timestamps
docker compose logs -f -t
```

## 🗂️ Volumes

### Développement

- `postgres_dev_data` : Données PostgreSQL
- `redis_dev_data` : Données Redis
- Code source monté pour le hot reload

### Production

- `postgres_prod_data` : Données PostgreSQL
- `redis_prod_data` : Données Redis
- `./backups` : Sauvegardes
- `./logs` : Logs de l'application

## 🔄 Sauvegarde

### Automatique

La production inclut un service de sauvegarde automatique qui s'exécute quotidiennement à 2h du matin.

### Manuelle

```bash
# Sauvegarde manuelle
docker exec u-silenziu-backup /backup.sh

# Restaurer une sauvegarde
docker exec -i u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio < backup_file.sql
```

## 🚨 Dépannage

### Problèmes courants

1. **Port déjà utilisé**
   ```bash
   # Vérifier les ports utilisés
   netstat -tulpn | grep :3000
   
   # Arrêter les services
   docker compose down
   ```

2. **Base de données non accessible**
   ```bash
   # Vérifier les logs PostgreSQL
   docker compose logs postgres
   
   # Redémarrer PostgreSQL
   docker compose restart postgres
   ```

3. **Application ne démarre pas**
   ```bash
   # Vérifier les logs de l'application
   docker compose logs u-silenziu
   
   # Reconstruire l'image
   docker compose build --no-cache u-silenziu
   ```

### Nettoyage

```bash
# Nettoyer les conteneurs arrêtés
docker compose down

# Nettoyer les volumes
docker volume prune

# Nettoyer les images
docker image prune -a

# Nettoyage complet
docker system prune -a --volumes
```

## 📚 Commandes utiles

```bash
# Entrer dans un conteneur
docker exec -it u-silenziu-app bash

# Voir les processus dans un conteneur
docker exec u-silenziu-app ps aux

# Copier des fichiers vers/depuis un conteneur
docker cp file.txt u-silenziu-app:/app/
docker cp u-silenziu-app:/app/file.txt ./

# Voir l'utilisation des ressources
docker stats

# Redémarrer un service
docker compose restart u-silenziu
```

## 🔗 URLs

### Développement

- Application : http://localhost:3000
- Admin : http://localhost:3000/admin/login
- Base de données : localhost:5432

### Production

- Application : https://usilenziu.com (ou IP:3000)
- Admin : https://usilenziu.com/admin/login
- Base de données : localhost:5432 (interne)

## 📝 Notes importantes

1. **Secrets** : Changez tous les secrets en production
2. **SSL** : Configurez les certificats SSL pour la production
3. **Sauvegarde** : Vérifiez que les sauvegardes fonctionnent
4. **Monitoring** : Surveillez les logs et les performances
5. **Mise à jour** : Mettez à jour régulièrement les images Docker
