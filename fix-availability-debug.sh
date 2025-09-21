#!/bin/bash

echo "=== CORRECTION API AVAILABILITY AVEC LOGS DEBUG ==="
echo ""

# 1. Pull correction
echo "1. 📥 RÉCUPÉRATION CORRECTION :"
echo "==============================="
git pull origin main

# 2. Rebuild rapide
echo ""
echo "2. 🔨 REBUILD RAPIDE :"
echo "====================="
docker compose -f docker-compose.prod.yml build u-silenziu

# 3. Redémarrer app
echo ""
echo "3. 🚀 REDÉMARRAGE APP :"
echo "======================="
docker compose -f docker-compose.prod.yml up -d u-silenziu

# 4. Attendre stabilisation
echo ""
echo "4. ⏳ ATTENTE (20s) :"
echo "===================="
sleep 20

# 5. Test API avec logs détaillés
echo ""
echo "5. 🧪 TEST API AVEC LOGS :"
echo "=========================="
echo "Test API availability :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-23&endDate=2025-09-23&roomName=Salle%202&debug=1"

# 6. Vérifier les logs détaillés
echo ""
echo ""
echo "6. 📋 LOGS DÉTAILLÉS :"
echo "====================="
echo "Recherche des nouveaux logs de debug :"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=30 | grep -E "Réservation trouvée|Availability keys|Looking for|Extracted|marqué comme occupé|not found"

# 7. Test simple pour voir le résultat
echo ""
echo ""
echo "7. ✅ RÉSULTAT FINAL :"
echo "====================="
echo "Vérification que 14:00 est maintenant 'false' :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-23&endDate=2025-09-23&roomName=Salle%202" | grep -o '"14:00":[^,}]*'

echo ""
echo ""
echo "=== CORRECTION TERMINÉE ==="
echo ""
echo "✅ Logs de debug ajoutés"
echo "✅ Normalisation des dates implémentée"
echo "✅ Messages d'erreur détaillés"
echo ""
echo "🎯 RÉSULTAT ATTENDU :"
echo "\"14:00\":false (au lieu de true)"
echo ""
echo "Si ça ne marche toujours pas, les logs vont nous dire exactement où est le problème !"
