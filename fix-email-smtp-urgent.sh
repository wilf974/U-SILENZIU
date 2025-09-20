#!/bin/bash

echo "=== FIX URGENT - CONFIGURATION SMTP EMAIL ==="
echo ""

# 1. Pull latest code
echo "1. Récupération du code corrigé..."
git pull origin main

# 2. Rebuild de l'application avec les corrections SMTP
echo ""
echo "2. REBUILD DE L'APPLICATION :"
echo "============================="
docker compose -f docker-compose.prod.yml down u-silenziu
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu
docker compose -f docker-compose.prod.yml up -d u-silenziu

# 3. Attendre le redémarrage
echo ""
echo "3. ATTENTE DU REDÉMARRAGE..."
sleep 30

# 4. Vérifier l'état
echo ""
echo "4. VÉRIFICATION DE L'ÉTAT :"
echo "=========================="
docker compose -f docker-compose.prod.yml ps

# 5. Vérifier la configuration SMTP en base
echo ""
echo "5. VÉRIFICATION CONFIG SMTP EN BASE :"
echo "===================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
    id, 
    host, 
    port, 
    secure, 
    username, 
    from_name, 
    from_email,
    is_active,
    created_at
FROM smtp_config 
WHERE is_active = true
ORDER BY created_at DESC 
LIMIT 1;
"

# 6. Test d'envoi d'email via une nouvelle réservation
echo ""
echo "6. TEST D'ENVOI EMAIL - NOUVELLE RÉSERVATION :"
echo "=============================================="
echo "Création d'une réservation de test pour jean.maillot14@gmail.com..."

curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Email Fix",
    "email": "jean.maillot14@gmail.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-22",
    "timeSlot": "16:20 - 16:40",
    "duration": 20,
    "numberOfPeople": 1,
    "specialRequests": "Test après correction SMTP"
  }'

# 7. Vérifier immédiatement les logs d'email
echo ""
echo "7. LOGS D'EMAIL IMMÉDIATEMENT APRÈS :"
echo "==================================="
sleep 5
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=30 | grep -i -E "email|smtp|mail|confirmation|envoi|transporteur"

# 8. Vérifier la nouvelle réservation en base
echo ""
echo "8. VÉRIFICATION DE LA NOUVELLE RÉSERVATION :"
echo "==========================================="
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
ORDER BY created_at DESC 
LIMIT 3;
"

# 9. Test direct de la fonction email (debug)
echo ""
echo "9. TEST DIRECT DE LA FONCTION EMAIL :"
echo "===================================="
docker exec u-silenziu-app node -e "
const { sendReservationConfirmationEmail } = require('./lib/email.js');

async function testEmailDirect() {
  try {
    console.log('🧪 Test direct de l\\'envoi d\\'email...');
    
    const testData = {
      reservationNumber: 'TEST001',
      customerName: 'Test Direct',
      customerEmail: 'jean.maillot14@gmail.com',
      customerPhone: '0123456789',
      roomName: 'Salle 1',
      date: '2025-09-22',
      timeSlot: '17:00 - 17:20',
      duration: 20,
      participants: 1,
      amount: 25,
      specialRequests: 'Test direct de la fonction email'
    };
    
    const result = await sendReservationConfirmationEmail(testData);
    console.log('📧 Résultat envoi email:', result);
    
  } catch (error) {
    console.error('❌ Erreur test direct:', error.message);
  }
}

testEmailDirect();
"

# 10. Logs finaux complets
echo ""
echo "10. LOGS FINAUX COMPLETS :"
echo "========================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50

echo ""
echo "=== FIX TERMINÉ ==="
echo "✅ Configuration SMTP corrigée (utilise la base au lieu des variables env)"
echo "✅ Logs d'email améliorés"  
echo "✅ Gestion d'erreur renforcée"
echo ""
echo "🔍 Vérifiez:"
echo "1. Les logs d'email ci-dessus"
echo "2. Votre boîte mail jean.maillot14@gmail.com"
echo "3. Le dossier spam si nécessaire"
echo ""
echo "Si l'email n'arrive toujours pas, vérifiez les paramètres SMTP dans l'admin !"
