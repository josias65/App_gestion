import 'package:flutter/material.dart';

class StockEditScreen extends StatefulWidget {
  final Map<String, dynamic>? existingItem;

  const StockEditScreen({super.key, this.existingItem});

  @override
  State<StockEditScreen> createState() => _StockEditScreenState();
}

class _StockEditScreenState extends State<StockEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _seuilMinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      final item = widget.existingItem!;
      _nomController.text = item['nom'];
      _referenceController.text = item['reference'];
      _quantiteController.text = item['quantite'].toString();
      _prixController.text = item['prixUnitaire'].toString();
      _seuilMinController.text = item['seuilMin'].toString();
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final nouvelArticle = {
        'id':
            widget.existingItem?['id'] ?? DateTime.now().millisecondsSinceEpoch,
        'nom': _nomController.text.trim(),
        'reference': _referenceController.text.trim(),
        'quantite': int.parse(_quantiteController.text.trim()),
        'prixUnitaire': int.parse(_prixController.text.trim()),
        'seuilMin': int.parse(_seuilMinController.text.trim()),
      };
      Navigator.pop(context, nouvelArticle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingItem == null
              ? 'Ajouter un matériel'
              : 'Modifier le matériel',
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom du matériel'),
                validator: (value) =>
                    value!.isEmpty ? 'Entrez le nom du matériel' : null,
              ),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(labelText: 'Référence'),
                validator: (value) =>
                    value!.isEmpty ? 'Entrez la référence' : null,
              ),
              TextFormField(
                controller: _quantiteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantité'),
                validator: (value) =>
                    value!.isEmpty ? 'Entrez la quantité' : null,
              ),
              TextFormField(
                controller: _prixController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix unitaire (FCFA)',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Entrez le prix unitaire' : null,
              ),
              TextFormField(
                controller: _seuilMinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Seuil minimum (alerte)',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Entrez le seuil minimum' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _saveItem,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
