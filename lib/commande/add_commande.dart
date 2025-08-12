import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
import '../routes/app_routes.dart';

class AddCommandeScreen extends StatefulWidget {
  final Map<String, dynamic>? commandeToEdit;

  const AddCommandeScreen({super.key, this.commandeToEdit});

  @override
  State<AddCommandeScreen> createState() => _AddCommandeScreenState();
}

class _AddCommandeScreenState extends State<AddCommandeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _clientController = TextEditingController();
  final _commentaireController = TextEditingController();
  final _designationController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _prixController = TextEditingController();

  DateTime? _dateLivraison;
  String _statut = 'En préparation';
  String _modePaiement = 'Virement bancaire';
  double _montantTotal = 0.0;
  final double _tva = 20.0;
  bool _isEditing = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _articles = [];
  final List<String> _statuts = [
    'En préparation',
    'Validée',
    'Expédiée',
    'Livrée',
    'Annulée',
  ];
  final List<String> _modesPaiement = [
    'Virement bancaire',
    'Carte bancaire',
    'Chèque',
    'Espèces',
    'PayPal',
  ];

  // Liste de clients pour la démo
  final List<Map<String, dynamic>> _clients = [
    {
      'id': 1,
      'nom': 'Entreprise ABC',
      'email': 'contact@abc.com',
      'telephone': '+225 0123456789',
    },
    {
      'id': 2,
      'nom': 'Société XYZ',
      'email': 'info@xyz.com',
      'telephone': '+225 0987654321',
    },
    {
      'id': 3,
      'nom': 'Compagnie DEF',
      'email': 'hello@def.com',
      'telephone': '+225 0555666777',
    },
    {
      'id': 4,
      'nom': 'Groupe GHI',
      'email': 'contact@ghi.com',
      'telephone': '+225 0333444555',
    },
    {
      'id': 5,
      'nom': 'Corporation JKL',
      'email': 'info@jkl.com',
      'telephone': '+225 0777888999',
    },
  ];

  // Liste d'articles pour la démo
  final List<Map<String, dynamic>> _articlesDisponibles = [
    {
      'id': 1,
      'designation': 'Ordinateur Portable HP',
      'prix': 350000,
      'stock': 8,
    },
    {'id': 2, 'designation': 'Imprimante Canon', 'prix': 150000, 'stock': 3},
    {'id': 3, 'designation': 'Routeur TP-Link', 'prix': 55000, 'stock': 10},
    {'id': 4, 'designation': 'Clavier mécanique', 'prix': 45000, 'stock': 1},
    {'id': 5, 'designation': 'Souris sans fil', 'prix': 25000, 'stock': 15},
    {'id': 6, 'designation': 'Écran 24 pouces', 'prix': 120000, 'stock': 5},
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.commandeToEdit != null;

    if (_isEditing) {
      // Remplir les champs avec les données existantes
      final commande = widget.commandeToEdit!;
      _numeroController.text = commande['numero'] ?? '';
      _clientController.text = commande['client'] ?? '';
      _commentaireController.text = commande['commentaire'] ?? '';
      _statut = commande['statut'] ?? 'En préparation';
      _modePaiement = commande['modePaiement'] ?? 'Virement bancaire';

      // Convertir la date si elle existe
      if (commande['dateLivraison'] != null) {
        try {
          _dateLivraison = DateTime.parse(commande['dateLivraison']);
        } catch (e) {
          _dateLivraison = DateTime.now().add(const Duration(days: 7));
        }
      }

      // Ajouter les articles existants
      if (commande['articles'] != null) {
        _articles.addAll(List<Map<String, dynamic>>.from(commande['articles']));
        _calculerMontantTotal();
      }
    } else {
      // Générer un numéro de commande automatique
      _numeroController.text =
          'CMD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    }
  }

  void _calculerMontantTotal() {
    _montantTotal = _articles.fold(0.0, (sum, article) {
      return sum + (article['quantite'] * article['prix']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier la commande' : 'Nouvelle commande',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Informations générales'),
              const SizedBox(height: 16),

              // Numéro de commande
              _buildTextFormField(
                controller: _numeroController,
                label: 'Numéro de commande*',
                icon: Icons.numbers,
                validator: (value) =>
                    value!.isEmpty ? 'Ce champ est obligatoire' : null,
                readOnly: _isEditing,
              ),
              const SizedBox(height: 16),

              // Client
              _buildTextFormField(
                controller: _clientController,
                label: 'Client*',
                icon: Icons.person,
                validator: (value) =>
                    value!.isEmpty ? 'Ce champ est obligatoire' : null,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _selectClient(context),
                ),
              ),
              const SizedBox(height: 16),

              // Date de livraison et Statut
              Row(
                children: [
                  Expanded(child: _buildDateSelector()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdownFormField(
                      label: 'Statut*',
                      value: _statut,
                      items: _statuts,
                      icon: Icons.flag,
                      onChanged: (value) => setState(() => _statut = value!),
                      validator: (value) =>
                          value == null ? 'Ce champ est obligatoire' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('Articles commandés'),
              const SizedBox(height: 12),

              // Liste des articles
              if (_articles.isEmpty)
                _buildEmptyArticlesState()
              else
                Column(
                  children: _articles
                      .map((article) => _buildArticleCard(article))
                      .toList(),
                ),
              const SizedBox(height: 12),

              // Ajout d'articles
              _buildAddArticleSection(),
              const SizedBox(height: 24),

              _buildSectionHeader('Informations financières'),
              const SizedBox(height: 16),

              // Montants
              _buildFinancialInfo(),
              const SizedBox(height: 16),

              // Mode de paiement
              _buildDropdownFormField(
                label: 'Mode de paiement*',
                value: _modePaiement,
                items: _modesPaiement,
                icon: Icons.payment,
                onChanged: (value) => setState(() => _modePaiement = value!),
                validator: (value) =>
                    value == null ? 'Ce champ est obligatoire' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('Commentaires'),
              const SizedBox(height: 12),

              _buildTextFormField(
                controller: _commentaireController,
                label: 'Commentaires',
                icon: Icons.comment,
                maxLines: 4,
                hintText: 'Ajoutez des commentaires ou instructions...',
              ),
              const SizedBox(height: 32),

              // Bouton de sauvegarde
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1976D2).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool readOnly = false,
    int maxLines = 1,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF1976D2).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      readOnly: readOnly,
      maxLines: maxLines,
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF1976D2).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date de livraison*',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF1976D2).withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          prefixIcon: const Icon(
            Icons.calendar_today,
            color: Color(0xFF1976D2),
          ),
        ),
        child: Text(
          _dateLivraison == null
              ? 'Sélectionner une date'
              : DateFormat('dd/MM/yyyy').format(_dateLivraison!),
          style: TextStyle(
            color: _dateLivraison == null ? Colors.grey.shade500 : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyArticlesState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun article ajouté',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des articles à votre commande',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildAddArticleSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajouter un article',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextFormField(
                    controller: _designationController,
                    label: 'Désignation',
                    icon: Icons.inventory_2,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildTextFormField(
                    controller: _quantiteController,
                    label: 'Qté',
                    icon: Icons.format_list_numbered,
                    validator: (value) {
                      if (value!.isEmpty) return 'Qté requise';
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) return 'Qté invalide';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildTextFormField(
                    controller: _prixController,
                    label: 'Prix unitaire',
                    icon: Icons.euro,
                    validator: (value) {
                      if (value!.isEmpty) return 'Prix requis';
                      final prix = double.tryParse(value);
                      if (prix == null || prix <= 0) return 'Prix invalide';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addArticle,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter l\'article'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                      side: const BorderSide(color: Color(0xFF1976D2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectArticle(context),
                    icon: const Icon(Icons.search),
                    label: const Text('Choisir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                      side: const BorderSide(color: Color(0xFF1976D2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    final total = article['quantite'] * article['prix'];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: Color(0xFF1976D2),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['designation'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${article['quantite']} x ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(article['prix'])}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(
                    locale: 'fr_FR',
                    symbol: 'FCFA',
                  ).format(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => _editArticle(article),
                      color: Colors.orange,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () => _removeArticle(article),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialInfo() {
    final montantHT = _montantTotal;
    final montantTVA = montantHT * _tva / 100;
    final montantTTC = montantHT + montantTVA;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Montant HT',
                NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: 'FCFA',
                ).format(montantHT),
                Icons.euro,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'TVA (${_tva.toStringAsFixed(0)}%)',
                NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: 'FCFA',
                ).format(montantTVA),
                Icons.percent,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Montant TTC',
          NumberFormat.currency(
            locale: 'fr_FR',
            symbol: 'FCFA',
          ).format(montantTTC),
          Icons.account_balance_wallet,
          const Color(0xFF1976D2),
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isTotal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveCommande,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save),
        label: Text(
          _isEditing ? 'Modifier la commande' : 'Enregistrer la commande',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _dateLivraison ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1976D2),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateLivraison) {
      setState(() {
        _dateLivraison = picked;
      });
    }
  }

  Future<void> _selectClient(BuildContext context) async {
    final selectedClient = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner un client'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _clients.length,
            itemBuilder: (context, index) {
              final client = _clients[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1976D2),
                  child: Text(
                    client['nom'][0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(client['nom']),
                subtitle: Text('${client['email']}\n${client['telephone']}'),
                onTap: () => Navigator.pop(context, client),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (selectedClient != null) {
      setState(() {
        _clientController.text = selectedClient['nom'];
      });
    }
  }

  Future<void> _selectArticle(BuildContext context) async {
    final selectedArticle = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner un article'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _articlesDisponibles.length,
            itemBuilder: (context, index) {
              final article = _articlesDisponibles[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Color(0xFF1976D2),
                  ),
                ),
                title: Text(article['designation']),
                subtitle: Text(
                  '${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(article['prix'])} - Stock: ${article['stock']}',
                ),
                trailing: article['stock'] > 0
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
                onTap: article['stock'] > 0
                    ? () => Navigator.pop(context, article)
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (selectedArticle != null) {
      setState(() {
        _designationController.text = selectedArticle['designation'];
        _prixController.text = selectedArticle['prix'].toString();
        _quantiteController.text = '1';
      });
    }
  }

  void _addArticle() {
    if (_designationController.text.isEmpty ||
        _quantiteController.text.isEmpty ||
        _prixController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs de l\'article'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quantite = int.tryParse(_quantiteController.text);
    final prix = double.tryParse(_prixController.text);

    if (quantite == null || quantite <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantité invalide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (prix == null || prix <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prix invalide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newArticle = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'designation': _designationController.text,
      'quantite': quantite,
      'prix': prix,
    };

    setState(() {
      _articles.add(newArticle);
      _calculerMontantTotal();
      _designationController.clear();
      _quantiteController.clear();
      _prixController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newArticle['designation']} ajouté à la commande'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editArticle(Map<String, dynamic> article) {
    _designationController.text = article['designation'];
    _quantiteController.text = article['quantite'].toString();
    _prixController.text = article['prix'].toString();

    setState(() {
      _articles.remove(article);
      _calculerMontantTotal();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Modifiez l\'article et cliquez sur "Ajouter l\'article"',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _removeArticle(Map<String, dynamic> article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${article['designation']}" de la commande ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _articles.remove(article);
                _calculerMontantTotal();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${article['designation']} supprimé de la commande',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCommande() async {
    if (_formKey.currentState!.validate()) {
      if (_articles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez ajouter au moins un article'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_dateLivraison == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une date de livraison'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simulation d'un appel API
      await Future.delayed(const Duration(seconds: 1));

      final commande = {
        'id': _isEditing
            ? widget.commandeToEdit!['id']
            : DateTime.now().millisecondsSinceEpoch,
        'numero': _numeroController.text,
        'client': _clientController.text,
        'dateLivraison': _dateLivraison,
        'articles': _articles,
      };

      // Appel API pour sauvegarder la commande
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Commande ${_isEditing ? 'modifiée' : 'ajoutée'} avec succès',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, commande);
    }
  }
}
