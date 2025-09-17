import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/appel_offre_service.dart';
import '../widgets/appel_offre_widgets.dart';

class TestAppelOffreScreen extends StatefulWidget {
  const TestAppelOffreScreen({super.key});

  @override
  State<TestAppelOffreScreen> createState() => _TestAppelOffreScreenState();
}

class _TestAppelOffreScreenState extends State<TestAppelOffreScreen> {
  final AppelOffreService _service = AppelOffreService();
  bool _isLoading = false;
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _appelsOffre = [];
  String _selectedTab = 'list';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Charger les appels d'offre
      final appelsResponse = await _service.getAppelsOffre(limit: 20);
      if (appelsResponse['success']) {
        setState(() {
          _appelsOffre = List<Map<String, dynamic>>.from(appelsResponse['data'] ?? []);
        });
      }

      // Charger les statistiques
      final statsResponse = await _service.getDetailedStats();
      if (statsResponse['success']) {
        setState(() {
          _stats = statsResponse['data'];
        });
      }
    } catch (e) {
      _showError('Erreur lors du chargement: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Appels d\'Offre'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Onglets
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTab('list', 'Liste', Icons.list),
                      ),
                      Expanded(
                        child: _buildTab('stats', 'Statistiques', Icons.analytics),
                      ),
                      Expanded(
                        child: _buildTab('test', 'Tests', Icons.science),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Contenu
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildTab(String tab, String label, IconData icon) {
    final isSelected = _selectedTab == tab;
    return InkWell(
      onTap: () => setState(() => _selectedTab = tab),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : null,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 20,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'list':
        return _buildListTab();
      case 'stats':
        return _buildStatsTab();
      case 'test':
        return _buildTestTab();
      default:
        return const Center(child: Text('Onglet non trouvé'));
    }
  }

  Widget _buildListTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _appelsOffre.length,
      itemBuilder: (context, index) {
        final appel = _appelsOffre[index];
        return AppelOffreCard(
          appelOffre: appel,
          onTap: () => _viewAppelOffre(appel),
          onEdit: () => _editAppelOffre(appel),
          onDelete: () => _deleteAppelOffre(appel['id']),
          onFavorite: () => _toggleFavorite(appel),
          onShare: () => _shareAppelOffre(appel),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    if (_stats == null) {
      return const Center(child: Text('Aucune statistique disponible'));
    }

    final general = _stats!['general'];
    final financial = _stats!['financial'];
    final soumissions = _stats!['soumissions'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques générales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistiques Générales',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Total appels d\'offre', general['total']?.toString() ?? '0'),
                  _buildStatRow('Appels ouverts', general['statusBreakdown']
                      ?.firstWhere((s) => s['status'] == 'open', orElse: () => {'count': 0})['count']?.toString() ?? '0'),
                  _buildStatRow('Total soumissions', soumissions['total_soumissions']?.toString() ?? '0'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistiques financières
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistiques Financières',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Budget total', _formatCurrency(financial['total_budget'])),
                  _buildStatRow('Budget moyen', _formatCurrency(financial['avg_budget'])),
                  _buildStatRow('Budget minimum', _formatCurrency(financial['min_budget'])),
                  _buildStatRow('Budget maximum', _formatCurrency(financial['max_budget'])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Répartition par statut
          if (general['statusBreakdown'] != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Répartition par Statut',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...general['statusBreakdown'].map<Widget>((status) =>
                      _buildStatRow(status['status'], status['count']?.toString() ?? '0')
                    ).toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0 FCFA';
    final num = double.tryParse(amount.toString());
    if (num == null) return '0 FCFA';
    
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M FCFA';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(0)}K FCFA';
    } else {
      return '${num.toStringAsFixed(0)} FCFA';
    }
  }

  Widget _buildTestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tests des Fonctionnalités',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Test de création d'appel d'offre
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Création Appel d\'Offre',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _testCreateAppelOffre,
                    child: const Text('Créer un appel d\'offre test'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Test de soumission
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Soumission',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _appelsOffre.isNotEmpty ? _testSubmitOffer : null,
                    child: const Text('Soumettre une offre test'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Test de commentaire
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Commentaire',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _appelsOffre.isNotEmpty ? _testAddComment : null,
                    child: const Text('Ajouter un commentaire test'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Test d'export
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Export',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _testExportData,
                    child: const Text('Exporter les données (CSV)'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Informations de debug
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations de Debug',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('URL API: ${ApiConfig.baseUrlForEnvironment}'),
                  Text('Appels d\'offre chargés: ${_appelsOffre.length}'),
                  Text('Statistiques disponibles: ${_stats != null ? 'Oui' : 'Non'}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewAppelOffre(Map<String, dynamic> appel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appel['title'] ?? appel['titre'] ?? 'Appel d\'offre'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: ${appel['description'] ?? 'Non spécifiée'}'),
              const SizedBox(height: 8),
              Text('Budget: ${appel['budget'] ?? 'Non spécifié'}'),
              const SizedBox(height: 8),
              Text('Statut: ${appel['status'] ?? appel['etat'] ?? 'Inconnu'}'),
              const SizedBox(height: 8),
              Text('Catégorie: ${appel['category'] ?? appel['categorie'] ?? 'Non spécifiée'}'),
              const SizedBox(height: 8),
              Text('Localisation: ${appel['location'] ?? appel['localisation'] ?? 'Non spécifiée'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _editAppelOffre(Map<String, dynamic> appel) {
    _showSuccess('Édition de l\'appel d\'offre: ${appel['title'] ?? appel['titre']}');
  }

  void _deleteAppelOffre(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet appel d\'offre ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _service.deleteAppelOffre(id);
                _showSuccess('Appel d\'offre supprimé avec succès');
                _loadData();
              } catch (e) {
                _showError('Erreur lors de la suppression: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(Map<String, dynamic> appel) {
    _showSuccess('Favori ${appel['favorite'] == true ? 'retiré' : 'ajouté'}');
  }

  void _shareAppelOffre(Map<String, dynamic> appel) {
    _showSuccess('Partage de l\'appel d\'offre: ${appel['title'] ?? appel['titre']}');
  }

  void _testCreateAppelOffre() async {
    try {
      final testData = {
        'title': 'Test Appel d\'Offre ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'Ceci est un appel d\'offre de test créé automatiquement',
        'budget': 1500000,
        'category': 'Test',
        'location': 'Abidjan',
        'urgency': 'normale',
        'deadline': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'criteria': [
          {'name': 'Prix', 'description': 'Compétitivité du prix', 'weight': 40},
          {'name': 'Qualité', 'description': 'Qualité de la solution', 'weight': 35},
          {'name': 'Délai', 'description': 'Respect des délais', 'weight': 25},
        ],
      };

      final result = await _service.createAppelOffre(testData);
      if (result['success']) {
        _showSuccess('Appel d\'offre test créé avec succès');
        _loadData();
      } else {
        _showError('Erreur: ${result['message']}');
      }
    } catch (e) {
      _showError('Erreur lors de la création: $e');
    }
  }

  void _testSubmitOffer() async {
    if (_appelsOffre.isEmpty) return;

    try {
      final testData = {
        'customer_id': 1, // ID du client test
        'amount': 1200000,
        'notes': 'Offre de test soumise automatiquement',
        'delivery_time': '30 jours',
        'warranty': '2 ans',
      };

      final result = await _service.submitOffer(_appelsOffre.first['id'], testData);
      if (result['success']) {
        _showSuccess('Offre test soumise avec succès');
        _loadData();
      } else {
        _showError('Erreur: ${result['message']}');
      }
    } catch (e) {
      _showError('Erreur lors de la soumission: $e');
    }
  }

  void _testAddComment() async {
    if (_appelsOffre.isEmpty) return;

    try {
      final result = await _service.addComment(
        _appelsOffre.first['id'], 
        'Commentaire de test ajouté automatiquement à ${DateTime.now().toString()}'
      );
      if (result['success']) {
        _showSuccess('Commentaire test ajouté avec succès');
        _loadData();
      } else {
        _showError('Erreur: ${result['message']}');
      }
    } catch (e) {
      _showError('Erreur lors de l\'ajout du commentaire: $e');
    }
  }

  void _testExportData() async {
    try {
      final data = await _service.exportData('csv');
      _showSuccess('Export CSV généré avec succès (${data.length} bytes)');
    } catch (e) {
      _showError('Erreur lors de l\'export: $e');
    }
  }
}
