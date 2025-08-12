import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailRecouvrementScreen extends StatefulWidget {
  final Map<String, dynamic> recouvrement;

  const DetailRecouvrementScreen({super.key, required this.recouvrement});

  @override
  State<DetailRecouvrementScreen> createState() =>
      _DetailRecouvrementScreenState();
}

class _DetailRecouvrementScreenState extends State<DetailRecouvrementScreen> {
  late Map<String, dynamic> _recouvrement;

  @override
  void initState() {
    super.initState();
    _recouvrement = Map.from(widget.recouvrement);
  }

  void _updateStatut(String nouveauStatut) {
    setState(() {
      _recouvrement['statut'] = nouveauStatut;
      // You can add a timestamp for the last action
      _recouvrement['derniereAction'] = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(DateTime.now());
    });
    // Here you would typically call an API to update the status in your backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Statut mis à jour à : $nouveauStatut'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Helper function to get the color for a given status
  Color getStatusColor(String status) {
    switch (status) {
      case 'Recouvré':
        return Colors.green.shade700;
      case 'En cours':
        return Colors.orange.shade700;
      case 'En attente':
        return Colors.red.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  // Helper function to get the icon for a given status
  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Recouvré':
        return Icons.check_circle_outline;
      case 'En cours':
        return Icons.access_time_outlined;
      case 'En attente':
        return Icons.warning_amber_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statutColor = getStatusColor(_recouvrement['statut']);
    final statutIcon = getStatusIcon(_recouvrement['statut']);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Détail du Recouvrement",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Client Name and Status Chip
            Card(
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
                            _recouvrement['client'] ?? 'Client inconnu',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(_recouvrement['statut']),
                          avatar: Icon(
                            statutIcon,
                            color: Colors.white,
                            size: 18,
                          ),
                          backgroundColor: statutColor,
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Montant : ${_recouvrement['montant'] ?? 'N/A'} FCFA',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Detailed Information Section
            _buildSectionCard(
              title: 'Informations détaillées',
              children: [
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  title: 'Date du recouvrement',
                  subtitle: _recouvrement['date'] ?? 'N/A',
                ),
                _buildInfoRow(
                  icon: Icons.fact_check_outlined,
                  title: 'Numéro de facture',
                  subtitle: _recouvrement['factureId'] ?? 'N/A',
                ),
                _buildInfoRow(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Solde restant',
                  subtitle: _recouvrement['soldeRestant'] ?? 'N/A',
                ),
                _buildInfoRow(
                  icon: Icons.history_toggle_off_outlined,
                  title: 'Dernière action',
                  subtitle: _recouvrement['derniereAction'] ?? 'Aucune',
                ),
                _buildInfoRow(
                  icon: Icons.comment_outlined,
                  title: 'Commentaire',
                  subtitle: _recouvrement['commentaire'] ?? 'Aucun commentaire',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Conditional Action Buttons Section
            if (_recouvrement['statut'] != 'Recouvré')
              _buildSectionCard(
                title: 'Actions rapides',
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _updateStatut('Recouvré'),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Marquer comme recouvré'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // You could add other actions here, e.g. "Send a reminder"
                ],
              ),
            const SizedBox(height: 24),

            // Back button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("Retour à la liste"),
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to create a consistent card for sections
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  // Helper widget to create a consistent info row with icon and text
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1976D2)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
