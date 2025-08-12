import 'package:appgestion/routes/app_routes.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:fl_chart/fl_chart.dart';
// ignore: unused_import
import 'package:appgestion/appel_d_offre/list_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// The main entry point of the Flutter application.
void main() {
  runApp(const MyApp());
}

// =============================================================================
// APP AND ROUTING SETUP
// =============================================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          color: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const DashboardScreen(),
      routes: {
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.clients: (context) =>
            const PlaceholderScreen(title: 'Clients'),
        AppRoutes.devis: (context) => const PlaceholderScreen(title: 'Devis'),
        AppRoutes.stock: (context) => const StockListScreen(),
        AppRoutes.commandes: (context) =>
            const PlaceholderScreen(title: 'Commandes'),
        AppRoutes.factures: (context) =>
            const PlaceholderScreen(title: 'Factures'),
        AppRoutes.marcheList: (context) =>
            const PlaceholderScreen(title: 'Marché'),
        AppRoutes.relances: (context) =>
            const PlaceholderScreen(title: 'Relances'),
        AppRoutes.recouvrements: (context) =>
            const PlaceholderScreen(title: 'Recouvrements'),
        AppRoutes.listAppelsOffres: (context) => const AppelsOffresScreen(),
        AppRoutes.settings: (context) =>
            const PlaceholderScreen(title: 'Paramètres'),
        AppRoutes.profil: (context) => const PlaceholderScreen(title: 'Profil'),
      },
    );
  }
}

// A generic placeholder screen for navigation.
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: Center(
        child: Text(
          'Contenu pour la section $title',
          style: const TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ),
    );
  }
}

// =============================================================================
// DASHBOARD SCREEN WIDGETS
// =============================================================================

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    BuildContext context,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tableau de bord",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.forceLogout();
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1E88E5)),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _buildDrawerItem(
              Icons.dashboard,
              'Tableau de Bord',
              context,
              '/dashboard',
            ),
            _buildDrawerItem(
              Icons.people,
              'Clients',
              context,
              AppRoutes.clients,
            ),
            _buildDrawerItem(
              Icons.shopping_cart,
              'Commandes',
              context,
              AppRoutes.commandes,
            ),
            _buildDrawerItem(
              Icons.receipt,
              'Factures',
              context,
              AppRoutes.factures,
            ),
            _buildDrawerItem(
              Icons.description,
              'Devis',
              context,
              AppRoutes.devis,
            ),
            _buildDrawerItem(
              Icons.inventory,
              'Stocks',
              context,
              AppRoutes.stock,
            ),
            _buildDrawerItem(
              Icons.shopping_bag_outlined,
              'Marché',
              context,
              AppRoutes.marcheList,
            ),
            _buildDrawerItem(
              Icons.access_time,
              'Relances',
              context,
              AppRoutes.relances,
            ),
            _buildDrawerItem(
              Icons.history_toggle_off,
              'Recouvrements',
              context,
              AppRoutes.recouvrements,
            ),
            _buildDrawerItem(
              Icons.assignment,
              'Appels d\'offres',
              context,
              AppRoutes.listAppelsOffres,
            ),
            const Divider(),
            _buildDrawerItem(
              Icons.settings,
              'Paramètres',
              context,
              AppRoutes.settings,
            ),
            _buildDrawerItem(Icons.person, 'Profil', context, AppRoutes.profil),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bienvenue👑",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Résumé de votre activité aujourd’hui",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                _StatCard(
                  title: "Ventes du jour",
                  value: "2 500 €",
                  subtitle: "+12% par rapport à hier",
                  icon: Icons.attach_money,
                  color: Color(0xFF1E88E5),
                ),
                SizedBox(width: 12),
                _StatCard(
                  title: "Commandes en cours",
                  value: "15",
                  subtitle: "En progression",
                  icon: Icons.inventory_2_outlined,
                  color: Color(0xFF0D9488),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Évolution des ventes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = [
                            'Lun',
                            'Mar',
                            'Mer',
                            'Jeu',
                            'Ven',
                            'Sam',
                            'Dim',
                          ];
                          return Text(titles[value.toInt()]);
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  barGroups: [3.0, 4.5, 3.2, 4.0, 5.0, 6.2, 5.1]
                      .asMap()
                      .entries
                      .map(
                        (e) => BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value,
                              color: const Color(0xFF1E88E5),
                              width: 14,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Dernières activités",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _ActivityItem(
              icon: Icons.receipt_long,
              text: "Facture #4325 générée",
            ),
            _ActivityItem(
              icon: Icons.person_add_alt_1,
              text: "Nouveau client ajouté",
            ),
          ],
        ),
      ),
    );
  }
}

// A widget for displaying a single statistical card on the dashboard.
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white70)),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// A widget for displaying a single recent activity item.
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ActivityItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0.5,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E3A8A)),
        title: Text(text),
      ),
    );
  }
}

// =============================================================================
// STOCK MANAGEMENT WIDGETS
// =============================================================================

// Placeholder screens for detail and edit views of stock items
class StockDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;
  const StockDetailScreen({Key? key, required this.article}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['nom']),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  article['nom'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Text(
                  'Référence: ${article['reference']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quantité: ${article['quantite']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prix Unitaire: ${article['prixUnitaire']} FCFA',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Seuil Minimum: ${article['seuilMin']}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StockEditScreen extends StatelessWidget {
  final Map<String, dynamic>? articleToEdit;
  const StockEditScreen({
    Key? key,
    this.articleToEdit,
    required Map<String, dynamic> article,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          articleToEdit == null
              ? 'Ajouter un article'
              : 'Modifier ${articleToEdit!['nom']} ',
        ),
        backgroundColor: const Color(0xFF1E88E5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (articleToEdit != null) {
              final updatedItem = Map<String, dynamic>.from(articleToEdit!);
              updatedItem['quantite'] += 10;
              Navigator.pop(context, updatedItem);
            } else {
              Navigator.pop(context, {
                'id': DateTime.now().millisecondsSinceEpoch,
                'nom': 'Nouvel article',
                'reference': 'NEW-REF',
                'quantite': 5,
                'prixUnitaire': 100000,
                'seuilMin': 2,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            articleToEdit == null ? 'Ajouter (simulé)' : 'Modifier (simulé)',
          ),
        ),
      ),
    );
  }
}

// The main stock list screen from our previous conversation
class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  final List<Map<String, dynamic>> _materiels = [
    {
      'id': 1,
      'nom': 'Ordinateur Portable HP',
      'reference': 'HP-LAPTOP-01',
      'quantite': 8,
      'prixUnitaire': 350000,
      'seuilMin': 5,
    },
    {
      'id': 2,
      'nom': 'Imprimante Canon',
      'reference': 'CAN-PRNT-2023',
      'quantite': 3,
      'prixUnitaire': 150000,
      'seuilMin': 2,
    },
    {
      'id': 3,
      'nom': 'Routeur TP-Link',
      'reference': 'TPL-ROUTER-AX1800',
      'quantite': 10,
      'prixUnitaire': 55000,
      'seuilMin': 4,
    },
    {
      'id': 4,
      'nom': 'Clavier mécanique',
      'reference': 'KBD-MECH-05',
      'quantite': 1,
      'prixUnitaire': 45000,
      'seuilMin': 3,
    },
  ];

  String _searchQuery = '';

  void _navigateToDetail(Map<String, dynamic> item) async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => StockDetailScreen(article: item)),
    );
    if (updated != null) {
      _updateItem(updated);
    }
  }

  void _navigateToEdit(Map<String, dynamic>? item) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => StockEditScreen(articleToEdit: item, article: {}),
      ),
    );

    if (result != null) {
      if (item == null) {
        _addItem(result);
      } else {
        _updateItem(result);
      }
    }
  }

  void _deleteItem(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cet article du stock ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _materiels.removeWhere((item) => item['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Article supprimé avec succès')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _addItem(Map<String, dynamic> newItem) {
    setState(() {
      _materiels.add(newItem);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newItem['nom']} a été ajouté au stock')),
    );
  }

  void _updateItem(Map<String, dynamic> updatedItem) {
    setState(() {
      final index = _materiels.indexWhere(
        (item) => item['id'] == updatedItem['id'],
      );
      if (index != -1) {
        _materiels[index] = updatedItem;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${updatedItem['nom']} a été mis à jour')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMateriels = _materiels.where((item) {
      final nom = item['nom'].toString().toLowerCase();
      final ref = item['reference'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return nom.contains(query) || ref.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Stock Informatique',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher un matériel',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: filteredMateriels.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun matériel trouvé.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filteredMateriels.length,
                    itemBuilder: (context, index) {
                      final item = filteredMateriels[index];
                      final quantite = item['quantite'] as int;
                      final seuilMin = item['seuilMin'] as int;
                      final enRupture = quantite <= seuilMin;

                      return _buildStockItemCard(item, enRupture);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEdit(null),
        label: const Text(
          'Ajouter un article',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF1976D2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStockItemCard(Map<String, dynamic> item, bool enRupture) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: enRupture
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _navigateToDetail(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: enRupture
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    enRupture
                        ? Icons.warning_amber
                        : Icons.inventory_2_outlined,
                    color: enRupture ? Colors.red : Colors.green,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nom'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Réf: ${item['reference']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantité: ${item['quantite']}',
                      style: TextStyle(
                        color: enRupture ? Colors.red : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Prix: ${item['prixUnitaire'].toString()} FCFA',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _navigateToEdit(item),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(item['id']),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// APPELS D'OFFRES SCREEN
// =============================================================================

class AppelsOffresScreen extends StatelessWidget {
  const AppelsOffresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> appels = [
      {
        'titre': 'Acquisition de serveurs haute performance',
        'date': '21/07/2025',
        'etat': 'Ouvert',
      },
      {
        'titre': 'Déploiement d\'un réseau sécurisé pour datacenter',
        'date': '18/07/2025',
        'etat': 'Clôturé',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appels d’offres'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appels.length,
        itemBuilder: (context, index) {
          final appel = appels[index];
          final isOpen = appel['etat'] == 'Ouvert';
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            child: ListTile(
              title: Text(appel['titre'] ?? ''),
              subtitle: Text('Date limite : ${appel['date']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isOpen ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  appel['etat'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                // Ajoute ici la navigation vers le détail si besoin
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Ajoute ici la logique pour créer un nouvel appel d’offres
        },
        label: const Text('Nouvel appel'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF0D47A1),
      ),
    );
  }
}
