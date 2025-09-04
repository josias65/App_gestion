import 'package:flutter/material.dart';
import '../database/simple_database_service.dart';

class SimpleDatabaseTestScreen extends StatefulWidget {
  const SimpleDatabaseTestScreen({super.key});

  @override
  State<SimpleDatabaseTestScreen> createState() => _SimpleDatabaseTestScreenState();
}

class _SimpleDatabaseTestScreenState extends State<SimpleDatabaseTestScreen> {
  final SimpleDatabaseService _dbService = SimpleDatabaseService.instance;
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

  Future<void> _testCreateCommande() async {
    setState(() => _isLoading = true);
    try {
      final success = await _dbService.createCommande({
        'client_id': '1',
        'reference': 'CMD-${DateTime.now().millisecondsSinceEpoch}',
        'date': DateTime.now().toIso8601String(),
        'status': 'En attente',
        'total': 150.0,
        'notes': 'Commande de test',
      });

      if (success) {
        _showSuccess('Commande créée avec succès');
        await _loadStatistics();
      } else {
        _showError('Échec de la création de la commande');
      }
    } catch (e) {
      _showError('Erreur lors de la création de la commande: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showClients() async {
    try {
      final clients = await _dbService.getClients();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Liste des Clients'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return ListTile(
                  title: Text(client['name']),
                  subtitle: Text(client['email']),
                  trailing: Text(client['phone'] ?? ''),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showError('Erreur lors de la récupération des clients: $e');
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
        title: const Text('Test Base de Données Simple'),
        actions: [
          IconButton(
            onPressed: _testSync,
            icon: const Icon(Icons.sync),
            tooltip: 'Synchroniser',
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
                                onPressed: _testCreateCommande,
                                icon: const Icon(Icons.shopping_cart),
                                label: const Text('Créer Commande'),
                              ),
                              ElevatedButton.icon(
                                onPressed: _showClients,
                                icon: const Icon(Icons.list),
                                label: const Text('Voir Clients'),
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
                  
                  const SizedBox(height: 16),
                  
                  // Informations
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Cette application utilise Hive pour le stockage local des données. '
                            'Les données sont synchronisées avec l\'API configurée dans api_config.dart.',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Fonctionnalités disponibles :',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          const Text('• Stockage local avec Hive'),
                          const Text('• Synchronisation avec API'),
                          const Text('• CRUD complet (Create, Read, Update, Delete)'),
                          const Text('• Statistiques en temps réel'),
                          const Text('• Recherche dans les données'),
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
