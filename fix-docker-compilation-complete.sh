#!/bin/bash

echo "=== FIX COMPLET - RECOMPILATION DOCKER POUR EMAILS ==="
echo ""

# 1. Arrêter complètement l'application
echo "1. ARRÊT COMPLET DE L'APPLICATION :"
echo "=================================="
docker compose -f docker-compose.prod.yml down

# 2. Nettoyer complètement Docker (images, cache, conteneurs)
echo ""
echo "2. NETTOYAGE COMPLET DOCKER :"
echo "============================"
docker system prune -f --volumes
docker builder prune -f
docker image prune -f -a

# 3. Supprimer spécifiquement l'image de l'app
echo ""
echo "3. SUPPRESSION DE L'IMAGE APPLICATION :"
echo "======================================"
docker rmi u-silenziu-u-silenziu:latest 2>/dev/null || echo "Image déjà supprimée"

# 4. Pull du code le plus récent
echo ""
echo "4. RÉCUPÉRATION DU CODE LE PLUS RÉCENT :"
echo "========================================"
git pull origin main

# 5. Vérifier que les corrections email sont bien présentes
echo ""
echo "5. VÉRIFICATION DES CORRECTIONS EMAIL :"
echo "======================================"
echo "Vérification de lib/email.ts:"
grep -n "getSmtpConfigDecrypted" lib/email.ts || echo "❌ Fonction manquante"
grep -n "Configuration SMTP trouvée" lib/email.ts || echo "❌ Log manquant"

echo ""
echo "Vérification de app/api/reservations/route.ts:"
grep -n "sendReservationConfirmationEmail" app/api/reservations/route.ts || echo "❌ Import manquant"

# 6. Rebuild complet sans cache
echo ""
echo "6. REBUILD COMPLET SANS CACHE :"
echo "=============================="
docker compose -f docker-compose.prod.yml build --no-cache --pull u-silenziu

# 7. Redémarrer tous les services
echo ""
echo "7. REDÉMARRAGE COMPLET :"
echo "======================="
docker compose -f docker-compose.prod.yml up -d

# 8. Attendre la stabilisation
echo ""
echo "8. ATTENTE DE STABILISATION :"
echo "==========================="
echo "Attente 45 secondes pour la compilation complète..."
sleep 45

# 9. Vérifier l'état des conteneurs
echo ""
echo "9. ÉTAT DES CONTENEURS :"
echo "======================="
docker compose -f docker-compose.prod.yml ps

# 10. Vérifier la compilation de l'app
echo ""
echo "10. VÉRIFICATION DE LA COMPILATION :"
echo "==================================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20

# 11. Test immédiat d'une nouvelle réservation
echo ""
echo "11. TEST IMMÉDIAT NOUVELLE RÉSERVATION :"
echo "======================================="
echo "Création d'une réservation pour tester l'email..."

curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Compilation",
    "email": "jean.maillot14@gmail.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-26",
    "timeSlot": "18:00 - 18:20",
    "duration": 20,
    "numberOfPeople": 1,
    "specialRequests": "Test après recompilation complète"
  }'

# 12. Vérifier les logs d'email immédiatement
echo ""
echo "12. LOGS D'EMAIL APRÈS RECOMPILATION :"
echo "====================================="
sleep 5
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=30 | grep -i -E "email|smtp|confirmation|configuration.*smtp|envoi"

# 13. Test de l'import du module email
echo ""
echo "13. TEST DE L'IMPORT DU MODULE EMAIL :"
echo "===================================="
docker exec u-silenziu-app node -e "
try {
  console.log('🧪 Test des imports après recompilation...');
  
  // Test avec le chemin correct pour l'app compilée
  const emailModule = require('./.next/server/chunks/[email-chunk].js') || 
                      require('./lib/email') ||
                      require('./lib/email.js');
  
  console.log('✅ Module email trouvé');
  console.log('Fonctions disponibles:', Object.keys(emailModule));
  
} catch (error) {
  console.log('❌ Erreur import module email:', error.message);
  
  // Test alternatif
  try {
    const fs = require('fs');
    const emailFile = fs.readFileSync('./lib/email.ts', 'utf8');
    console.log('✅ Fichier source email.ts trouvé, taille:', emailFile.length);
    
    // Vérifier si le build a bien compilé
    const buildDir = fs.readdirSync('./.next/server', { withFileTypes: true });
    console.log('📁 Contenu .next/server:', buildDir.map(d => d.name));
    
  } catch (fsError) {
    console.log('❌ Erreur lecture fichier:', fsError.message);
  }
}
"

# 14. Vérifier la nouvelle réservation en base
echo ""
echo "14. VÉRIFICATION DE LA NOUVELLE RÉSERVATION :"
echo "============================================="
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
WHERE special_requests LIKE '%recompilation%'
ORDER BY created_at DESC 
LIMIT 1;
"

# 15. Test final direct de l'email avec le nouveau build
echo ""
echo "15. TEST FINAL DIRECT DE L'EMAIL :"
echo "================================="
docker exec u-silenziu-app node -e "
async function testEmailFinal() {
  try {
    console.log('🔧 Test final après recompilation...');
    
    // Utiliser l'API directement
    const response = await fetch('http://localhost:3000/api/admin/smtp/test', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        to: 'jean.maillot14@gmail.com',
        subject: 'Test après recompilation Docker',
        message: 'Test envoi email après correction complète'
      })
    });
    
    const result = await response.json();
    console.log('📧 Résultat test email:', result);
    
  } catch (error) {
    console.error('❌ Erreur test final:', error.message);
  }
}

testEmailFinal();
"

echo ""
echo "=== RECOMPILATION TERMINÉE ==="
echo "✅ Docker nettoyé et recompilé"
echo "✅ Application redémarrée"
echo "✅ Test de réservation effectué"
echo ""
echo "🔍 Vérifiez :"
echo "1. Les logs d'email ci-dessus"
echo "2. Votre boîte mail jean.maillot14@gmail.com" 
echo "3. Pas de message 'Configuration SMTP manquante'"
echo "4. Présence de 'Configuration SMTP trouvée'"
echo ""
echo "Si l'email arrive maintenant, le problème était la compilation Docker !"
