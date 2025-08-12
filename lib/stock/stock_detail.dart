import 'package:appgestion/stock/stock_edit.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import '../routes/app_routes.dart';

class StockDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const StockDetailScreen({super.key, required this.article});

  // Méthode pour modifier l'article
  Future<void> _modifierArticle(BuildContext context) async {
    final updatedArticle = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => StockEditScreen(existingItem: article)),
    );
    if (updatedArticle != null) {
      Navigator.pop(context, updatedArticle);
    }
  }

  // Méthode pour supprimer l'article
  void _supprimerArticle(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${article['nom']}" ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context, true); // Signal de suppression
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
    final int quantite = article['quantite'] as int;
    final int seuilMin = article['seuilMin'] as int;
    final bool enRupture = quantite <= seuilMin;
    final double prixUnitaire = (article['prixUnitaire'] as int).toDouble();
    final double valeurTotale = quantite * prixUnitaire;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          article['nom'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Modifier',
            onPressed: () => _modifierArticle(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Supprimer',
            onPressed: () => _supprimerArticle(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicateur visuel du statut du stock
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: enRupture ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: enRupture ? Colors.red : Colors.green,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    enRupture
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    color: enRupture ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    enRupture ? 'Stock faible !' : 'En stock',
                    style: TextStyle(
                      color: enRupture ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Carte d'informations sur l'article
            _buildInfoCard(
              children: [
                _buildInfoRow(
                  Icons.label_outline,
                  'Référence',
                  article['reference'],
                ),
                _buildInfoRow(
                  Icons.category_outlined,
                  'Nom du matériel',
                  article['nom'],
                ),
                _buildInfoRow(
                  Icons.inventory_2_outlined,
                  'Quantité disponible',
                  '$quantite',
                ),
                _buildInfoRow(
                  Icons.warning_amber_outlined,
                  'Seuil minimum',
                  '$seuilMin',
                ),
                _buildInfoRow(
                  Icons.attach_money_outlined,
                  'Prix unitaire',
                  '${prixUnitaire.toStringAsFixed(0)} FCFA',
                ),
                _buildInfoRow(
                  Icons.monetization_on_outlined,
                  'Valeur totale du stock',
                  '${valeurTotale.toStringAsFixed(0)} FCFA',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget utilitaire pour une carte d'informations
  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  // Widget utilitaire pour une ligne d'information
  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
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
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
