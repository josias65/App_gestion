@echo off
echo ========================================
echo   Configuration Appels d'Offre Avances
echo ========================================
echo.

echo [1/4] Installation des dependances backend...
cd backend
npm install
if %errorlevel% neq 0 (
    echo ERREUR: Echec de l'installation des dependances
    pause
    exit /b 1
)

echo [2/4] Amelioration de la base de donnees...
node scripts/enhance-database.js
if %errorlevel% neq 0 (
    echo ERREUR: Echec de l'amelioration de la base de donnees
    pause
    exit /b 1
)

echo [3/4] Initialisation de la base de donnees...
node scripts/init-database.js
if %errorlevel% neq 0 (
    echo ERREUR: Echec de l'initialisation de la base de donnees
    pause
    exit /b 1
)

echo [4/4] Demarrage du serveur backend...
echo.
echo ========================================
echo   SERVEUR PRET !
echo ========================================
echo.
echo Le serveur backend est maintenant demarre avec toutes les
echo nouvelles fonctionnalites pour les appels d'offre :
echo.
echo ✅ Gestion des documents
echo ✅ Systeme de commentaires
echo ✅ Historique des modifications
echo ✅ Criteres d'evaluation
echo ✅ Notifications
echo ✅ Analytics avancés
echo ✅ Export des données
echo.
echo Vous pouvez maintenant tester l'application Flutter !
echo.
echo URL du serveur : http://localhost:8000
echo.

npm start
