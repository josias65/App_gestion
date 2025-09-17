@echo off
echo ========================================
echo    NETTOYAGE COMPLET DE L'APPLICATION
echo ========================================
echo.

echo 🧹 Suppression des données par défaut...
echo.

echo 📂 Nettoyage de la base de données...
cd backend
node scripts/clean-database.js

echo.
echo ✅ Nettoyage terminé !
echo.
echo 📝 Résumé des actions effectuées :
echo    - Suppression de toutes les données par défaut
echo    - Nettoyage des listes mock dans le code Flutter
echo    - Réinitialisation des compteurs de base de données
echo.
echo 🎯 Votre application est maintenant propre et prête pour des données réelles !
echo.
echo 💡 Prochaines étapes :
echo    1. Démarrer le backend : cd backend && npm start
echo    2. Lancer l'app Flutter : flutter run
echo    3. Créer vos propres données via l'interface
echo.
pause
