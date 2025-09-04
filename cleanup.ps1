# Script de nettoyage du projet Flutter

# Dossiers à conserver
$keepDirs = @(
    "config",
    "models",
    "providers",
    "screens",
    "services",
    "widgets"
)

# Fichiers à conserver à la racine
$keepFiles = @(
    "main.dart"
)

# Dossiers à supprimer
$removeDirs = @(
    "appel_d_offre",
    "client",
    "commande",
    "devis",
    "facture",
    "login",
    "marche",
    "profil",
    "recouvrements",
    "relances",
    "retour",
    "temp"
)

# Emplacement du projet
$projectPath = "$PSScriptRoot\lib"
$backupPath = "$PSScriptRoot\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Créer un dossier de sauvegarde
Write-Host "Création d'une sauvegarde dans $backupPath" -ForegroundColor Yellow
New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

# Sauvegarder les fichiers importants
foreach ($dir in $keepDirs) {
    $source = Join-Path $projectPath $dir
    if (Test-Path $source) {
        $dest = Join-Path $backupPath $dir
        New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
        Copy-Item -Path $source -Destination $dest -Recurse -Force
        Write-Host "Sauvegardé: $dir" -ForegroundColor Green
    }
}

# Sauvegarder les fichiers à la racine
foreach ($file in $keepFiles) {
    $source = Join-Path $projectPath $file
    if (Test-Path $source) {
        $dest = Join-Path $backupPath $file
        Copy-Item -Path $source -Destination $dest -Force
        Write-Host "Sauvegardé: $file" -ForegroundColor Green
    }
}

# Supprimer les dossiers inutiles
foreach ($dir in $removeDirs) {
    $path = Join-Path $projectPath $dir
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Host "Supprimé: $dir" -ForegroundColor Red
    }
}

# Supprimer les fichiers .DS_Store et autres fichiers système
Get-ChildItem -Path $projectPath -Include ".DS_Store", "Thumbs.db" -File -Recurse | Remove-Item -Force

Write-Host "\nNettoyage terminé ! Une sauvegarde a été créée dans: $backupPath" -ForegroundColor Green
Write-Host "Structure actuelle du dossier lib:" -ForegroundColor Cyan
Get-ChildItem -Path $projectPath -Recurse -Directory | Select-Object FullName | Sort-Object FullName

# Afficher les prochaines étapes
Write-Host "\nProchaines étapes:" -ForegroundColor Yellow
Write-Host "1. Vérifiez la sauvegarde dans $backupPath"
Write-Host "2. Exécutez 'flutter clean' pour nettoyer le cache"
Write-Host "3. Exécutez 'flutter pub get' pour mettre à jour les dépendances"
Write-Host "4. Lancez l'application avec 'flutter run'"
