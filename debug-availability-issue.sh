#!/bin/bash

echo "=== DIAGNOSTIC PROBLÈME DISPONIBILITÉ ==="
echo ""

# 1. Test API availability directement
echo "1. 🔍 TEST API AVAILABILITY :"
echo "============================"
echo "Test pour Salle 2, date 2025-09-23 :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-23&endDate=2025-09-23&roomName=Salle%202"
echo ""
echo ""

# 2. Test sans filtre de salle
echo "2. 🔍 TEST SANS FILTRE SALLE :"
echo "============================="
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-23&endDate=2025-09-23"
echo ""
echo ""

# 3. Vérifier la réservation dans la base
echo "3. 🔍 VÉRIFICATION BASE DE DONNÉES :"
echo "==================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  reservation_number,
  customer_name,
  room_name,
  date,
  time_slot,
  status,
  participants
FROM reservations 
WHERE date = '2025-09-23' AND room_name = 'Salle 2'
ORDER BY time_slot;
"

# 4. Vérifier tous les réservations confirmées
echo ""
echo "4. 🔍 TOUTES LES RÉSERVATIONS CONFIRMÉES :"
echo "========================================"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT COUNT(*) as total_confirmed
FROM reservations 
WHERE status = 'confirmed';
"

# 5. Vérifier les logs de l'API en temps réel
echo ""
echo "5. 🔍 LOGS API EN TEMPS RÉEL :"
echo "============================="
echo "Recherche des logs de vérification disponibilité :"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=30 | grep -E "Vérification disponibilité|Réservation trouvée|Créneau marqué"

# 6. Test de l'API avec des dates différentes
echo ""
echo "6. 🔍 TEST AUTRES FORMATS DE DATE :"
echo "=================================="
echo "Test avec format ISO complet :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-23T00:00:00&endDate=2025-09-23T23:59:59&roomName=Salle%202"
echo ""
echo ""

# 7. Forcer un appel API pour voir les logs
echo "7. 🔍 FORCER APPEL API :"
echo "======================="
echo "Simulation d'une recherche de créneaux :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-23&endDate=2025-09-23&roomName=Salle%202&t=$(date +%s)"

echo ""
echo ""
echo "=== RÉSULTATS ATTENDUS ==="
echo ""
echo "✅ L'API devrait retourner :"
echo '{"success":true,"data":{"2025-09-23":{"14:00":false,"14:20":true,...}}}'
echo ""
echo "❌ Si 14:00 = true, alors le problème est dans l'API"
echo "❌ Si 14:00 = false mais frontend montre 'disponible', c'est un problème de cache/frontend"
echo ""
echo "🔧 SOLUTIONS POSSIBLES :"
echo "- Vider le cache navigateur (Ctrl+F5)"
echo "- Mode navigation privée"
echo "- Vérifier les logs Docker pour les erreurs"
