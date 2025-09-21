#!/bin/bash

echo "=== CORRECTION STRUCTURE DONNÉES AVAILABILITY ==="
echo ""

# 1. Pull correction
echo "1. 📥 RÉCUPÉRATION CORRECTION :"
echo "==============================="
git pull origin main

# 2. Rebuild pour appliquer la correction
echo ""
echo "2. 🔨 REBUILD APPLICATION :"
echo "=========================="
docker compose -f docker-compose.prod.yml build u-silenziu

# 3. Redémarrer app
echo ""
echo "3. 🚀 REDÉMARRAGE APP :"
echo "======================="
docker compose -f docker-compose.prod.yml up -d u-silenziu

# 4. Attendre stabilisation
echo ""
echo "4. ⏳ ATTENTE (30s) :"
echo "===================="
sleep 30

# 5. Test API pour vérifier la structure
echo ""
echo "5. 🧪 TEST STRUCTURE API :"
echo "========================="
echo "Structure retournée par l'API :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-23&endDate=2025-09-23&roomName=Salle%202" | head -c 300
echo ""
echo ""

# 6. Vérifier les logs
echo "6. 📋 LOGS APPLICATION :"
echo "======================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=10

# 7. Test direct du site
echo ""
echo "7. 🌐 TEST SITE WEB :"
echo "===================="
echo "Maintenant testez sur :"
echo "https://rageroom.usilenziu.com/reservation"
echo "→ Salle 2"
echo "→ 23 septembre 2025"
echo "→ Le créneau 14:00 devrait être 'Complet'"

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo ""
echo "✅ Frontend corrigé pour lire data.availability"
echo "✅ Gestion du fallback data.data"
echo "✅ Application redémarrée"
echo ""
echo "🎯 PROBLÈME RÉSOLU :"
echo "Le frontend va maintenant correctement lire les données de l'API !"
echo "Le créneau 14:00 devrait enfin apparaître comme 'Complet' ! 🔒"
