# appgestion

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data to pass to the DetailRecouvrementScreen
    final sampleRecouvrement = {
      'id': 123456789,
      'client': 'Client Exemple SARL',
      'montant': '150000',
      'soldeRestant': '50000',
      'factureId': 'FACT-2023-001',
      'date': '15/08/2025',
      'statut': 'En cours',
      'commentaire': 'Premier contact établi. Client a demandé une prolongation.',
    };

    return MaterialApp(
      title: 'Détail du recouvrement',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // Use a a simple home screen to show navigation to the detail screen
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Accueil'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailRecouvrementScreen(recouvrement: sampleRecouvrement),
                ),
              );
            },
            child: const Text('Voir le détail du recouvrement'),
          ),
        ),
      ),
    );
  }
}
