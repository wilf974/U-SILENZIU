#!/bin/bash

echo "=== DIAGNOSTIC ET CORRECTION DES PAIEMENTS ==="
echo ""

# Fonction pour exécuter une commande dans le conteneur PostgreSQL
run_psql() {
    docker exec -i u-silenziu-postgres psql -U postgres -d rageroom_db -c "$1"
}

echo "1. Vérification de la structure de la table reservations:"
echo "---------------------------------------------------------"
run_psql "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = 'reservations' ORDER BY ordinal_position;"

echo ""
echo "2. Réservations avec paiements problématiques:"
echo "---------------------------------------------"
run_psql "SELECT id, reservation_number, customer_name, payment_status, payment_amount, amount, status FROM reservations WHERE payment_status IS NOT NULL ORDER BY updated_at DESC LIMIT 10;"

echo ""
echo "3. Réservations avec valeurs NULL problématiques:"
echo "------------------------------------------------"
run_psql "SELECT COUNT(*) as total_null_amount FROM reservations WHERE amount IS NULL;"
run_psql "SELECT COUNT(*) as total_null_payment_amount FROM reservations WHERE payment_amount IS NULL;"
run_psql "SELECT COUNT(*) as total_null_payment_status FROM reservations WHERE payment_status IS NULL;"

echo ""
echo "4. Correction des valeurs NULL problématiques:"
echo "---------------------------------------------"
# Mettre les valeurs par défaut pour les réservations sans montant
run_psql "UPDATE reservations SET amount = 0 WHERE amount IS NULL;"
run_psql "UPDATE reservations SET payment_amount = 0 WHERE payment_amount IS NULL;"
run_psql "UPDATE reservations SET payment_status = 'pending' WHERE payment_status IS NULL;"

echo ""
echo "5. Réservations après correction:"
echo "--------------------------------"
run_psql "SELECT id, reservation_number, customer_name, payment_status, payment_amount, amount, status FROM reservations WHERE payment_status IS NOT NULL ORDER BY updated_at DESC LIMIT 5;"

echo ""
echo "6. Vérification des statistiques de revenus:"
echo "-------------------------------------------"
run_psql "SELECT
    COUNT(*) as total_confirmed,
    COALESCE(SUM(payment_amount), 0) as total_payment_amount,
    COALESCE(SUM(amount), 0) as total_amount
FROM reservations WHERE status = 'confirmed';"

echo ""
echo "7. Logs récents de l'application:"
echo "--------------------------------"
docker logs u-silenziu-app --tail=20 | grep -E "(error|Error|ERROR|payment|réservation|reservation|NaN|undefined|null)"

echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
echo ""
echo "✅ Corrections appliquées :"
echo "   - amount NULL → 0"
echo "   - payment_amount NULL → 0"
echo "   - payment_status NULL → 'pending'"
echo ""
echo "🔄 Redémarrage de l'application recommandé :"
echo "   docker restart u-silenziu-app"
