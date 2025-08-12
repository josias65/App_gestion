import 'package:flutter/material.dart';

class HistoriqueMarchesScreen extends StatefulWidget {
  const HistoriqueMarchesScreen({super.key});

  @override
  State<HistoriqueMarchesScreen> createState() => _HistoriqueMarchesScreenState();
}

class _HistoriqueMarchesScreenState extends State<HistoriqueMarchesScreen> {
  // Liste fictive des offres soumises
  final List<Map<String, dynamic>> _soumissions = [
    {
      'id': 1,
      'titre': 'Construction d’un hangar',
      'dateSoumission': '2025-07-15',
      'montant': '3 000 000 FCFA',
      'statut': 'acceptée',
    },
    {
      'id': 2,
      'titre': 'Fourniture de matériel informatique',
      'dateSoumission': '2025-07-10',
      'montant': '1 200 000 FCFA',
      'statut': 'en attente',
    },
    {
      'id': 3,
      'titre': 'Réhabilitation d’un bâtiment',
      'dateSoumission': '2025-06-28',
      'montant': '2 400 000 FCFA',
      'statut': 'rejetée',
    },
    {
      'id': 4,
      'titre': 'Développement d’un logiciel de gestion',
      'dateSoumission': '2025-06-20',
      'montant': '5 500 000 FCFA',
      'statut': 'en attente',
    },
  ];

  String _searchQuery = '';
  String _selectedStatut = 'Tous';

  Color getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'acceptée':
        return Colors.green.shade600;
      case 'rejetée':
        return Colors.red.shade600;
      case 'en attente':
        return Colors.orange.shade600;
      default:
        return Colors.blueGrey.shade600;
    }
  }

  IconData getStatutIcon(String statut) {
    switch (statut.toLowerCase()) {
      case 'acceptée':
        return Icons.check_circle_outline;
      case 'rejetée':
        return Icons.cancel_outlined;
      case 'en attente':
        return Icons.access_time_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSoumissions = _soumissions.where((soumission) {
      final matchesSearch = soumission['titre'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedStatut == 'Tous' || soumission['statut'] == _selectedStatut.toLowerCase();
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Historique des marchés",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Rechercher un marché',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Tous', 'Acceptée', 'En attente', 'Rejetée'].map((statut) {
                    return ChoiceChip(
                      label: Text(statut),
                      selected: _selectedStatut == statut,
                      selectedColor: getStatutColor(statut.toLowerCase()),
                      labelStyle: TextStyle(
                        color: _selectedStatut == statut ? Colors.white : Colors.black87,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatut = selected ? statut : 'Tous';
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredSoumissions.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune soumission trouvée.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filteredSoumissions.length,
                    itemBuilder: (context, index) {
                      final soum = filteredSoumissions[index];
                      return _buildSubmissionCard(soum);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> soum) {
    final statusColor = getStatutColor(soum['statut']);
    final statusIcon = getStatutIcon(soum['statut']);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          // TODO: Implémenter la navigation vers l'écran de détail de la soumission
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Détails de la soumission pour : ${soum['titre']}")),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      soum['titre'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      soum['statut'].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    avatar: Icon(statusIcon, color: Colors.white, size: 18),
                    backgroundColor: statusColor,
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              _buildInfoRow(
                icon: Icons.monetization_on_outlined,
                label: 'Montant',
                value: soum['montant'],
              ),
              _buildInfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Date de soumission',
                value: soum['dateSoumission'],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label : $value',
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}