import 'package:shared_preferences/shared_preferences.dart';

// Script pour nettoyer les données d'authentification
Future<void> clearAuthData() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Supprimer toutes les clés d'authentification
  await prefs.remove('auth_token');
  await prefs.remove('refresh_token');
  await prefs.remove('user_data');
  await prefs.remove('token'); // Ancienne clé
  
  print('Données d\'authentification nettoyées avec succès !');
  print('Redémarrez l\'application pour voir l\'écran de login.');
}

// Pour tester, exécutez cette fonction
void main() async {
  await clearAuthData();
}
