#!/bin/bash

echo "=== DIAGNOSTIC EMAIL DE CONFIRMATION ==="
echo ""

# 1. Vérifier la configuration SMTP dans la base
echo "1. CONFIGURATION SMTP DANS LA BASE :"
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
    CASE 
        WHEN password_encrypted IS NOT NULL THEN 'CONFIGURED'
        ELSE 'NOT CONFIGURED'
    END as password_status,
    tls_reject_unauthorized,
    tls_min_version,
    is_active,
    created_at,
    updated_at
FROM smtp_config 
ORDER BY created_at DESC 
LIMIT 1;
"

# 2. Vérifier les variables d'environnement
echo ""
echo "2. VARIABLES D'ENVIRONNEMENT :"
echo "============================="
docker exec u-silenziu-app env | grep -E "SMTP|EMAIL" || echo "Aucune variable SMTP trouvée"

# 3. Vérifier les logs d'envoi d'email
echo ""
echo "3. LOGS D'ENVOI D'EMAIL (dernières tentatives) :"
echo "==============================================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=100 | grep -i -E "email|smtp|mail|confirmation|nodemailer" || echo "Aucun log d'email trouvé"

# 4. Tester la connexion SMTP directement
echo ""
echo "4. TEST DE CONNEXION SMTP :"
echo "=========================="
docker exec u-silenziu-app node -e "
const nodemailer = require('nodemailer');

async function testSMTP() {
  try {
    // Récupérer la config depuis la base
    const { Pool } = require('pg');
    const pool = new Pool({
      host: process.env.POSTGRES_HOST || 'postgres',
      port: process.env.POSTGRES_PORT || 5432,
      database: process.env.POSTGRES_DB || 'usilenzio',
      user: process.env.POSTGRES_USER || 'usilenzio_user',
      password: process.env.POSTGRES_PASSWORD || 'usilenzio_secure_2025',
    });

    const client = await pool.connect();
    const result = await client.query('SELECT * FROM smtp_config WHERE is_active = true ORDER BY created_at DESC LIMIT 1');
    client.release();

    if (result.rows.length === 0) {
      console.log('❌ ERREUR: Aucune configuration SMTP active trouvée');
      return;
    }

    const config = result.rows[0];
    console.log('📧 Configuration SMTP trouvée:', {
      host: config.host,
      port: config.port,
      secure: config.secure,
      username: config.username,
      from_email: config.from_email
    });

    // Créer le transporteur
    const transporter = nodemailer.createTransporter({
      host: config.host,
      port: config.port,
      secure: config.secure,
      auth: {
        user: config.username,
        pass: config.password_encrypted, // Note: devrait être décrypté
      },
      tls: {
        rejectUnauthorized: config.tls_reject_unauthorized,
        minVersion: config.tls_min_version,
      },
    });

    // Vérifier la connexion
    await transporter.verify();
    console.log('✅ SMTP: Connexion réussie');

    // Test d'envoi simple
    const testEmail = {
      from: config.from_email,
      to: 'jean.maillot14@gmail.com',
      subject: 'Test SMTP - U Silenziu',
      text: 'Test de connexion SMTP réussi !',
    };

    const info = await transporter.sendMail(testEmail);
    console.log('✅ EMAIL: Envoi réussi', info.messageId);

  } catch (error) {
    console.log('❌ ERREUR SMTP:', error.message);
    console.log('Stack:', error.stack);
  }
}

testSMTP();
"

# 5. Vérifier si la fonction sendReservationConfirmationEmail est appelée
echo ""
echo "5. VÉRIFICATION DU CODE D'ENVOI D'EMAIL :"
echo "========================================"
echo "Recherche dans les logs de la dernière réservation..."
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=200 | grep -A 10 -B 10 "250920001" || echo "Pas de logs pour cette réservation"

# 6. Créer une nouvelle réservation pour tester l'email
echo ""
echo "6. CRÉATION D'UNE NOUVELLE RÉSERVATION POUR TESTER :"
echo "==================================================="
echo "Test avec votre email: jean.maillot14@gmail.com"

curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Email",
    "email": "jean.maillot14@gmail.com",
    "phone": "0612345678",
    "roomName": "Salle 1",
    "date": "2025-09-21",
    "timeSlot": "16:00 - 16:20",
    "duration": 20,
    "numberOfPeople": 1,
    "specialRequests": "Test envoi email"
  }' | jq '.'

# 7. Vérifier les logs immédiatement après
echo ""
echo "7. LOGS IMMÉDIATEMENT APRÈS LA RÉSERVATION :"
echo "==========================================="
sleep 5
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50 | grep -i -E "email|smtp|mail|confirmation|test.*email" || echo "Pas de logs d'email"

echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
echo ""
echo "Vérifiez :"
echo "1. Configuration SMTP en base"
echo "2. Variables d'environnement"
echo "3. Logs d'erreur SMTP"
echo "4. Test de connexion directe"
echo "5. Réception de l'email de test"
