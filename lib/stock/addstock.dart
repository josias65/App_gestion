import 'package:flutter/material.dart';

class AddStockScreen extends StatefulWidget {
  final Map<String, dynamic>? articleToEdit;

  const AddStockScreen({super.key, this.articleToEdit});

  @override
  State<AddStockScreen> createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomController = TextEditingController();
  final TextEditingController marqueController = TextEditingController();
  final TextEditingController modeleController = TextEditingController();
  final TextEditingController quantiteController = TextEditingController();
  final TextEditingController prixUnitaireController = TextEditingController();
  final TextEditingController seuilMinController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();

  DateTime? dateEntree;
  String type = 'PC';
  String etat = 'Neuf';
  bool _isEditing = false;

  final List<String> types = [
    'PC',
    'Imprimante',
    'Routeur',
    'Switch',
    'Serveur',
    'Écran',
    'Clavier',
    'Souris',
  ];
  final List<String> etats = ['Neuf', 'Bon état', 'À réparer', 'Hors service'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.articleToEdit != null;

    if (_isEditing) {
      final article = widget.articleToEdit!;
      nomController.text = article['nom'] ?? '';
      marqueController.text = article['marque'] ?? '';
      modeleController.text = article['modele'] ?? '';
      quantiteController.text = article['quantite']?.toString() ?? '';
      prixUnitaireController.text = article['prixUnitaire']?.toString() ?? '';
      seuilMinController.text = article['seuilMin']?.toString() ?? '';
      referenceController.text = article['reference'] ?? '';
      type = article['type'] ?? 'PC';
      etat = article['etat'] ?? 'Neuf';

      if (article['dateEntree'] != null) {
        try {
          dateEntree = DateTime.parse(article['dateEntree']);
        } catch (e) {
          dateEntree = DateTime.now();
        }
      }
    }
  }

  void _enregistrer() {
    if (_formKey.currentState?.validate() ?? false) {
      final nouvelItem = {
        'id': _isEditing
            ? widget.articleToEdit!['id']
            : DateTime.now().millisecondsSinceEpoch,
        'nom': nomController.text,
        'type': type,
        'marque': marqueController.text,
        'modele': modeleController.text,
        'reference': referenceController.text,
        'quantite': int.tryParse(quantiteController.text) ?? 0,
        'prixUnitaire': int.tryParse(prixUnitaireController.text) ?? 0,
        'seuilMin': int.tryParse(seuilMinController.text) ?? 0,
        'etat': etat,
        'dateEntree':
            dateEntree?.toIso8601String() ?? DateTime.now().toIso8601String(),
      };

      Navigator.pop(context, nouvelItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Article modifié avec succès !'
                : 'Article ajouté au stock avec succès !',
          ),
          backgroundColor: _isEditing ? Colors.blue : Colors.green,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateEntree ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Sélectionner une date d\'entrée',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );

    if (picked != null && picked != dateEntree) {
      setState(() => dateEntree = picked);
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    marqueController.dispose();
    modeleController.dispose();
    quantiteController.dispose();
    prixUnitaireController.dispose();
    seuilMinController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier l\'article' : 'Ajouter un article',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo.shade600,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: 'Informations générales',
                children: [
                  _buildTextFormField(
                    controller: nomController,
                    label: 'Nom de l\'appareil',
                    icon: Icons.computer_outlined,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownFormField(
                    label: 'Type d\'appareil',
                    value: type,
                    items: types,
                    icon: Icons.devices_other_outlined,
                    onChanged: (value) => setState(() => type = value ?? 'PC'),
                  ),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: marqueController,
                    label: 'Marque',
                    icon: Icons.branding_watermark_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: modeleController,
                    label: 'Modèle',
                    icon: Icons.model_training_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Détails du stock',
                children: [
                  _buildTextFormField(
                    controller: quantiteController,
                    label: 'Quantité',
                    icon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number,
                    validator: _positiveIntegerValidator,
                  ),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: prixUnitaireController,
                    label: 'Prix unitaire (FCFA)',
                    icon: Icons.monetization_on_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _positiveDoubleValidator,
                  ),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: seuilMinController,
                    label: 'Seuil minimum',
                    icon: Icons.warning_amber_outlined,
                    keyboardType: TextInputType.number,
                    validator: _positiveIntegerValidator,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownFormField(
                    label: 'État',
                    value: etat,
                    items: etats,
                    icon: Icons.info_outline,
                    onChanged: (value) =>
                        setState(() => etat = value ?? 'Neuf'),
                  ),
                  const SizedBox(height: 12),
                  _buildDateSelection(),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _enregistrer,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer l\'article'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDateSelection() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date d\'entrée',
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.indigo),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        child: Text(
          dateEntree == null
              ? 'Aucune date sélectionnée'
              : '${dateEntree!.day}/${dateEntree!.month}/${dateEntree!.year}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  String? _positiveIntegerValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une valeur';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Entrez un nombre entier valide';
    }
    if (number <= 0) {
      return 'La valeur doit être positive';
    }
    return null;
  }

  String? _positiveDoubleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une valeur';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Entrez un nombre valide';
    }
    if (number <= 0) {
      return 'La valeur doit être positive';
    }
    return null;
  }
}
