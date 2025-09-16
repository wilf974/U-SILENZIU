#!/usr/bin/env pwsh

# Script de test pour valider que le bandeau en haut de la page affiche les bonnes informations
# depuis la base de données via l'API de configuration du pied de page

Write-Host "🧪 Test du Bandeau Dynamique - U Silenziu" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$baseUrl = "http://localhost:3000"
$apiUrl = "$baseUrl/api/footer-config"

# Fonction pour tester une URL
function Test-Url {
    param($url, $description)
    
    try {
        Write-Host "🔍 Test: $description" -ForegroundColor Yellow
        Write-Host "   URL: $url" -ForegroundColor Gray
        
        $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ Succès (Status: $($response.StatusCode))" -ForegroundColor Green
            return $true
        } else {
            Write-Host "   ❌ Échec (Status: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "   ❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Fonction pour tester l'API de configuration
function Test-ConfigAPI {
    try {
        Write-Host "🔍 Test de l'API de configuration du pied de page" -ForegroundColor Yellow
        Write-Host "   URL: $apiUrl" -ForegroundColor Gray
        
        $response = Invoke-WebRequest -Uri $apiUrl -Method GET -UseBasicParsing -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            $data = $response.Content | ConvertFrom-Json
            
            if ($data.success -and $data.data) {
                Write-Host "   ✅ API fonctionnelle" -ForegroundColor Green
                Write-Host "   📞 Téléphone: $($data.data.contact_phone)" -ForegroundColor Cyan
                Write-Host "   📧 Email: $($data.data.contact_email)" -ForegroundColor Cyan
                Write-Host "   📍 Adresse: $($data.data.contact_address)" -ForegroundColor Cyan
                return $true
            } else {
                Write-Host "   ❌ Réponse API invalide" -ForegroundColor Red
                return $false
            }
        } else {
            Write-Host "   ❌ Échec API (Status: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "   ❌ Erreur API: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Fonction pour vérifier le contenu du bandeau
function Test-BandeauContent {
    try {
        Write-Host "🔍 Test du contenu du bandeau sur la page d'accueil" -ForegroundColor Yellow
        
        $response = Invoke-WebRequest -Uri $baseUrl -Method GET -UseBasicParsing -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            $content = $response.Content
            
            # Vérifier la présence des éléments du bandeau
            $checks = @(
                @{ Pattern = "bg-kaki-600"; Description = "Couleur de fond du bandeau" },
                @{ Pattern = "Phone.*size.*12"; Description = "Icône téléphone" },
                @{ Pattern = "Mail.*size.*12"; Description = "Icône email" },
                @{ Pattern = "Clock.*size.*10"; Description = "Icône horloge" },
                @{ Pattern = "\+33.*7.*83.*83.*64.*53"; Description = "Numéro de téléphone" },
                @{ Pattern = "info@usilenziu\.com"; Description = "Adresse email" },
                @{ Pattern = "Mardi-Jeudi.*14h-21h"; Description = "Horaires d'ouverture" }
            )
            
            $allPassed = $true
            foreach ($check in $checks) {
                if ($content -match $check.Pattern) {
                    Write-Host "   ✅ $($check.Description)" -ForegroundColor Green
                } else {
                    Write-Host "   ❌ $($check.Description) - Non trouvé" -ForegroundColor Red
                    $allPassed = $false
                }
            }
            
            return $allPassed
        } else {
            Write-Host "   ❌ Impossible d'accéder à la page d'accueil" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "   ❌ Erreur lors de la vérification du bandeau: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Exécution des tests
Write-Host "🚀 Démarrage des tests..." -ForegroundColor Green
Write-Host ""

$tests = @(
    @{ Name = "Page d'accueil"; Function = { Test-Url $baseUrl "Accès à la page d'accueil" } },
    @{ Name = "API de configuration"; Function = { Test-ConfigAPI } },
    @{ Name = "Contenu du bandeau"; Function = { Test-BandeauContent } }
)

$results = @()
foreach ($test in $tests) {
    Write-Host "🧪 Test: $($test.Name)" -ForegroundColor Magenta
    $result = & $test.Function
    $results += @{ Name = $test.Name; Success = $result }
    Write-Host ""
}

# Résumé des résultats
Write-Host "📊 Résumé des tests" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

$successCount = 0
foreach ($result in $results) {
    $status = if ($result.Success) { "✅ SUCCÈS" } else { "❌ ÉCHEC" }
    $color = if ($result.Success) { "Green" } else { "Red" }
    Write-Host "$status - $($result.Name)" -ForegroundColor $color
    if ($result.Success) { $successCount++ }
}

Write-Host ""
Write-Host "🎯 Résultat global: $successCount/$($results.Count) tests réussis" -ForegroundColor $(if ($successCount -eq $results.Count) { "Green" } else { "Yellow" })

if ($successCount -eq $results.Count) {
    Write-Host ""
    Write-Host "🎉 Tous les tests sont passés ! Le bandeau utilise maintenant les informations dynamiques." -ForegroundColor Green
    Write-Host "💡 Les informations de contact dans le bandeau sont maintenant synchronisées avec la base de données." -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "⚠️ Certains tests ont échoué. Vérifiez les erreurs ci-dessus." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔧 Pour modifier les informations du bandeau:" -ForegroundColor Cyan
Write-Host "   1. Accédez à l'interface d'administration: $baseUrl/admin" -ForegroundColor Gray
Write-Host "   2. Allez dans Gestion de la Page d'Accueil" -ForegroundColor Gray
Write-Host "   3. Modifiez la Configuration du Pied de Page" -ForegroundColor Gray
Write-Host "   4. Les changements seront automatiquement visibles dans le bandeau" -ForegroundColor Gray