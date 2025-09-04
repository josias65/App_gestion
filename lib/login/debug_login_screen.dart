import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class DebugLoginScreen extends StatefulWidget {
  const DebugLoginScreen({super.key});

  @override
  State<DebugLoginScreen> createState() => _DebugLoginScreenState();
}

class _DebugLoginScreenState extends State<DebugLoginScreen> {
  final emailController = TextEditingController(text: 'test@example.com');
  final passwordController = TextEditingController(text: 'password123');
  bool isLoading = false;
  String? debugInfo;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _testLogin() async {
    setState(() {
      isLoading = true;
      debugInfo = null;
      errorMessage = null;
    });

    try {
      final authService = AuthService();

      debugInfo = 'Tentative de connexion...\n';
      debugInfo = 'Email: ${emailController.text}\n';
      debugInfo = 'Mot de passe: ${passwordController.text}\n\n';

      final result = await authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (result.success) {
        debugInfo = '✅ Connexion réussie!\n';
        if (result.user != null) {
          final user = result.user!;
          debugInfo = '${debugInfo}Utilisateur: ${user.name}\n';
          debugInfo = '${debugInfo}Email: ${user.email}\n';
        }

        final token = await authService.getToken();
        if (token != null) {
          debugInfo = '${debugInfo}Token: ${token.length > 20 ? '${token.substring(0, 20)}...' : token}\n';
        }

        final isLoggedIn = await authService.isLoggedIn();
        debugInfo = '${debugInfo}Est connecté: $isLoggedIn\n';
      } else {
        errorMessage = '❌ Erreur: ${result.message}';
      }
    } catch (e) {
      errorMessage = '❌ Exception: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Connexion'),
        backgroundColor: const Color(0xFF0F0465),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations de test
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Credentials de test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Email: test@example.com'),
                    const Text('Mot de passe: password123'),
                    const SizedBox(height: 8),
                    const Text('OU'),
                    const SizedBox(height: 8),
                    const Text('Email: admin@neo.com'),
                    const Text('Mot de passe: admin123'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Champs de saisie
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 24),

            // Bouton de test
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _testLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F0465),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Test en cours...'),
                        ],
                      )
                    : const Text(
                        'Tester Connexion',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Informations de débogage
            if (debugInfo != null)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Informations de débogage',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        debugInfo!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Messages d'erreur
            if (errorMessage != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Erreur',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
