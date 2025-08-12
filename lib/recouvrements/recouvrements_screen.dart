import 'package:flutter/material.dart';

class DetailRecouvrementScreen extends StatelessWidget {
  final Map<String, String> recouvrement;
  const DetailRecouvrementScreen({Key? key, required this.recouvrement})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails pour ${recouvrement['client']}'),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              icon: Icons.person,
              title: 'Client',
              value: recouvrement['client']!,
            ),
            const SizedBox(height: 12),
            _buildDetailCard(
              icon: Icons.euro,
              title: 'Montant',
              value: recouvrement['montant']!,
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 12),
            _buildDetailCard(
              icon: Icons.calendar_today,
              title: 'Date',
              value: recouvrement['date']!,
            ),
            const SizedBox(height: 12),
            _buildDetailCard(
              icon: _getStatusIcon(recouvrement['statut']!),
              title: 'Statut',
              value: recouvrement['statut']!,
              color: _getStatusColor(recouvrement['statut']!),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Commentaire',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recouvrement['commentaire']!,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.blue),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Recouvré':
        return Colors.green;
      case 'En cours':
        return Colors.orange;
      case 'En attente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Recouvré':
        return Icons.check_circle;
      case 'En cours':
        return Icons.access_time;
      case 'En attente':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }
}

class AddRecouvrementScreen extends StatefulWidget {
  const AddRecouvrementScreen({Key? key}) : super(key: key);

  @override
  State<AddRecouvrementScreen> createState() => _AddRecouvrementScreenState();
}

class _AddRecouvrementScreenState extends State<AddRecouvrementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _montantController = TextEditingController();
  final _commentaireController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedStatus = 'En attente';

  @override
  void dispose() {
    _clientController.dispose();
    _montantController.dispose();
    _commentaireController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un recouvrement'),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _clientController,
                decoration: InputDecoration(
                  labelText: 'Client*',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un client';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montantController,
                decoration: InputDecoration(
                  labelText: 'Montant*',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.euro),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date*',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Sélectionner une date',
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Statut*',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.stairs),
                ),
                items: ['En attente', 'En cours', 'Recouvré']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentaireController,
                decoration: InputDecoration(
                  labelText: 'Commentaire',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedDate != null) {
                    Navigator.pop(context, {
                      'client': _clientController.text,
                      'date':
                          '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      'montant': '${_montantController.text} €',
                      'statut': _selectedStatus,
                      'commentaire': _commentaireController.text,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecouvrementsScreen extends StatefulWidget {
  const RecouvrementsScreen({super.key});

  @override
  State<RecouvrementsScreen> createState() => _RecouvrementsScreenState();
}

class _RecouvrementsScreenState extends State<RecouvrementsScreen> {
  List<Map<String, String>> _recouvrements = [
    {
      'client': 'Jean Dupont',
      'date': '15/07/2025',
      'montant': '500 €',
      'statut': 'En cours',
      'commentaire': 'Paiement partiel reçu',
    },
    {
      'client': 'Marie Curie',
      'date': '18/07/2025',
      'montant': '1500 €',
      'statut': 'Recouvré',
      'commentaire': 'Paiement intégral',
    },
    {
      'client': 'Paul Martin',
      'date': '20/07/2025',
      'montant': '700 €',
      'statut': 'En attente',
      'commentaire': 'Relance prévue',
    },
  ];

  String _searchQuery = '';
  String _selectedFilter = 'Tous';

  void _addRecouvrement() async {
    final newRecouvrement = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRecouvrementScreen()),
    );
    if (newRecouvrement != null) {
      setState(() {
        _recouvrements.add(newRecouvrement as Map<String, String>);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouveau recouvrement ajouté avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _markAsRecovered(int index) {
    setState(() {
      _recouvrements[index]['statut'] = 'Recouvré';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Le recouvrement pour ${_recouvrements[index]['client']} a été marqué comme Recouvré.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecouvrements = _recouvrements.where((recouvrement) {
      final matchesSearch = recouvrement['client']!.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesFilter =
          _selectedFilter == 'Tous' ||
          recouvrement['statut'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Recouvrements',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Ajouter un recouvrement',
            onPressed: _addRecouvrement,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Rechercher un client',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Tous', 'En attente', 'En cours', 'Recouvré'].map((
                    statut,
                  ) {
                    return FilterChip(
                      label: Text(statut),
                      selected: _selectedFilter == statut,
                      selectedColor: const Color(0xFF1976D2),
                      labelStyle: TextStyle(
                        color: _selectedFilter == statut
                            ? Colors.white
                            : Colors.black87,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected ? statut : 'Tous';
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredRecouvrements.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucun recouvrement trouvé',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredRecouvrements.length,
                    itemBuilder: (context, index) {
                      final recouvrement = filteredRecouvrements[index];
                      final originalIndex = _recouvrements.indexOf(
                        recouvrement,
                      );
                      return _buildRecouvrementCard(
                        recouvrement,
                        originalIndex,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecouvrementCard(Map<String, String> recouvrement, int index) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'Recouvré':
          return Colors.green;
        case 'En cours':
          return Colors.orange;
        case 'En attente':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    IconData getStatusIcon(String status) {
      switch (status) {
        case 'Recouvré':
          return Icons.check_circle;
        case 'En cours':
          return Icons.access_time;
        case 'En attente':
          return Icons.warning;
        default:
          return Icons.help_outline;
      }
    }

    final statusColor = getStatusColor(recouvrement['statut']!);
    final statusIcon = getStatusIcon(recouvrement['statut']!);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailRecouvrementScreen(recouvrement: recouvrement),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      recouvrement['client']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          recouvrement['statut']!,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.euro, 'Montant', recouvrement['montant']!),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today,
                'Date',
                recouvrement['date']!,
              ),
              const SizedBox(height: 12),
              if (recouvrement['commentaire']!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Commentaire :',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recouvrement['commentaire']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              if (recouvrement['statut'] != 'Recouvré')
                Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                        ),
                        label: Text(
                          'Marquer comme Recouvré',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                        onPressed: () => _markAsRecovered(index),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label : ', style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
