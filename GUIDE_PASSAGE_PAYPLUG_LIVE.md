# 🚀 Guide de Passage Payplug en Mode LIVE

## 📋 Vue d'ensemble

Ce guide vous explique comment passer de Payplug en mode TEST à mode LIVE sur votre VPS de production.

## ⚠️ IMPORTANT - Avant de commencer

- **Mode LIVE = Paiements RÉELS** : Les transactions seront facturées
- **Testez d'abord** : Vérifiez que tout fonctionne en mode TEST
- **Sauvegardez** : Le script crée automatiquement des sauvegardes
- **Clés LIVE** : Assurez-vous d'avoir vos clés Payplug LIVE

## 🔑 Prérequis

### 1. Clés Payplug LIVE
Vous devez avoir :
- **Clé secrète LIVE** : `sk_live_...`
- **Clé publique LIVE** : `pk_live_...`
- **Secret webhook LIVE** : `whsec_live_...`

### 2. Accès au VPS
```bash
ssh root@VOTRE_IP_VPS
cd /opt/usilenziu  # ou /var/www/usilenziu
```

## 🚀 Procédure de Passage en LIVE

### 1. Mise à jour du code sur le VPS
```bash
# Récupérer les derniers changements
git pull origin main

# Rendre les scripts exécutables
chmod +x switch-payplug-live.sh
chmod +x switch-payplug-test.sh
chmod +x test-payplug-live.sh
```

### 2. Exécution du script de passage en LIVE
```bash
./switch-payplug-live.sh
```

Le script va :
- ✅ Vérifier que vous êtes sur le VPS
- ✅ Demander vos clés Payplug LIVE
- ✅ Valider le format des clés
- ✅ Créer des sauvegardes automatiques
- ✅ Mettre à jour la configuration
- ✅ Redémarrer les services Docker
- ✅ Tester la nouvelle configuration

### 3. Test de la configuration LIVE
```bash
./test-payplug-live.sh
```

Ce script va :
- ✅ Vérifier que le mode est bien "live"
- ✅ Tester l'API de configuration
- ✅ Tester la création de paiement
- ✅ Vérifier l'URL du webhook

## 🔧 Configuration du Webhook Payplug

### 1. Connexion à votre compte Payplug
- Connectez-vous à votre [espace Payplug](https://portal.payplug.com)
- Allez dans **Paramètres** > **Webhooks**

### 2. Configuration de l'URL
- **URL du webhook** : `https://rageroom.usilenziu.com/api/webhooks/payplug`
- **Événements** : Sélectionnez tous les événements de paiement
- **Secret** : Utilisez le même secret que dans votre configuration

### 3. Test du webhook
- Payplug enverra un webhook de test
- Vérifiez les logs de votre application

## 🧪 Tests de Validation

### 1. Test avec un petit montant
```bash
# Test via l'interface admin
# 1. Allez sur https://rageroom.usilenziu.com/admin
# 2. Créez une réservation test
# 3. Procédez au paiement avec un montant de 1€
# 4. Vérifiez que le paiement est traité
```

### 2. Vérification des logs
```bash
# Voir les logs de l'application
docker-compose -f docker-compose.prod.yml logs u-silenziu

# Voir les logs des webhooks
docker-compose -f docker-compose.prod.yml logs u-silenziu | grep webhook
```

## 🔄 Retour en Mode TEST

Si vous devez revenir en mode TEST :

```bash
./switch-payplug-test.sh
```

## 📊 Monitoring et Surveillance

### 1. Vérification du statut
```bash
# Statut des services
docker-compose -f docker-compose.prod.yml ps

# Logs en temps réel
docker-compose -f docker-compose.prod.yml logs -f u-silenziu
```

### 2. Interface d'administration
- **URL** : `https://rageroom.usilenziu.com/admin`
- **Configuration Payplug** : Vérifiez que le mode est "Live"
- **Test de paiement** : Utilisez l'interface pour tester

## 🚨 Dépannage

### Problème : Erreur de clés
```bash
# Vérifier la configuration
grep PAYPLUG env.prod

# Vérifier les services
docker-compose -f docker-compose.prod.yml logs u-silenziu
```

### Problème : Webhook non reçu
```bash
# Vérifier l'URL du webhook
curl -X POST "https://rageroom.usilenziu.com/api/webhooks/payplug" \
  -H "Content-Type: application/json" \
  -d '{"test": true}'

# Vérifier les logs
docker-compose -f docker-compose.prod.yml logs u-silenziu | grep webhook
```

### Problème : Paiement échoue
```bash
# Vérifier la configuration Payplug
./test-payplug-live.sh

# Vérifier les logs de paiement
docker-compose -f docker-compose.prod.yml logs u-silenziu | grep payment
```

## 📋 Checklist de Validation

- [ ] Clés Payplug LIVE configurées
- [ ] Mode "live" activé
- [ ] Services Docker redémarrés
- [ ] API de configuration accessible
- [ ] Création de paiement fonctionne
- [ ] Webhook configuré dans Payplug
- [ ] Test de paiement réussi
- [ ] Logs sans erreur
- [ ] Interface admin fonctionnelle

## 🔗 URLs Importantes

- **Site** : https://rageroom.usilenziu.com
- **Admin** : https://rageroom.usilenziu.com/admin
- **Webhook** : https://rageroom.usilenziu.com/api/webhooks/payplug
- **API Config** : https://rageroom.usilenziu.com/api/admin/payplug-config

## 📞 Support

En cas de problème :
1. Vérifiez les logs : `docker-compose -f docker-compose.prod.yml logs u-silenziu`
2. Testez la configuration : `./test-payplug-live.sh`
3. Revenez en mode TEST si nécessaire : `./switch-payplug-test.sh`

---

**⚠️ RAPPEL IMPORTANT** : En mode LIVE, tous les paiements sont RÉELS et seront facturés. Testez toujours avec de petits montants avant de lancer en production.
