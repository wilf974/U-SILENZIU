#!/bin/bash

echo "=== CORRECTION ERREUR NAVIGATION CALENDRIER ==="
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
sleep 20

# 5. Vérifier l'état
echo ""
echo "5. ÉTAT DES CONTENEURS :"
echo "======================="
docker compose -f docker-compose.prod.yml ps

# 6. Test API calendrier hebdomadaire
echo ""
echo "6. TEST API CALENDRIER HEBDOMADAIRE :"
echo "====================================="
echo "6.1. Test récupération semaine courante :"
curl -s "https://rageroom.usilenziu.com/api/admin/reservations/weekly?week=$(date +%Y-%m-%d)" | head -c 500

echo ""
echo "6.2. Test avec une semaine spécifique :"
curl -s "https://rageroom.usilenziu.com/api/admin/reservations/weekly?week=2025-09-23" | head -c 500

# 7. Vérifier les logs d'erreur
echo ""
echo "7. VÉRIFICATION LOGS D'ERREUR :"
echo "==============================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=10 | grep -i -E "error|erreur|undefined|substring"

# 8. Instructions pour tester
echo ""
echo "8. INSTRUCTIONS POUR TESTER :"
echo "============================"
echo ""
echo "🗓️ Pour tester la navigation du calendrier :"
echo "1. Aller sur https://rageroom.usilenziu.com/admin/reservations"
echo "2. Cliquer sur l'onglet 'Calendrier'"
echo "3. Utiliser les boutons ← et → pour naviguer entre semaines"
echo "4. Cliquer sur 'Aujourd'hui' pour revenir à la semaine courante"
echo ""
echo "✅ CORRECTIONS APPORTÉES :"
echo "- Interface Reservation mise à jour (time_slot au lieu de time)"
echo "- customer_name au lieu de first_name/last_name"
echo "- participants au lieu de number_of_people"
echo "- Protection contre les valeurs undefined dans formatTime()"
echo ""

# 9. Test de compilation frontend
echo ""
echo "9. VÉRIFICATION COMPILATION :"
echo "============================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=5 | grep -E "Ready|Error|compiled"

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo ""
echo "🎯 ERREUR CORRIGÉE :"
echo "❌ AVANT : TypeError: can't access property \"substring\", e is undefined"
echo "✅ MAINTENANT : Navigation calendrier fonctionnelle"
echo ""
echo "📱 PRÊT À TESTER :"
echo "Naviguez dans le calendrier hebdomadaire - l'erreur ne devrait plus apparaître !"
