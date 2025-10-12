#!/bin/bash

# Script pour corriger manuellement le statut de paiement d'une réservation
# Usage: ./fix-reservation-payment.sh <reservation_id> <payment_id> <payment_status> [payment_amount]

if [ $# -lt 3 ]; then
    echo "Usage: $0 <reservation_id> <payment_id> <payment_status> [payment_amount]"
    echo ""
    echo "Exemples:"
    echo "  $0 123e4567-e89b-12d3-a456-426614174000 pay_123456789 paid 50.00"
    echo "  $0 123e4567-e89b-12d3-a456-426614174000 pay_987654321 failed"
    echo ""
    echo "Statuts possibles: paid, failed, pending, cancelled, refunded"
    exit 1
fi

RESERVATION_ID=$1
PAYMENT_ID=$2
PAYMENT_STATUS=$3
PAYMENT_AMOUNT=$4

echo "=== CORRECTION MANUELLE DE PAIEMENT ==="
echo "Réservation ID: $RESERVATION_ID"
echo "Payment ID: $PAYMENT_ID"
echo "Status: $PAYMENT_STATUS"
echo "Montant: ${PAYMENT_AMOUNT:-N/A}"
echo ""

# Fonction pour exécuter une commande dans le conteneur PostgreSQL
run_psql() {
    docker exec -i u-silenziu-postgres psql -U postgres -d rageroom_db -c "$1"
}

echo "1. Réservation avant correction:"
echo "-------------------------------"
run_psql "SELECT id, reservation_number, customer_name, payment_status, payment_amount, amount, status FROM reservations WHERE id = '$RESERVATION_ID';"

echo ""
echo "2. Application de la correction:"
echo "------------------------------"
if [ -n "$PAYMENT_AMOUNT" ]; then
    run_psql "UPDATE reservations SET payment_id = '$PAYMENT_ID', payment_status = '$PAYMENT_STATUS', payment_amount = $PAYMENT_AMOUNT, payment_date = NOW(), updated_at = NOW() WHERE id = '$RESERVATION_ID';"
else
    run_psql "UPDATE reservations SET payment_id = '$PAYMENT_ID', payment_status = '$PAYMENT_STATUS', payment_date = NOW(), updated_at = NOW() WHERE id = '$RESERVATION_ID';"
fi

echo ""
echo "3. Réservation après correction:"
echo "------------------------------"
run_psql "SELECT id, reservation_number, customer_name, payment_status, payment_amount, amount, status FROM reservations WHERE id = '$RESERVATION_ID';"

echo ""
echo "✅ Correction terminée !"
echo "Redémarrez l'application pour voir les changements:"
echo "docker restart u-silenziu-app"
