import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
import '../routes/app_routes.dart';

class MarcheAddScreen extends StatefulWidget {
  final Map<String, dynamic>? marcheToEdit;

  const MarcheAddScreen({super.key, this.marcheToEdit});

  @override
  State<MarcheAddScreen> createState() => _MarcheAddScreenState();
}

class _MarcheAddScreenState extends State<MarcheAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _delaiController = TextEditingController();
  DateTime? _dateLimite;
  final List<String> _documentsRequises = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.marcheToEdit != null;

    if (_isEditing) {
      // Remplir les champs avec les données existantes
      final marche = widget.marcheToEdit!;
      _titreController.text = marche['nom'] ?? marche['titre'] ?? '';
      _descriptionController.text = marche['description'] ?? '';
      _budgetController.text = marche['budget']?.toString() ?? '';
      _delaiController.text = marche['delai'] ?? '';

      // Convertir la date limite si elle existe
      if (marche['soumission_date_limite'] != null) {
        try {
          _dateLimite = DateFormat(
            'yyyy-MM-dd',
          ).parse(marche['soumission_date_limite']);
        } catch (e) {
          // Si le format ne correspond pas, on laisse null
        }
      }

      // Ajouter les documents existants
      if (marche['documents'] != null) {
        _documentsRequises.addAll(
          (marche['documents'] as List<dynamic>).map((doc) => doc.toString()),
        );
      }
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _delaiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateLimite ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateLimite = picked;
      });
    }
  }

  void _ajouterDocument() {
    showDialog(
      context: context,
      builder: (context) {
        final documentController = TextEditingController();
        return AlertDialog(
          title: const Text(
            'Ajouter un document requis',
            style: TextStyle(fontSize: 18),
          ),
          content: TextField(
            controller: documentController,
            decoration: const InputDecoration(
              labelText: 'Nom du document',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (documentController.text.isNotEmpty) {
                  setState(() {
                    _documentsRequises.add(documentController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Créer l'objet marché
      final marcheData = {
        'id': _isEditing
            ? widget.marcheToEdit!['id']
            : 'marche_${DateTime.now().millisecondsSinceEpoch}',
        'nom': _titreController.text,
        'description': _descriptionController.text,
        'budget': double.tryParse(_budgetController.text),
        'delai': _delaiController.text,
        'soumission_date_limite': _dateLimite != null
            ? DateFormat('yyyy-MM-dd').format(_dateLimite!)
            : null,
        'documents': _documentsRequises,
        'statut': _isEditing ? widget.marcheToEdit!['statut'] : 'En cours',
        'date_debut': _isEditing
            ? widget.marcheToEdit!['date_debut']
            : DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'date_fin': _isEditing ? widget.marcheToEdit!['date_fin'] : null,
      };

      // Retour à l'écran précédent avec les données
      Navigator.pop(context, marcheData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Marché modifié avec succès !'
                : 'Nouveau marché créé avec succès !',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le Marché' : 'Nouveau Marché'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section Titre
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre du marché*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Section Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description détaillée*',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Section Budget et Délai
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Budget (frcfa)*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.euro),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un budget';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Montant invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _delaiController,
                      decoration: const InputDecoration(
                        labelText: 'Délai (mois)*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un délai';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section Date limite
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date limite de soumission*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dateLimite != null
                            ? DateFormat('dd/MM/yyyy').format(_dateLimite!)
                            : 'Sélectionner une date',
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Section Documents requis
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Documents requis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._documentsRequises.map(
                        (doc) => ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(doc),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _documentsRequises.remove(doc);
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un document'),
                        onPressed: _ajouterDocument,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton de soumission
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isEditing ? 'Modifier le marché' : 'Enregistrer le marché',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
