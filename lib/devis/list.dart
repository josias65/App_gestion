import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../models/devis_model.dart';

class DevisListScreen extends StatefulWidget {
  const DevisListScreen({super.key});

  @override
  State<DevisListScreen> createState() => _DevisListScreenState();
}

class _DevisListScreenState extends State<DevisListScreen>
    with TickerProviderStateMixin {
  // Animation controller for fade-in effect on the body
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State variable to track the currently selected filter
  String selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
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
    _animationController.dispose();
    super.dispose();
  }

  // Helper function to determine the color based on the quote status
  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepté':
        return Colors.green;
      case 'refusé':
        return Colors.red;
      case 'en attente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Helper function to determine the icon based on the quote status
  IconData statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepté':
        return Icons.check_circle;
      case 'refusé':
        return Icons.cancel;
      case 'en attente':
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DevisModel> devisList = [
      DevisModel(
        reference: "DV001",
        client: "Josias",
        date: "2025-07-15",
        status: "En attente",
        total: 1250.0,
      ),
      DevisModel(
        reference: "DV002",
        client: "Sarah",
        date: "2025-07-14",
        status: "Accepté",
        total: 850.0,
      ),
      DevisModel(
        reference: "DV003",
        client: "Daniel",
        date: "2025-07-13",
        status: "Refusé",
        total: 490.0,
      ),
    ];

    // Filter the quotes based on the selected status
    var filteredDevis = devisList.where((devis) {
      if (selectedFilter == 'Tous') return true;
      return devis.status == selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboard,
                (route) => false,
              );
            },
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Mes Devis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3F1FBF), Color(0xFF6C5CE7)],
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header with statistics
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF8F9FF)],
                ),
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
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          devisList.length.toString(),
                          Icons.description_outlined,
                          const Color(0xFF3F1FBF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Acceptés',
                          devisList
                              .where((d) => d.status == 'Accepté')
                              .length
                              .toString(),
                          Icons.check_circle_outline,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'En attente',
                          devisList
                              .where((d) => d.status == 'En attente')
                              .length
                              .toString(),
                          Icons.access_time,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Refusés',
                          devisList
                              .where((d) => d.status == 'Refusé')
                              .length
                              .toString(),
                          Icons.cancel_outlined,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Total amount card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3F1FBF), Color(0xFF6C5CE7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Montant Total',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${devisList.fold(0.0, (sum, devis) => sum + devis.total).toStringAsFixed(2)} €',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter chips
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(Icons.filter_list, color: Color(0xFF3F1FBF)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Tous',
                          'En attente',
                          'Accepté',
                          'Refusé',
                        ].map((filter) => _buildFilterChip(filter)).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // List of quotes
            Expanded(
              child: filteredDevis.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredDevis.length,
                      itemBuilder: (context, index) {
                        final devis = filteredDevis[index];
                        return TweenAnimationBuilder(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: _buildDevisCard(
                                  devis,
                                  statusColor,
                                  statusIcon,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3F1FBF), Color(0xFF6C5CE7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3F1FBF).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.createDevis),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Créer un devis",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // Widget to build the small stat cards in the header
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
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget to build a single filter chip
  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3F1FBF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF3F1FBF),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Widget to build a single quote card
  Widget _buildDevisCard(
    DevisModel devis,
    Color Function(String) statusColor,
    IconData Function(String) statusIcon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.pushNamed(
              context,
              AppRoutes.getDevisDetail(devis.reference),
              arguments: {'devis': devis},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3F1FBF), Color(0xFF6C5CE7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            devis.reference,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${devis.total.toStringAsFixed(2)} €",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F1FBF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            devis.client,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            devis.date,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(devis.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: statusColor(
                                  devis.status,
                                ).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusIcon(devis.status),
                                  size: 14,
                                  color: statusColor(devis.status),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  devis.status,
                                  style: TextStyle(
                                    color: statusColor(devis.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget to display a message when the list is empty
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF3F1FBF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 50,
              color: Color(0xFF3F1FBF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun devis trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres ou créez un nouveau devis',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
