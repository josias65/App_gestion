import 'package:flutter/material.dart';
import '../services/backend_tester.dart';
import '../services/connectivity_service.dart';

class TestBackendScreen extends StatefulWidget {
  const TestBackendScreen({super.key});

  @override
  State<TestBackendScreen> createState() => _TestBackendScreenState();
}

class _TestBackendScreenState extends State<TestBackendScreen> {
  bool _isLoading = false;
  String _testResults = '';
  String _endpointResults = '';
  Map<String, dynamic>? _connectionStatus;
  Map<String, dynamic>? _authStatus;
  Map<String, dynamic>? _endpointsStatus;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResults = '';
      _connectionStatus = null;
    });

    try {
      final result = await ConnectivityService.testConnection();
      setState(() {
        _connectionStatus = result;
        _testResults = result['success'] 
          ? '✅ ${result['message']}\n📊 Données: ${result['data']}'
          : '❌ ${result['message']}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResults = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testAuthentication() async {
    setState(() {
      _isLoading = true;
      _authStatus = null;
    });

    try {
      final result = await ConnectivityService.testAuthentication();
      setState(() {
        _authStatus = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _authStatus = {'success': false, 'message': 'Erreur: $e'};
        _isLoading = false;
      });
    }
  }

  Future<void> _testAllEndpoints() async {
    setState(() {
      _isLoading = true;
      _endpointsStatus = null;
    });

    try {
      final result = await ConnectivityService.testAllEndpoints();
      setState(() {
        _endpointsStatus = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _endpointsStatus = {'success': false, 'message': 'Erreur: $e'};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Backend'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration Backend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('URL: http://10.0.2.2:8000'),
                    const Text('Utilisateurs de test:'),
                    const Text('• admin@neo.com / admin123'),
                    const Text('• test@example.com / password123'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _testConnection,
                            icon: const Icon(Icons.wifi),
                            label: const Text('Test Connexion'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _testAuthentication,
                            icon: const Icon(Icons.lock),
                            label: const Text('Test Auth'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testAllEndpoints,
                        icon: const Icon(Icons.api),
                        label: const Text('Test Tous les Endpoints'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Test en cours...'),
                  ],
                ),
              ),
            // Affichage des résultats de connexion
            if (_connectionStatus != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _connectionStatus!['success'] ? Icons.check_circle : Icons.error,
                            color: _connectionStatus!['success'] ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Test de Connexion',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _connectionStatus!['message'],
                        style: TextStyle(
                          color: _connectionStatus!['success'] ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Affichage des résultats d'authentification
            if (_authStatus != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _authStatus!['success'] ? Icons.check_circle : Icons.error,
                            color: _authStatus!['success'] ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Test d\'Authentification',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _authStatus!['message'],
                        style: TextStyle(
                          color: _authStatus!['success'] ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Affichage des résultats des endpoints
            if (_endpointsStatus != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _endpointsStatus!['success'] ? Icons.check_circle : Icons.error,
                              color: _endpointsStatus!['success'] ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Test des Endpoints',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_endpointsStatus!['message']),
                        const SizedBox(height: 16),
                        if (_endpointsStatus!['data'] != null)
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: (_endpointsStatus!['data'] as Map<String, dynamic>)
                                    .entries
                                    .map((entry) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            children: [
                                              Icon(
                                                entry.value['success'] ? Icons.check : Icons.close,
                                                color: entry.value['success'] ? Colors.green : Colors.red,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text('${entry.key}: ${entry.value['message']}'),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Démarrez le backend avec start-backend.bat'),
                    const Text('2. Vérifiez que le serveur écoute sur le port 8000'),
                    const Text('3. Lancez les tests ci-dessus'),
                    const Text('4. Vérifiez les résultats dans les logs'),
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
