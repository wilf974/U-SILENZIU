# 🧪 Guide de Test de l'Interface Payplug sur VPS

## 📋 Vue d'ensemble

Ce guide vous explique comment tester l'interface de configuration Payplug directement sur votre VPS de production.

## 🚀 Commandes VPS

### 1. Se connecter au VPS
```bash
ssh root@VOTRE_IP_VPS
cd /opt/usilenziu
```

### 2. Mettre à jour le code
```bash
git pull origin main
```

### 3. Redémarrer les services
```bash
docker-compose -f docker-compose.prod.yml restart u-silenziu
```

### 4. Tester l'API de configuration
```bash
# Rendre le script exécutable
chmod +x test-payplug-vps-interface.sh

# Exécuter le test
./test-payplug-vps-interface.sh
```

## 🌐 Test via le Navigateur

### 1. Accéder à l'administration
- URL: `https://rageroom.usilenziu.com/admin`
- Connectez-vous avec vos identifiants admin

### 2. Ouvrir la configuration Payplug
- Dans le menu admin, cliquez sur "Configuration Payplug"
- L'interface s'ouvre avec les paramètres actuels

### 3. Tester le changement de mode

#### Mode TEST (recommandé pour commencer)
- ✅ Sélectionnez "Test (recommandé pour commencer)"
- ✅ Entrez vos clés de test :
  - Clé secrète: `sk_test_4qzp5fowqEGBG93PjzZOlF`
  - Clé publique: `pk_test_4qzp5fowqEGBG93PjzZOlF`
  - Secret webhook: `whsec_test_4qzp5fowqEGBG93PjzZOlF`
- ✅ Cliquez sur "Sauvegarder"

#### Mode LIVE (production)
- ⚠️ Sélectionnez "Live (production)"
- ⚠️ Entrez vos clés LIVE :
  - Clé secrète: `sk_live_...` (vos vraies clés)
  - Clé publique: `pk_live_...` (vos vraies clés)
  - Secret webhook: `whsec_live_...` (votre vrai secret)
- ⚠️ Cliquez sur "Sauvegarder"

## 🔍 Fonctionnalités à Tester

### ✅ Validation des Clés
- L'interface valide automatiquement les préfixes des clés
- Mode TEST : doit commencer par `sk_test_` et `pk_test_`
- Mode LIVE : doit commencer par `sk_live_` et `pk_live_`

### ✅ Indicateurs Visuels
- **Mode TEST** : Message bleu informatif
- **Mode LIVE** : Message rouge d'avertissement
- **Erreurs** : Bordures rouges sur les champs invalides

### ✅ Sauvegarde Automatique
- Mise à jour de `env.prod`
- Mise à jour de `docker-compose.prod.yml`
- Redémarrage automatique des services Docker

### ✅ Test de Configuration
- Bouton "Tester" pour valider la configuration
- Vérification de la connectivité avec Payplug

## 🧪 Tests Recommandés

### 1. Test Complet Mode TEST
```bash
# Sur le VPS
curl -X POST "https://rageroom.usilenziu.com/api/admin/payplug-config" \
  -H "Content-Type: application/json" \
  -d '{
    "secretKey": "sk_test_4qzp5fowqEGBG93PjzZOlF",
    "publicKey": "pk_test_4qzp5fowqEGBG93PjzZOlF",
    "webhookSecret": "whsec_test_4qzp5fowqEGBG93PjzZOlF",
    "mode": "test"
  }'
```

### 2. Test de Validation
```bash
# Test avec clé invalide (doit échouer)
curl -X POST "https://rageroom.usilenziu.com/api/admin/payplug-config" \
  -H "Content-Type: application/json" \
  -d '{
    "secretKey": "sk_invalid_key",
    "publicKey": "pk_invalid_key",
    "webhookSecret": "whsec_invalid",
    "mode": "test"
  }'
```

### 3. Vérification de la Configuration
```bash
# Récupérer la configuration actuelle
curl "https://rageroom.usilenziu.com/api/admin/payplug-config"
```

## 🔧 Dépannage

### Problème : Interface non accessible
```bash
# Vérifier que les services sont démarrés
docker-compose -f docker-compose.prod.yml ps

# Redémarrer si nécessaire
docker-compose -f docker-compose.prod.yml restart u-silenziu
```

### Problème : Erreur de validation
- Vérifiez que les clés correspondent au mode sélectionné
- Les clés TEST doivent commencer par `sk_test_` et `pk_test_`
- Les clés LIVE doivent commencer par `sk_live_` et `pk_live_`

### Problème : Sauvegarde échoue
```bash
# Vérifier les permissions
ls -la env.prod docker-compose.prod.yml

# Vérifier les logs
docker-compose -f docker-compose.prod.yml logs u-silenziu
```

## 📊 Résultats Attendus

### ✅ Succès
- Interface accessible via l'administration
- Changement de mode fonctionnel
- Validation des clés en temps réel
- Sauvegarde automatique des fichiers
- Redémarrage des services

### ❌ Échecs Possibles
- Erreur 404 : Interface non trouvée
- Erreur 500 : Problème de configuration
- Validation échoue : Clés incorrectes
- Sauvegarde échoue : Permissions insuffisantes

## 🎯 Prochaines Étapes

1. **Tester l'interface** via le navigateur
2. **Valider le changement de mode** TEST/LIVE
3. **Tester un paiement** en mode TEST
4. **Passer en mode LIVE** quand prêt
5. **Surveiller les logs** pour détecter les problèmes

## 📞 Support

Si vous rencontrez des problèmes :
1. Vérifiez les logs Docker
2. Testez l'API directement avec curl
3. Vérifiez la configuration des fichiers
4. Redémarrez les services si nécessaire

---

**L'interface de configuration Payplug est maintenant opérationnelle sur votre VPS ! 🚀**
