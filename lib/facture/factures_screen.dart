import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detail_facture.dart';
import 'add_facture.dart';
import 'edit_facture.dart';

class FactureScreen extends StatefulWidget {
  const FactureScreen({super.key});

  @override
  State<FactureScreen> createState() => _FactureScreenState();
}

class _FactureScreenState extends State<FactureScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> factures = [];
  bool isLoading = false;
  int currentPage = 1;
  final int pageSize = 20;
  bool hasMore = true;
  String searchQuery = '';
  String selectedFilter = 'Tous';
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final List<String> filterOptions = [
    'Tous',
    'Payées',
    'Impayées',
    'En attente',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _loadFactures();
    _scrollController.addListener(_scrollListener);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMore) {
      _loadFactures();
    }
  }

  Future<void> _loadFactures() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    List<Map<String, dynamic>> newFactures = List.generate(
      pageSize,
      (index) => {
        'id': 'FAC${((currentPage - 1) * pageSize) + index + 1}-2025',
        'numero': 'FAC${((currentPage - 1) * pageSize) + index + 1}-2025',
        'client': 'Client ${((currentPage - 1) * pageSize) + index + 1}',
        'date': DateTime.now().subtract(Duration(days: index * 2)),
        'statut': ['Payée', 'Impayée', 'En attente'][index % 3],
        'montant': 1500.00 + (index * 100),
        'echeance': DateTime.now().add(Duration(days: 30 - (index * 5))),
      },
    );

    if (searchQuery.isNotEmpty) {
      newFactures = newFactures
          .where(
            (facture) =>
                facture['client'].toString().toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                facture['numero'].toString().toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    if (selectedFilter != 'Tous') {
      newFactures = newFactures
          .where((facture) => facture['statut'] == selectedFilter)
          .toList();
    }

    setState(() {
      factures.addAll(newFactures);
      isLoading = false;
      currentPage++;
      if (newFactures.length < pageSize) hasMore = false;
    });
  }

  void _onSearch(String query) {
    setState(() {
      searchQuery = query;
      factures.clear();
      currentPage = 1;
      hasMore = true;
    });
    _loadFactures();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
      factures.clear();
      currentPage = 1;
      hasMore = true;
    });
    _loadFactures();
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'Payée':
        return const Color(0xFF4CAF50);
      case 'Impayée':
        return const Color(0xFFE53935);
      case 'En attente':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getStatusIcon(String statut) {
    switch (statut) {
      case 'Payée':
        return Icons.check_circle;
      case 'Impayée':
        return Icons.error;
      case 'En attente':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Factures',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Rechercher une facture...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF1976D2),
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterOptions.map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1976D2),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) => _onFilterChanged(filter),
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF1976D2),
                          checkmarkColor: Colors.white,
                          elevation: isSelected ? 4 : 1,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.easeOutCubic,
                ),
              ),
          child: factures.isEmpty && !isLoading
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: factures.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < factures.length) {
                      final facture = factures[index];
                      return _buildFactureCard(facture, index);
                    } else {
                      return _buildLoadingIndicator();
                    }
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFactureScreen()),
          );
        },
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Facture'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 80,
              color: const Color(0xFF1976D2).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune facture trouvée',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par créer votre première facture',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFactureScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer une facture'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactureCard(Map<String, dynamic> facture, int index) {
    final statusColor = _getStatusColor(facture['statut']);
    final isOverdue =
        facture['statut'] == 'Impayée' &&
        facture['echeance'].isBefore(DateTime.now());

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 50),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.blue.shade50.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailFactureScreen(factureId: facture['id']),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1976D2,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: Color(0xFF1976D2),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      facture['numero'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      facture['client'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getStatusIcon(facture['statut']),
                                          size: 16,
                                          color: statusColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          facture['statut'],
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${facture['montant'].toStringAsFixed(2)} €',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1976D2),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  Icons.calendar_today,
                                  'Date',
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(facture['date']),
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  Icons.schedule,
                                  'Échéance',
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(facture['echeance']),
                                  isOverdue: isOverdue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditFactureScreen(
                                          factureId: facture['id'],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Modifier'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1976D2),
                                    side: const BorderSide(
                                      color: Color(0xFF1976D2),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailFactureScreen(
                                              factureId: facture['id'],
                                            ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.visibility, size: 16),
                                  label: const Text('Voir'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      },
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value, {
    bool isOverdue = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isOverdue ? Colors.red : Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isOverdue ? Colors.red : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
        ),
      ),
    );
  }
}
