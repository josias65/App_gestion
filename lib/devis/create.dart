import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateDevisScreen extends StatefulWidget {
  const CreateDevisScreen({super.key});

  @override
  State<CreateDevisScreen> createState() => _CreateDevisScreenState();
}

class _CreateDevisScreenState extends State<CreateDevisScreen> {
  String? selectedClient;
  final List<String> clients = ["Josias", "Joyce", "Malick"];
  final List<Map<String, dynamic>> articles = [];

  final articleController = TextEditingController();
  final prixController = TextEditingController();
  final quantiteController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  // Calculates the total cost by multiplying the price and quantity for each item.
  double get total => articles.fold(
        0,
        (sum, item) => sum + (item['prix'] as double) * (item['quantite'] as int),
      );

  // Adds a new article to the list if the inputs are valid.
  void ajouterArticle() {
    final nom = articleController.text.trim();
    final prixText = prixController.text.trim();
    final quantiteText = quantiteController.text.trim();
    final prix = double.tryParse(prixText);
    final quantite = int.tryParse(quantiteText);

    // Validate all inputs before adding the article.
    if (nom.isEmpty ||
        prix == null ||
        prix <= 0 ||
        quantite == null ||
        quantite <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez entrer un article, une quantité et un prix valides.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      articles.add({"nom": nom, "prix": prix, "quantite": quantite});
      articleController.clear();
      prixController.clear();
      quantiteController.clear();
    });
  }

  // Removes an article from the list by its index.
  void supprimerArticle(int index) {
    setState(() {
      articles.removeAt(index);
    });
  }

  // Shows a date picker dialog to select the quote's date.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Handles the logic for sending the quote.
  void envoyerDevis() {
    if (selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un client.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (articles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins un article.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Placeholder logic for sending the quote (e.g., API call).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Devis pour $selectedClient (Total: ${total.toStringAsFixed(2)} €) envoyé avec succès!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    articleController.dispose();
    prixController.dispose();
    quantiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Créer un Devis",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client and Date section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Sélectionner un client",
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      value: selectedClient,
                      items: clients
                          .map(
                            (client) => DropdownMenuItem(
                              value: client,
                              child: Text(client),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedClient = value),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                      ),
                      title: Text(
                        "Date du devis : ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.edit, color: Colors.blue),
                      onTap: () => _selectDate(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Add Articles section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ajouter des articles",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: articleController,
                      decoration: const InputDecoration(
                        labelText: "Nom de l'article",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: quantiteController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Qté",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              prefixIcon: Icon(Icons.format_list_numbered),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: prixController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: "Prix unitaire (€)",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              prefixIcon: Icon(Icons.euro),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: ajouterArticle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Summary section
            const Text(
              "Récapitulatif du devis",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: articles.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun article ajouté. Ajoutez des articles pour voir le récapitulatif.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final item = articles[index];
                        final subtotal =
                            (item['prix'] as double) *
                            (item['quantite'] as int);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF1E88E5),
                              child: Text(
                                item['quantite'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(item['nom']),
                            subtitle: Text(
                              "${item['quantite']} x ${item['prix'].toStringAsFixed(2)} €",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${subtotal.toStringAsFixed(2)} €",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => supprimerArticle(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Montant total :",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "${total.toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: envoyerDevis,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  "Envoyer le devis",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
