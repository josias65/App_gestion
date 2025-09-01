import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddRecouvrementScreen extends StatefulWidget {
  const AddRecouvrementScreen({super.key});

  @override
  State<AddRecouvrementScreen> createState() => _AddRecouvrementScreenState();
}

class _AddRecouvrementScreenState extends State<AddRecouvrementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _montantController = TextEditingController();
  final _soldeRestantController = TextEditingController();
  final _factureIdController = TextEditingController();
  final _commentaireController = TextEditingController();

  DateTime? _selectedDate;
  String _statut = 'En attente';

  @override
  void dispose() {
    _clientController.dispose();
    _montantController.dispose();
    _soldeRestantController.dispose();
    _factureIdController.dispose();
    _commentaireController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Sélectionner la date de recouvrement',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1976D2), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // Check if a date has been selected
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une date de recouvrement.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final newRecouvrement = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'client': _clientController.text,
        'montant': _montantController.text,
        'soldeRestant': _soldeRestantController.text,
        'factureId': _factureIdController.text,
        'date': DateFormat('dd/MM/yyyy').format(_selectedDate!),
        'statut': _statut,
        'commentaire': _commentaireController.text,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recouvrement enregistré avec succès !'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back and return the new data
      Navigator.pop(context, newRecouvrement);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un recouvrement',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Informations de base'),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _clientController,
                labelText: 'Nom du client',
                icon: Icons.person_outline,
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer le nom du client' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _factureIdController,
                labelText: 'Numéro de facture',
                icon: Icons.receipt_long_outlined,
                validator: (value) => value!.isEmpty
                    ? 'Veuillez entrer un numéro de facture'
                    : null,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Détails du recouvrement'),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _montantController,
                labelText: 'Montant total (FCFA)',
                icon: Icons.monetization_on_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer le montant total';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _soldeRestantController,
                labelText: 'Solde restant (FCFA)',
                icon: Icons.account_balance_wallet_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer le solde restant';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDateSelector(),
              const SizedBox(height: 16),
              _buildStatusDropdown(),
              const SizedBox(height: 24),
              _buildSectionHeader('Commentaire'),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _commentaireController,
                labelText: 'Ajouter un commentaire',
                icon: Icons.comment_outlined,
                maxLines: 3,
                validator: (value) => null, // Optional field, no validation
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Enregistrer le recouvrement"),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
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
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date de recouvrement',
          prefixIcon: const Icon(
            Icons.calendar_today,
            color: Color(0xFF1976D2),
          ),
          errorText: _selectedDate == null && _formKey.currentState != null && _formKey.currentState!.validate()
              ? 'Veuillez sélectionner une date'
              : null,
        ),
        child: Text(
          _selectedDate != null
              ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
              : 'Sélectionner une date',
          style: TextStyle(
            color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _statut,
      decoration: const InputDecoration(
        labelText: 'Statut du recouvrement',
        prefixIcon: Icon(
          Icons.flag_circle_outlined,
          color: Color(0xFF1976D2),
        ),
      ),
      items: const ['En attente', 'En cours', 'Recouvré'].map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (val) => setState(() => _statut = val!),
      validator: (val) =>
          val == null ? 'Veuillez sélectionner un statut' : null,
    );
  }
}
