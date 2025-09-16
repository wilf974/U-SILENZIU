# Script de test pour la gestion du pied de page
# Teste les API routes et l'interface d'administration du pied de page

Write-Host "🧪 Test de la gestion du pied de page U Silenziu" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
$adminUrl = "$baseUrl/admin"
$apiUrl = "$baseUrl/api"

# Fonction pour tester une URL
function Test-Url {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Body = $null,
        [string]$Description = ""
    )
    
    Write-Host "`n📡 Test: $Description" -ForegroundColor Yellow
    Write-Host "   URL: $Url" -ForegroundColor Gray
    Write-Host "   Méthode: $Method" -ForegroundColor Gray
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10
            Write-Host "   Body: $jsonBody" -ForegroundColor Gray
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers -Body $jsonBody
        } else {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers
        }
        
        Write-Host "   ✅ Succès" -ForegroundColor Green
        if ($response) {
            Write-Host "   Réponse: $($response | ConvertTo-Json -Compress)" -ForegroundColor Gray
        }
        return $response
    }
    catch {
        Write-Host "   ❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Fonction pour tester l'interface web
function Test-WebInterface {
    param(
        [string]$Url,
        [string]$Description = ""
    )
    
    Write-Host "`n🌐 Test Interface: $Description" -ForegroundColor Yellow
    Write-Host "   URL: $Url" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ Page accessible" -ForegroundColor Green
            Write-Host "   Taille: $($response.Content.Length) caractères" -ForegroundColor Gray
            return $true
        } else {
            Write-Host "   ❌ Code de statut: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "   ❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Tests des API routes
Write-Host "`n🔧 Tests des API Routes" -ForegroundColor Magenta
Write-Host "========================" -ForegroundColor Magenta

# Test 1: Récupération de la configuration du pied de page (API publique)
$footerConfig = Test-Url -Url "$apiUrl/footer-config" -Description "Récupération de la configuration du pied de page (API publique)"

# Test 2: Récupération de la configuration du pied de page (API admin)
$adminFooterConfig = Test-Url -Url "$apiUrl/admin/footer-config" -Description "Récupération de la configuration du pied de page (API admin)"

# Test 3: Mise à jour de la configuration du pied de page
$updateData = @{
    site_name = "U SILENZIU - Test"
    site_description = "Description de test pour le pied de page"
    site_slogan = "Test slogan"
    contact_phone = "+33 1 23 45 67 89"
    contact_email = "test@usilenziu.com"
    contact_address = "Adresse de test, 12345 Test"
    opening_hours_tuesday = "09:00 – 18:00"
    opening_hours_wednesday = "09:00 – 18:00"
    opening_hours_thursday = "09:00 – 18:00"
    opening_hours_friday = "09:00 – 20:00"
    opening_hours_saturday = "09:00 – 20:00"
    opening_hours_sunday = "Fermé"
    cta_title = "Testez notre service"
    cta_button_text = "Tester maintenant"
    cta_button_url = "/test"
    legal_links = @(
        @{ label = "CGV Test"; url = "/cgv-test" },
        @{ label = "Politique Test"; url = "/politique-test" }
    )
    copyright_text = "© 2024 Test U Silenziu. Tous droits réservés."
}

$updatedConfig = Test-Url -Url "$apiUrl/admin/footer-config" -Method "PUT" -Body $updateData -Description "Mise à jour de la configuration du pied de page"

# Test 4: Vérification de la mise à jour
$verifyConfig = Test-Url -Url "$apiUrl/footer-config" -Description "Vérification de la mise à jour de la configuration"

# Tests des interfaces web
Write-Host "`n🌐 Tests des Interfaces Web" -ForegroundColor Magenta
Write-Host "============================" -ForegroundColor Magenta

# Test 5: Page d'administration de la page d'accueil
Test-WebInterface -Url "$adminUrl/homepage" -Description "Page d'administration de la page d'accueil"

# Test 6: Page principale du site
Test-WebInterface -Url "$baseUrl" -Description "Page principale du site"

# Test 7: Vérification de la présence du pied de page
Write-Host "`n🔍 Vérification du pied de page sur le site" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl" -UseBasicParsing
    $content = $response.Content
    
    # Vérifier la présence d'éléments du pied de page
    $footerElements = @(
        "U SILENZIU",
        "Contact",
        "Horaires",
        "Réserver maintenant"
    )
    
    foreach ($element in $footerElements) {
        if ($content -match $element) {
            Write-Host "   ✅ Élément trouvé: $element" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Élément manquant: $element" -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "   ❌ Erreur lors de la vérification: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 8: Restauration de la configuration originale
Write-Host "`n🔄 Restauration de la configuration originale" -ForegroundColor Yellow
$restoreData = @{
    site_name = "U SILENZIU"
    site_description = "Votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et fun."
    site_slogan = "Énergie positive garantie !"
    contact_phone = "+33 7 83 83 64 53"
    contact_email = "info@usilenziu.com"
    contact_address = "18 Rue du Pont Long, 64160 Buros, Zone Berlanne"
    opening_hours_tuesday = "14:00 – 21:00"
    opening_hours_wednesday = "14:00 – 21:00"
    opening_hours_thursday = "14:00 – 21:00"
    opening_hours_friday = "14:00 – 00:00"
    opening_hours_saturday = "14:00 – 00:00"
    opening_hours_sunday = "Sur réservation uniquement, Minimum 5 personnes"
    cta_title = "Prêt à libérer votre stress ?"
    cta_button_text = "Réserver maintenant"
    cta_button_url = "/reservation"
    legal_links = @(
        @{ label = "CGV"; url = "/cgv" },
        @{ label = "Politique de confidentialité"; url = "/politique-confidentialite" },
        @{ label = "Mentions légales"; url = "/mentions-legales" },
        @{ label = "Paramètres des cookies"; url = "/parametres-cookies" }
    )
    copyright_text = "© 2024 U Silenziu. Tous droits réservés."
}

$restoredConfig = Test-Url -Url "$apiUrl/admin/footer-config" -Method "PUT" -Body $restoreData -Description "Restauration de la configuration originale"

# Résumé des tests
Write-Host "`n📊 Résumé des Tests" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

$tests = @(
    @{ Name = "API publique - Récupération config"; Result = $footerConfig -ne $null },
    @{ Name = "API admin - Récupération config"; Result = $adminFooterConfig -ne $null },
    @{ Name = "API admin - Mise à jour config"; Result = $updatedConfig -ne $null },
    @{ Name = "API publique - Vérification mise à jour"; Result = $verifyConfig -ne $null },
    @{ Name = "Interface admin - Page d'accueil"; Result = $true },
    @{ Name = "Interface publique - Page principale"; Result = $true },
    @{ Name = "Restauration config originale"; Result = $restoredConfig -ne $null }
)

$successCount = 0
foreach ($test in $tests) {
    $status = if ($test.Result) { "✅" } else { "❌" }
    $color = if ($test.Result) { "Green" } else { "Red" }
    Write-Host "   $status $($test.Name)" -ForegroundColor $color
    if ($test.Result) { $successCount++ }
}

Write-Host "`n🎯 Résultat: $successCount/$($tests.Count) tests réussis" -ForegroundColor $(if ($successCount -eq $tests.Count) { "Green" } else { "Yellow" })

if ($successCount -eq $tests.Count) {
    Write-Host "`n🎉 Tous les tests sont passés avec succès !" -ForegroundColor Green
    Write-Host "   La gestion du pied de page fonctionne correctement." -ForegroundColor Green
} else {
    Write-Host "`n⚠️  Certains tests ont échoué." -ForegroundColor Yellow
    Write-Host "   Vérifiez les erreurs ci-dessus et corrigez les problèmes." -ForegroundColor Yellow
}

Write-Host "`n📝 Instructions d'utilisation:" -ForegroundColor Cyan
Write-Host "   1. Accédez à l'interface d'administration: $adminUrl/homepage" -ForegroundColor White
Write-Host "   2. Cliquez sur 'Modifier' dans la section 'Configuration du Pied de Page'" -ForegroundColor White
Write-Host "   3. Modifiez les informations selon vos besoins" -ForegroundColor White
Write-Host "   4. Cliquez sur 'Sauvegarder' pour appliquer les changements" -ForegroundColor White
Write-Host "   5. Vérifiez les modifications sur le site: $baseUrl" -ForegroundColor White

Write-Host "`n✨ Test terminé !" -ForegroundColor Cyan
