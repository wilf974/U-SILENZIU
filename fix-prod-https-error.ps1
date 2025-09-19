#!/usr/bin/env pwsh
# Script de correction pour l'erreur HTTP 500 en production HTTPS
# U Silenziu - Septembre 2025
# Résout les problèmes de configuration Next.js et Docker Compose

Write-Host "🔧 CORRECTION ERREUR HTTP 500 PRODUCTION HTTPS" -ForegroundColor Red
Write-Host "====================================================" -ForegroundColor Red
Write-Host ""

Write-Host "📋 Problèmes identifiés et corrigés :" -ForegroundColor Cyan
Write-Host "   ❌ Next.js config: domains seulement localhost" -ForegroundColor Yellow
Write-Host "   ❌ Variables d'environnement manquantes" -ForegroundColor Yellow
Write-Host "   ❌ Configuration HTTPS incohérente" -ForegroundColor Yellow
Write-Host ""

Write-Host "✅ Solutions appliquées :" -ForegroundColor Green
Write-Host "   • next.config.js: Ajout domaines production" -ForegroundColor White
Write-Host "   • docker-compose.prod.yml: Variables HTTPS complètes" -ForegroundColor White
Write-Host "   • Headers de sécurité ajoutés" -ForegroundColor White
Write-Host ""

Write-Host "🚀 DÉPLOIEMENT SUR LE VPS :" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Connectez-vous à votre VPS :" -ForegroundColor Yellow
Write-Host "   ssh root@votre-vps-ip" -ForegroundColor White
Write-Host ""
Write-Host "2. Allez dans le répertoire du projet :" -ForegroundColor Yellow
Write-Host "   cd /root/U-SILENZIU" -ForegroundColor White
Write-Host ""
Write-Host "3. Récupérez les dernières modifications :" -ForegroundColor Yellow
Write-Host "   git pull origin main" -ForegroundColor White
Write-Host ""
Write-Host "4. Reconstruisez et redémarrez :" -ForegroundColor Yellow
Write-Host "   docker compose -f docker-compose.prod.yml down" -ForegroundColor White
Write-Host "   docker compose -f docker-compose.prod.yml up -d --build" -ForegroundColor White
Write-Host ""
Write-Host "5. Vérifiez les logs :" -ForegroundColor Yellow
Write-Host "   docker compose -f docker-compose.prod.yml logs -f u-silenziu" -ForegroundColor White
Write-Host ""

Write-Host "⚠️  VÉRIFICATIONS IMPORTANTES :" -ForegroundColor Red
Write-Host ""
Write-Host "1. Certificat SSL :" -ForegroundColor Yellow
Write-Host "   • Vérifiez que le certificat Let's Encrypt est valide" -ForegroundColor White
Write-Host "   • Domaine rageroom.usilenziu.com doit pointer vers votre VPS" -ForegroundColor White
Write-Host ""
Write-Host "2. Configuration Nginx :" -ForegroundColor Yellow
Write-Host "   • Proxy vers u-silenziu:3000 configuré" -ForegroundColor White
Write-Host "   • Headers HTTPS correctement transmis" -ForegroundColor White
Write-Host ""
Write-Host "3. Variables d'environnement :" -ForegroundColor Yellow
Write-Host "   • NEXT_PUBLIC_APP_URL=https://rageroom.usilenziu.com" -ForegroundColor White
Write-Host "   • Tous les secrets de production changés" -ForegroundColor White
Write-Host ""

Write-Host "🔍 DIAGNOSTIC EN CAS DE PROBLÈME :" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Logs de l'application :" -ForegroundColor Yellow
Write-Host "   docker logs u-silenziu-app" -ForegroundColor White
Write-Host ""
Write-Host "2. Logs Nginx :" -ForegroundColor Yellow
Write-Host "   docker logs u-silenziu-nginx-prod" -ForegroundColor White
Write-Host ""
Write-Host "3. Logs base de données :" -ForegroundColor Yellow
Write-Host "   docker logs u-silenziu-postgres" -ForegroundColor White
Write-Host ""
Write-Host "4. Test de connectivité :" -ForegroundColor Yellow
Write-Host "   curl -I https://rageroom.usilenziu.com" -ForegroundColor White
Write-Host ""

Write-Host "📁 Fichiers modifiés :" -ForegroundColor Green
Write-Host "   ✅ next.config.js" -ForegroundColor White
Write-Host "   ✅ docker-compose.prod.yml" -ForegroundColor White
Write-Host ""

Write-Host "🌐 Après le déploiement :" -ForegroundColor Cyan
Write-Host "   • Site accessible : https://rageroom.usilenziu.com" -ForegroundColor White
Write-Host "   • Admin : https://rageroom.usilenziu.com/admin" -ForegroundColor White
Write-Host "   • API : https://rageroom.usilenziu.com/api" -ForegroundColor White
Write-Host ""

Write-Host "✅ CORRECTIONS PRÊTES POUR LE DÉPLOIEMENT !" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Conseil : Gardez ce fichier ouvert pendant le déploiement pour référence" -ForegroundColor Yellow
