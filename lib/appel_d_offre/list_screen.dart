import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../routes/app_routes.dart';

class AppelsOffresScreen extends StatefulWidget {
  const AppelsOffresScreen({super.key});

  @override
  State<AppelsOffresScreen> createState() => _AppelsOffresScreenState();
}

class _AppelsOffresScreenState extends State<AppelsOffresScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _headerController;
  late Animation<double> _fabAnimation;
  late Animation<double> _headerAnimation;

  String _searchQuery = '';
  String _selectedFilter = 'Tous';
  bool _showFavorites = false;

  final List<String> _filters = [
    'Tous',
    'Ouvert',
    'Clôturé',
    'En cours',
    'Terminé',
  ];

  final List<Map<String, dynamic>> _appelsOffres = [
    {
      'id': 1,
      'titre': 'Acquisition de serveurs haute performance',
      'description':
          'Achat et installation de serveurs pour infrastructure informatique',
      'date': '21/07/2025',
      'etat': 'Ouvert',
      'budget': '5 000 000 FCFA',
      'categorie': 'Informatique',
      'soumissions': 12,
      'favori': false,
      'urgence': 'Haute',
      'localisation': 'Abidjan',
      'dateLimite': '30/08/2025',
      'documents': ['Cahier des charges', 'Spécifications techniques', 'Devis'],
    },
    {
      'id': 2,
      'titre': 'Déploiement d\'un réseau sécurisé pour datacenter',
      'description': 'Installation et configuration d\'un réseau sécurisé',
      'date': '18/07/2025',
      'etat': 'Clôturé',
      'budget': '3 500 000 FCFA',
      'categorie': 'Réseau',
      'soumissions': 8,
      'favori': true,
      'urgence': 'Moyenne',
      'localisation': 'Yamoussoukro',
      'dateLimite': '25/08/2025',
      'documents': ['Plan réseau', 'Sécurité', 'Maintenance'],
    },
    {
      'id': 3,
      'titre': 'Fourniture de matériel de bureau',
      'description': 'Achat de mobilier et équipements de bureau',
      'date': '25/07/2025',
      'etat': 'Ouvert',
      'budget': '2 000 000 FCFA',
      'categorie': 'Mobilier',
      'soumissions': 5,
      'favori': false,
      'urgence': 'Basse',
      'localisation': 'Bouaké',
      'dateLimite': '15/09/2025',
      'documents': ['Catalogue mobilier', 'Spécifications', 'Installation'],
    },
  ];

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  void _ajouterAppelOffre() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addAppelOffre);

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _appelsOffres.add(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouvel appel d\'offre ajouté avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _modifierAppelOffre(Map<String, dynamic> appel) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addAppelOffre,
      arguments: appel,
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final index = _appelsOffres.indexWhere((a) => a['id'] == appel['id']);
        if (index != -1) {
          _appelsOffres[index] = result;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appel d\'offre modifié avec succès'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _supprimerAppelOffre(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cet appel d\'offre ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _appelsOffres.removeWhere((appel) => appel['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appel d\'offre supprimé avec succès'),
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

  void _toggleFavorite(int id) {
    setState(() {
      final index = _appelsOffres.indexWhere((appel) => appel['id'] == id);
      if (index != -1) {
        _appelsOffres[index]['favori'] = !_appelsOffres[index]['favori'];
      }
    });
  }

  Color _getEtatColor(String etat) {
    switch (etat) {
      case 'Ouvert':
        return const Color(0xFF4CAF50);
      case 'Clôturé':
        return Colors.grey;
      case 'En cours':
        return const Color(0xFF2196F3);
      case 'Terminé':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> get _filteredAppels {
    return _appelsOffres.where((appel) {
      final matchesSearch =
          appel['titre'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          appel['description'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesFilter =
          _selectedFilter == 'Tous' || appel['etat'] == _selectedFilter;
      final matchesFavorites = !_showFavorites || appel['favori'] == true;

      return matchesSearch && matchesFilter && matchesFavorites;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.blue),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AnimatedBuilder(
            animation: _headerAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - _headerAnimation.value)),
                child: Opacity(
                  opacity: _headerAnimation.value.clamp(0.0, 1.0),
                  child: AppBar(
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    toolbarHeight: 80,
                    leading: Container(
                      margin: const EdgeInsets.only(
                        left: 16,
                        top: 8,
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    title: const Text(
                      'Appels d\'Offres',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
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
                      hintText: 'Rechercher un appel d\'offre...',
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
                        _buildFilterChip('Ouvert'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Clôturé'),
                        const SizedBox(width: 8),
                        _buildFilterChip('En cours'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Terminé'),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Favoris'),
                          selected: _showFavorites,
                          onSelected: (selected) {
                            setState(() {
                              _showFavorites = selected;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: const Color(
                            0xFF0F0465,
                          ).withOpacity(0.2),
                          checkmarkColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Liste des appels d'offres
            Expanded(
              child: _filteredAppels.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun appel d\'offre trouvé',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredAppels.length,
                      itemBuilder: (context, index) {
                        final appel = _filteredAppels[index];
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
                                AppRoutes.detailAppelOffre,
                                arguments: appel,
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
                                          color: _getEtatColor(
                                            appel['etat'],
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.assignment,
                                          color: _getEtatColor(appel['etat']),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              appel['titre'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              appel['categorie'],
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
                                                AppRoutes.detailAppelOffre,
                                                arguments: appel,
                                              );
                                              break;
                                            case 'edit':
                                              _modifierAppelOffre(appel);
                                              break;
                                            case 'delete':
                                              _supprimerAppelOffre(appel['id']);
                                              break;
                                            case 'favorite':
                                              _toggleFavorite(appel['id']);
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
                                          PopupMenuItem(
                                            value: 'favorite',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  appel['favori']
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: appel['favori']
                                                      ? Colors.red
                                                      : null,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  appel['favori']
                                                      ? 'Retirer des favoris'
                                                      : 'Ajouter aux favoris',
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
                                          appel['etat'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: _getEtatColor(
                                          appel['etat'],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        appel['budget'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF0F0465),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    appel['description'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Date limite: ${appel['dateLimite']}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        appel['localisation'],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
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
        floatingActionButton: AnimatedBuilder(
          animation: _fabAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabAnimation.value,
              child: FloatingActionButton.extended(
                onPressed: _ajouterAppelOffre,
                backgroundColor: const Color(0xFF4CAF50),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Nouvel appel d\'offre',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          },
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
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }
}
