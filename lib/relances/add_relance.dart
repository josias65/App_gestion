import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
import '../routes/app_routes.dart';

class AddRelanceScreen extends StatefulWidget {
  final Map<String, dynamic>? relanceToEdit;

  const AddRelanceScreen({super.key, this.relanceToEdit});

  @override
  State<AddRelanceScreen> createState() => _AddRelanceScreenState();
}

class _AddRelanceScreenState extends State<AddRelanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _factureIdController = TextEditingController();
  final TextEditingController _commentaireController = TextEditingController();

  DateTime? _selectedDate;
  String _statut = 'En attente';
  bool _isEditing = false;

  final List<String> statuts = ['En attente', 'Relancé', 'Payé'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.relanceToEdit != null;

    if (_isEditing) {
      // Remplir les champs avec les données existantes
      final relance = widget.relanceToEdit!;
      _clientController.text = relance['client'] ?? '';
      _montantController.text = relance['montant']?.toString() ?? '';
      _factureIdController.text = relance['factureId']?.toString() ?? '';
      _commentaireController.text = relance['commentaire']?.toString() ?? '';
      _statut = relance['statut'] ?? 'En attente';

      // Convertir la date si elle existe
      if (relance['date'] != null) {
        try {
          _selectedDate = DateFormat('yyyy-MM-dd').parse(relance['date']);
        } catch (e) {
          // Si le format ne correspond pas, on laisse null
        }
      }
    }
  }

  @override
  void dispose() {
    _clientController.dispose();
    _montantController.dispose();
    _factureIdController.dispose();
    _commentaireController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final relanceData = {
        'id': _isEditing
            ? widget.relanceToEdit!['id']
            : DateTime.now().millisecondsSinceEpoch,
        'client': _clientController.text,
        'montant': _montantController.text,
        'factureId': _factureIdController.text,
        'date': _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'statut': _statut,
        'commentaire': _commentaireController.text,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? "Relance modifiée avec succès !"
                : "Relance ajoutée avec succès !",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, relanceData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _isEditing ? "Modifier la relance" : "Ajouter une relance",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Informations sur le client'),
              const SizedBox(height: 16),
              // Champ Client
              _buildTextFormField(
                controller: _clientController,
                labelText: "Nom du client",
                icon: Icons.person_outline,
                validator: (value) =>
                    value!.isEmpty ? "Veuillez entrer le nom du client" : null,
              ),
              const SizedBox(height: 16),

              // Champ Numéro de facture
              _buildTextFormField(
                controller: _factureIdController,
                labelText: "Numéro de facture",
                icon: Icons.receipt_long_outlined,
                validator: (value) => value!.isEmpty
                    ? "Veuillez entrer un numéro de facture"
                    : null,
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('Détails de la relance'),
              const SizedBox(height: 16),
              // Champ Montant
              _buildTextFormField(
                controller: _montantController,
                labelText: "Montant (FCFA)",
                icon: Icons.monetization_on_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Veuillez entrer un montant";
                  }
                  if (double.tryParse(value) == null) {
                    return "Veuillez entrer un nombre valide";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Sélecteur de date
              _buildDateSelector(),
              const SizedBox(height: 16),
              // Dropdown de statut
              _buildStatusDropdown(),
              const SizedBox(height: 24),

              _buildSectionHeader('Commentaires'),
              const SizedBox(height: 16),
              // Champ Commentaire
              _buildTextFormField(
                controller: _commentaireController,
                labelText: "Ajouter un commentaire",
                icon: Icons.comment_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              // Bouton de soumission
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.send_outlined),
                label: Text(
                  _isEditing ? "Modifier la relance" : "Enregistrer la relance",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
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

  // Widget helper pour construire les en-têtes de section
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Widget helper pour construire un champ de texte standard
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  // Widget helper pour construire le sélecteur de date
  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? now,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 5),
        );
        if (date != null && date != _selectedDate) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Date d'échéance",
          prefixIcon: const Icon(
            Icons.calendar_today,
            color: Color(0xFF1976D2),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _selectedDate != null
              ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
              : "Sélectionner une date",
          style: TextStyle(
            color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Widget helper pour construire le dropdown de statut
  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _statut,
      decoration: InputDecoration(
        labelText: "Statut de la relance",
        prefixIcon: const Icon(
          Icons.flag_circle_outlined,
          color: Color(0xFF1976D2),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: statuts.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _statut = value!;
        });
      },
      validator: (value) => value == null ? "Veuillez choisir un statut" : null,
    );
  }
}
