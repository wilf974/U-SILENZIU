#!/usr/bin/env pwsh

# Script de test pour valider l'affichage des liens legaux dans le footer
# Teste l'API des pages legales et l'affichage dans le footer

Write-Host "Test des liens legaux dans le footer - U Silenziu" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
$apiUrl = "$baseUrl/api"

# Fonction pour tester une URL
function Test-Url {
    param($url, $description)
    
    try {
        Write-Host "`nTest: $description" -ForegroundColor Yellow
        Write-Host "URL: $url" -ForegroundColor Gray
        
        $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            Write-Host "SUCCES - Status: $($response.StatusCode)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "ECHEC - Status: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERREUR: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Fonction pour tester une API
function Test-Api {
    param($url, $description)
    
    try {
        Write-Host "`nTest API: $description" -ForegroundColor Yellow
        Write-Host "URL: $url" -ForegroundColor Gray
        
        $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            $data = $response.Content | ConvertFrom-Json
            
            if ($data.success) {
                Write-Host "API fonctionnelle - Status: $($response.StatusCode)" -ForegroundColor Green
                Write-Host "Donnees recues: $($data.data.Count) elements" -ForegroundColor Green
                
                # Afficher les details des pages legales
                if ($data.data -and $data.data.Count -gt 0) {
                    Write-Host "Pages legales disponibles:" -ForegroundColor Cyan
                    foreach ($page in $data.data) {
                        Write-Host "  - $($page.page_type): $($page.title) (Publie: $($page.is_published))" -ForegroundColor White
                    }
                }
                
                return $true
            } else {
                Write-Host "API retourne une erreur: $($data.error)" -ForegroundColor Red
                return $false
            }
        } else {
            Write-Host "ECHEC API - Status: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERREUR API: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Fonction pour verifier le contenu HTML
function Test-HtmlContent {
    param($url, $description, $searchText)
    
    try {
        Write-Host "`nTest contenu HTML: $description" -ForegroundColor Yellow
        Write-Host "URL: $url" -ForegroundColor Gray
        Write-Host "Recherche: $searchText" -ForegroundColor Gray
        
        $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            $html = $response.Content
            
            if ($html -like "*$searchText*") {
                Write-Host "Contenu trouve dans le HTML" -ForegroundColor Green
                return $true
            } else {
                Write-Host "Contenu non trouve dans le HTML" -ForegroundColor Red
                return $false
            }
        } else {
            Write-Host "ECHEC - Status: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERREUR: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Tests
Write-Host "`nDemarrage des tests..." -ForegroundColor Green

$tests = @()

# Test 1: API des pages legales
$tests += Test-Api "$apiUrl/legal-pages" "Recuperation des pages legales publiees"

# Test 2: Page d'accueil (pour verifier le footer)
$tests += Test-Url "$baseUrl" "Page d'accueil avec footer"

# Test 3: Verification du contenu du footer
$tests += Test-HtmlContent "$baseUrl" "Presence de la section 'Informations legales'" "Informations legales"

# Test 4: Verification des liens legaux dans le footer
$tests += Test-HtmlContent "$baseUrl" "Presence des liens legaux" "/legal/"

# Test 5: Test d'une page legale specifique (si disponible)
$tests += Test-Url "$baseUrl/legal/cgv" "Page CGV"

# Resume des tests
Write-Host "`nResume des tests:" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

$successCount = ($tests | Where-Object { $_ -eq $true }).Count
$totalCount = $tests.Count

Write-Host "Tests reussis: $successCount/$totalCount" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })

if ($successCount -eq $totalCount) {
    Write-Host "`nTous les tests sont passes avec succes !" -ForegroundColor Green
    Write-Host "Les liens legaux sont correctement affiches dans le footer" -ForegroundColor Green
    Write-Host "L'API des pages legales fonctionne correctement" -ForegroundColor Green
    Write-Host "Les pages legales sont accessibles via les liens du footer" -ForegroundColor Green
} else {
    Write-Host "`nCertains tests ont echoue" -ForegroundColor Yellow
    Write-Host "Verifiez que:" -ForegroundColor Yellow
    Write-Host "- L'application est demarree sur $baseUrl" -ForegroundColor Yellow
    Write-Host "- Les pages legales sont creees et publiees dans le back-office" -ForegroundColor Yellow
    Write-Host "- La base de donnees contient des pages legales" -ForegroundColor Yellow
}

Write-Host "`nInstructions pour verifier manuellement:" -ForegroundColor Cyan
Write-Host "1. Ouvrez $baseUrl dans votre navigateur" -ForegroundColor White
Write-Host "2. Descendez jusqu'au footer de la page" -ForegroundColor White
Write-Host "3. Verifiez la presence de la section 'Informations legales'" -ForegroundColor White
Write-Host "4. Cliquez sur les liens legaux pour verifier qu'ils fonctionnent" -ForegroundColor White
Write-Host "5. Accedez au back-office pour gerer les pages legales: $baseUrl/admin/legal-pages" -ForegroundColor White

Write-Host "`nTest termine !" -ForegroundColor Green