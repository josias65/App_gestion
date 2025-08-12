import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Données de l'utilisateur (à rendre dynamiques si besoin)
    const String nomUtilisateur = "Josias KING";
    const String email = "admin@neo.com";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: const Color(0xFF0F0465),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF0F0465),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              nomUtilisateur,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Divider(),

            /// Modifier mot de passe
            ListTile(
              leading: const Icon(Icons.lock_outline, color: Color(0xFF0F0465)),
              title: const Text("Changer le mot de passe"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/change-password',
                ); // À adapter à ta route réelle
              },
            ),
            const Divider(),

            /// Paramètres
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF0F0465)),
              title: const Text("Paramètres de l’application"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/settings',
                ); // À adapter à ta route réelle
              },
            ),
            const Divider(),

            const SizedBox(height: 30),

            /// Déconnexion
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Confirmation"),
                    content: const Text(
                      "Voulez-vous vraiment vous déconnecter ?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Annuler"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text("Se déconnecter"),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Se déconnecter"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
