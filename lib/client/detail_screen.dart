import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> client;

  const ClientDetailScreen({super.key, required this.client});

  // This widget builds the main screen with a TabBar for navigation.
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            client['nom'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF3F1FBF),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3F1FBF), Color(0xFF6A4EFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            tabs: const [
              Tab(icon: Icon(Icons.shopping_cart), text: "Ventes"),
              Tab(icon: Icon(Icons.build), text: "Maintenance"),
              Tab(icon: Icon(Icons.description), text: "Documents"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildVentesTab(),
            _buildMaintenanceTab(),
            _buildDocumentsTab(),
          ],
        ),
        bottomNavigationBar: _buildBottomButtons(context),
      ),
    );
  }

  // Helper method to build the bottom action buttons.
  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _createDevis(context),
              icon: const Icon(Icons.description, size: 20),
              label: const Text("Créer un devis"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B41FC),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _sendMessage(context),
              icon: const Icon(Icons.message, size: 20),
              label: const Text("Message"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C0380),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab content for "Ventes" (Sales).
  Widget _buildVentesTab() {
    // Mock data for sales history.
    final List<Map<String, dynamic>> ventes = [
      {
        'id': '#CMD-2023-0456',
        'date': DateTime(2023, 5, 15),
        'montant': 12500.0,
        'statut': 'Payé',
        'produits': ['Serveur Rack DL380', 'Switch Cisco 48 ports'],
      },
      {
        'id': '#CMD-2023-0289',
        'date': DateTime(2023, 3, 8),
        'montant': 8700.0,
        'statut': 'Payé',
        'produits': ['Firewall Fortinet 100F', 'Licence 1 an'],
      },
      {
        'id': '#CMD-2023-0112',
        'date': DateTime(2023, 1, 22),
        'montant': 4300.0,
        'statut': 'Annulé',
        'produits': ['NAS Synology DS1821+'],
      },
    ];

    // Calculate total revenue from mock data.
    final totalRevenue = ventes
        .where((v) => v['statut'] != 'Annulé')
        .fold(0.0, (sum, item) => sum + item['montant']);

    final lastOrderDate = ventes.isNotEmpty
        ? DateFormat('dd/MM/yyyy').format(ventes.first['date'])
        : 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Chiffre d\'affaires total',
            value: NumberFormat.currency(
              locale: 'fr_FR',
              symbol: '€',
            ).format(totalRevenue),
            icon: Icons.euro,
            color: Colors.green.shade100,
            iconColor: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Dernière commande',
            value: lastOrderDate,
            icon: Icons.calendar_today,
            color: Colors.blue.shade100,
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 24),
          const Text(
            'Historique des commandes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F1FBF),
            ),
          ),
          const SizedBox(height: 12),
          ...ventes.map((vente) => _buildVenteCard(vente)),
        ],
      ),
    );
  }

  // Tab content for "Maintenance"
  Widget _buildMaintenanceTab() {
    // Mock data for maintenance interventions.
    final List<Map<String, dynamic>> interventions = [
      {
        'id': '#INT-2023-078',
        'date': DateTime(2023, 6, 10),
        'technicien': 'Jean Dupont',
        'type': 'Maintenance préventive',
        'statut': 'Terminé',
        'description': 'Vérification et nettoyage des serveurs',
      },
      {
        'id': '#INT-2023-065',
        'date': DateTime(2023, 4, 5),
        'technicien': 'Marie Leroy',
        'type': 'Dépannage urgent',
        'statut': 'Terminé',
        'description': 'Problème de connexion réseau',
      },
      {
        'id': '#INT-2023-089',
        'date': DateTime(2023, 7, 2),
        'technicien': 'Pierre Martin',
        'type': 'Mise à jour logicielle',
        'statut': 'Planifié',
        'description': 'Mise à jour des systèmes de sécurité',
      },
    ];

    final nextIntervention = interventions
        .firstWhere(
          (inter) => inter['statut'] == 'Planifié',
          orElse: () => {
            'date': DateTime.now(),
            'description': 'Pas d\'intervention planifiée',
          },
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Prochaine intervention',
            value: DateFormat('dd/MM/yyyy').format(nextIntervention['date']),
            icon: Icons.calendar_today,
            color: Colors.orange.shade100,
            iconColor: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Contrat actif',
            value: 'Premium Support',
            icon: Icons.verified_user,
            color: Colors.purple.shade100,
            iconColor: Colors.purple,
          ),
          const SizedBox(height: 24),
          const Text(
            'Historique des interventions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F1FBF),
            ),
          ),
          const SizedBox(height: 12),
          ...interventions
              .map((inter) => _buildInterventionCard(inter)),
        ],
      ),
    );
  }

  // Tab content for "Documents"
  Widget _buildDocumentsTab() {
    // Mock data for shared documents.
    final List<Map<String, dynamic>> documents = [
      {
        'type': 'Contrat',
        'nom': 'Contrat de maintenance 2023.pdf',
        'date': DateTime(2023, 1, 10),
        'taille': '2.4 MB',
      },
      {
        'type': 'Facture',
        'nom': 'Facture_2023-0456.pdf',
        'date': DateTime(2023, 5, 18),
        'taille': '1.1 MB',
      },
      {
        'type': 'Devis',
        'nom': 'Devis_serveurs_2023.pdf',
        'date': DateTime(2023, 4, 22),
        'taille': '3.2 MB',
      },
    ];

    final totalSize = documents.fold(0.0, (sum, item) {
      final size = double.tryParse(item['taille'].split(' ')[0]) ?? 0.0;
      return sum + size;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Espace de stockage',
            value: '${totalSize.toStringAsFixed(1)} MB utilisés',
            icon: Icons.cloud,
            color: Colors.blueGrey.shade100,
            iconColor: Colors.blueGrey,
          ),
          const SizedBox(height: 24),
          const Text(
            'Documents partagés',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F1FBF),
            ),
          ),
          const SizedBox(height: 12),
          ...documents.map((doc) => _buildDocumentCard(doc)).toList(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload),
            label: const Text('Ajouter un document'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFF3F1FBF)),
              foregroundColor: const Color(0xFF3F1FBF),
            ),
          ),
        ],
      ),
    );
  }

  // A reusable card widget to display key information.
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // A card to display a single sales record.
  Widget _buildVenteCard(Map<String, dynamic> vente) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isAnnule = vente['statut'] == 'Annulé';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vente['id'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isAnnule
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAnnule
                            ? Colors.red.shade200
                            : Colors.green.shade200,
                      ),
                    ),
                    child: Text(
                      vente['statut'],
                      style: TextStyle(
                        color: isAnnule ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: '€',
                ).format(vente['montant']),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F1FBF),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(vente['date']),
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              const Text(
                'Produits :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...vente['produits'].map<Widget>(
                (produit) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '• $produit',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A card to display a single maintenance intervention.
  Widget _buildInterventionCard(Map<String, dynamic> intervention) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isPlanifie = intervention['statut'] == 'Planifié';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    intervention['id'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPlanifie
                          ? Colors.orange.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPlanifie
                            ? Colors.orange.shade200
                            : Colors.green.shade200,
                      ),
                    ),
                    child: Text(
                      intervention['statut'],
                      style: TextStyle(
                        color: isPlanifie ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                intervention['type'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F1FBF),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(intervention['date']),
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    intervention['technicien'],
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                intervention['description'],
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A card to display a single document.
  Widget _buildDocumentCard(Map<String, dynamic> document) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    IconData icon;
    Color color;

    switch (document['type']) {
      case 'Contrat':
        icon = Icons.assignment;
        color = Colors.purple;
        break;
      case 'Facture':
        icon = Icons.receipt;
        color = Colors.blue;
        break;
      case 'Devis':
        icon = Icons.description;
        color = Colors.green;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document['nom'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${document['type']} • ${document['taille']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(document['date']),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Placeholder for the "Créer un devis" action.
  void _createDevis(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau devis'),
        content: const Text('Fonctionnalité de création de devis'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(onPressed: () {}, child: const Text('Créer')),
        ],
      ),
    );
  }

  // Placeholder for the "Message" action.
  void _sendMessage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Envoyer un message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Sujet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F1FBF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Envoyer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
