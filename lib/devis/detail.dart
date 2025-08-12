import 'package:flutter/material.dart';
import '../../models/devis_model.dart';

class DevisDetailScreen extends StatelessWidget {
  final DevisModel devis;

  const DevisDetailScreen({super.key, required this.devis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Devis ${devis.reference}"),
        backgroundColor: const Color(0xFF3F1FBF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Client : ${devis.client}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text("Date : ${devis.date}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              "Statut : ${devis.status}",
              style: TextStyle(
                fontSize: 16,
                color: devis.status.toLowerCase() == 'validé'
                    ? Colors.green
                    : (devis.status.toLowerCase() == 'refusé'
                          ? Colors.red
                          : Colors.orange),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Document PDF (exemple fictif)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Icon(
                  Icons.picture_as_pdf,
                  size: 120,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter le téléchargement
                  },
                  icon: const Icon(Icons.download),
                  label: const Text("Télécharger"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F1FBF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter le partage
                  },
                  icon: const Icon(Icons.share),
                  label: const Text("Partager"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F1FBF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
