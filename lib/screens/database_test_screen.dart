import 'package:flutter/material.dart';
import '../services/unified_database_service.dart';
import '../database/sync_service.dart';
import '../widgets/sync_status_widget.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  final UnifiedDatabaseService _dbService = UnifiedDatabaseService.instance;
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _dbService.getStatistics();
      setState(() => _statistics = stats);
    } catch (e) {
      _showError('Erreur lors du chargement des statistiques: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testSync() async {
    setState(() => _isLoading = true);
    try {
      await _dbService.syncAll();
      await _loadStatistics();
      _showSuccess('Synchronisation terminée avec succès');
    } catch (e) {
      _showError('Erreur lors de la synchronisation: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testCreateClient() async {
    setState(() => _isLoading = true);
    try {
      final success = await _dbService.createClient({
        'name': 'Client Test ${DateTime.now().millisecondsSinceEpoch}',
        'email': 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        'phone': '+1234567890',
        'address': '123 Test Street',
        'city': 'Test City',
        'country': 'Test Country',
      });

      if (success) {
        _showSuccess('Client créé avec succès');
        await _loadStatistics();
      } else {
        _showError('Échec de la création du client');
      }
    } catch (e) {
      _showError('Erreur lors de la création du client: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testCreateArticle() async {
    setState(() => _isLoading = true);
    try {
      final success = await _dbService.createArticle({
        'name': 'Article Test ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'Description de l\'article test',
        'price': 99.99,
        'quantity': 10,
        'unit': 'pièce',
        'category': 'Test',
      });

      if (success) {
        _showSuccess('Article créé avec succès');
        await _loadStatistics();
      } else {
        _showError('Échec de la création de l\'article');
      }
    } catch (e) {
      _showError('Erreur lors de la création de l\'article: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Base de Données'),
        actions: [
          const SyncStatusWidget(showDetails: true),
          const SizedBox(width: 8),
          SyncButton(
            isOnline: _dbService.isOnline,
            isSyncing: _dbService.isSyncing,
            onPressed: _testSync,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statut de connexion
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statut de Connexion',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _dbService.isOnline ? Icons.wifi : Icons.wifi_off,
                                color: _dbService.isOnline ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _dbService.isOnline ? 'En ligne' : 'Hors ligne',
                                style: TextStyle(
                                  color: _dbService.isOnline ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _dbService.isSyncing ? Icons.sync : Icons.sync_disabled,
                                color: _dbService.isSyncing ? Colors.orange : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _dbService.isSyncing ? 'Synchronisation en cours...' : 'Synchronisation inactive',
                                style: TextStyle(
                                  color: _dbService.isSyncing ? Colors.orange : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Statistiques
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statistiques',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_statistics.isNotEmpty) ...[
                            _buildStatItem('Clients', _statistics['total_clients']?.toString() ?? '0'),
                            _buildStatItem('Articles', _statistics['total_articles']?.toString() ?? '0'),
                            _buildStatItem('Commandes', _statistics['total_commandes']?.toString() ?? '0'),
                            _buildStatItem('Factures', _statistics['total_factures']?.toString() ?? '0'),
                            _buildStatItem('Devis', _statistics['total_devis']?.toString() ?? '0'),
                            const Divider(),
                            _buildStatItem('Chiffre d\'affaires', '${_statistics['total_revenue']?.toStringAsFixed(2) ?? '0.00'} €'),
                            _buildStatItem('Montant payé', '${_statistics['total_paid']?.toStringAsFixed(2) ?? '0.00'} €'),
                            _buildStatItem('Montant en attente', '${_statistics['pending_amount']?.toStringAsFixed(2) ?? '0.00'} €'),
                            if (_statistics['last_sync'] != null) ...[
                              const Divider(),
                              _buildStatItem('Dernière sync', _formatLastSync(_statistics['last_sync'])),
                            ],
                          ] else
                            const Text('Aucune donnée disponible'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Boutons de test
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tests de Base de Données',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _testSync,
                                icon: const Icon(Icons.sync),
                                label: const Text('Synchroniser'),
                              ),
                              ElevatedButton.icon(
                                onPressed: _testCreateClient,
                                icon: const Icon(Icons.person_add),
                                label: const Text('Créer Client'),
                              ),
                              ElevatedButton.icon(
                                onPressed: _testCreateArticle,
                                icon: const Icon(Icons.add_box),
                                label: const Text('Créer Article'),
                              ),
                              ElevatedButton.icon(
                                onPressed: _loadStatistics,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Actualiser'),
                              ),
                            ],
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

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatLastSync(String lastSync) {
    try {
      final date = DateTime.parse(lastSync);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 1) {
        return 'À l\'instant';
      } else if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes}min';
      } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours}h';
      } else {
        return 'Il y a ${difference.inDays}j';
      }
    } catch (e) {
      return 'Inconnu';
    }
  }
}
