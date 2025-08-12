import 'package:flutter/material.dart';

import '../login/dashboard_screen.dart';
import 'detail_commande.dart';
// ignore: unused_import
import 'package:appgestion/routes/app_routes.dart';

class CommandesScreen extends StatefulWidget {
  const CommandesScreen({super.key});

  @override
  State<CommandesScreen> createState() => _CommandesScreenState();
}

class _CommandesScreenState extends State<CommandesScreen>
    with TickerProviderStateMixin {
  // Animation controller for fade-in effect on the whole screen
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State variables for search and filtering
  String selectedFilter = 'Tous';
  String searchQuery = '';

  // Mock data for the list of orders
  final List<Map<String, String>> commandes = const [
    {
      'numero': 'CMD001',
      'client': 'Jean Dupont',
      'date': '2025-07-20',
      'statut': 'En cours',
    },
    {
      'numero': 'CMD002',
      'client': 'Marie Curie',
      'date': '2025-07-22',
      'statut': 'Livrée',
    },
    {
      'numero': 'CMD003',
      'client': 'Paul Martin',
      'date': '2025-07-25',
      'statut': 'Annulée',
    },
    {
      'numero': 'CMD004',
      'client': 'Lucie Bernard',
      'date': '2025-07-28',
      'statut': 'En cours',
    },
    {
      'numero': 'CMD005',
      'client': 'Pierre Dubois',
      'date': '2025-07-30',
      'statut': 'Livrée',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller and start the animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    // Dispose the animation controller when the widget is removed
    _animationController.dispose();
    super.dispose();
  }

  // Getter to provide a filtered list of orders based on search and status
  List<Map<String, String>> get filteredCommandes {
    return commandes.where((commande) {
      final matchesSearch =
          commande['client']!.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          commande['numero']!.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesFilter =
          selectedFilter == 'Tous' || commande['statut'] == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // Helper method to get the status color
  Color statusColor(String status) {
    switch (status) {
      case 'Livrée':
        return Colors.green;
      case 'Annulée':
        return Colors.red;
      case 'En cours':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get the status icon
  IconData statusIcon(String status) {
    switch (status) {
      case 'Livrée':
        return Icons.check_circle;
      case 'Annulée':
        return Icons.cancel;
      case 'En cours':
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredCommandes;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Light grey background
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation, // Apply fade animation to the body
        child: Column(
          children: [
            _buildStatsHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 20),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : _buildCommandesList(filtered),
            ),
          ],
        ),
      ),
    );
  }

  // --- Auxiliary Widgets ---

  // Custom app bar with modern styling
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          },
        ),
      ),
      title: const Text(
        'Mes Commandes',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF0D47A1)),
            onPressed: () async {
              final nouvelleCommande = await Navigator.pushNamed(
                context,
                '/addCommande',
              );

              if (nouvelleCommande != null && mounted) {
                setState(() {
                  commandes.add(nouvelleCommande as Map<String, String>);
                });
              }
            },
          ),
        ),
      ],
    );
  }

  // Header showing order statistics
  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques des commandes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Row for the first three stat cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  commandes.length.toString(),
                  Icons.shopping_cart_outlined,
                  const Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'En cours',
                  commandes
                      .where((c) => c['statut'] == 'En cours')
                      .length
                      .toString(),
                  Icons.access_time,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Livrées',
                  commandes
                      .where((c) => c['statut'] == 'Livrée')
                      .length
                      .toString(),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row for the last stat card (Annulées)
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Annulées',
                  commandes
                      .where((c) => c['statut'] == 'Annulée')
                      .length
                      .toString(),
                  Icons.cancel_outlined,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable widget for a single statistic card
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Search bar widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
          hintText: "Rechercher une commande ou un client...",
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
          ),
        ),
      ),
    );
  }

  // Filter chips for different order statuses
  Widget _buildFilterChips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            'Tous',
            'En cours',
            'Livrée',
            'Annulée',
          ].map((filter) => _buildFilterChip(filter)).toList(),
        ),
      ),
    );
  }

  // Reusable widget for a single filter chip
  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D47A1) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D47A1) : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0D47A1).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // List of filtered orders with animations
  Widget _buildCommandesList(List<Map<String, String>> filtered) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final commande = filtered[index];
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildCommandeCard(commande),
              ),
            );
          },
        );
      },
    );
  }

  // Reusable widget for a single order card
  Widget _buildCommandeCard(Map<String, String> commande) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DetailCommandeScreen(commande: commande, commandeId: ''),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container for the order
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Order details (number, client, date)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commande n°${commande['numero']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Client: ${commande['client']!}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${commande['date']!}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Status pill for the order
              _buildStatusPill(commande['statut']!),
              const SizedBox(width: 8),
              // Arrow icon
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for the status pill (e.g., 'Livrée', 'En cours')
  Widget _buildStatusPill(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor(status).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon(status), size: 14, color: statusColor(status)),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: statusColor(status),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display when no orders are found
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucune commande trouvée',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Essayez de modifier vos critères de recherche ou d'ajouter une nouvelle commande.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AppRoutes {
  static const String addCommande = '/addCommande';
  static const String detailCommande = '/detailCommande';
}
