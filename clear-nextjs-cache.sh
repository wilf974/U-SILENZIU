#!/bin/bash

echo "=== VIDAGE CACHE NEXT.JS ET REDÉMARRAGE ==="
echo ""

# 1. Arrêter l'application
echo "1. 🛑 ARRÊT DE L'APPLICATION :"
echo "=============================="
docker compose -f docker-compose.prod.yml stop u-silenziu

# 2. Supprimer le cache Next.js dans le conteneur
echo ""
echo "2. 🧹 SUPPRESSION CACHE NEXT.JS :"
echo "================================="
docker compose -f docker-compose.prod.yml run --rm u-silenziu rm -rf /app/.next/cache/*
echo "Cache Next.js supprimé"

# 3. Redémarrer l'application
echo ""
echo "3. 🚀 REDÉMARRAGE APPLICATION :"
echo "==============================="
docker compose -f docker-compose.prod.yml up -d u-silenziu

# 4. Attendre stabilisation
echo ""
echo "4. ⏳ ATTENTE STABILISATION :"
echo "============================"
sleep 30

# 5. Test immédiat de l'API
echo ""
echo "5. 🧪 TEST API SANS CACHE :"
echo "=========================="
echo "Test avec timestamp pour forcer le bypass du cache :"
TIMESTAMP=$(date +%s)
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-23&endDate=2025-09-23&roomName=Salle%202&t=$TIMESTAMP" | grep -o '"14:00":[^,}]*'

# 6. Test du site
echo ""
echo ""
echo "6. 🌐 TEST SITE WEB :"
echo "===================="
echo "Testez maintenant sur :"
echo "https://rageroom.usilenziu.com/reservation?formule=Salle%202"
echo ""
echo "Le créneau 14:00 du 23/09/2025 devrait maintenant être 'Complet'"

# 7. Alternative - rebuild si le cache persiste
echo ""
echo "7. 🔄 SI LE PROBLÈME PERSISTE :"
echo "==============================="
echo "Executez cette commande pour un rebuild complet :"
echo "docker compose -f docker-compose.prod.yml build --no-cache u-silenziu"
echo "docker compose -f docker-compose.prod.yml up -d u-silenziu"

echo ""
echo "=== CACHE NEXT.JS VIDÉ ==="
echo ""
echo "✅ Application redémarrée"
echo "✅ Cache Next.js supprimé"  
echo "✅ API testée"
echo ""
echo "🎯 Le créneau 14:00 devrait maintenant être 'Complet' !"
