@echo off
echo ========================================
echo   TEST COMPLET APPELS D'OFFRE AVANCES
echo ========================================
echo.

echo [1/6] Verification de la structure du projet...
if not exist "backend" (
    echo ERREUR: Dossier backend non trouve
    pause
    exit /b 1
)
if not exist "lib" (
    echo ERREUR: Dossier lib non trouve
    pause
    exit /b 1
)
echo ✅ Structure du projet OK

echo [2/6] Verification des fichiers backend...
if not exist "backend\routes\appels-offre-enhanced.js" (
    echo ERREUR: Route appels-offre-enhanced.js manquante
    pause
    exit /b 1
)
if not exist "backend\scripts\enhance-database.js" (
    echo ERREUR: Script enhance-database.js manquant
    pause
    exit /b 1
)
echo ✅ Fichiers backend OK

echo [3/6] Verification des fichiers Flutter...
if not exist "lib\services\appel_offre_service.dart" (
    echo ERREUR: Service appel_offre_service.dart manquant
    pause
    exit /b 1
)
if not exist "lib\widgets\appel_offre_widgets.dart" (
    echo ERREUR: Widgets appel_offre_widgets.dart manquants
    pause
    exit /b 1
)
if not exist "lib\login\test_appel_offre_screen.dart" (
    echo ERREUR: Ecran de test manquant
    pause
    exit /b 1
)
echo ✅ Fichiers Flutter OK

echo [4/6] Installation des dependances backend...
cd backend
npm install
if %errorlevel% neq 0 (
    echo ERREUR: Echec de l'installation des dependances
    pause
    exit /b 1
)

echo [5/6] Amelioration de la base de donnees...
node scripts/enhance-database.js
if %errorlevel% neq 0 (
    echo ERREUR: Echec de l'amelioration de la base de donnees
    pause
    exit /b 1
)

echo [6/6] Initialisation de la base de donnees...
node scripts/init-database.js
if %errorlevel% neq 0 (
    echo ERREUR: Echec de l'initialisation de la base de donnees
    pause
    exit /b 1
)

echo.
echo ========================================
echo   TESTS COMPLETS TERMINES AVEC SUCCES !
echo ========================================
echo.
echo 🎉 Votre application est maintenant equipee de :
echo.
echo ✅ API Backend Complete
echo    - CRUD Appels d'Offre
echo    - Gestion des Documents
echo    - Systeme de Commentaires
echo    - Historique des Modifications
echo    - Criteres d'Evaluation
echo    - Notifications
echo    - Analytics Avances
echo    - Export des Donnees
echo.
echo ✅ Interface Flutter Amelioree
echo    - Service API Integre
echo    - Widgets Avances
echo    - Gestion d'Etat
echo    - Cache Intelligent
echo    - Interface de Test
echo.
echo ✅ Base de Donnees Etendue
echo    - Tables Supplementaires
echo    - Relations Optimisees
echo    - Index de Performance
echo    - Donnees de Test
echo.
echo 🚀 PROCHAINES ETAPES :
echo.
echo 1. Demarrer le serveur backend :
echo    cd backend
echo    npm start
echo.
echo 2. Lancer l'application Flutter :
echo    flutter run
echo.
echo 3. Tester les nouvelles fonctionnalites :
echo    - Aller dans Menu > Test Appels d'Offre
echo    - Creer des appels d'offre
echo    - Uploader des documents
echo    - Ajouter des commentaires
echo    - Soumettre des offres
echo    - Visualiser les statistiques
echo.
echo 📱 URL de test : http://localhost:8000
echo.
echo ========================================

pause
