#!/usr/bin/env pwsh

Write-Host "Test du Bandeau Dynamique - U Silenziu" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:3000"
$apiUrl = "$baseUrl/api/footer-config"

# Test 1: Accès à la page d'accueil
Write-Host "Test 1: Accès à la page d'accueil" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Page d'accueil accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Page d'accueil non accessible" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: API de configuration
Write-Host "Test 2: API de configuration" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $apiUrl -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        $data = $response.Content | ConvertFrom-Json
        if ($data.success -and $data.data) {
            Write-Host "✅ API fonctionnelle" -ForegroundColor Green
            Write-Host "📞 Téléphone: $($data.data.contact_phone)" -ForegroundColor Cyan
            Write-Host "📧 Email: $($data.data.contact_email)" -ForegroundColor Cyan
        } else {
            Write-Host "❌ Réponse API invalide" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ API non accessible" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur API: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Vérification du contenu du bandeau
Write-Host "Test 3: Contenu du bandeau" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        $content = $response.Content
        
        if ($content -match "bg-kaki-600") {
            Write-Host "✅ Couleur de fond du bandeau" -ForegroundColor Green
        } else {
            Write-Host "❌ Couleur de fond du bandeau manquante" -ForegroundColor Red
        }
        
        if ($content -match "\+33.*7.*83.*83.*64.*53") {
            Write-Host "✅ Numéro de téléphone présent" -ForegroundColor Green
        } else {
            Write-Host "❌ Numéro de téléphone manquant" -ForegroundColor Red
        }
        
        if ($content -match "info@usilenziu\.com") {
            Write-Host "✅ Adresse email présente" -ForegroundColor Green
        } else {
            Write-Host "❌ Adresse email manquante" -ForegroundColor Red
        }
        
        if ($content -match "Mardi-Jeudi.*14h-21h") {
            Write-Host "✅ Horaires d'ouverture présents" -ForegroundColor Green
        } else {
            Write-Host "❌ Horaires d'ouverture manquants" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test terminé !" -ForegroundColor Cyan
