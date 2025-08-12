import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  final List<Map<String, dynamic>> _materiels = [
    {
      'id': 1,
      'nom': 'Ordinateur Portable HP',
      'reference': 'HP-LAPTOP-01',
      'quantite': 8,
      'prixUnitaire': 350000,
      'seuilMin': 5,
      'type': 'PC',
      'marque': 'HP',
      'modele': 'Pavilion',
      'etat': 'Neuf',
      'dateEntree': '2024-01-15',
    },
    {
      'id': 2,
      'nom': 'Imprimante Canon',
      'reference': 'CAN-PRNT-2023',
      'quantite': 3,
      'prixUnitaire': 150000,
      'seuilMin': 2,
      'type': 'Imprimante',
      'marque': 'Canon',
      'modele': 'Pixma',
      'etat': 'Bon état',
      'dateEntree': '2024-02-10',
    },
    {
      'id': 3,
      'nom': 'Routeur TP-Link',
      'reference': 'TPL-ROUTER-AX1800',
      'quantite': 10,
      'prixUnitaire': 55000,
      'seuilMin': 4,
      'type': 'Routeur',
      'marque': 'TP-Link',
      'modele': 'AX1800',
      'etat': 'Neuf',
      'dateEntree': '2024-03-05',
    },
    {
      'id': 4,
      'nom': 'Clavier mécanique',
      'reference': 'KBD-MECH-05',
      'quantite': 1,
      'prixUnitaire': 45000,
      'seuilMin': 3,
      'type': 'Clavier',
      'marque': 'Logitech',
      'modele': 'G Pro',
      'etat': 'Neuf',
      'dateEntree': '2024-01-20',
    },
  ];

  String _searchQuery = '';
  String _selectedFilter = 'Tous';
  bool _showLowStock = false;

  // ignore: unused_field
  final List<String> _filters = [
    'Tous',
    'PC',
    'Imprimante',
    'Routeur',
    'Switch',
    'Serveur',
    'Écran',
    'Clavier',
    'Souris',
  ];

  void _ajouterArticle() async {
    final result = await Navigator.pushNamed<Map<String, dynamic>>(
      context,
      AppRoutes.addStock,
    );

    if (result != null) {
      setState(() {
        _materiels.add(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result['nom']} a été ajouté au stock'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _modifierArticle(Map<String, dynamic> article) async {
    final result = await Navigator.pushNamed<Map<String, dynamic>>(
      context,
      AppRoutes.stockEdit,
      arguments: article,
    );

    if (result != null) {
      setState(() {
        final index = _materiels.indexWhere(
          (item) => item['id'] == article['id'],
        );
        if (index != -1) {
          _materiels[index] = result;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result['nom']} a été modifié avec succès'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _supprimerArticle(int id) {
    final article = _materiels.firstWhere((item) => item['id'] == id);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${article['nom']}" du stock ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _materiels.removeWhere((item) => item['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${article['nom']} a été supprimé du stock'),
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

  void _voirDetails(Map<String, dynamic> article) async {
    final result = await Navigator.pushNamed<Map<String, dynamic>>(
      context,
      AppRoutes.stockDetail,
      arguments: article,
    );

    if (result != null) {
      // Si l'article a été modifié depuis les détails
      setState(() {
        final index = _materiels.indexWhere(
          (item) => item['id'] == article['id'],
        );
        if (index != -1) {
          _materiels[index] = result;
        }
      });
    }
  }

  List<Map<String, dynamic>> get _filteredMateriels {
    return _materiels.where((item) {
      final matchesSearch =
          item['nom'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item['reference'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item['marque'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesFilter =
          _selectedFilter == 'Tous' || item['type'] == _selectedFilter;
      final matchesLowStock =
          !_showLowStock || (item['quantite'] <= item['seuilMin']);

      return matchesSearch && matchesFilter && matchesLowStock;
    }).toList();
  }

  Color _getStockColor(int quantite, int seuilMin) {
    if (quantite <= seuilMin) {
      return Colors.red;
    } else if (quantite <= seuilMin * 2) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Stock Informatique',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: 'Ajouter un article',
            onPressed: _ajouterArticle,
          ),
        ],
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
                    hintText: 'Rechercher un article...',
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
                      _buildFilterChip('Tous'),
                      const SizedBox(width: 8),
                      _buildFilterChip('PC'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Imprimante'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Routeur'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Switch'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Serveur'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Écran'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Clavier'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Souris'),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Stock faible'),
                        selected: _showLowStock,
                        onSelected: (selected) {
                          setState(() {
                            _showLowStock = selected;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.red.withOpacity(0.2),
                        checkmarkColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Liste des articles
          Expanded(
            child: _filteredMateriels.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucun article trouvé',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredMateriels.length,
                    itemBuilder: (context, index) {
                      final item = _filteredMateriels[index];
                      final quantite = item['quantite'] as int;
                      final seuilMin = item['seuilMin'] as int;
                      final enRupture = quantite <= seuilMin;
                      final stockColor = _getStockColor(quantite, seuilMin);

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: enRupture
                              ? const BorderSide(color: Colors.red, width: 2)
                              : BorderSide.none,
                        ),
                        child: InkWell(
                          onTap: () => _voirDetails(item),
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
                                        color: stockColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        enRupture
                                            ? Icons.warning_amber
                                            : Icons.inventory_2_outlined,
                                        color: stockColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['nom'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${item['marque']} ${item['modele']}',
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
                                            _voirDetails(item);
                                            break;
                                          case 'edit':
                                            _modifierArticle(item);
                                            break;
                                          case 'delete':
                                            _supprimerArticle(item['id']);
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
                                        item['type'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF1976D2),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${item['prixUnitaire']} FCFA',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.inventory_2,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Quantité: ${item['quantite']}',
                                      style: TextStyle(
                                        color: stockColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Réf: ${item['reference']}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                if (enRupture) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Stock faible ! Seuil: ${item['seuilMin']}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
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
        onPressed: _ajouterArticle,
        label: const Text(
          'Nouvel article',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF1976D2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
