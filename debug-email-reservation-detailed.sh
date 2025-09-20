#!/bin/bash

echo "=== DEBUG DÉTAILLÉ - EMAIL RÉSERVATION ==="
echo ""

# 1. Créer une réservation de test avec logs détaillés
echo "1. CRÉATION D'UNE RÉSERVATION DE TEST :"
echo "====================================="
echo "Email de test: jean.maillot14@gmail.com"

echo "Avant la réservation - logs actuels:"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=5

echo ""
echo "Création de la réservation..."
RESPONSE=$(curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Debug",
    "lastName": "Email Test",
    "email": "jean.maillot14@gmail.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-25",
    "timeSlot": "17:20 - 17:40",
    "duration": 20,
    "numberOfPeople": 1,
    "specialRequests": "Test debug email détaillé"
  }')

echo "Réponse API:"
echo "$RESPONSE"

# 2. Vérifier immédiatement les logs après la réservation
echo ""
echo "2. LOGS IMMÉDIATEMENT APRÈS LA RÉSERVATION :"
echo "==========================================="
sleep 3
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50

# 3. Vérifier la réservation en base
echo ""
echo "3. VÉRIFICATION DE LA RÉSERVATION EN BASE :"
echo "=========================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
    id, 
    reservation_number, 
    customer_name, 
    customer_email, 
    room_name, 
    date, 
    time_slot,
    participants,
    amount,
    status,
    special_requests,
    created_at
FROM reservations 
WHERE customer_email = 'jean.maillot14@gmail.com' 
AND special_requests LIKE '%debug%'
ORDER BY created_at DESC 
LIMIT 1;
"

# 4. Test direct de l'envoi d'email avec la même réservation
echo ""
echo "4. TEST DIRECT DE L'ENVOI D'EMAIL :"
echo "=================================="
docker exec u-silenziu-app node -e "
const { sendReservationConfirmationEmail } = require('./lib/email.js');

async function testEmailWithRealData() {
  try {
    console.log('🧪 Test avec les données réelles de réservation...');
    
    const emailData = {
      reservationNumber: '250920002', // ou le numéro généré
      customerName: 'Debug Email Test',
      customerEmail: 'jean.maillot14@gmail.com',
      customerPhone: '0123456789',
      roomName: 'Salle 1',
      date: '2025-09-25',
      timeSlot: '17:20 - 17:40',
      duration: 20,
      participants: 1,
      amount: 25,
      specialRequests: 'Test debug email détaillé'
    };
    
    console.log('📧 Données email:', emailData);
    
    const result = await sendReservationConfirmationEmail(emailData);
    console.log('✅ Résultat envoi email:', result);
    
  } catch (error) {
    console.error('❌ Erreur test direct:', error);
    console.error('Stack:', error.stack);
  }
}

testEmailWithRealData();
"

# 5. Vérifier les erreurs Node.js et les promises rejetées
echo ""
echo "5. RECHERCHE D'ERREURS NON CATCHÉES :"
echo "===================================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=100 | grep -i -E "error|unhandled|promise|rejection|crash|fail"

# 6. Vérifier le code de l'API réservation
echo ""
echo "6. VÉRIFICATION DU CODE API RÉSERVATION :"
echo "========================================"
echo "Recherche de l'appel sendReservationConfirmationEmail..."
docker exec u-silenziu-app grep -n "sendReservationConfirmationEmail" /app/.next/server/app/api/reservations/route.js 2>/dev/null || echo "Fichier compilé non trouvé"

# 7. Test du système de notifications
echo ""
echo "7. TEST SYSTÈME DE NOTIFICATIONS :"
echo "================================="
echo "Recherche des logs de notification automatique..."
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=200 | grep -i -E "notification|cron|smtp.*trouvée|smtp.*initialisée"

# 8. Vérifier l'import de la fonction email
echo ""
echo "8. VÉRIFICATION DES IMPORTS :"
echo "============================"
docker exec u-silenziu-app node -e "
try {
  console.log('Test des imports...');
  const emailModule = require('./lib/email.js');
  console.log('✅ Module email importé');
  console.log('Fonctions disponibles:', Object.keys(emailModule));
  
  const dbModule = require('./lib/database.js');
  console.log('✅ Module database importé');
  console.log('getSmtpConfigDecrypted disponible:', typeof dbModule.getSmtpConfigDecrypted);
  
} catch (error) {
  console.error('❌ Erreur import:', error.message);
}
"

# 9. Dernière vérification des logs en temps réel
echo ""
echo "9. LOGS EN TEMPS RÉEL (10 secondes) :"
echo "==================================="
echo "Surveillance des logs pendant 10 secondes..."
timeout 10 docker compose -f docker-compose.prod.yml logs u-silenziu -f || echo "Surveillance terminée"

echo ""
echo "=== DEBUG TERMINÉ ==="
echo ""
echo "🔍 Points à vérifier :"
echo "1. La réservation a-t-elle été créée ?"
echo "2. Y a-t-il des erreurs dans les logs ?"
echo "3. L'email de test direct fonctionne-t-il ?"
echo "4. Y a-t-il des erreurs de compilation ?"
echo "5. L'email est-il arrivé dans jean.maillot14@gmail.com ?"
