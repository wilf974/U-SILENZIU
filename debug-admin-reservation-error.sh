#!/bin/bash

echo "=== DIAGNOSTIC ERREUR CRÉATION RÉSERVATION ADMIN ==="
echo ""

# 1. Test avec logs détaillés
echo "1. 🧪 TEST AVEC LOGS DÉTAILLÉS :"
echo "================================="
curl -v -X POST "https://rageroom.usilenziu.com/api/admin/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Test",
    "last_name": "Admin",
    "email": "test.admin@example.com",
    "phone": "0123456789",
    "date": "2025-09-25",
    "time": "15:00",
    "duration": 20,
    "number_of_people": 2,
    "room_name": "Salle 1",
    "status": "confirmed",
    "notes": "Test depuis admin"
  }' 2>&1

echo ""
echo ""

# 2. Vérifier les logs de l'application
echo "2. 🔍 LOGS APPLICATION :"
echo "========================"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20 | grep -E "reservation|Reservation|error|Error|ERROR" || echo "Aucun log récent"

echo ""
echo ""

# 3. Test simple de l'API
echo "3. 🧪 TEST API SIMPLE :"
echo "======================"
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | head -5

echo ""
echo ""

# 4. Vérifier la structure de la table reservations
echo "4. 🔍 STRUCTURE TABLE RESERVATIONS :"
echo "===================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d reservations"

echo ""
echo ""

# 5. Test de création directe en base
echo "5. 🧪 TEST CRÉATION DIRECTE EN BASE :"
echo "====================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO reservations (
  reservation_number, customer_name, customer_email, customer_phone,
  room_name, date, time_slot, duration, participants, status, amount, special_requests
) VALUES (
  'TEST001', 'Test Admin', 'test@admin.com', '0123456789',
  'Salle 1', '2025-09-25', '15:00', 20, 2, 'confirmed', 50.00, 'Test direct'
) RETURNING id, reservation_number, customer_name;
"

echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
