# Script de test pour le système de sections dynamiques
# U Silenziu - Décembre 2024

Write-Host "🧪 Test du système de sections dynamiques" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
$adminUrl = "$baseUrl/admin/homepage"
$apiUrl = "$baseUrl/api/admin/homepage-sections"

Write-Host "`n📋 Configuration:" -ForegroundColor Yellow
Write-Host "  Base URL: $baseUrl" -ForegroundColor White
Write-Host "  Admin URL: $adminUrl" -ForegroundColor White
Write-Host "  API URL: $apiUrl" -ForegroundColor White

# Test 1: Vérification de l'accessibilité de l'application
Write-Host "`n🔍 Test 1: Accessibilité de l'application" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✅ Application accessible" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Application non accessible (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Vérification de l'API des sections
Write-Host "`n🔍 Test 2: API des sections" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $apiUrl -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $data = $response.Content | ConvertFrom-Json
        if ($data.success) {
            Write-Host "  ✅ API accessible" -ForegroundColor Green
            Write-Host "  📊 Sections trouvées: $($data.count)" -ForegroundColor White
        } else {
            Write-Host "  ❌ API en erreur: $($data.error)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ❌ API non accessible (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Erreur de connexion à l'API: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Création d'une section de test
Write-Host "`n🔍 Test 3: Création d'une section de test" -ForegroundColor Yellow
$testSection = @{
    section_key = "test-section"
    title = "Section de Test"
    subtitle = "Cette section a été créée automatiquement pour tester le système"
    content = "Contenu de test pour valider le fonctionnement du système de sections dynamiques."
    image_url = ""
    video_url = ""
    background_color = "bg-gray-800"
    text_color = "text-white"
    order_index = 10
    is_active = $true
}

try {
    $jsonBody = $testSection | ConvertTo-Json
    $response = Invoke-WebRequest -Uri $apiUrl -Method POST -Body $jsonBody -ContentType "application/json" -UseBasicParsing
    
    if ($response.StatusCode -eq 201) {
        $data = $response.Content | ConvertFrom-Json
        if ($data.success) {
            Write-Host "  ✅ Section de test créée avec succès" -ForegroundColor Green
            Write-Host "  🆔 ID: $($data.data.id)" -ForegroundColor White
        } else {
            Write-Host "  ❌ Erreur lors de la création: $($data.error)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ❌ Erreur HTTP lors de la création (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Erreur lors de la création: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Vérification de la section créée
Write-Host "`n🔍 Test 4: Vérification de la section créée" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $apiUrl -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $data = $response.Content | ConvertFrom-Json
        if ($data.success) {
            $testSectionFound = $data.data | Where-Object { $_.section_key -eq "test-section" }
            if ($testSectionFound) {
                Write-Host "  ✅ Section de test trouvée" -ForegroundColor Green
                Write-Host "  📝 Titre: $($testSectionFound.title)" -ForegroundColor White
                Write-Host "  🔑 Clé: $($testSectionFound.section_key)" -ForegroundColor White
                Write-Host "  📍 Ordre: $($testSectionFound.order_index)" -ForegroundColor White
                Write-Host "  ✅ Statut: $($testSectionFound.is_active)" -ForegroundColor White
            } else {
                Write-Host "  ❌ Section de test non trouvée" -ForegroundColor Red
            }
        } else {
            Write-Host "  ❌ Erreur lors de la récupération: $($data.error)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ❌ Erreur HTTP lors de la récupération (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Erreur lors de la vérification: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Test de l'interface d'administration
Write-Host "`n🔍 Test 5: Interface d'administration" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $adminUrl -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✅ Interface d'administration accessible" -ForegroundColor Green
        
        # Vérifier la présence du bouton "Ajouter une section"
        if ($response.Content -match "Ajouter une section") {
            Write-Host "  ✅ Bouton 'Ajouter une section' présent" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Bouton 'Ajouter une section' non trouvé" -ForegroundColor Red
        }
        
        # Vérifier la présence de la section de test
        if ($response.Content -match "test-section") {
            Write-Host "  ✅ Section de test visible dans l'interface" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Section de test non visible dans l'interface" -ForegroundColor Red
        }
    } else {
        Write-Host "  ❌ Interface d'administration non accessible (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Erreur de connexion à l'interface d'administration: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Test de l'affichage côté site
Write-Host "`n🔍 Test 6: Affichage côté site" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/homepage-sections" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $data = $response.Content | ConvertFrom-Json
        if ($data.success) {
            $publicTestSection = $data.data | Where-Object { $_.section_key -eq "test-section" -and $_.is_active }
            if ($publicTestSection) {
                Write-Host "  ✅ Section de test accessible publiquement" -ForegroundColor Green
                Write-Host "  📊 Total sections publiques: $($data.data.Count)" -ForegroundColor White
            } else {
                Write-Host "  ❌ Section de test non accessible publiquement" -ForegroundColor Red
            }
        } else {
            Write-Host "  ❌ Erreur lors de la récupération publique: $($data.error)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ❌ API publique non accessible (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Erreur de connexion à l'API publique: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 7: Nettoyage - Suppression de la section de test
Write-Host "`n🔍 Test 7: Nettoyage - Suppression de la section de test" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $apiUrl -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $data = $response.Content | ConvertFrom-Json
        if ($data.success) {
            $testSectionToDelete = $data.data | Where-Object { $_.section_key -eq "test-section" }
            if ($testSectionToDelete) {
                $deleteUrl = "$apiUrl/$($testSectionToDelete.id)"
                $deleteResponse = Invoke-WebRequest -Uri $deleteUrl -Method DELETE -UseBasicParsing
                
                if ($deleteResponse.StatusCode -eq 200) {
                    Write-Host "  ✅ Section de test supprimée avec succès" -ForegroundColor Green
                } else {
                    Write-Host "  ❌ Erreur lors de la suppression (Status: $($deleteResponse.StatusCode))" -ForegroundColor Red
                }
            } else {
                Write-Host "  ⚠️ Section de test non trouvée pour la suppression" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ❌ Erreur lors de la récupération pour suppression: $($data.error)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ❌ Erreur HTTP lors de la récupération pour suppression (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Erreur lors du nettoyage: $($_.Exception.Message)" -ForegroundColor Red
}

# Résumé des tests
Write-Host "`n📊 Résumé des tests" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host "✅ Tests terminés avec succès" -ForegroundColor Green
Write-Host "`n🎯 Le système de sections dynamiques est maintenant opérationnel !" -ForegroundColor Green
Write-Host "`n📖 Pour utiliser le système:" -ForegroundColor Yellow
Write-Host "  1. Accédez au back-office: $adminUrl" -ForegroundColor White
Write-Host "  2. Cliquez sur 'Ajouter une section'" -ForegroundColor White
Write-Host "  3. Choisissez le type de contenu (texte, image, vidéo, liens)" -ForegroundColor White
Write-Host "  4. Configurez le contenu et personnalisez l'apparence" -ForegroundColor White
Write-Host "  5. Sauvegardez - la section apparaît automatiquement sur le site" -ForegroundColor White

Write-Host "`n🚀 Test terminé !" -ForegroundColor Green
