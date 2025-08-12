import 'package:flutter/material.dart';

class EditRecouvrementScreen extends StatefulWidget {
  final Map<String, dynamic> recouvrement;

  const EditRecouvrementScreen({super.key, required this.recouvrement});

  @override
  State<EditRecouvrementScreen> createState() => _EditRecouvrementScreenState();
}

class _EditRecouvrementScreenState extends State<EditRecouvrementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController clientController;
  late TextEditingController montantController;
  late TextEditingController dateController;
  String statut = "En attente";

  @override
  void initState() {
    super.initState();
    clientController = TextEditingController(
      text: widget.recouvrement['client'],
    );
    montantController = TextEditingController(
      text: widget.recouvrement['montant'].toString(),
    );
    dateController = TextEditingController(text: widget.recouvrement['date']);
    statut = widget.recouvrement['statut'];
  }

  @override
  void dispose() {
    clientController.dispose();
    montantController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'client': clientController.text,
        'montant': double.parse(montantController.text),
        'date': dateController.text,
        'statut': statut,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le Recouvrement"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: clientController,
                decoration: const InputDecoration(labelText: 'Client'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              DropdownButtonFormField<String>(
                value: statut,
                decoration: const InputDecoration(labelText: "Statut"),
                items: const [
                  DropdownMenuItem(
                    value: "En attente",
                    child: Text("En attente"),
                  ),
                  DropdownMenuItem(value: "Recouvré", child: Text("Recouvré")),
                  DropdownMenuItem(value: "Payé", child: Text("Payé")),
                ],
                onChanged: (value) {
                  setState(() {
                    statut = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Enregistrer les modifications"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
