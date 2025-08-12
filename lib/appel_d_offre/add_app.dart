import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: unused_import
import '../routes/app_routes.dart';

class AddAppelOffreScreen extends StatefulWidget {
  final Map<String, dynamic>? appelToEdit;

  const AddAppelOffreScreen({super.key, this.appelToEdit});

  @override
  State<AddAppelOffreScreen> createState() => _AddAppelOffreScreenState();
}

class _AddAppelOffreScreenState extends State<AddAppelOffreScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateLimiteController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _categorieController = TextEditingController();
  final TextEditingController _localisationController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedCategorie = 'Informatique';
  String _selectedUrgence = 'Normale';
  bool _isLoading = false;
  bool _isEditing = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _categories = [
    'Informatique',
    'Construction',
    'Services',
    'Fournitures',
    'Équipements',
    'Formation',
    'Consultation',
    'Autre',
  ];

  final List<String> _urgences = ['Basse', 'Normale', 'Haute', 'Urgente'];

  @override
  void initState() {
    super.initState();

    _isEditing = widget.appelToEdit != null;

    if (_isEditing) {
      // Remplir les champs avec les données existantes
      final appel = widget.appelToEdit!;
      _titreController.text = appel['titre'] ?? '';
      _descriptionController.text = appel['description'] ?? '';
      _budgetController.text = appel['budget'] ?? '';
      _categorieController.text = appel['categorie'] ?? '';
      _localisationController.text = appel['localisation'] ?? '';
      _selectedCategorie = appel['categorie'] ?? 'Informatique';
      _selectedUrgence = appel['urgence'] ?? 'Normale';

      // Convertir la date si elle existe
      if (appel['dateLimite'] != null) {
        try {
          // Supposons que la date est au format dd/MM/yyyy
          final parts = appel['dateLimite'].split('/');
          if (parts.length == 3) {
            _selectedDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (e) {
          // Si le format ne correspond pas, on laisse null
        }
      }
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titreController.dispose();
    _descriptionController.dispose();
    _dateLimiteController.dispose();
    _budgetController.dispose();
    _categorieController.dispose();
    _localisationController.dispose();
    super.dispose();
  }

  /// Sélecteur de date amélioré
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F0465),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F0465),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Soumission du formulaire
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() {
        _isLoading = true;
      });

      // Simulation d'un appel API
      await Future.delayed(const Duration(seconds: 1));

      final appelData = {
        'id': _isEditing
            ? widget.appelToEdit!['id']
            : DateTime.now().millisecondsSinceEpoch,
        'titre': _titreController.text,
        'description': _descriptionController.text,
        'budget': _budgetController.text,
        'categorie': _selectedCategorie,
        'localisation': _localisationController.text,
        'urgence': _selectedUrgence,
        'dateLimite':
            '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
        'date':
            '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
        'etat': 'Ouvert',
        'soumissions': 0,
        'favori': false,
        'documents': ['Cahier des charges', 'Spécifications techniques'],
      };

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _isEditing
                        ? 'Appel d\'offre modifié avec succès !'
                        : 'Appel d\'offre créé avec succès !',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        Navigator.pop(context, appelData);
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date limite'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color(0xFF0F0465),
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            toolbarHeight: 80,
            leading: Container(
              margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              _isEditing
                  ? 'Modifier l\'appel d\'offre'
                  : 'Nouvel appel d\'offre',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFF0F0465),
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            actions: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        body: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8F9FF),
                    Color(0xFFEDF2FF),
                    Color(0xFFE8EAF6),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader('Informations générales'),
                      const SizedBox(height: 20),

                      // Titre
                      _buildTextFormField(
                        controller: _titreController,
                        labelText: 'Titre de l\'appel d\'offre',
                        icon: Icons.title,
                        validator: (value) =>
                            value!.isEmpty ? 'Veuillez entrer un titre' : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _buildTextFormField(
                        controller: _descriptionController,
                        labelText: 'Description détaillée',
                        icon: Icons.description,
                        maxLines: 4,
                        validator: (value) => value!.isEmpty
                            ? 'Veuillez entrer une description'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Catégorie
                      _buildDropdownFormField(
                        value: _selectedCategorie,
                        labelText: 'Catégorie',
                        icon: Icons.category,
                        items: _categories,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategorie = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader('Détails financiers et temporels'),
                      const SizedBox(height: 20),

                      // Budget
                      _buildTextFormField(
                        controller: _budgetController,
                        labelText: 'Budget estimé (FCFA)',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Veuillez entrer un budget';
                          }
                          if (double.tryParse(value.replaceAll(' ', '')) ==
                              null) {
                            return 'Veuillez entrer un montant valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date limite
                      _buildDateSelector(),
                      const SizedBox(height: 16),

                      // Niveau d'urgence
                      _buildDropdownFormField(
                        value: _selectedUrgence,
                        labelText: 'Niveau d\'urgence',
                        icon: Icons.priority_high,
                        items: _urgences,
                        onChanged: (value) {
                          setState(() {
                            _selectedUrgence = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader('Informations géographiques'),
                      const SizedBox(height: 20),

                      // Localisation
                      _buildTextFormField(
                        controller: _localisationController,
                        labelText: 'Localisation',
                        icon: Icons.location_on,
                        validator: (value) => value!.isEmpty
                            ? 'Veuillez entrer une localisation'
                            : null,
                      ),
                      const SizedBox(height: 32),

                      // Bouton de soumission
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitForm,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          _isEditing
                              ? 'Modifier l\'appel d\'offre'
                              : 'Créer l\'appel d\'offre',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F0465),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0465).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0F0465).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F0465),
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: const Color(0xFF0F0465)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF0F0465).withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF0F0465).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F0465), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildDropdownFormField({
    required String value,
    required String labelText,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: const Color(0xFF0F0465)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF0F0465).withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF0F0465).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F0465), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: (value) =>
          value == null ? 'Veuillez sélectionner une option' : null,
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date limite de soumission',
          prefixIcon: const Icon(
            Icons.calendar_today,
            color: Color(0xFF0F0465),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF0F0465).withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF0F0465).withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0F0465), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Text(
          _selectedDate != null
              ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
              : 'Sélectionner une date',
          style: TextStyle(
            color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
