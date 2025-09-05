@echo off
title AppGestion - Démarrage Complet
color 0A

echo.
echo ========================================
echo    🚀 APPGESTION - DÉMARRAGE COMPLET
echo ========================================
echo.

REM Vérifier si Node.js est installé
echo 🔍 Vérification de Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js n'est pas installé !
    echo.
    echo 📥 Téléchargement de Node.js...
    start https://nodejs.org/
    echo.
    echo ⏳ Veuillez installer Node.js et relancer ce script.
    pause
    exit /b 1
)

echo ✅ Node.js détecté
node --version
echo.

REM Aller dans le dossier backend
cd backend

REM Vérifier si les dépendances sont installées
echo 📦 Vérification des dépendances...
if not exist "node_modules" (
    echo 📥 Installation des dépendances...
    npm install
    if %errorlevel% neq 0 (
        echo ❌ Erreur lors de l'installation des dépendances
        pause
        exit /b 1
    )
    echo ✅ Dépendances installées
) else (
    echo ✅ Dépendances déjà installées
)

REM Vérifier si la base de données existe
echo 🗄️ Vérification de la base de données...
if not exist "database.sqlite" (
    echo 📥 Initialisation de la base de données...
    npm run init-db
    if %errorlevel% neq 0 (
        echo ❌ Erreur lors de l'initialisation de la base de données
        pause
        exit /b 1
    )
    echo ✅ Base de données initialisée
) else (
    echo ✅ Base de données existante trouvée
)

echo.
echo ========================================
echo    🌐 DÉMARRAGE DU SERVEUR BACKEND
echo ========================================
echo.
echo 📱 Accessible depuis Flutter sur: http://10.0.2.2:8000
echo 🌐 Accessible localement sur: http://localhost:8000
echo.
echo 👤 Utilisateurs de test:
echo    - Admin: admin@neo.com / admin123
echo    - Test: test@example.com / password123
echo.
echo 📊 Base de données: SQLite (database.sqlite)
echo.
echo ⚠️  Gardez cette fenêtre ouverte pendant l'utilisation de l'app
echo.
echo Appuyez sur Ctrl+C pour arrêter le serveur
echo.

REM Démarrer le serveur
npm start

echo.
echo 👋 Serveur arrêté. Appuyez sur une touche pour fermer...
pause >nul
