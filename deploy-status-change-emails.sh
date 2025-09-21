#!/bin/bash

echo "=== DÉPLOIEMENT EMAILS DE CHANGEMENT DE STATUT ==="
echo ""

# 1. Pull des nouvelles fonctions
echo "1. RÉCUPÉRATION DU CODE :"
echo "========================"
git pull origin main

# 2. Rebuild rapide
echo ""
echo "2. REBUILD DE L'APPLICATION :"
echo "============================"
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu

# 3. Redémarrer l'app
echo ""
echo "3. REDÉMARRAGE APPLICATION :"
echo "=========================="
docker compose -f docker-compose.prod.yml up -d u-silenziu

# 4. Attendre stabilisation
echo ""
echo "4. ATTENTE STABILISATION :"
echo "========================="
sleep 30

# 5. Vérifier l'état
echo ""
echo "5. ÉTAT DES CONTENEURS :"
echo "======================="
docker compose -f docker-compose.prod.yml ps

# 6. Vérifier les logs de compilation
echo ""
echo "6. LOGS DE COMPILATION :"
echo "======================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=10

# 7. Test des APIs
echo ""
echo "7. TEST DES APIs :"
echo "================="

echo "7.1. Test GET réservations :"
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | head -c 300

echo ""
echo "7.2. Test d'une réservation spécifique :"
RESERVATION_ID=$(curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "ID de réservation trouvé: $RESERVATION_ID"

if [ ! -z "$RESERVATION_ID" ]; then
  curl -s "https://rageroom.usilenziu.com/api/admin/reservations/$RESERVATION_ID" | head -c 300
else
  echo "Aucune réservation trouvée pour les tests"
fi

# 8. Instructions pour tester les emails
echo ""
echo "8. INSTRUCTIONS POUR TESTER LES EMAILS :"
echo "========================================"
echo ""
echo "✅ Pour tester EMAIL DE CONFIRMATION :"
echo "1. Aller sur https://rageroom.usilenziu.com/admin/reservations"
echo "2. Cliquer sur l'icône ✅ (confirmer) d'une réservation 'En attente'"
echo "3. Vérifier l'email dans jean.maillot14@gmail.com"
echo ""
echo "❌ Pour tester EMAIL D'ANNULATION :"
echo "1. Aller sur https://rageroom.usilenziu.com/admin/reservations"
echo "2. Cliquer sur l'icône ❌ (annuler) d'une réservation"
echo "3. Vérifier l'email dans jean.maillot14@gmail.com"
echo ""
echo "📧 Types d'emails maintenant disponibles :"
echo "- 📨 Email de demande de réservation (status: pending)"
echo "- ✅ Email de confirmation (status: confirmed)"
echo "- ❌ Email d'annulation (status: cancelled)"
echo ""

# 9. Créer une réservation de test si aucune n'existe
echo ""
echo "9. CRÉATION D'UNE RÉSERVATION DE TEST :"
echo "======================================"
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Statut Change",
    "email": "jean.maillot14@gmail.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-30",
    "timeSlot": "14:00 - 14:20",
    "duration": 20,
    "numberOfPeople": 1,
    "specialRequests": "Réservation pour tester les emails de changement de statut"
  }'

echo ""
echo "10. LOGS D'EMAIL EN TEMPS RÉEL :"
echo "==============================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20 | grep -i -E "email|smtp|validation|annulation|confirmation"

echo ""
echo "=== DÉPLOIEMENT TERMINÉ ==="
echo ""
echo "🎯 FONCTIONNALITÉS IMPLÉMENTÉES :"
echo "✅ Email de confirmation automatique à la réservation"
echo "✅ Email de validation lors du passage en 'confirmé'"
echo "✅ Email d'annulation lors du passage en 'annulé'"
echo ""
echo "🧪 PRÊT À TESTER :"
echo "1. Créez ou utilisez une réservation existante"
echo "2. Changez son statut via l'admin"
echo "3. Vérifiez l'email reçu"
echo ""
echo "Les emails seront envoyés automatiquement ! 📧✨"
