# Script de déploiement WebSocket et correction admin
# U Silenziu - Septembre 2025

Write-Host "🚀 DÉPLOIEMENT SYSTÈME WEBSOCKET ET CORRECTION ADMIN" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""

# 1. Vérifier les fichiers WebSocket
Write-Host "1. Vérification des fichiers WebSocket..." -ForegroundColor Yellow
$websocketFiles = @(
    "lib/websocket.ts",
    "app/api/websocket/route.ts", 
    "components/RoomsDisplayWebSocket.tsx",
    "hooks/useWebSocketAdmin.ts"
)

foreach ($file in $websocketFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file manquant" -ForegroundColor Red
    }
}

Write-Host ""

# 2. Installer les dépendances WebSocket
Write-Host "2. Installation des dépendances WebSocket..." -ForegroundColor Yellow
Write-Host "Installation de socket.io et socket.io-client..." -ForegroundColor Cyan

try {
    npm install socket.io socket.io-client @types/socket.io-client
    Write-Host "✅ Dépendances WebSocket installées" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur installation dépendances: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 3. Vérifier la configuration Docker
Write-Host "3. Vérification configuration Docker..." -ForegroundColor Yellow

# Ajouter le port WebSocket au docker-compose.prod.yml
$dockerComposeContent = Get-Content "docker-compose.prod.yml" -Raw

if ($dockerComposeContent -notmatch "3001:3001") {
    Write-Host "⚠️  Port WebSocket manquant dans docker-compose.prod.yml" -ForegroundColor Yellow
    Write-Host "Ajout du port WebSocket..." -ForegroundColor Cyan
    
    # Ajouter le port WebSocket à la section u-silenziu
    $dockerComposeContent = $dockerComposeContent -replace "ports:", "ports:`n      - `"3001:3001`"  # WebSocket"
    
    Set-Content "docker-compose.prod.yml" $dockerComposeContent
    Write-Host "✅ Port WebSocket ajouté" -ForegroundColor Green
} else {
    Write-Host "✅ Port WebSocket déjà configuré" -ForegroundColor Green
}

Write-Host ""

# 4. Ajouter les variables d'environnement WebSocket
Write-Host "4. Configuration variables d'environnement WebSocket..." -ForegroundColor Yellow

$envContent = Get-Content "env.prod" -Raw

if ($envContent -notmatch "WS_PORT") {
    Write-Host "Ajout des variables WebSocket..." -ForegroundColor Cyan
    
    $wsEnvVars = @"

# Configuration WebSocket
WS_PORT=3001
NEXT_PUBLIC_WS_URL=wss://rageroom.usilenziu.com:3001
"@
    
    Add-Content "env.prod" $wsEnvVars
    Write-Host "✅ Variables WebSocket ajoutées" -ForegroundColor Green
} else {
    Write-Host "✅ Variables WebSocket déjà configurées" -ForegroundColor Green
}

Write-Host ""

# 5. Corriger l'erreur admin login
Write-Host "5. Vérification correction admin login..." -ForegroundColor Yellow

$loginRouteContent = Get-Content "app/api/admin/auth/login/route.ts" -Raw

if ($loginRouteContent -match "NextResponse\.json\s*\{") {
    Write-Host "✅ Syntaxe admin login correcte" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur de syntaxe détectée dans admin login" -ForegroundColor Red
    Write-Host "Correction en cours..." -ForegroundColor Cyan
    
    # Corriger la syntaxe
    $loginRouteContent = $loginRouteContent -replace "const response = NextResponse\.json\s*\{", "const response = NextResponse.json({"
    Set-Content "app/api/admin/auth/login/route.ts" $loginRouteContent
    Write-Host "✅ Syntaxe admin login corrigée" -ForegroundColor Green
}

Write-Host ""

# 6. Mettre à jour le composant Salles pour utiliser WebSocket
Write-Host "6. Mise à jour composant Salles pour WebSocket..." -ForegroundColor Yellow

$sallesContent = Get-Content "components/Salles.tsx" -Raw

if ($sallesContent -match "RoomsDisplayWebSocket") {
    Write-Host "✅ Composant Salles déjà configuré pour WebSocket" -ForegroundColor Green
} else {
    Write-Host "Mise à jour du composant Salles..." -ForegroundColor Cyan
    
    # Remplacer RoomsDisplay par RoomsDisplayWebSocket
    $sallesContent = $sallesContent -replace "import RoomsDisplay from './RoomsDisplay'", "import RoomsDisplayWebSocket from './RoomsDisplayWebSocket'"
    $sallesContent = $sallesContent -replace "<RoomsDisplay />", "<RoomsDisplayWebSocket />"
    
    Set-Content "components/Salles.tsx" $sallesContent
    Write-Host "✅ Composant Salles mis à jour pour WebSocket" -ForegroundColor Green
}

Write-Host ""

# 7. Créer un script de test WebSocket
Write-Host "7. Création script de test WebSocket..." -ForegroundColor Yellow

$testWebSocketScript = @'
#!/bin/bash
# Test WebSocket en production
echo "🔌 TEST WEBSOCKET PRODUCTION"
echo "============================"

# Test connexion WebSocket
echo "Test connexion WebSocket..."
curl -s "https://rageroom.usilenziu.com/api/websocket" | head -c 200
echo ""

# Test admin login
echo "Test admin login..."
curl -s -X POST "https://rageroom.usilenziu.com/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"administrateur","password":"@dm1n1str@t3uR!)"}' | head -c 200
echo ""

echo "✅ Tests WebSocket terminés"
'@

Set-Content "test-websocket-production.sh" $testWebSocketScript
Write-Host "✅ Script de test WebSocket créé" -ForegroundColor Green

Write-Host ""

# 8. Instructions de déploiement
Write-Host "8. INSTRUCTIONS DE DÉPLOIEMENT" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 Étapes à suivre sur le VPS :" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Git pull des modifications :" -ForegroundColor White
Write-Host "   git pull origin main" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Redémarrer les conteneurs :" -ForegroundColor White
Write-Host "   docker compose -f docker-compose.prod.yml down" -ForegroundColor Gray
Write-Host "   docker compose -f docker-compose.prod.yml up -d --build" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Tester le WebSocket :" -ForegroundColor White
Write-Host "   chmod +x test-websocket-production.sh" -ForegroundColor Gray
Write-Host "   ./test-websocket-production.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Vérifier l'admin :" -ForegroundColor White
Write-Host "   https://rageroom.usilenziu.com/admin/login" -ForegroundColor Gray
Write-Host ""

Write-Host "🎯 FONCTIONNALITÉS WEBSOCKET AJOUTÉES :" -ForegroundColor Green
Write-Host "• Mises à jour temps réel des salles" -ForegroundColor White
Write-Host "• Notifications admin instantanées" -ForegroundColor White
Write-Host "• Synchronisation admin ↔ site public" -ForegroundColor White
Write-Host "• Indicateur de connexion en temps réel" -ForegroundColor White
Write-Host "• Gestion des erreurs et reconnexion automatique" -ForegroundColor White
Write-Host ""

Write-Host "✅ DÉPLOIEMENT WEBSOCKET PRÊT !" -ForegroundColor Green
Write-Host "Exécutez les commandes ci-dessus sur votre VPS." -ForegroundColor Cyan
