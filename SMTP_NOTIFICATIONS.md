# Système de Notifications SMTP - U Silenziu

## Vue d'ensemble

Le système de notifications SMTP permet d'envoyer automatiquement des emails de rappel aux clients ayant des réservations prévues dans les 24h. Le système est entièrement configurable depuis l'interface d'administration.

## Fonctionnalités

### ✅ Configuration SMTP personnalisable
- Hôte SMTP configurable (Office 365, Gmail, etc.)
- Port et sécurité (SSL/TLS/STARTTLS)
- Identifiants chiffrés en base de données
- Test de connexion en temps réel

### ✅ Notifications automatiques
- Détection des réservations dans les 24h
- Email de rappel personnalisé avec détails complets
- Template HTML sombre kaki/noir
- Gestion des erreurs et logs détaillés

### ✅ Sécurité
- Mots de passe chiffrés en AES
- Validation des paramètres SMTP
- Protection des routes d'administration
- Pas d'exposition d'informations sensibles

## Configuration

### 1. Accès à l'interface d'administration

1. Accédez à `http://localhost:3000/admin`
2. Connectez-vous avec les identifiants admin (par défaut: `admin` / `admin123`)
3. Cliquez sur "Configuration SMTP" dans la barre d'outils

### 2. Configuration des paramètres SMTP

#### Office 365 / Outlook
```
Hôte: smtp-mail.outlook.com
Port: 587
Sécurisé: Non (STARTTLS automatique)
Nom d'utilisateur: votre@email.com
Mot de passe: votre mot de passe ou mot de passe d'application
TLS: Rejeter certificats non autorisés (activé)
```

#### Gmail
```
Hôte: smtp.gmail.com
Port: 587
Sécurisé: Non (STARTTLS automatique)
Nom d'utilisateur: votre@gmail.com
Mot de passe: mot de passe d'application (obligatoire)
TLS: Rejeter certificats non autorisés (activé)
```

#### Autres fournisseurs
- **OVH**: `smtp.ovh.net` (port 587)
- **Orange**: `smtp.orange.fr` (port 587)
- **Free**: `smtp.free.fr` (port 587)

### 3. Test de la configuration

1. Remplissez tous les champs requis
2. Cliquez sur "Tester la connexion"
3. Vérifiez que le statut affiche "SMTP connecté"
4. Cliquez sur "Sauvegarder la configuration"

## Utilisation

### Envoi automatique des notifications

Les notifications s'envoient automatiquement via l'endpoint :
```
POST /api/notifications/send
```

### Déclenchement manuel

Pour tester manuellement :
```bash
# Vérifier les réservations prévues
curl http://localhost:3000/api/notifications/send

# Envoyer les notifications
curl -X POST http://localhost:3000/api/notifications/send
```

### Script PowerShell de test

Utilisez le script `test-notifications.ps1` :
```powershell
.\test-notifications.ps1
```

## Template d'email

### Design
- **Thème** : Sombre kaki/noir cohérent avec le site
- **Responsive** : Adaptation mobile et desktop
- **Informations** : Tous les détails de la réservation

### Contenu inclus
- Numéro de réservation
- Nom et prénom du client
- Salle réservée
- Date et heure
- Nombre de personnes
- Durée de la session
- Instructions d'arrivée
- Informations de contact

## API Endpoints

### Configuration SMTP

#### GET `/api/admin/smtp/config`
Récupère la configuration SMTP (sans le mot de passe)

#### POST `/api/admin/smtp/save`
Sauvegarde la configuration SMTP

**Body:**
```json
{
  "host": "smtp.office365.com",
  "port": 587,
  "secure": false,
  "username": "votre@email.com",
  "password": "votre-mot-de-passe",
  "tlsRejectUnauthorized": true,
  "tlsMinVersion": "TLSv1.2"
}
```

#### POST `/api/admin/smtp/test`
Teste la connexion SMTP avec une configuration

#### GET `/api/admin/smtp/status`
Vérifie le statut de connexion SMTP

### Notifications

#### GET `/api/notifications/send`
Récupère les réservations prévues dans les 24h

#### POST `/api/notifications/send`
Envoie les notifications de rappel

**Réponse:**
```json
{
  "success": true,
  "message": "Notifications envoyées: 5/5",
  "sentCount": 5,
  "totalReservations": 5,
  "errors": []
}
```

## Sécurité

### Chiffrement des mots de passe
- **Algorithme** : AES-256-CBC
- **Clé** : Variable d'environnement `ENCRYPTION_KEY`
- **Stockage** : Base de données PostgreSQL

### Configuration d'environnement
```env
ENCRYPTION_KEY=your-secure-encryption-key-change-in-production
ADMIN_KEY=admin123
```

⚠️ **Important** : Changez la clé de chiffrement en production !

## Dépannage

### Erreurs courantes

#### "Configuration SMTP invalide ou manquante"
- Vérifiez que la configuration est sauvegardée
- Testez la connexion depuis l'interface admin

#### "Erreur de connexion"
- Vérifiez les paramètres SMTP
- Assurez-vous que le port n'est pas bloqué
- Vérifiez les identifiants

#### "Service SMTP non configuré"
- Configurez SMTP depuis `/admin/smtp`
- Vérifiez que la configuration est valide

#### "SSL routines:ssl3_get_record:wrong version number"
- **Solution principale** : Décochez "Rejeter les certificats non autorisés"
- Vérifiez que le port correspond à la sécurité (465 = SSL, 587 = STARTTLS)
- Assurez-vous que votre antivirus ne bloque pas les ports SMTP
- Vérifiez que votre fournisseur d'accès n'a pas bloqué les ports 25, 465, 587
- Pour Office 365 : Utilisez `smtp.office365.com` (pas `outlook.office365.com`)

### Logs
Les erreurs sont loggées dans la console Docker :
```bash
docker-compose logs -f u-silenziu-app
```

## Configuration CRON (Production)

Pour l'envoi automatique quotidien, configurez une tâche CRON :

```bash
# Envoyer les notifications tous les jours à 9h
0 9 * * * curl -X POST http://localhost:3000/api/notifications/send
```

### Avec Vercel Cron Jobs
```json
{
  "crons": [
    {
      "path": "/api/notifications/send",
      "schedule": "0 9 * * *"
    }
  ]
}
```

## Maintenance

### Sauvegarde de la configuration
La configuration SMTP est stockée dans la base de données PostgreSQL :
```bash
# Sauvegarder la base de données
docker cp u-silenziu-app:/app/data/reservations.db ./backup/
```

### Mise à jour de la configuration
1. Accédez à `/admin/smtp`
2. Modifiez les paramètres
3. Testez la connexion
4. Sauvegardez

## Support

Pour toute question ou problème :
1. Vérifiez les logs Docker
2. Testez la configuration SMTP
3. Consultez la documentation de votre fournisseur SMTP
4. Vérifiez que les ports ne sont pas bloqués par le firewall

---

**Système de notifications SMTP U Silenziu** - Version 1.0
