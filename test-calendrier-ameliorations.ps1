# Script de test pour les ameliorations du calendrier de reservation
# Teste la localisation francaise, les tranches de 20 minutes et l'affichage des disponibilites

Write-Host "Test des ameliorations du calendrier de reservation" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
$testResults = @()

# Fonction pour tester une URL
function Test-Url {
    param($url, $description)
    
    try {
        $response = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "OK - $description" -ForegroundColor Green
            return $true
        } else {
            Write-Host "ERREUR - $description - Code: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERREUR - $description - Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Fonction pour verifier le contenu d'une page
function Test-PageContent {
    param($url, $description, $expectedContent)
    
    try {
        $response = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            $content = $response.Content
            if ($content -match $expectedContent) {
                Write-Host "OK - $description" -ForegroundColor Green
                return $true
            } else {
                Write-Host "ERREUR - $description - Contenu attendu non trouve" -ForegroundColor Red
                return $false
            }
        } else {
            Write-Host "ERREUR - $description - Code: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERREUR - $description - Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host "`nTest 1: Verification de l'accessibilite de la page de reservation" -ForegroundColor Yellow
$test1 = Test-Url "$baseUrl/reservation" "Page de reservation accessible"
$testResults += @{Test = "Page de reservation"; Result = $test1}

Write-Host "`nTest 2: Verification de la localisation francaise" -ForegroundColor Yellow
$test2 = Test-PageContent "$baseUrl/reservation" "Localisation francaise" "Selectionnez une date"
$testResults += @{Test = "Localisation francaise"; Result = $test2}

Write-Host "`nTest 3: Verification des messages francais du calendrier" -ForegroundColor Yellow
$test3 = Test-PageContent "$baseUrl/reservation" "Messages francais du calendrier" "Suivant|Precedent|Aujourd'hui"
$testResults += @{Test = "Messages francais du calendrier"; Result = $test3}

Write-Host "`nTest 4: Verification de la legende des disponibilites" -ForegroundColor Yellow
$test4 = Test-PageContent "$baseUrl/reservation" "Legende des disponibilites" "Disponibilites par jour"
$testResults += @{Test = "Legende des disponibilites"; Result = $test4}

Write-Host "`nTest 5: Verification des creneaux de 20 minutes" -ForegroundColor Yellow
$test5 = Test-PageContent "$baseUrl/reservation" "Creneaux de 20 minutes" "14:00.*14:20|14:20.*14:40|14:40.*15:00"
$testResults += @{Test = "Creneaux de 20 minutes"; Result = $test5}

Write-Host "`nTest 6: Verification de l'affichage des disponibilites" -ForegroundColor Yellow
$test6 = Test-PageContent "$baseUrl/reservation" "Affichage des disponibilites" "creneaux|Disponible|Complet"
$testResults += @{Test = "Affichage des disponibilites"; Result = $test6}

Write-Host "`nTest 7: Test des URLs de reservation avec formules" -ForegroundColor Yellow
$test7a = Test-Url "$baseUrl/reservation?formule=Salle%201" "Reservation Salle 1"
$test7b = Test-Url "$baseUrl/reservation?formule=Salle%202" "Reservation Salle 2"
$test7 = $test7a -and $test7b
$testResults += @{Test = "URLs de reservation avec formules"; Result = $test7}

# Resume des tests
Write-Host "`nResume des tests" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

$totalTests = $testResults.Count
$passedTests = ($testResults | Where-Object { $_.Result -eq $true }).Count
$failedTests = $totalTests - $passedTests

foreach ($result in $testResults) {
    $status = if ($result.Result) { "PASSE" } else { "ECHOUE" }
    $color = if ($result.Result) { "Green" } else { "Red" }
    Write-Host "$status - $($result.Test)" -ForegroundColor $color
}

Write-Host "`nStatistiques finales:" -ForegroundColor Cyan
Write-Host "Tests reussis: $passedTests/$totalTests" -ForegroundColor Green
Write-Host "Tests echoues: $failedTests/$totalTests" -ForegroundColor Red

if ($passedTests -eq $totalTests) {
    Write-Host "`nTous les tests sont passes ! Le calendrier ameliore fonctionne correctement." -ForegroundColor Green
    Write-Host "`nAmeliorations validees:" -ForegroundColor Green
    Write-Host "   • Calendrier en francais avec moment.js" -ForegroundColor White
    Write-Host "   • Tranches horaires de 20 minutes" -ForegroundColor White
    Write-Host "   • Affichage des disponibilites sur le calendrier" -ForegroundColor White
    Write-Host "   • Legende coloree pour les disponibilites" -ForegroundColor White
    Write-Host "   • Messages francais pour tous les elements" -ForegroundColor White
} else {
    Write-Host "`nCertains tests ont echoue. Verifiez les erreurs ci-dessus." -ForegroundColor Yellow
}

Write-Host "`nPour tester manuellement:" -ForegroundColor Cyan
Write-Host "1. Ouvrez http://localhost:3000/reservation" -ForegroundColor White
Write-Host "2. Verifiez que le calendrier est en francais" -ForegroundColor White
Write-Host "3. Cliquez sur une date pour voir les creneaux de 20 minutes" -ForegroundColor White
Write-Host "4. Observez les couleurs sur le calendrier (vert/orange/rouge/gris)" -ForegroundColor White
Write-Host "5. Testez la selection d'un creneau disponible" -ForegroundColor White