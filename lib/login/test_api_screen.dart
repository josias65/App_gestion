import 'package:flutter/material.dart';
import '../services/test_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({super.key});

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  final TestService _testService = TestService();
  // ignore: unused_field
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _testResults;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API'),
        backgroundColor: const Color(0xFF0F0465),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configuration actuelle
            _buildConfigCard(),
            const SizedBox(height: 16),
            
            // Bouton de test
            _buildTestButton(),
            const SizedBox(height: 16),
            
            // Résultats des tests
            if (_testResults != null) _buildResultsCard(),
            
            // Erreur
            if (_error != null) _buildErrorCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration actuelle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('URL de base: ${ApiConfig.baseUrlForEnvironment}'),
            Text('Mode développement: ${ApiConfig.isDevelopment}'),
            Text('Timeout: ${ApiConfig.requestTimeout.inSeconds}s'),
            const SizedBox(height: 8),
            const Text(
              'Endpoints:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Login: ${ApiConfig.loginEndpoint}'),
            Text('• Register: ${ApiConfig.registerEndpoint}'),
            Text('• Refresh: ${ApiConfig.refreshEndpoint}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _runTests,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F0465),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
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
                  Text('Tests en cours...'),
                ],
              )
            : const Text(
                'Lancer les tests',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résultats des tests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Test de connectivité
            _buildTestResult(
              'Connectivité',
              _testResults!['connectivity'] ?? false,
              'Test de connexion à l\'API',
            ),
            
            // Test JSONPlaceholder
            _buildTestResult(
              'JSONPlaceholder',
              _testResults!['jsonPlaceholder'] ?? false,
              'Test avec API publique',
            ),
            
            // Test authentification simulée
            _buildTestResult(
              'Auth Simulation',
              _testResults!['authSimulation']?['success'] ?? false,
              'Test d\'authentification simulée',
            ),
            
            // Test votre API
            _buildTestResult(
              'Votre API',
              _testResults!['yourApi']?['success'] ?? false,
              'Test de votre API spécifique',
            ),
            
            const SizedBox(height: 16),
            
            // Résumé
            if (_testResults!['summary'] != null) _buildSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResult(String title, bool success, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final summary = _testResults!['summary'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Résumé',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  '${summary['successCount']}/${summary['totalTests']} tests réussis (${summary['successRate']})',
                  style: TextStyle(
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _testResults = null;
      _error = null;
    });

    try {
      final results = await _testService.runFullTest();
      
      setState(() {
        _testResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors des tests: $e';
        _isLoading = false;
      });
    }
  }
}
