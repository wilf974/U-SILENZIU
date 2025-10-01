#!/bin/bash

# Script de correction urgente pour les erreurs de réservation sur VPS
# U Silenziu - Janvier 2025

echo "🚨 CORRECTION URGENTE ERREUR RÉSERVATION VPS"
echo "============================================"
echo ""

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages colorés
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}📋 $1${NC}"
}

print_step() {
    echo -e "${WHITE}   $1${NC}"
}

print_warning "CORRECTION URGENTE DES ERREURS DE RÉSERVATION"
echo "=================================================="
echo ""

# Étape 1: Arrêter les services
print_info "1️⃣ Arrêt des services..."
echo ""

docker-compose -f docker-compose.prod.yml down

print_status "Services arrêtés"

echo ""

# Étape 2: Vérifier et corriger la base de données
print_info "2️⃣ Vérification de la base de données..."
echo ""

# Démarrer seulement PostgreSQL pour les vérifications
docker-compose -f docker-compose.prod.yml up -d postgres

# Attendre que PostgreSQL soit prêt
sleep 10

# Vérifier la structure de la table reservations
print_step "Vérification de la structure de la table reservations..."

docker-compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenziu -c "\d reservations" 2>/dev/null

echo ""

# Étape 3: Corriger la structure si nécessaire
print_info "3️⃣ Correction de la structure de la base de données..."
echo ""

# Script SQL pour corriger la structure
cat > fix_reservations_table.sql << 'EOF'
-- Correction de la structure de la table reservations
-- U Silenziu - Janvier 2025

-- Vérifier si la table existe
DO $$
BEGIN
    -- Créer la table si elle n'existe pas
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'reservations') THEN
        CREATE TABLE reservations (
            id SERIAL PRIMARY KEY,
            reservation_number VARCHAR(20) UNIQUE NOT NULL,
            room_id INTEGER NOT NULL,
            date DATE NOT NULL,
            time_slot VARCHAR(20) NOT NULL,
            number_of_people INTEGER NOT NULL,
            first_name VARCHAR(100) NOT NULL,
            last_name VARCHAR(100) NOT NULL,
            email VARCHAR(255) NOT NULL,
            phone VARCHAR(20) NOT NULL,
            notes TEXT,
            status VARCHAR(20) DEFAULT 'pending',
            payment_status VARCHAR(20) DEFAULT 'pending',
            payment_id VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        -- Créer les index
        CREATE INDEX idx_reservations_date ON reservations(date);
        CREATE INDEX idx_reservations_room_id ON reservations(room_id);
        CREATE INDEX idx_reservations_email ON reservations(email);
        CREATE INDEX idx_reservations_status ON reservations(status);
        
        RAISE NOTICE 'Table reservations créée avec succès';
    ELSE
        RAISE NOTICE 'Table reservations existe déjà';
    END IF;
    
    -- Vérifier et ajouter les colonnes manquantes
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'reservations' AND column_name = 'first_name') THEN
        ALTER TABLE reservations ADD COLUMN first_name VARCHAR(100);
        RAISE NOTICE 'Colonne first_name ajoutée';
    END IF;
    
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'reservations' AND column_name = 'last_name') THEN
        ALTER TABLE reservations ADD COLUMN last_name VARCHAR(100);
        RAISE NOTICE 'Colonne last_name ajoutée';
    END IF;
    
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'reservations' AND column_name = 'email') THEN
        ALTER TABLE reservations ADD COLUMN email VARCHAR(255);
        RAISE NOTICE 'Colonne email ajoutée';
    END IF;
    
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'reservations' AND column_name = 'phone') THEN
        ALTER TABLE reservations ADD COLUMN phone VARCHAR(20);
        RAISE NOTICE 'Colonne phone ajoutée';
    END IF;
    
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'reservations' AND column_name = 'time_slot') THEN
        ALTER TABLE reservations ADD COLUMN time_slot VARCHAR(20);
        RAISE NOTICE 'Colonne time_slot ajoutée';
    END IF;
    
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'reservations' AND column_name = 'number_of_people') THEN
        ALTER TABLE reservations ADD COLUMN number_of_people INTEGER;
        RAISE NOTICE 'Colonne number_of_people ajoutée';
    END IF;
    
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'reservations' AND column_name = 'notes') THEN
        ALTER TABLE reservations ADD COLUMN notes TEXT;
        RAISE NOTICE 'Colonne notes ajoutée';
    END IF;
    
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'reservations' AND column_name = 'payment_status') THEN
        ALTER TABLE reservations ADD COLUMN payment_status VARCHAR(20) DEFAULT 'pending';
        RAISE NOTICE 'Colonne payment_status ajoutée';
    END IF;
    
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'reservations' AND column_name = 'payment_id') THEN
        ALTER TABLE reservations ADD COLUMN payment_id VARCHAR(255);
        RAISE NOTICE 'Colonne payment_id ajoutée';
    END IF;
    
END $$;
EOF

# Exécuter le script de correction
docker-compose -f docker-compose.prod.yml exec -T postgres psql -U usilenzio_user -d usilenziu < fix_reservations_table.sql

print_status "Structure de la base de données vérifiée et corrigée"

echo ""

# Étape 4: Vérifier les variables d'environnement
print_info "4️⃣ Vérification des variables d'environnement..."
echo ""

# Vérifier que les variables essentielles sont présentes
if grep -q "DATABASE_URL" env.prod; then
    print_status "DATABASE_URL configurée"
else
    print_error "DATABASE_URL manquante dans env.prod"
fi

if grep -q "POSTGRES_HOST" env.prod; then
    print_status "POSTGRES_HOST configuré"
else
    print_error "POSTGRES_HOST manquant dans env.prod"
fi

echo ""

# Étape 5: Redémarrer tous les services
print_info "5️⃣ Redémarrage des services..."
echo ""

docker-compose -f docker-compose.prod.yml up -d --build

print_status "Services redémarrés"

echo ""

# Étape 6: Attendre que les services soient prêts
print_info "6️⃣ Attente du démarrage des services..."
echo ""

sleep 30

# Vérifier que les services sont démarrés
print_step "Vérification de l'état des services..."

docker-compose -f docker-compose.prod.yml ps

echo ""

# Étape 7: Test de l'API de réservation
print_info "7️⃣ Test de l'API de réservation..."
echo ""

# Test simple de l'API
test_data='{
    "room_id": 2,
    "date": "2025-01-15",
    "time_slot": "14:00-16:00",
    "number_of_people": 2,
    "first_name": "Test",
    "last_name": "Correction",
    "email": "test@correction.com",
    "phone": "0123456789",
    "notes": "Test après correction"
}'

response=$(curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
    -H "Content-Type: application/json" \
    -d "$test_data" \
    -w "HTTP_CODE:%{http_code}")

http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
response_body=$(echo "$response" | sed 's/HTTP_CODE:[0-9]*$//')

echo "Code de réponse HTTP: $http_code"

if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
    print_status "API de réservation fonctionnelle après correction !"
    echo "Réponse: $response_body"
else
    print_error "Problème persistant avec l'API de réservation (HTTP $http_code)"
    echo "Réponse: $response_body"
fi

echo ""

# Nettoyage
rm -f fix_reservations_table.sql

print_warning "CORRECTION TERMINÉE"
echo "==================="
echo ""
print_info "Actions effectuées:"
print_step "1. Arrêt des services"
print_step "2. Vérification de la base de données"
print_step "3. Correction de la structure de la table reservations"
print_step "4. Vérification des variables d'environnement"
print_step "5. Redémarrage des services"
print_step "6. Test de l'API de réservation"
echo ""
print_info "Prochaines étapes:"
print_step "1. Tester une réservation via l'interface web"
print_step "2. Vérifier les logs si des erreurs persistent"
print_step "3. Contacter le support si nécessaire"
echo ""
print_status "Correction urgente terminée ! 🚀"
