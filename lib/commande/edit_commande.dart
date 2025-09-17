import 'package:flutter/material.dart';

class EditCommandeScreen extends StatefulWidget {
  final String commandeId;

  const EditCommandeScreen({
    super.key,
    required this.commandeId,
    required Map<String, dynamic> commandeToEdit,
  });

  @override
  State<EditCommandeScreen> createState() => _EditCommandeScreenState();
}

class _EditCommandeScreenState extends State<EditCommandeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Données de la commande (à charger depuis API dans un vrai cas)
  String? _numero;
  String? _client;
  String? _date;
  String? _statut;

  // Simulation d’un chargement initial
  @override
  void initState() {
    super.initState();
    // Charger les données de la commande
    _numero = 'CMD001';
    _client = 'Jean Dupont';
    _date = '2025-07-20';
    _statut = 'En cours';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier une commande'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Bouton retour
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _numero,
                decoration: const InputDecoration(labelText: 'Numéro'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer un numéro'
                    : null,
                onSaved: (value) => _numero = value,
              ),
              TextFormField(
                initialValue: _client,
                decoration: const InputDecoration(labelText: 'Client'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer un client'
                    : null,
                onSaved: (value) => _client = value,
              ),
              TextFormField(
                initialValue: _date,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Veuillez entrer une date';
                  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!regex.hasMatch(value)) return 'Format de date invalide';
                  return null;
                },
                onSaved: (value) => _date = value,
              ),
              TextFormField(
                initialValue: _statut,
                decoration: const InputDecoration(labelText: 'Statut'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer un statut'
                    : null,
                onSaved: (value) => _statut = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Ici tu appelleras ton API pour modifier la commande
                    // Puis tu retournes true pour dire que ça a fonctionné
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Modifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
