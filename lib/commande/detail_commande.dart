import 'package:flutter/material.dart';

class DetailCommandeScreen extends StatelessWidget {
  final String commandeId;
  final Map<String, dynamic> commande;

  const DetailCommandeScreen({
    super.key,
    required this.commandeId,
    required this.commande,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Commande n°$commandeId',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black54),
            onPressed: () {
              // Logique pour éditer la commande
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité d\'édition à implémenter'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Informations générales
            _buildSection(
              title: 'Informations générales',
              icon: Icons.info_outline,
              children: [
                _buildDetailRow(
                  'Numéro de commande',
                  commande['numero']?.toString() ?? 'Non renseigné',
                ),
                _buildDetailRow(
                  'Client',
                  commande['client']?.toString() ?? 'Non renseigné',
                  icon: Icons.person_outline,
                ),
                _buildDetailRow(
                  'Date de commande',
                  commande['date']?.toString() ?? 'Non renseigné',
                  icon: Icons.calendar_today,
                ),
                _buildStatusChip(commande['statut']?.toString() ?? 'Inconnu'),
              ],
            ),
            const SizedBox(height: 24),

            // Section Détails des articles
            _buildSection(
              title: 'Articles de la commande',
              icon: Icons.shopping_bag_outlined,
              children: [
                _buildArticleItem('Écran incurvé 27"', 'x1', '349.99 €'),
                _buildArticleItem('Clavier mécanique RGB', 'x2', '129.99 €'),
                const Divider(),
                _buildTotalRow('Total des articles', '609.97 €'),
              ],
            ),
            const SizedBox(height: 24),

            // Section Livraison
            _buildSection(
              title: 'Informations de livraison',
              icon: Icons.local_shipping_outlined,
              children: [
                _buildDetailRow(
                  'Adresse',
                  '123 Rue de la Liberté, 75001 Paris',
                ),
                _buildDetailRow('Mode de livraison', 'Standard (4-5 jours)'),
                _buildDetailRow('Frais de port', '5.00 €'),
              ],
            ),
            const SizedBox(height: 24),

            // Section Paiement
            _buildSection(
              title: 'Informations de paiement',
              icon: Icons.payment,
              children: [
                _buildDetailRow('Méthode', 'Carte de crédit'),
                _buildDetailRow('Statut du paiement', 'Payé'),
                _buildDetailRow('Montant total', '614.97 €', isTotal: true),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  // Widgets auxiliaires pour une meilleure lisibilité
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0D47A1)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isTotal ? Colors.black87 : Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF0D47A1) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final statusInfo = _getStatusInfo(status);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusInfo.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusInfo.icon, size: 16, color: statusInfo.color),
            const SizedBox(width: 8),
            Text(
              status,
              style: TextStyle(
                color: statusInfo.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(String name, String quantity, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              quantity,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              price,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Logique pour annuler la commande
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Annulation à implémenter')),
                );
              },
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: const Text('Annuler', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Logique pour marquer comme livrée
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mise à jour du statut à implémenter'),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text(
                'Marquer livrée',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'livrée':
        return _StatusInfo(Colors.green, Icons.check_circle);
      case 'annulée':
        return _StatusInfo(Colors.red, Icons.cancel);
      case 'en cours':
        return _StatusInfo(Colors.orange, Icons.access_time);
      default:
        return _StatusInfo(Colors.grey, Icons.help);
    }
  }
}

class _StatusInfo {
  final Color color;
  final IconData icon;
  _StatusInfo(this.color, this.icon);
}
