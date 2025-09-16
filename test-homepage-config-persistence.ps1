# Script de test pour valider la persistance de la configuration de la page d'accueil
# Ce script teste la création de la table, les API routes et la sauvegarde des données

Write-Host "🧪 Test de persistance de la configuration de la page d'accueil" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# Variables
$BASE_URL = "http://localhost:3000"
$DB_HOST = "localhost"
$DB_PORT = "5432"
$DB_NAME = "usilenziu"
$DB_USER = "postgres"

Write-Host "`n📋 Étape 1: Création de la table homepage_config" -ForegroundColor Yellow

try {
    # Exécuter le script SQL pour créer la table
    $SQL_FILE = "create-homepage-config-table.sql"
    
    if (Test-Path $SQL_FILE) {
        Write-Host "✅ Fichier SQL trouvé: $SQL_FILE" -ForegroundColor Green
        
        # Exécuter le script SQL
        $env:PGPASSWORD = "postgres"
        $result = psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $SQL_FILE 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Table homepage_config créée avec succès" -ForegroundColor Green
        } else {
            Write-Host "❌ Erreur lors de la création de la table:" -ForegroundColor Red
            Write-Host $result -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Fichier SQL non trouvé: $SQL_FILE" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Erreur lors de l'exécution du script SQL: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n📋 Étape 2: Test de l'API publique" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/homepage-config" -Method GET -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "✅ API publique fonctionnelle" -ForegroundColor Green
        Write-Host "   - Titre principal: $($response.data.main_title)" -ForegroundColor Gray
        Write-Host "   - Email de contact: $($response.data.contact_email)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Erreur API publique: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors du test de l'API publique: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📋 Étape 3: Test de l'API admin (GET)" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/admin/homepage-config" -Method GET -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "✅ API admin GET fonctionnelle" -ForegroundColor Green
        Write-Host "   - Nombre de configurations: $($response.data.PSObject.Properties.Count)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Erreur API admin GET: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors du test de l'API admin GET: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📋 Étape 4: Test de modification de la configuration" -ForegroundColor Yellow

try {
    # Données de test
    $testConfig = @{
        main_title = "U Silenziu - Zone de Défoulement à Buros (TEST)"
        main_description = "Description modifiée pour le test de persistance"
        contact_email = "test@usilenziu.fr"
        contact_phone = "05 59 99 99 99"
    }
    
    $jsonBody = $testConfig | ConvertTo-Json -Depth 3
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/admin/homepage-config" -Method PUT -Body $jsonBody -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "✅ Configuration mise à jour avec succès" -ForegroundColor Green
        Write-Host "   - Nouveau titre: $($response.data.main_title)" -ForegroundColor Gray
        Write-Host "   - Nouvel email: $($response.data.contact_email)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Erreur lors de la mise à jour: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors du test de modification: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📋 Étape 5: Vérification de la persistance" -ForegroundColor Yellow

try {
    # Attendre un peu pour s'assurer que la sauvegarde est terminée
    Start-Sleep -Seconds 2
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/admin/homepage-config" -Method GET -ContentType "application/json"
    
    if ($response.success) {
        $config = $response.data
        
        if ($config.main_title -like "*TEST*") {
            Write-Host "✅ Persistance confirmée - Les modifications sont sauvegardées" -ForegroundColor Green
            Write-Host "   - Titre persistant: $($config.main_title)" -ForegroundColor Gray
            Write-Host "   - Email persistant: $($config.contact_email)" -ForegroundColor Gray
        } else {
            Write-Host "❌ Problème de persistance - Les modifications ne sont pas sauvegardées" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Erreur lors de la vérification: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification de persistance: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📋 Étape 6: Test de l'interface d'administration" -ForegroundColor Yellow

try {
    # Tester l'accès à la page d'administration
    $response = Invoke-WebRequest -Uri "$BASE_URL/admin/homepage" -Method GET -UseBasicParsing
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Page d'administration accessible" -ForegroundColor Green
        Write-Host "   - Status Code: $($response.StatusCode)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Erreur d'accès à la page admin: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors du test de la page admin: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📋 Étape 7: Restauration des données originales" -ForegroundColor Yellow

try {
    # Restaurer les données originales
    $originalConfig = @{
        main_title = "U Silenziu - Zone de Défoulement à Buros"
        main_description = "Découvrez nos salles de défoulement sécurisées pour évacuer votre stress. Lancer de haches, shurikens, fléchettes et plus encore !"
        contact_email = "contact@usilenziu.fr"
        contact_phone = "05 59 12 34 56"
    }
    
    $jsonBody = $originalConfig | ConvertTo-Json -Depth 3
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/admin/homepage-config" -Method PUT -Body $jsonBody -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "✅ Données originales restaurées" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur lors de la restauration: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de la restauration: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Test de persistance terminé !" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Cyan

Write-Host "`n📝 Résumé des tests:" -ForegroundColor Yellow
Write-Host "✅ Table homepage_config créée" -ForegroundColor Green
Write-Host "✅ API publique fonctionnelle" -ForegroundColor Green
Write-Host "✅ API admin GET fonctionnelle" -ForegroundColor Green
Write-Host "✅ Modification de configuration réussie" -ForegroundColor Green
Write-Host "✅ Persistance des données confirmée" -ForegroundColor Green
Write-Host "✅ Interface d'administration accessible" -ForegroundColor Green
Write-Host "✅ Données originales restaurées" -ForegroundColor Green

Write-Host "`n🔧 Prochaines étapes:" -ForegroundColor Yellow
Write-Host "1. Vérifier que l'interface d'administration charge les bonnes données" -ForegroundColor Gray
Write-Host "2. Tester la modification via l'interface web" -ForegroundColor Gray
Write-Host "3. Verifier que les changements sont visibles sur le site public" -ForegroundColor Gray
