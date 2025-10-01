# 🚀 Guide de Déploiement Payplug sur VPS

## 📋 Prérequis

### 1. VPS Configuré
- **OS** : Ubuntu 22.04 LTS ou Debian 11+
- **RAM** : Minimum 2GB (4GB recommandé)
- **Stockage** : Minimum 20GB SSD
- **Docker** : Installé et fonctionnel
- **Domaine** : `rageroom.usilenziu.com` configuré

### 2. Clés Payplug de Production
- **Clé secrète** : `sk_live_...` (Clé LIVE)
- **Clé publique** : `pk_live_...` (Clé LIVE)
- **Secret webhook** : `whsec_live_...` (Clé LIVE)

## 🔧 Configuration des Clés Payplug

### 1. Activer la Clé LIVE
1. Connectez-vous à votre compte Payplug
2. Allez dans "Paramètres" → "Clés API"
3. Activez votre "Clé LIVE" (si pas encore fait)
4. Récupérez vos clés de production

### 2. Configurer les Variables d'Environnement
```bash
# Éditer le fichier docker-compose.prod.yml
nano docker-compose.prod.yml
```

Remplacez les valeurs suivantes :
```yaml
# Configuration Payplug (PRODUCTION)
- PAYPLUG_SECRET_KEY=sk_live_VOTRE_CLE_SECRETE
- PAYPLUG_PUBLIC_KEY=pk_live_VOTRE_CLE_PUBLIQUE
- PAYPLUG_WEBHOOK_SECRET=whsec_live_VOTRE_SECRET_WEBHOOK
- PAYPLUG_MODE=live
- NEXT_PUBLIC_SITE_URL=https://rageroom.usilenziu.com
```

## 🚀 Déploiement sur VPS

### 1. Connexion au VPS
```bash
ssh root@VOTRE_IP_VPS
```

### 2. Navigation vers le répertoire du projet
```bash
cd /opt/usilenziu
# ou
cd /var/www/usilenziu
```

### 3. Mise à jour du code (si nécessaire)
```bash
git pull origin main
```

### 4. Déploiement avec le script automatisé
```bash
# Rendre le script exécutable
chmod +x deploy-payplug-vps.sh

# Exécuter le déploiement
./deploy-payplug-vps.sh
```

### 5. Déploiement manuel (alternative)
```bash
# Arrêter les conteneurs existants
docker-compose -f docker-compose.prod.yml down

# Construire et démarrer les conteneurs
docker-compose -f docker-compose.prod.yml up -d --build

# Vérifier le statut
docker-compose -f docker-compose.prod.yml ps
```

## 🧪 Tests de Validation

### 1. Test de l'API de Paiement
```bash
# Créer un paiement test
curl -X POST "https://rageroom.usilenziu.com/api/payments/create" \
  -H "Content-Type: application/json" \
  -d '{
    "reservationNumber": "TEST'$(date +%Y%m%d%H%M%S)'",
    "amount": 50,
    "currency": "EUR",
    "customer": {
      "email": "test@usilenziu.com",
      "first_name": "Test",
      "last_name": "Production"
    },
    "metadata": {
      "test": true
    }
  }'
```

### 2. Test de la Page de Retour
```bash
# Tester la page de retour
curl -I "https://rageroom.usilenziu.com/reservation/payment/return?reservation=TEST123&status=success"
```

### 3. Test du Webhook
```bash
# Tester le webhook (erreur 400 normale sans signature)
curl -X POST "https://rageroom.usilenziu.com/api/webhooks/payplug" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "payment.paid",
    "data": {
      "id": "test_payment_123",
      "amount": 5000,
      "currency": "EUR",
      "metadata": {
        "reservation_number": "TEST123"
      }
    }
  }'
```

## 📊 Surveillance et Maintenance

### 1. Vérifier les Logs
```bash
# Logs de l'application
docker-compose -f docker-compose.prod.yml logs -f u-silenziu

# Logs de la base de données
docker-compose -f docker-compose.prod.yml logs -f postgres

# Logs de Nginx
docker-compose -f docker-compose.prod.yml logs -f nginx
```

### 2. Vérifier le Statut des Conteneurs
```bash
# Statut des conteneurs
docker-compose -f docker-compose.prod.yml ps

# Utilisation des ressources
docker stats
```

### 3. Redémarrer les Services
```bash
# Redémarrer l'application
docker-compose -f docker-compose.prod.yml restart u-silenziu

# Redémarrer tous les services
docker-compose -f docker-compose.prod.yml restart
```

## 🔒 Configuration des Webhooks Payplug

### 1. URL du Webhook
```
https://rageroom.usilenziu.com/api/webhooks/payplug
```

### 2. Configuration dans Payplug
1. Connectez-vous à votre compte Payplug
2. Allez dans "Paramètres" → "Webhooks"
3. Ajoutez l'URL du webhook
4. Sélectionnez les événements :
   - `payment.paid`
   - `payment.failed`
   - `payment.refunded`
5. Sauvegardez la configuration

### 3. Test des Webhooks
```bash
# Vérifier que le webhook est accessible
curl -I "https://rageroom.usilenziu.com/api/webhooks/payplug"
```

## 🚨 Dépannage

### 1. Problèmes de Connexion
```bash
# Vérifier la connectivité
ping rageroom.usilenziu.com

# Vérifier les ports
netstat -tlnp | grep :80
netstat -tlnp | grep :443
```

### 2. Problèmes Docker
```bash
# Vérifier les conteneurs
docker ps -a

# Vérifier les images
docker images

# Nettoyer les conteneurs arrêtés
docker container prune
```

### 3. Problèmes de Base de Données
```bash
# Se connecter à la base de données
docker-compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio

# Vérifier les tables
\dt

# Vérifier les réservations
SELECT * FROM reservations LIMIT 5;
```

### 4. Problèmes de Certificats SSL
```bash
# Vérifier les certificats
openssl s_client -connect rageroom.usilenziu.com:443 -servername rageroom.usilenziu.com

# Renouveler les certificats Let's Encrypt
certbot renew --dry-run
```

## 📋 Checklist de Déploiement

### Avant le Déploiement
- [ ] Clés Payplug de production configurées
- [ ] Variables d'environnement mises à jour
- [ ] Certificats SSL valides
- [ ] Base de données sauvegardée

### Après le Déploiement
- [ ] Conteneurs démarrés correctement
- [ ] Site accessible via HTTPS
- [ ] API de paiement fonctionnelle
- [ ] Page de retour accessible
- [ ] Webhook accessible
- [ ] Emails de confirmation fonctionnels

### Tests de Validation
- [ ] Création de paiement test
- [ ] Redirection vers Payplug
- [ ] Retour après paiement
- [ ] Webhook Payplug
- [ ] Emails de confirmation
- [ ] Interface d'administration

## 🎯 URLs Importantes

- **Site principal** : https://rageroom.usilenziu.com
- **Réservation** : https://rageroom.usilenziu.com/reservation
- **Administration** : https://rageroom.usilenziu.com/admin
- **Page de retour** : https://rageroom.usilenziu.com/reservation/payment/return
- **Webhook** : https://rageroom.usilenziu.com/api/webhooks/payplug

## 📞 Support

En cas de problème :
1. Vérifiez les logs : `docker-compose -f docker-compose.prod.yml logs -f u-silenziu`
2. Vérifiez le statut des conteneurs : `docker-compose -f docker-compose.prod.yml ps`
3. Testez les endpoints : Utilisez les commandes curl ci-dessus
4. Contactez le support technique si nécessaire

---

**🎉 Félicitations ! Votre système Payplug est maintenant déployé en production !**
