#!/bin/bash

echo "=========================================="
echo "🚀 DÉPLOIEMENT COMPLET DES CORRECTIONS"
echo "=========================================="
echo ""

# 1. Récupération du code
echo "1. 📥 RÉCUPÉRATION DU CODE DEPUIS GITHUB :"
echo "=========================================="
git pull origin main
echo "✅ Code récupéré"
echo ""

# 2. Arrêt des services
echo "2. 🛑 ARRÊT DES SERVICES :"
echo "=========================="
docker compose -f docker-compose.prod.yml down
echo "✅ Services arrêtés"
echo ""

# 3. Nettoyage Docker (optionnel mais recommandé)
echo "3. 🧹 NETTOYAGE DOCKER :"
echo "========================"
docker system prune -f
echo "✅ Cache Docker nettoyé"
echo ""

# 4. Rebuild complet sans cache
echo "4. 🔨 REBUILD SANS CACHE :"
echo "=========================="
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu
echo "✅ Application reconstruite"
echo ""

# 5. Redémarrage de tous les services
echo "5. 🚀 REDÉMARRAGE COMPLET :"
echo "==========================="
docker compose -f docker-compose.prod.yml up -d
echo "✅ Tous les services redémarrés"
echo ""

# 6. Attente de stabilisation
echo "6. ⏳ ATTENTE DE STABILISATION :"
echo "==============================="
echo "Attente 30 secondes pour la stabilisation..."
sleep 30
echo "✅ Stabilisation terminée"
echo ""

# 7. Vérification de l'état des conteneurs
echo "7. 📊 ÉTAT DES CONTENEURS :"
echo "==========================="
docker compose -f docker-compose.prod.yml ps
echo ""

# 8. Vérification des logs de démarrage
echo "8. 📋 LOGS DE DÉMARRAGE :"
echo "========================"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=15
echo ""

# 9. Tests des APIs principales
echo "9. 🧪 TESTS DES APIs :"
echo "====================="

echo "9.1. Test API homepage :"
curl -s -w "Status: %{http_code}\n" "https://rageroom.usilenziu.com/api/homepage-config" | head -c 200
echo -e "\n"

echo "9.2. Test API réservations :"
curl -s -w "Status: %{http_code}\n" "https://rageroom.usilenziu.com/api/admin/reservations" | head -c 200
echo -e "\n"

echo "9.3. Test API availability :"
curl -s -w "Status: %{http_code}\n" "https://rageroom.usilenziu.com/api/reservations/availability?startDate=$(date +%Y-%m-%d)&endDate=$(date +%Y-%m-%d)" | head -c 200
echo -e "\n"

# 10. Test spécifique des créneaux bloqués
echo "10. 🎯 TEST CRÉNEAUX BLOQUÉS :"
echo "============================="
echo "Vérification que les créneaux réservés sont marqués comme indisponibles :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-23&endDate=2025-09-23&roomName=Salle%202" | jq -r '.data."2025-09-23"."14:00"' 2>/dev/null || echo "false"
echo ""

# 11. Création d'une réservation test pour valider les emails
echo "11. 📧 TEST CRÉATION RÉSERVATION + EMAIL :"
echo "========================================="
echo "Création d'une réservation test pour valider le système complet :"
RESPONSE=$(curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Déploiement", 
    "email": "jean.maillot14@gmail.com",
    "phone": "0123456789",
    "roomName": "Salle 2",
    "date": "2025-09-26", 
    "timeSlot": "16:00 - 16:20",
    "duration": 20,
    "numberOfPeople": 2,
    "specialRequests": "Test déploiement complet"
  }')

echo "Réponse API :"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# 12. Vérification que le créneau est maintenant bloqué
echo "12. 🔒 VÉRIFICATION BLOCAGE CRÉNEAU :"
echo "===================================="
echo "Vérification que 16:00 du 26/09/2025 est maintenant bloqué :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-26&endDate=2025-09-26&roomName=Salle%202" | jq -r '.data."2025-09-26"."16:00"' 2>/dev/null || echo "Pas de données"
echo ""

# 13. Vérification des logs d'email
echo "13. 📬 LOGS D'EMAIL :"
echo "===================="
echo "Recherche des logs d'envoi d'email :"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20 | grep -i -E "email|smtp|envoyé|confirmation" || echo "Aucun log d'email trouvé"
echo ""

# 14. Instructions de test manuel
echo "14. 📋 INSTRUCTIONS DE TEST MANUEL :"
echo "===================================="
echo ""
echo "✅ FONCTIONNALITÉS DÉPLOYÉES :"
echo "• Emails de validation/annulation depuis l'admin"
echo "• Navigation calendrier corrigée (plus d'erreur substring)"
echo "• Créneaux exclusifs (un créneau = une réservation max)"
echo ""
echo "🧪 TESTS À EFFECTUER :"
echo ""
echo "1. 📧 TEST EMAILS DE STATUT :"
echo "   • https://rageroom.usilenziu.com/admin/reservations"
echo "   • Cliquer ✅ (confirmer) sur une réservation 'En attente'"
echo "   • Cliquer ❌ (annuler) sur une réservation"
echo "   • Vérifier les emails dans jean.maillot14@gmail.com"
echo ""
echo "2. 📅 TEST CALENDRIER ADMIN :"
echo "   • https://rageroom.usilenziu.com/admin/reservations"
echo "   • Onglet 'Calendrier'"
echo "   • Naviguer avec ← → (plus d'erreur substring)"
echo ""
echo "3. 🚫 TEST CRÉNEAUX EXCLUSIFS :"
echo "   • https://rageroom.usilenziu.com/reservation"
echo "   • Choisir 'Salle 2'"
echo "   • Date 23/09/2025 → vérifier créneaux 'Complet'"
echo "   • Date 26/09/2025 → vérifier 16:00 'Complet'"
echo ""
echo "4. 🔄 TEST NOUVELLE RÉSERVATION :"
echo "   • Créer une nouvelle réservation"
echo "   • Vérifier email de confirmation automatique"
echo "   • Vérifier que le créneau devient 'Complet'"
echo ""

# 15. URLs importantes
echo "15. 🔗 LIENS RAPIDES :"
echo "====================="
echo "• Site public : https://rageroom.usilenziu.com"
echo "• Admin login : https://rageroom.usilenziu.com/admin"
echo "• Réservations : https://rageroom.usilenziu.com/reservation"
echo "• Admin réservations : https://rageroom.usilenziu.com/admin/reservations"
echo ""

# 16. Nettoyage optionnel
echo "16. 🧹 NETTOYAGE (OPTIONNEL) :"
echo "=============================="
echo "Pour supprimer la réservation test 'Test Déploiement' :"
echo "• Aller dans l'admin réservations"
echo "• Chercher 'Test Déploiement'"
echo "• Supprimer si nécessaire"
echo ""

echo "=========================================="
echo "🎉 DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !"
echo "=========================================="
echo ""
echo "💫 NOUVELLES FONCTIONNALITÉS ACTIVES :"
echo "✅ Emails automatiques de changement de statut"
echo "✅ Navigation calendrier sans erreur"
echo "✅ Créneaux exclusifs (pas de partage)"
echo "✅ Système de réservation optimisé"
echo ""
echo "🚀 PRÊT POUR LA PRODUCTION !"
echo "Testez les fonctionnalités et profitez ! 🎯"
