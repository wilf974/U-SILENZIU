# Environnements Docker - U Silenziu

Ce projet utilise deux environnements Docker distincts : **développement** et **production**.

## 🏗️ Architecture

### Environnement de Développement
- **Fichier** : `docker-compose.dev.yml`
- **Database** : `usilenzio_dev` (port 5432)
- **Hot reload** : Activé
- **Debug** : Port 9229 exposé
- **Redis** : Port 6379
- **Volumes** : Code source synchronisé pour le hot reload

### Environnement de Production
- **Fichier** : `docker-compose.prod.yml`
- **Database** : `usilenzio` (port 5432)
- **Nginx** : Reverse proxy (ports 80/443)
- **Redis** : Avec configuration de sécurité
- **Backup** : Service de sauvegarde automatique
- **Sécurité** : Options de sécurité renforcées

## 🚀 Utilisation Rapide

### Script Utilitaire (Recommandé)
```powershell
# Démarrer le développement
.\docker-switch.ps1 dev

# Démarrer la production
.\docker-switch.ps1 prod

# Arrêter tous les environnements
.\docker-switch.ps1 stop
```

### Commandes Manuelles

#### Développement
```powershell
# Démarrer
docker-compose -f docker-compose.dev.yml up -d --build

# Logs en temps réel
docker-compose -f docker-compose.dev.yml logs -f

# Arrêter
docker-compose -f docker-compose.dev.yml down
```

#### Production
```powershell
# Démarrer
docker-compose -f docker-compose.prod.yml up -d --build

# Logs en temps réel
docker-compose -f docker-compose.prod.yml logs -f

# Arrêter
docker-compose -f docker-compose.prod.yml down
```

## ⚙️ Configuration

### Variables d'Environnement

#### Développement
1. Copiez `env.dev.example` vers `.env.dev`
2. Modifiez les valeurs selon vos besoins
3. Les secrets peuvent être simples en dev

#### Production
1. Copiez `env.prod.example` vers `.env.prod`
2. **CHANGEZ TOUS LES SECRETS** avec des valeurs sécurisées
3. Configurez votre domaine et SMTP

### Exemple de génération de secrets
```powershell
# Générer des secrets sécurisés
[System.Web.Security.Membership]::GeneratePassword(32, 5)
```

## 🔧 Services Disponibles

### Développement
| Service | Port | Description |
|---------|------|-------------|
| App Next.js | 3000 | Application principale |
| Debug Node.js | 9229 | Port de debug |
| PostgreSQL | 5432 | Base de données dev |
| Redis | 6379 | Cache et sessions |

### Production
| Service | Port | Description |
|---------|------|-------------|
| Nginx HTTP | 80 | Reverse proxy |
| Nginx HTTPS | 443 | Reverse proxy SSL |
| App Next.js | 3000 | Application (interne) |
| PostgreSQL | 5432 | Base de données prod |
| Redis | 6379 | Cache et sessions |

## 📁 Structure des Fichiers

```
├── docker-compose.dev.yml      # Configuration développement
├── docker-compose.prod.yml     # Configuration production
├── Dockerfile                  # Dockerfile production
├── Dockerfile.dev             # Dockerfile développement
├── docker-switch.ps1          # Script utilitaire
├── dev-start.ps1              # Script démarrage dev
├── prod-deploy.ps1            # Script démarrage prod
├── env.dev.example            # Variables d'env dev
├── env.prod.example           # Variables d'env prod
└── DOCKER_ENVIRONMENTS.md     # Cette documentation
```

## 🛡️ Sécurité

### Développement
- Secrets simples (non critiques)
- Tous les ports exposés
- Debug activé
- Hot reload pour la productivité

### Production
- **Secrets forts obligatoires**
- Ports minimaux exposés
- `no-new-privileges:true`
- `tmpfs` pour les fichiers temporaires
- Nginx en reverse proxy
- Service de sauvegarde automatique

## 📋 Workflow Recommandé

### Développement Quotidien
1. `.\docker-switch.ps1 dev` - Démarrer l'environnement
2. Développer avec hot reload
3. Tester les fonctionnalités
4. Commit et push

### Déploiement Production
1. Tests finaux en dev
2. `.\docker-switch.ps1 prod` - Tester en local
3. Vérifier toutes les fonctionnalités
4. Déployer sur le VPS avec les mêmes fichiers

## 🚨 Points d'Attention

### Avant le Déploiement Production
- [ ] Tous les secrets changés dans `.env.prod`
- [ ] Domaine configuré correctement
- [ ] SMTP configuré pour les emails
- [ ] Certificats SSL prêts (si applicable)
- [ ] Sauvegarde de la base de données testée

### Maintenance
- Logs : `docker-compose -f docker-compose.prod.yml logs -f`
- Sauvegarde manuelle : `docker exec u-silenziu-backup /backup.sh`
- Update : Rebuild avec `--build`

## 🆘 Dépannage

### Service ne démarre pas
```powershell
# Vérifier les logs
docker-compose -f docker-compose.dev.yml logs service_name

# Vérifier l'état
docker-compose -f docker-compose.dev.yml ps
```

### Base de données inaccessible
```powershell
# Vérifier la connexion
docker exec -it u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev
```

### Reset complet
```powershell
# Arrêter et supprimer tout
.\docker-switch.ps1 stop
docker system prune -f
docker volume prune -f

# Redémarrer
.\docker-switch.ps1 dev
```

## 📞 Support

En cas de problème :
1. Vérifiez les logs des services
2. Consultez cette documentation
3. Vérifiez la configuration des variables d'environnement
4. Reset complet si nécessaire

---

**Auteur** : Assistant IA  
**Dernière mise à jour** : Septembre 2024
