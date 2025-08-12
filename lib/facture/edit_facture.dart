import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// The main entry point of the Flutter application.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoice App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          color: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
      // This is the starting screen for the app
      home: const EditFactureScreen(factureId: 'FAC001-2025'),
    );
  }
}

// A screen to edit an existing invoice.
class EditFactureScreen extends StatefulWidget {
  final String factureId;

  const EditFactureScreen({super.key, required this.factureId});

  @override
  State<EditFactureScreen> createState() => _EditFactureScreenState();
}

class _EditFactureScreenState extends State<EditFactureScreen> {
  final _formKey = GlobalKey<FormState>();

  // Use TextEditingControllers for better control over form fields
  final _numeroController = TextEditingController();
  final _clientController = TextEditingController();
  final _dateController = TextEditingController();
  final _montantController = TextEditingController();

  // State variables for the dropdown and date picker
  String? _statut;
  final List<String> _statutOptions = ['Payée', 'Impayée', 'En attente'];

  @override
  void initState() {
    super.initState();
    // Load the invoice data when the widget is initialized
    _loadFactureData();
  }

  // A mock function to simulate fetching invoice data from a database.
  void _loadFactureData() {
    // In a real app, you would make an API call here using widget.factureId
    final mockFacture = {
      'numero': 'FAC001-2025',
      'client': 'Jean Dupont',
      'date': '2025-07-21',
      'statut': 'Payée',
      'montant': '1500.00',
    };

    _numeroController.text = mockFacture['numero']!;
    _clientController.text = mockFacture['client']!;
    _dateController.text = mockFacture['date']!;
    _montantController.text = mockFacture['montant']!;
    _statut = mockFacture['statut']!;
  }

  // A function to handle the date picker dialog.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // A function to handle saving the form data.
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // In a real app, you would call your API to update the invoice here.
      // For this example, we just show a success message.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facture modifiée avec succès!')),
      );
      // Navigate back to the previous screen.
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier une facture'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _numeroController,
                        decoration: const InputDecoration(labelText: 'Numéro'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez entrer un numéro'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _clientController,
                        decoration: const InputDecoration(labelText: 'Client'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez entrer un client'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Date (YYYY-MM-DD)',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        readOnly: true, // Prevent manual typing
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _statut,
                        decoration: const InputDecoration(labelText: 'Statut'),
                        items: _statutOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _statut = newValue;
                          });
                        },
                        validator: (value) => value == null
                            ? 'Veuillez sélectionner un statut'
                            : null,
                        onSaved: (value) => _statut = value,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _montantController,
                        decoration: const InputDecoration(
                          labelText: 'Montant',
                          prefixText: '€ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un montant';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save),
                label: const Text('Sauvegarder les modifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
