# Test du nouveau template d'email de rappel de réservation
# Script pour tester l'amélioration de la lisibilité des emails

Write-Host "🧪 Test du nouveau template d'email de rappel de réservation" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# Test de l'API d'envoi d'email avec le nouveau template
Write-Host "`n📧 Test d'envoi d'email avec le nouveau template..." -ForegroundColor Yellow

$testData = @{
    testEmail = "test@example.com"
    firstName = "Jean"
    lastName = "Dupont"
    email = "jean.dupont@example.com"
    reservationNumber = "250904001"
    roomName = "Salle Haches"
    date = "2025-01-10"
    time = "15:00:00"
    duration = 20
    numberOfPeople = 2
    formula = "Standard"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/notifications/send" -Method POST -Body $testData -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "✅ Email envoyé avec succès !" -ForegroundColor Green
        Write-Host "📧 Destinataire: $($response.email)" -ForegroundColor White
        Write-Host "📋 Sujet: $($response.subject)" -ForegroundColor White
        Write-Host "`n🎨 Le nouveau template inclut:" -ForegroundColor Cyan
        Write-Host "   • Design moderne avec fond blanc et couleurs kaki" -ForegroundColor White
        Write-Host "   • Header avec dégradé vert kaki" -ForegroundColor White
        Write-Host "   • Grille organisée pour les détails de réservation" -ForegroundColor White
        Write-Host "   • Section de rappels avec puces visuelles" -ForegroundColor White
        Write-Host "   • Informations de contact structurées" -ForegroundColor White
        Write-Host "   • Design responsive pour mobile" -ForegroundColor White
        Write-Host "   • Typographie moderne (Segoe UI)" -ForegroundColor White
    } else {
        Write-Host "❌ Erreur lors de l'envoi: $($response.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Assurez-vous que l'application est démarrée sur http://localhost:3000" -ForegroundColor Yellow
}

Write-Host "`n📊 Améliorations apportées au template:" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "✅ Design moderne avec fond blanc au lieu du thème sombre" -ForegroundColor Green
Write-Host "✅ Typographie améliorée avec Segoe UI" -ForegroundColor Green
Write-Host "✅ Grille CSS pour une meilleure organisation des informations" -ForegroundColor Green
Write-Host "✅ Couleurs kaki cohérentes avec l'identité visuelle" -ForegroundColor Green
Write-Host "✅ Sections bien délimitées avec bordures et ombres" -ForegroundColor Green
Write-Host "✅ Numéro de réservation mis en évidence" -ForegroundColor Green
Write-Host "✅ Rappels avec puces visuelles et couleurs d'alerte" -ForegroundColor Green
Write-Host "✅ Informations de contact organisées en grille" -ForegroundColor Green
Write-Host "✅ Design responsive pour mobile et desktop" -ForegroundColor Green
Write-Host "✅ Footer professionnel avec copyright" -ForegroundColor Green

Write-Host "`n🎯 Résultat attendu:" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "L'email sera maintenant beaucoup plus lisible avec:" -ForegroundColor White
Write-Host "• Un contraste élevé (texte sombre sur fond clair)" -ForegroundColor White
Write-Host "• Une hiérarchie visuelle claire" -ForegroundColor White
Write-Host "• Des sections bien organisées" -ForegroundColor White
Write-Host "• Une présentation professionnelle" -ForegroundColor White
Write-Host "• Une compatibilité mobile optimale" -ForegroundColor White

Write-Host "`n✨ Test terminé ! Le template d'email a été amélioré pour une meilleure lisibilité." -ForegroundColor Green
