#!/bin/bash

echo "=== CORRECTION LOGIQUE DISPONIBILITÉ DES CRÉNEAUX ==="
echo ""

# 1. Pull des corrections
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
sleep 25

# 5. Vérifier l'état
echo ""
echo "5. ÉTAT DES CONTENEURS :"
echo "======================="
docker compose -f docker-compose.prod.yml ps

# 6. Test API availability avec une date qui a des réservations
echo ""
echo "6. TEST API AVAILABILITY :"
echo "========================="
echo "6.1. Test disponibilité avec salle qui a des réservations :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-23&endDate=2025-09-23&roomName=Salle%202" | jq '.'

echo ""
echo "6.2. Test structure des données retournées :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-23&endDate=2025-09-23" | jq '.data'

# 7. Test de création d'une réservation pour vérifier le blocage
echo ""
echo "7. TEST BLOCAGE APRÈS RÉSERVATION :"
echo "=================================="
echo "7.1. Créer une réservation test :"
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Blocage",
    "email": "test@example.com",
    "phone": "0123456789",
    "roomName": "Salle 2",
    "date": "2025-09-25",
    "timeSlot": "15:00 - 15:20",
    "duration": 20,
    "numberOfPeople": 1,
    "specialRequests": "Test blocage créneau"
  }' | jq '.'

echo ""
echo "7.2. Vérifier que le créneau 15:00 est maintenant bloqué :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-25&endDate=2025-09-25&roomName=Salle%202" | jq '.data."2025-09-25"."15:00"'

# 8. Vérifier les logs
echo ""
echo "8. VÉRIFICATION LOGS :"
echo "====================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=10 | grep -i -E "availability|réservation|créneau"

# 9. Instructions pour tester
echo ""
echo "9. INSTRUCTIONS POUR TESTER :"
echo "============================"
echo ""
echo "🎯 COMPORTEMENT ATTENDU MAINTENANT :"
echo "• Un créneau avec 1 réservation = COMPLET (peu importe le nombre de places)"
echo "• Plus de partage de créneaux entre clients"
echo "• Chaque réservation bloque complètement son créneau"
echo ""
echo "🧪 Pour tester sur le site :"
echo "1. Aller sur https://rageroom.usilenziu.com/reservation"
echo "2. Choisir 'Salle 2' (qui a des réservations)"
echo "3. Sélectionner le 23 septembre 2025"
echo "4. Vérifier que 14:00 est marqué 'Complet'"
echo "5. Choisir le 25 septembre 2025"
echo "6. Vérifier que 15:00 est marqué 'Complet' (réservation test)"
echo ""
echo "✅ CORRECTIONS APPORTÉES :"
echo "- Frontend utilise maintenant les booléens de l'API au lieu de calculer la capacité"
echo "- Un créneau réservé = indisponible pour tous"
echo "- Format d'heure corrigé (HH:MM au lieu de HH:MM:SS)"
echo "- Logique 'créneau occupé = complet' implémentée"
echo ""

# 10. Cleanup - supprimer la réservation test si nécessaire
echo ""
echo "10. NETTOYAGE :"
echo "=============="
echo "Pour supprimer la réservation test 15:00 du 25/09/2025 :"
echo "Aller sur https://rageroom.usilenziu.com/admin/reservations"
echo "Chercher 'Test Blocage' et supprimer si nécessaire"

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo ""
echo "🎯 NOUVELLE LOGIQUE :"
echo "❌ AVANT : Créneau partagé selon capacité max"
echo "✅ MAINTENANT : Un créneau = une réservation max"
echo ""
echo "📱 PRÊT À TESTER :"
echo "Les créneaux avec réservations sont maintenant complètement bloqués !"
