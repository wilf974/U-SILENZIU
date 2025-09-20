#!/bin/bash

echo "=== FIX URGENT - INTERFACE SMTP MANQUANTE ==="
echo ""

# 1. Pull les corrections
echo "1. RÉCUPÉRATION DES CORRECTIONS :"
echo "================================="
git pull origin main

# 2. Vérifier la base de données pour from_name
echo ""
echo "2. VÉRIFICATION COLONNE FROM_NAME EN BASE :"
echo "=========================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d smtp_config;"

# 3. Ajouter la colonne from_name si elle n'existe pas
echo ""
echo "3. AJOUT DE LA COLONNE FROM_NAME SI NÉCESSAIRE :"
echo "=============================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
ALTER TABLE smtp_config 
ADD COLUMN IF NOT EXISTS from_name VARCHAR(255) DEFAULT 'U Silenziu';
"

# 4. Mettre à jour les configs existantes
echo ""
echo "4. MISE À JOUR DES CONFIGS EXISTANTES :"
echo "======================================"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE smtp_config 
SET from_name = 'U Silenziu' 
WHERE from_name IS NULL OR from_name = '';
"

# 5. Vérifier la structure finale
echo ""
echo "5. STRUCTURE FINALE DE LA TABLE :"
echo "================================"
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

# 6. Rebuild maintenant avec l'interface corrigée
echo ""
echo "6. REBUILD AVEC INTERFACE CORRIGÉE :"
echo "==================================="
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu

# 7. Redémarrer l'application
echo ""
echo "7. REDÉMARRAGE DE L'APPLICATION :"
echo "================================"
docker compose -f docker-compose.prod.yml up -d

# 8. Attendre stabilisation
echo ""
echo "8. ATTENTE STABILISATION :"
echo "========================="
sleep 30

# 9. Vérifier l'état
echo ""
echo "9. ÉTAT DES CONTENEURS :"
echo "======================="
docker compose -f docker-compose.prod.yml ps

# 10. Test immédiat d'une réservation
echo ""
echo "10. TEST IMMÉDIAT RÉSERVATION :"
echo "=============================="
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Interface Fix",
    "email": "jean.maillot14@gmail.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-27",
    "timeSlot": "19:00 - 19:20",
    "duration": 20,
    "numberOfPeople": 1,
    "specialRequests": "Test après fix interface SMTP"
  }'

# 11. Vérifier les logs d'email
echo ""
echo "11. LOGS D'EMAIL APRÈS FIX :"
echo "=========================="
sleep 5
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20

echo ""
echo "=== FIX INTERFACE TERMINÉ ==="
echo "✅ Interface SmtpConfig corrigée (from_name ajouté)"
echo "✅ Colonne from_name ajoutée en base"
echo "✅ Application recompilée et redémarrée"
echo ""
echo "🔍 Vérifiez :"
echo "1. Absence d'erreur TypeScript"
echo "2. Logs 'Configuration SMTP trouvée'"
echo "3. Email de confirmation reçu"
echo ""
echo "L'email devrait maintenant fonctionner !"
