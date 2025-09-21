#!/bin/bash

echo "=== TEST RÉPONSE API RAW ==="
echo ""

# 1. Test GET d'abord
echo "1. 🧪 TEST GET API ADMIN :"
echo "=========================="
curl -s "https://rageroom.usilenziu.com/api/admin/reservations"
echo ""

# 2. Test POST avec réponse brute
echo "2. 🧪 TEST POST API ADMIN (RÉPONSE BRUTE) :"
echo "==========================================="
curl -s -X POST "https://rageroom.usilenziu.com/api/admin/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Test",
    "last_name": "Raw",
    "email": "test.raw@example.com",
    "phone": "0123456789",
    "date": "2025-09-25",
    "time": "15:00",
    "duration": 20,
    "number_of_people": 2,
    "room_name": "Salle 1",
    "status": "confirmed",
    "notes": "Test raw"
  }'

echo ""
echo ""

# 3. Test avec code de statut HTTP
echo "3. 🧪 TEST AVEC CODE STATUT :"
echo "============================="
curl -w "HTTP Status: %{http_code}\n" -s -X POST "https://rageroom.usilenziu.com/api/admin/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Test",
    "last_name": "Status",
    "email": "test.status@example.com",
    "phone": "0123456789",
    "date": "2025-09-25",
    "time": "15:00",
    "duration": 20,
    "number_of_people": 2,
    "room_name": "Salle 1",
    "status": "confirmed",
    "notes": "Test status"
  }' > /dev/null

echo ""
echo "=== TEST TERMINÉ ==="
