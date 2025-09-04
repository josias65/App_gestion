# Nettoyage du projet Flutter

Ce projet a été nettoyé pour ne conserver que les fichiers essentiels liés à l'authentification.

## Fichiers conservés

- `lib/config/`
  - `api_config.dart`
  - `app_config.dart`
- `lib/models/`
  - `user_model.dart`
- `lib/providers/`
  - `auth_provider.dart`
- `lib/screens/`
  - `auth/login_screen.dart`
  - `home/home_screen.dart`
- `lib/services/`
  - `auth_service_new.dart`
- `lib/widgets/`
  - `app_bar.dart`
  - `custom_text_field.dart`
  - `primary_button.dart`
- `lib/main.dart`

## Comment utiliser le script de nettoyage

1. **Sauvegardez votre travail** avant de procéder.
2. **Exécutez le script PowerShell** en tant qu'administrateur :
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\cleanup.ps1
   ```
3. Le script va :
   - Créer une sauvegarde complète dans un dossier `backup_<date>`
   - Supprimer les dossiers et fichiers inutiles
   - Nettoyer les fichiers système indésirables

## Prochaines étapes

1. Vérifiez que tout fonctionne correctement :
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. Si tout est bon, vous pouvez supprimer le dossier de sauvegarde.

3. Si quelque chose ne va pas, restaurez les fichiers depuis le dossier de sauvegarde.

## Remarques

- Le script ne modifie pas les fichiers en dehors du dossier `lib/`
- Les dépendances dans `pubspec.yaml` ne sont pas modifiées
- Les fichiers de configuration Android/iOS ne sont pas affectés
