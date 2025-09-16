# API Documentation - Système de Réservation U Silenziu

## Vue d'ensemble

L'API de gestion des réservations permet de créer, récupérer, mettre à jour et supprimer des réservations pour l'établissement U Silenziu. Toutes les données sont stockées dans une base de données PostgreSQL.

## Base URL

```
http://localhost:3000/api
```

## Endpoints

### 1. Créer une nouvelle réservation

**POST** `/reservations`

#### Corps de la requête
```json
{
  "firstName": "Jean",
  "lastName": "Dupont",
  "email": "jean.dupont@email.com",
  "phone": "0123456789",
  "date": "2024-12-25",
  "timeSlot": "14:00 - 16:00",
  "duration": 120,
  "numberOfPeople": 4,
  "formula": "Escape Game",
  "roomName": "Salle Mystère"
}
```

#### Réponse (201 Created)
```json
{
  "id": 1,
  "reservationNumber": "241225001",
  "firstName": "Jean",
  "lastName": "Dupont",
  "email": "jean.dupont@email.com",
  "phone": "0123456789",
  "date": "2024-12-25",
  "timeSlot": "14:00 - 16:00",
  "duration": 120,
  "numberOfPeople": 4,
  "formula": "Escape Game",
  "roomName": "Salle Mystère",
  "status": "pending",
  "createdAt": "2024-12-24T21:30:00.000Z",
  "updatedAt": "2024-12-24T21:30:00.000Z"
}
```

### 2. Récupérer toutes les réservations

**GET** `/reservations`

#### Réponse (200 OK)
```json
[
  {
    "id": 1,
    "reservationNumber": "241225001",
    "firstName": "Jean",
    "lastName": "Dupont",
    "email": "jean.dupont@email.com",
    "phone": "0123456789",
    "date": "2024-12-25",
    "timeSlot": "14:00 - 16:00",
    "duration": 120,
    "numberOfPeople": 4,
    "formula": "Escape Game",
    "roomName": "Salle Mystère",
    "status": "pending",
    "createdAt": "2024-12-24T21:30:00.000Z",
    "updatedAt": "2024-12-24T21:30:00.000Z"
  }
]
```

### 3. Récupérer une réservation par numéro

**GET** `/reservations/{reservationNumber}`

#### Exemple
```
GET /reservations/241225001
```

#### Réponse (200 OK)
```json
{
  "id": 1,
  "reservationNumber": "241225001",
  "firstName": "Jean",
  "lastName": "Dupont",
  "email": "jean.dupont@email.com",
  "phone": "0123456789",
  "date": "2024-12-25",
  "timeSlot": "14:00 - 16:00",
  "duration": 120,
  "numberOfPeople": 4,
  "formula": "Escape Game",
  "roomName": "Salle Mystère",
  "status": "pending",
  "createdAt": "2024-12-24T21:30:00.000Z",
  "updatedAt": "2024-12-24T21:30:00.000Z"
}
```

#### Réponse (404 Not Found)
```json
{
  "error": "Réservation non trouvée"
}
```

### 4. Mettre à jour le statut d'une réservation

**PUT** `/reservations/{reservationNumber}`

#### Corps de la requête
```json
{
  "status": "confirmed"
}
```

#### Statuts disponibles
- `pending` : En attente
- `confirmed` : Confirmée
- `cancelled` : Annulée

#### Réponse (200 OK)
```json
{
  "id": 1,
  "reservationNumber": "241225001",
  "firstName": "Jean",
  "lastName": "Dupont",
  "email": "jean.dupont@email.com",
  "phone": "0123456789",
  "date": "2024-12-25",
  "timeSlot": "14:00 - 16:00",
  "duration": 120,
  "numberOfPeople": 4,
  "formula": "Escape Game",
  "roomName": "Salle Mystère",
  "status": "confirmed",
  "createdAt": "2024-12-24T21:30:00.000Z",
  "updatedAt": "2024-12-24T21:35:00.000Z"
}
```

### 5. Supprimer une réservation

**DELETE** `/reservations/{reservationNumber}`

#### Exemple
```
DELETE /reservations/241225001
```

#### Réponse (200 OK)
```json
{
  "message": "Réservation supprimée avec succès"
}
```

### 6. Récupérer les réservations par date

**GET** `/reservations/date/{date}`

#### Exemple
```
GET /reservations/date/2024-12-25
```

#### Réponse (200 OK)
```json
[
  {
    "id": 1,
    "reservationNumber": "241225001",
    "firstName": "Jean",
    "lastName": "Dupont",
    "email": "jean.dupont@email.com",
    "phone": "0123456789",
    "date": "2024-12-25",
    "timeSlot": "14:00 - 16:00",
    "duration": 120,
    "numberOfPeople": 4,
    "formula": "Escape Game",
    "roomName": "Salle Mystère",
    "status": "pending",
    "createdAt": "2024-12-24T21:30:00.000Z",
    "updatedAt": "2024-12-24T21:30:00.000Z"
  }
]
```

## Format des numéros de réservation

Les numéros de réservation suivent le format : `DDMMYY + numéro séquentiel`

### Exemples
- `241225001` : Première réservation du 25 décembre 2024
- `241225002` : Deuxième réservation du 25 décembre 2024
- `241226001` : Première réservation du 26 décembre 2024

## Codes d'erreur

### 400 Bad Request
- Champs manquants dans la requête
- Format de date invalide
- Statut invalide

### 404 Not Found
- Réservation non trouvée

### 500 Internal Server Error
- Erreur de base de données
- Erreur serveur

## Exemples d'utilisation

### Créer une réservation avec cURL
```bash
curl -X POST http://localhost:3000/api/reservations \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Marie",
    "lastName": "Martin",
    "email": "marie.martin@email.com",
    "phone": "0987654321",
    "date": "2024-12-26",
    "timeSlot": "10:00 - 12:00",
    "duration": 120,
    "numberOfPeople": 6,
    "formula": "Escape Game",
    "roomName": "Salle Aventure"
  }'
```

### Confirmer une réservation
```bash
curl -X PUT http://localhost:3000/api/reservations/241225001 \
  -H "Content-Type: application/json" \
  -d '{"status": "confirmed"}'
```

### Récupérer les réservations d'une date
```bash
curl http://localhost:3000/api/reservations/date/2024-12-25
```

## Notes importantes

1. **Validation** : Tous les champs sont validés côté serveur
2. **Numérotation** : Les numéros de réservation sont générés automatiquement et sont uniques
3. **Dates** : Utilisez le format ISO (YYYY-MM-DD) pour les dates
4. **Statuts** : Seuls les statuts `pending`, `confirmed`, et `cancelled` sont acceptés
5. **Base de données** : Les données sont persistantes et stockées dans `data/reservations.db`
