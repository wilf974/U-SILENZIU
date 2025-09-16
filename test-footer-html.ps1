# Test pour vérifier le HTML du footer
Write-Host "Test du HTML du footer..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/" -UseBasicParsing -TimeoutSec 10
    $html = $response.Content
    
    # Chercher la section des liens légaux
    if ($html -match "Informations légales") {
        Write-Host "✅ Section 'Informations légales' trouvée" -ForegroundColor Green
        
        # Extraire la section complète
        $footerSection = [regex]::Match($html, '(?s)Informations légales.*?</div>')
        if ($footerSection.Success) {
            Write-Host "Contenu de la section:" -ForegroundColor Cyan
            Write-Host $footerSection.Value -ForegroundColor White
        }
        
        # Compter les liens /legal/
        $legalLinks = [regex]::Matches($html, 'href="(/legal/[^"]+)"')
        Write-Host "`nLiens légaux trouvés: $($legalLinks.Count)" -ForegroundColor Cyan
        foreach ($link in $legalLinks) {
            Write-Host "- $($link.Groups[1].Value)" -ForegroundColor White
        }
    } else {
        Write-Host "❌ Section 'Informations légales' non trouvée" -ForegroundColor Red
        
        # Chercher d'autres indices
        if ($html -match "legal") {
            Write-Host "Le mot 'legal' est présent dans le HTML" -ForegroundColor Yellow
        }
        if ($html -match "/legal/") {
            Write-Host "Des liens /legal/ sont présents" -ForegroundColor Yellow
        }
    }
    
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
}
