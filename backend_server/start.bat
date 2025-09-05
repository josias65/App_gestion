@echo off
echo 🚀 Démarrage du backend AppGestion...

:: Vérifier si Node.js est installé
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Node.js n'est pas installé. Veuillez l'installer depuis https://nodejs.org/
    pause
    exit /b 1
)

:: Vérifier si npm est installé
where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ npm n'est pas installé. Veuillez l'installer avec Node.js
    pause
    exit /b 1
)

:: Aller dans le dossier du backend
cd /d "%~dp0"

:: Installer les dépendances si nécessaire
if not exist "node_modules" (
    echo 📦 Installation des dépendances...
    npm install
)

echo 🌟 Démarrage du serveur en mode développement...
npm run dev

pause