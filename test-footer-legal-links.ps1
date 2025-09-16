# Test simple pour vérifier les liens légaux dans le footer
Write-Host "=== Test des Liens Légaux dans le Footer ===" -ForegroundColor Green

# Test de la nouvelle API
Write-Host "`nTest API: Récupération des pages légales pour le footer" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/legal-pages" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $data = $response.Content | ConvertFrom-Json
        if ($data.success -and $data.data.Count -gt 0) {
            Write-Host "✅ Succès - API fonctionnelle" -ForegroundColor Green
            Write-Host "   Pages légales trouvées: $($data.data.Count)" -ForegroundColor Cyan
            foreach ($page in $data.data) {
                Write-Host "   - $($page.title) ($($page.page_type))" -ForegroundColor White
            }
        } else {
            Write-Host "❌ Échec - Aucune page légale trouvée" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Échec - Status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

# Test de la page d'accueil pour voir si le footer contient les liens
Write-Host "`nTest: Page d'accueil avec footer" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $content = $response.Content
        
        # Vérifier si les liens légaux sont présents
        if ($content -match "Informations légales" -and $content -match "/legal/") {
            Write-Host "✅ Succès - Footer contient les liens légaux" -ForegroundColor Green
            
            # Extraire les liens légaux trouvés
            $legalLinks = [regex]::Matches($content, 'href="(/legal/[^"]+)"')
            if ($legalLinks.Count -gt 0) {
                Write-Host "   Liens trouvés:" -ForegroundColor Cyan
                foreach ($link in $legalLinks) {
                    Write-Host "   - $($link.Groups[1].Value)" -ForegroundColor White
                }
            }
        } else {
            Write-Host "❌ Échec - Footer ne contient pas les liens légaux" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Échec - Status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Fin du Test ===" -ForegroundColor Green
