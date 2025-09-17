import 'package:flutter/material.dart';
import '../../models/devis_model.dart';

class DevisDetailScreen extends StatelessWidget {
  final DevisModel devis;

  const DevisDetailScreen({super.key, required this.devis, required devisId});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepté':
      case 'validé':
        return Colors.green;
      case 'refusé':
        return Colors.red;
      case 'en attente':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepté':
      case 'validé':
        return Icons.check_circle;
      case 'refusé':
        return Icons.cancel;
      case 'en attente':
        return Icons.access_time;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(devis.status);
    final tva = 20.0;
    final montantHT = devis.total;
    final montantTVA = montantHT * tva / 100;
    final montantTTC = montantHT + montantTVA;

    return Scaffold(
      appBar: AppBar(
        title: Text('Devis ${devis.reference}'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier',
            onPressed: () {
              // TODO: Naviguer vers l'édition du devis
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Supprimer',
            onPressed: () {
              // TODO: Supprimer le devis
            },
          ),
        ],
      ),
      floatingActionButton: Wrap(
        spacing: 16,
        children: [
          FloatingActionButton.extended(
            heroTag: 'download',
            backgroundColor: Colors.blue,
            icon: const Icon(Icons.download),
            label: const Text('Télécharger'),
            onPressed: () {
              // TODO: Implémenter le téléchargement
            },
          ),
          FloatingActionButton.extended(
            heroTag: 'share',
            backgroundColor: Colors.blue,
            icon: const Icon(Icons.share),
            label: const Text('Partager'),
            onPressed: () {
              // TODO: Implémenter le partage
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête client et statut
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(
                    _getStatusIcon(devis.status),
                    color: statusColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        devis.client,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            devis.date,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(devis.status),
                              size: 16,
                              color: statusColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              devis.status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Résumé du devis
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Résumé du devis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Montant HT',
                      '${montantHT.toStringAsFixed(2)} €',
                    ),
                    _buildInfoRow(
                      'TVA (20%)',
                      '${montantTVA.toStringAsFixed(2)} €',
                    ),
                    _buildInfoRow(
                      'Montant TTC',
                      '${montantTTC.toStringAsFixed(2)} €',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Liste des articles du devis
            if (devis.articles.isNotEmpty) ...[
              const Text(
                'Articles du devis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Désignation',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Qté',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'PU',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ...devis.articles.map((article) {
                      final designation = article['designation'] ?? '';
                      final quantite = article['quantite'] ?? 1;
                      final prix = article['prix'] ?? 0;
                      final sousTotal = (quantite is num && prix is num)
                          ? quantite * prix
                          : 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text('$designation')),
                            Expanded(child: Text('$quantite')),
                            Expanded(
                              child: Text('${prix.toStringAsFixed(2)} €'),
                            ),
                            Expanded(
                              child: Text(
                                '${sousTotal.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
            // Section PDF fictif
            Center(
              child: Column(
                children: [
                  const Text(
                    'Aperçu du document PDF',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Actions principales (déjà dans le FAB)
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
