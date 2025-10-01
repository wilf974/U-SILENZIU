# 🚀 Commandes VPS pour Déploiement Payplug

## 📋 Commandes de Base pour le VPS

### 1. Connexion au VPS
```bash
ssh root@VOTRE_IP_VPS
```

### 2. Navigation vers le projet
```bash
cd /opt/usilenziu
# ou
cd /var/www/usilenziu
```

### 3. Mise à jour du code
```bash
git pull origin main
```

## 🔧 Configuration des Clés Payplug

### 1. Éditer le fichier de configuration
```bash
nano docker-compose.prod.yml
```

### 2. Remplacer les valeurs Payplug
Recherchez et remplacez :
```yaml
# Configuration Payplug (PRODUCTION)
- PAYPLUG_SECRET_KEY=sk_live_VOTRE_CLE_SECRETE
- PAYPLUG_PUBLIC_KEY=pk_live_VOTRE_CLE_PUBLIQUE  
- PAYPLUG_WEBHOOK_SECRET=whsec_live_VOTRE_SECRET_WEBHOOK
- PAYPLUG_MODE=live
- NEXT_PUBLIC_SITE_URL=https://rageroom.usilenziu.com
```

## 🚀 Déploiement

### Option 1: Script automatisé
```bash
# Rendre le script exécutable
chmod +x deploy-payplug-vps.sh

# Exécuter le déploiement
./deploy-payplug-vps.sh
```

### Option 2: Commandes manuelles
```bash
# Arrêter les conteneurs existants
docker-compose -f docker-compose.prod.yml down

# Construire et démarrer les conteneurs
docker-compose -f docker-compose.prod.yml up -d --build

# Vérifier le statut
docker-compose -f docker-compose.prod.yml ps
```

## 🧪 Tests de Validation

### 1. Test automatisé
```bash
# Rendre le script exécutable
chmod +x test-payplug-production.sh

# Exécuter les tests
./test-payplug-production.sh
```

### 2. Tests manuels

#### Test de l'API de paiement
```bash
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

#### Test de la page de retour
```bash
curl -I "https://rageroom.usilenziu.com/reservation/payment/return?reservation=TEST123&status=success"
```

#### Test du webhook
```bash
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

## 📊 Surveillance

### 1. Vérifier les logs
```bash
# Logs de l'application
docker-compose -f docker-compose.prod.yml logs -f u-silenziu

# Logs de la base de données
docker-compose -f docker-compose.prod.yml logs -f postgres

# Logs de Nginx
docker-compose -f docker-compose.prod.yml logs -f nginx
```

### 2. Statut des conteneurs
```bash
# Statut des conteneurs
docker-compose -f docker-compose.prod.yml ps

# Utilisation des ressources
docker stats
```

### 3. Redémarrer les services
```bash
# Redémarrer l'application
docker-compose -f docker-compose.prod.yml restart u-silenziu

# Redémarrer tous les services
docker-compose -f docker-compose.prod.yml restart
```

## 🔒 Configuration Webhook Payplug

### 1. URL du webhook
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

## 🚨 Dépannage

### 1. Problèmes de connexion
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

### 3. Problèmes de base de données
```bash
# Se connecter à la base de données
docker-compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio

# Vérifier les tables
\dt

# Vérifier les réservations
SELECT * FROM reservations LIMIT 5;
```

### 4. Problèmes de certificats SSL
```bash
# Vérifier les certificats
openssl s_client -connect rageroom.usilenziu.com:443 -servername rageroom.usilenziu.com

# Renouveler les certificats Let's Encrypt
certbot renew --dry-run
```

## 📋 Checklist de Déploiement

### Avant le déploiement
- [ ] Clés Payplug de production configurées
- [ ] Variables d'environnement mises à jour
- [ ] Certificats SSL valides
- [ ] Base de données sauvegardée

### Après le déploiement
- [ ] Conteneurs démarrés correctement
- [ ] Site accessible via HTTPS
- [ ] API de paiement fonctionnelle
- [ ] Page de retour accessible
- [ ] Webhook accessible
- [ ] Emails de confirmation fonctionnels

### Tests de validation
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

**🎉 Votre système Payplug est maintenant prêt pour la production !**
