import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class MarcheListScreen extends StatefulWidget {
  const MarcheListScreen({Key? key}) : super(key: key);

  @override
  State<MarcheListScreen> createState() => _MarcheListScreenState();
}

class _MarcheListScreenState extends State<MarcheListScreen> {
  final List<Map<String, dynamic>> _marches = [
    {
      'id': 'marche_001',
      'nom': 'Création d\'une application mobile',
      'statut': 'En cours',
      'date_debut': '2025-07-20',
      'date_fin': '2025-12-31',
      'budget': 500000.00,
      'description': 'Application mobile pour la gestion de projets.',
      'soumission_date_limite': '2025-08-30',
      'documents': [
        'Cahier des charges',
        'Maquettes UI/UX',
        'Plan de développement',
      ],
    },
    {
      'id': 'marche_002',
      'nom': 'Fourniture de matériel informatique',
      'statut': 'Terminé',
      'date_debut': '2025-05-10',
      'date_fin': '2025-06-30',
      'budget': 75000.00,
      'description': 'Livraison de 200 PC et équipements réseau.',
      'soumission_date_limite': '2025-05-25',
      'documents': ['Spécifications techniques', 'Devis détaillé', 'Garantie'],
    },
    {
      'id': 'marche_003',
      'nom': 'Création d\'un site e-commerce',
      'statut': 'En attente',
      'date_debut': '2025-09-01',
      'date_fin': '2026-01-15',
      'budget': 35000.00,
      'description': 'Site de vente en ligne pour PME.',
      'soumission_date_limite': '2025-08-15',
      'documents': ['Cahier des charges', 'Maquettes', 'Plan de déploiement'],
    },
  ];

  Color _getChipColor(String statut) {
    switch (statut) {
      case 'En cours':
        return Colors.blue;
      case 'Terminé':
        return Colors.green;
      case 'En attente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _ajouterMarche() async {
    final result = await Navigator.pushNamed(context, AppRoutes.marcheAdd);

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _marches.add(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouveau marché ajouté avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _modifierMarche(Map<String, dynamic> marche) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.marcheAdd,
      arguments: marche,
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final index = _marches.indexWhere((m) => m['id'] == marche['id']);
        if (index != -1) {
          _marches[index] = result;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marché modifié avec succès'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _supprimerMarche(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce marché ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _marches.removeWhere((marche) => marche['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Marché supprimé avec succès'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Liste des Marchés',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Ajouter un marché',
            onPressed: _ajouterMarche,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historique',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.marcheHistorique),
          ),
          IconButton(
            icon: const Icon(Icons.assignment_turned_in),
            tooltip: 'Soumissions',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.marcheSoumission),
          ),
        ],
      ),
      body: _marches.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun marché à afficher',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ajoutez votre premier marché',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _marches.length,
              itemBuilder: (context, index) {
                final marche = _marches[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.marcheDetail,
                        arguments: marche,
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
                                    marche['statut']!,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.work,
                                  color: _getChipColor(marche['statut']!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      marche['nom']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: ${marche['id']}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _modifierMarche(marche);
                                      break;
                                    case 'delete':
                                      _supprimerMarche(marche['id']);
                                      break;
                                    case 'detail':
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.marcheDetail,
                                        arguments: marche,
                                      );
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
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text(
                                          'Supprimer',
                                          style: TextStyle(color: Colors.red),
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
                          Text(
                            'Soumission jusqu\'au : ${marche['soumission_date_limite']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  marche['statut']!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: _getChipColor(
                                  marche['statut']!,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${marche['budget']?.toStringAsFixed(0)} frcfa',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1976D2),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterMarche,
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouveau marché',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
