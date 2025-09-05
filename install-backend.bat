@echo off
echo 🚀 Installation automatique du backend AppGestion...
echo.

REM Vérifier si Node.js est installé
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js n'est pas installé !
    echo 📥 Veuillez installer Node.js depuis https://nodejs.org/
    echo.
    echo Appuyez sur une touche pour ouvrir le site de téléchargement...
    pause >nul
    start https://nodejs.org/
    exit /b 1
)

echo ✅ Node.js détecté
node --version

REM Aller dans le dossier backend
cd backend

echo.
echo 📦 Installation des dépendances...
npm install
if %errorlevel% neq 0 (
    echo ❌ Erreur lors de l'installation des dépendances
    pause
    exit /b 1
)

echo.
echo 🗄️ Initialisation de la base de données...
npm run init-db
if %errorlevel% neq 0 (
    echo ❌ Erreur lors de l'initialisation de la base de données
    pause
    exit /b 1
)

echo.
echo ✅ Installation terminée avec succès !
echo.
echo 🌐 Pour démarrer le serveur, utilisez :
echo    npm start
echo.
echo 📱 Ou utilisez le script start-backend.bat
echo.
echo 👤 Utilisateurs de test créés :
echo    - Admin: admin@neo.com / admin123
echo    - Test: test@example.com / password123
echo.
pause
