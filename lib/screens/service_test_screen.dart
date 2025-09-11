import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/api_client.dart';
import '../services/connectivity_service.dart';
import '../config/api_config.dart';

/// Écran de test pour vérifier le fonctionnement des services
class ServiceTestScreen extends StatefulWidget {
  const ServiceTestScreen({super.key});

  @override
  State<ServiceTestScreen> createState() => _ServiceTestScreenState();
}

class _ServiceTestScreenState extends State<ServiceTestScreen> {
  final List<TestResult> _testResults = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test des Services'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // En-tête avec informations
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration de l\'Application',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Mode développement: ${ApiConfig.isDevelopment}'),
                Text('Mode mock: ${ApiConfig.useMockData}'),
                Text('URL API: ${ApiConfig.baseUrlForEnvironment}'),
              ],
            ),
          ),
          
          // Boutons de test
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runAllTests,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Tous les Tests'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _clearResults,
                    icon: const Icon(Icons.clear),
                    label: const Text('Effacer'),
                  ),
                ),
              ],
            ),
          ),
          
          // Résultats des tests
          Expanded(
            child: ListView.builder(
              itemCount: _testResults.length,
              itemBuilder: (context, index) {
                final result = _testResults[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      result.success ? Icons.check_circle : Icons.error,
                      color: result.success ? Colors.green : Colors.red,
                    ),
                    title: Text(result.serviceName),
                    subtitle: Text(result.message),
                    trailing: result.duration != null
                        ? Text('${result.duration!.inMilliseconds}ms')
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    // Test de la base de données
    await _testDatabaseService();
    
    // Test du client API
    await _testApiClient();
    
    // Test de la connectivité
    await _testConnectivityService();
    
    // Test de l'authentification
    await _testAuthentication();

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _testDatabaseService() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final databaseService = DatabaseService.instance;
      
      // Test de sauvegarde d'un client
      final testClient = {
        'id': 'test_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Client Test',
        'email': 'test@example.com',
        'phone': '+33 1 23 45 67 89',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final saveResult = await databaseService.saveClient(testClient);
      if (!saveResult) throw Exception('Échec de la sauvegarde');
      
      // Test de récupération des clients
      final clients = await databaseService.getAllClients();
      if (clients.isEmpty) throw Exception('Aucun client trouvé');
      
      // Test des statistiques
      final stats = await databaseService.getStatistics();
      if (stats.isEmpty) throw Exception('Aucune statistique trouvée');
      
      stopwatch.stop();
      _addTestResult(
        'Base de Données',
        'Tous les tests de base de données ont réussi',
        true,
        stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      _addTestResult(
        'Base de Données',
        'Erreur: ${e.toString()}',
        false,
        stopwatch.elapsed,
      );
    }
  }

  Future<void> _testApiClient() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final apiClient = ApiClient.instance;
      
      // Test de santé de l'API
      final healthResponse = await apiClient.checkHealth();
      if (!healthResponse.isSuccess) throw Exception('API non accessible');
      
      // Test de récupération des clients
      final clientsResponse = await apiClient.getClients();
      if (!clientsResponse.isSuccess) throw Exception('Échec de récupération des clients');
      
      // Test de récupération des statistiques
      final statsResponse = await apiClient.getDashboardStats();
      if (!statsResponse.isSuccess) throw Exception('Échec de récupération des statistiques');
      
      stopwatch.stop();
      _addTestResult(
        'Client API',
        'Tous les tests API ont réussi',
        true,
        stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      _addTestResult(
        'Client API',
        'Erreur: ${e.toString()}',
        false,
        stopwatch.elapsed,
      );
    }
  }

  Future<void> _testConnectivityService() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final connectivityService = ConnectivityService.instance;
      
      // Test de connectivité
      final isConnected = await connectivityService.isConnected();
      if (!isConnected) throw Exception('Pas de connexion Internet');
      
      // Test du type de connexion
      final connectionType = await connectivityService.getConnectionType();
      if (connectionType.isEmpty) throw Exception('Type de connexion inconnu');
      
      // Test de ping
      final pingResult = await connectivityService.pingTest();
      if (!pingResult) throw Exception('Test de ping échoué');
      
      // Test des informations complètes
      final info = await connectivityService.getConnectivityInfo();
      if (info.isEmpty) throw Exception('Informations de connectivité manquantes');
      
      stopwatch.stop();
      _addTestResult(
        'Connectivité',
        'Connexion: $connectionType, Ping: ${pingResult ? "OK" : "Échec"}',
        true,
        stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      _addTestResult(
        'Connectivité',
        'Erreur: ${e.toString()}',
        false,
        stopwatch.elapsed,
      );
    }
  }

  Future<void> _testAuthentication() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final apiClient = ApiClient.instance;
      
      // Test de connexion avec des identifiants de test
      final loginResponse = await apiClient.login('admin@neo.com', 'admin123');
      if (!loginResponse.isSuccess) throw Exception('Échec de la connexion');
      
      stopwatch.stop();
      _addTestResult(
        'Authentification',
        'Connexion réussie avec les identifiants de test',
        true,
        stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      _addTestResult(
        'Authentification',
        'Erreur: ${e.toString()}',
        false,
        stopwatch.elapsed,
      );
    }
  }

  void _addTestResult(String serviceName, String message, bool success, Duration duration) {
    setState(() {
      _testResults.add(TestResult(
        serviceName: serviceName,
        message: message,
        success: success,
        duration: duration,
      ));
    });
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }
}

class TestResult {
  final String serviceName;
  final String message;
  final bool success;
  final Duration? duration;

  TestResult({
    required this.serviceName,
    required this.message,
    required this.success,
    this.duration,
  });
}


