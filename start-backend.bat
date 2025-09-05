@echo off
echo 🚀 Démarrage du backend AppGestion...
echo.

REM Vérifier si Node.js est installé
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js n'est pas installé. Veuillez installer Node.js depuis https://nodejs.org/
    pause
    exit /b 1
)

REM Aller dans le dossier backend
cd backend

REM Vérifier si les dépendances sont installées
if not exist "node_modules" (
    echo 📦 Installation des dépendances...
    npm install
    if %errorlevel% neq 0 (
        echo ❌ Erreur lors de l'installation des dépendances
        pause
        exit /b 1
    )
)

REM Initialiser la base de données si elle n'existe pas
if not exist "database.sqlite" (
    echo 🗄️ Initialisation de la base de données...
    npm run init-db
    if %errorlevel% neq 0 (
        echo ❌ Erreur lors de l'initialisation de la base de données
        pause
        exit /b 1
    )
)

REM Démarrer le serveur
echo 🌐 Démarrage du serveur...
echo 📱 Accessible depuis Flutter sur: http://10.0.2.2:8000
echo 🌐 Accessible localement sur: http://localhost:8000
echo.
echo 👤 Utilisateurs par défaut:
echo    - Admin: admin@neo.com / admin123
echo    - Test: test@example.com / password123
echo.
echo Appuyez sur Ctrl+C pour arrêter le serveur
echo.

npm start
