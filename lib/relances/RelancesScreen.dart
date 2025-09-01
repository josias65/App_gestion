import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class RelancesScreen extends StatefulWidget {
  const RelancesScreen({super.key});

  @override
  State<RelancesScreen> createState() => _RelancesScreenState();
}

class _RelancesScreenState extends State<RelancesScreen> {
  // Liste des relances avec des données plus complètes
  List<Map<String, dynamic>> _relances = [
    {
      'id': 1,
      'client': 'Marc KPELOU',
      'date': '2025-07-20',
      'montant': '350',
      'statut': 'En attente',
      'factureId': 'FAC-001',
      'commentaire': 'Relance pour facture en retard',
    },
    {
      'id': 2,
      'client': 'Mouss SISOKO',
      'date': '2025-07-22',
      'montant': '1200',
      'statut': 'Relancé',
      'factureId': 'FAC-002',
      'commentaire': 'Deuxième relance envoyée',
    },
    {
      'id': 3,
      'client': 'Paul TEGE',
      'date': '2025-07-23',
      'montant': '500',
      'statut': 'Payé',
      'factureId': 'FAC-003',
      'commentaire': 'Paiement reçu',
    },
  ];

  String _searchQuery = '';
  String _selectedFilter = 'Toutes';

  void _ajouterRelance() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addRelance);

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _relances.add(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouvelle relance ajoutée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _modifierRelance(Map<String, dynamic> relance) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.editRelance,
      arguments: relance,
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final index = _relances.indexWhere((r) => r['id'] == relance['id']);
        if (index != -1) {
          _relances[index] = result;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relance modifiée avec succès'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _supprimerRelance(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette relance ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _relances.removeWhere((relance) => relance['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Relance supprimée avec succès'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _markAsPaid(int index) {
    setState(() {
      _relances[index]['statut'] = 'Payé';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'La relance pour ${_relances[index]['client']} a été marquée comme Payée.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _relaunch(int index) {
    setState(() {
      _relances[index]['statut'] = 'Relancé';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'La relance pour ${_relances[index]['client']} a été traitée et relancée.',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Color _getChipColor(String statut) {
    switch (statut) {
      case 'En attente':
        return Colors.blue;
      case 'Relancé':
        return Colors.orange;
      case 'Payé':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> get _filteredRelances {
    var filtered = _relances.where((relance) {
      final nom = relance['client'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return nom.contains(query);
    }).toList();

    if (_selectedFilter != 'Toutes') {
      filtered = filtered
          .where((relance) => relance['statut'] == _selectedFilter)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Gestion des Relances',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom de client...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                // Filtres
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Toutes'),
                      const SizedBox(width: 8),
                      _buildFilterChip('En attente'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Relancé'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Payé'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Liste des relances
          Expanded(
            child: _filteredRelances.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notification_important_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucune relance trouvée',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredRelances.length,
                    itemBuilder: (context, index) {
                      final relance = _filteredRelances[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.detailRelance,
                              arguments: relance,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _getChipColor(
                                          relance['statut'],
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.notification_important,
                                        color: _getChipColor(relance['statut']),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            relance['client'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Facture: ${relance['factureId']}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'detail':
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.detailRelance,
                                              arguments: relance,
                                            );
                                            break;
                                          case 'edit':
                                            _modifierRelance(relance);
                                            break;
                                          case 'delete':
                                            _supprimerRelance(relance['id']);
                                            break;
                                          case 'paid':
                                            _markAsPaid(index);
                                            break;
                                          case 'relaunch':
                                            _relaunch(index);
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'detail',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility),
                                              SizedBox(width: 8),
                                              Text('Voir détails'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('Modifier'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'paid',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Marquer payé',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'relaunch',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.refresh,
                                                color: Colors.orange,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Relancer',
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Supprimer',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      child: const Icon(Icons.more_vert),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                        relance['statut'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: _getChipColor(
                                        relance['statut'],
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${relance['montant']} FCFA',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Date: ${relance['date']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterRelance,
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouvelle relance',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1976D2).withOpacity(0.2),
      checkmarkColor: const Color(0xFF1976D2),
    );
  }
}
