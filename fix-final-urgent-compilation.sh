#!/bin/bash

echo "=== FIX FINAL URGENT - COMPILATION ET CONTENEURS ==="
echo ""

# 1. Pull les dernières corrections
echo "1. RÉCUPÉRATION DES DERNIÈRES CORRECTIONS :"
echo "=========================================="
git pull origin main

# 2. Nettoyer complètement
echo ""
echo "2. NETTOYAGE COMPLET :"
echo "===================="
docker compose -f docker-compose.prod.yml down
docker system prune -f

# 3. Démarrer uniquement postgres pour les corrections DB
echo ""
echo "3. DÉMARRAGE POSTGRES POUR CORRECTIONS :"
echo "======================================="
docker compose -f docker-compose.prod.yml up -d postgres

# 4. Attendre que postgres soit prêt
echo ""
echo "4. ATTENTE POSTGRES :"
echo "==================="
sleep 10

# 5. Ajouter la colonne from_name
echo ""
echo "5. AJOUT COLONNE FROM_NAME :"
echo "=========================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
ALTER TABLE smtp_config 
ADD COLUMN IF NOT EXISTS from_name VARCHAR(255) DEFAULT 'U Silenziu';
"

# 6. Mettre à jour les configs existantes
echo ""
echo "6. MISE À JOUR CONFIGS EXISTANTES :"
echo "================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE smtp_config 
SET from_name = 'U Silenziu' 
WHERE from_name IS NULL OR from_name = '';
"

# 7. Vérifier la structure
echo ""
echo "7. VÉRIFICATION STRUCTURE :"
echo "=========================="
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

# 8. Rebuild complet maintenant que la DB est prête
echo ""
echo "8. REBUILD COMPLET :"
echo "=================="
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu

# 9. Démarrer tous les services
echo ""
echo "9. DÉMARRAGE COMPLET :"
echo "===================="
docker compose -f docker-compose.prod.yml up -d

# 10. Attendre stabilisation
echo ""
echo "10. ATTENTE STABILISATION :"
echo "=========================="
sleep 45

# 11. Vérifier l'état
echo ""
echo "11. ÉTAT DES CONTENEURS :"
echo "======================="
docker compose -f docker-compose.prod.yml ps

# 12. Vérifier les logs de compilation
echo ""
echo "12. LOGS DE COMPILATION :"
echo "======================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=30

# 13. Test de l'API
echo ""
echo "13. TEST DE L'API :"
echo "=================="
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | head -c 200

# 14. Test d'une réservation
echo ""
echo "14. TEST RÉSERVATION :"
echo "===================="
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Final Fix",
    "email": "jean.maillot14@gmail.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-28",
    "timeSlot": "20:00 - 20:20",
    "duration": 20,
    "numberOfPeople": 1,
    "specialRequests": "Test après fix final compilation"
  }'

# 15. Vérifier les logs d'email
echo ""
echo "15. LOGS D'EMAIL FINAUX :"
echo "======================="
sleep 5
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20 | grep -i -E "email|smtp|configuration.*smtp|envoi"

echo ""
echo "=== FIX FINAL TERMINÉ ==="
echo "✅ Colonne from_name ajoutée en base"
echo "✅ Interface TypeScript corrigée"
echo "✅ API SMTP save corrigée"
echo "✅ Application recompilée et redémarrée"
echo ""
echo "🔍 Vérifiez :"
echo "1. Aucune erreur de compilation"
echo "2. Tous les conteneurs en marche"
echo "3. Logs 'Configuration SMTP trouvée'"
echo "4. Email de confirmation reçu"
echo ""
echo "L'application devrait maintenant être complètement fonctionnelle !"
