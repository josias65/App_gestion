// ignore_for_file: unused_import, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:shared_preferences/shared_preferences.dart';

import 'config/api_config.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'services/database_service.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';

// Import de tous les écrans principaux
import 'login/login.dart';
import 'login/dashboard_screen.dart'
        // ignore: undefined_hidden_name
        hide
        StockListScreen,
        StockDetailScreen,
        StockEditScreen;
import 'login/settings_simple.dart';
import 'login/mot_de_passe.dart';
import 'profil/profil_screen.dart';
import 'client/list_screen.dart';
import 'client/add_screen.dart';
import 'client/detail_screen.dart';
import 'appel_d_offre/list_screen.dart';
import 'appel_d_offre/add_app.dart';
import 'appel_d_offre/detail_app_screen.dart';
import 'marche/marche_list.dart';
import 'marche/marche_add.dart';
import 'marche/marche_detail.dart';
import 'marche/soumission.dart';
import 'marche/historique_marches.dart';
import 'stock/stock_list.dart';
import 'stock/addstock.dart';
import 'stock/stock_detail.dart';
import 'stock/stock_edit.dart';
import 'devis/list.dart';
import 'devis/create.dart';
import 'devis/detail.dart';
import 'models/devis_model.dart';
import 'commande/commandes_screen.dart';
import 'commande/add_commande.dart';
import 'commande/detail_commande.dart';
import 'commande/edit_commande.dart';
import 'facture/factures_screen.dart';
import 'facture/add_facture.dart';
import 'facture/detail_facture.dart';
import 'facture/edit_facture.dart';
import 'relances/RelancesScreen.dart';
import 'relances/add_relance.dart';
import 'relances/detail_relance.dart';
import 'relances/edit_relance.dart';
import 'recouvrements/recouvrements_screen.dart'
    hide AddRecouvrementScreen, DetailRecouvrementScreen;
import 'recouvrements/add_recouvrement.dart';
import 'recouvrements/detail_recouvrement.dart';
import 'recouvrements/edit_recouvrement.dart';
import 'routes/app_routes.dart';

import 'login/test_backend_screen.dart';
import 'screens/service_test_screen.dart';
import 'login/test_appel_offre_screen.dart';

Future<void> main() async {
  // Assure que le binding Flutter est initialisé
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration de l'orientation de l'écran
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialisation des services
  await _initializeServices();

  // Démarrer l'application
  runApp(const MyApp());
}

/// Initialise les services de l'application
Future<void> _initializeServices() async {
  try {
    // Initialiser SharedPreferences
    await SharedPreferences.getInstance();

    // Initialiser Hive
    await Hive.initFlutter();

    // Initialiser le service de base de données
    await DatabaseService.initialize();

    // Initialiser le client API
    final apiClient = ApiClient.instance;
    apiClient.initialize();

    // Vérifier si on est en mode développement
    final bool isDev = AppConfig.isDevelopment;
    final bool useMock = ApiConfig.useMockData;

    if (kDebugMode) {
      print('Mode développement: $isDev');
      print('Mode mock activé: $useMock');
      print('URL de base de l\'API: ${ApiConfig.baseUrlForEnvironment}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erreur lors de l\'initialisation des services: $e');
    }
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  get args => null;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Fournisseur d'authentification
        ChangeNotifierProvider(create: (context) => AuthProvider()),

        // Fournisseur du client API
        Provider<ApiClient>(
          create: (context) => ApiClient.instance,
          dispose: (_, client) => client.dispose(),
        ),

        // Fournisseur du service de base de données
        Provider<DatabaseService>(
          create: (context) => DatabaseService.instance,
          dispose: (_, service) => service.close(),
        ),
      ],
      child: MaterialApp(
        title: 'Gestion Commerciale',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return authProvider.isAuthenticated
                ? const DashboardScreen()
                : const LoginScreen();
          },
        ),
        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.dashboard: (context) => const DashboardScreen(),
          AppRoutes.settings: (context) => const SettingsScreenSimple(),
          AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
          AppRoutes.profil: (context) => const ProfileScreen(),
          AppRoutes.clients: (context) => const ClientListScreen(),
          AppRoutes.addClient: (context) => const AddClientScreen(),
          AppRoutes.appelsOffre: (context) => const AppelsOffresScreen(),
          AppRoutes.listAppelsOffres: (context) => const AppelsOffresScreen(),
          AppRoutes.devis: (context) => const DevisListScreen(),
          AppRoutes.createDevis: (context) => const CreateDevisScreen(),
          AppRoutes.marcheList: (context) => const MarcheListScreen(),
          AppRoutes.marcheHistorique: (context) =>
              const HistoriqueMarchesScreen(),
          AppRoutes.stock: (context) => const StockListScreen(),
          AppRoutes.relances: (context) => const RelancesScreen(),
          AppRoutes.recouvrements: (context) => const RecouvrementsScreen(),
          AppRoutes.addRecouvrement: (context) => const AddRecouvrementScreen(),
          AppRoutes.commandes: (context) => const CommandesScreen(),
          AppRoutes.addCommande: (context) => const AddCommandeScreen(),
          AppRoutes.factures: (context) => const FactureScreen(),
          AppRoutes.addFacture: (context) => const AddFactureScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            // --- Appel d'offre ---
            case AppRoutes.detailAppelOffre:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute(
                  builder: (_) => DetailAppelOffreScreen(appel: args),
                );
              }
              break;
            case AppRoutes.addAppelOffre:
              return MaterialPageRoute(
                builder: (_) => const AddAppelOffreScreen(),
              );

            // --- Marché ---
            case AppRoutes.marcheDetail:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute(
                  builder: (_) => MarcheDetailScreen(appel: args),
                );
              }
              break;
            case AppRoutes.marcheAdd:
              final marcheToEdit = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => MarcheAddScreen(marcheToEdit: marcheToEdit),
              );
            case AppRoutes.marcheSoumission:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute(
                  builder: (_) => SoumissionScreen(
                    marche: args,
                    appelId: '',
                    marcheId: '',
                    appel: const {},
                  ),
                );
              }
              break;

            // --- Stock ---
            case AppRoutes.stockDetail:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute(
                  builder: (_) => StockDetailScreen(article: args),
                );
              }
              break;
            case AppRoutes.addStock:
              final articleToEdit = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute<Map<String, dynamic>>(
                builder: (_) => AddStockScreen(articleToEdit: articleToEdit),
              );
            case AppRoutes.stockEdit:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute<Map<String, dynamic>>(
                  builder: (_) => StockEditScreen(existingItem: args),
                );
              }
              break;

            // --- Client ---
            case AppRoutes.clientDetail:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute(
                  builder: (_) => ClientDetailScreen(client: args),
                );
              }
              break;

            // --- Devis ---
            case AppRoutes.devisDetail:
              final arg = settings.arguments;
              DevisModel? devis;
              if (arg is DevisModel) {
                devis = arg;
              } else if (arg is Map<String, dynamic>) {
                devis = DevisModel(
                  reference: arg['reference'] ?? '',
                  client: arg['client'] ?? '',
                  date: arg['date'] ?? '',
                  status: arg['status'] ?? '',
                  total: (arg['total'] is num) ? arg['total'].toDouble() : 0.0,
                  articles:
                      (arg['articles'] as List<dynamic>?)
                          ?.cast<Map<String, dynamic>>() ??
                      [],
                );
              }
              if (devis != null) {
                return MaterialPageRoute(
                  builder: (_) =>
                      DevisDetailScreen(devis: args, devisId: args['id'] ?? ''),
                );
              }
              break;

            // --- Commande ---
            case AppRoutes.detailCommande:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute(
                  builder: (_) => DetailCommandeScreen(
                    commande: args,
                    commandeId: args['id'] ?? '',
                  ),
                );
              }
              break;
            case AppRoutes.editCommande:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute<Map<String, dynamic>>(
                  builder: (_) => EditCommandeScreen(
                    commandeToEdit: args,
                    commandeId: args['id'] ?? '',
                  ),
                );
              }
              break;

            // --- Facture ---
            case AppRoutes.detailFacture:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute(
                  builder: (_) =>
                      DetailFactureScreen(facture: args, factureId: ''),
                );
              }
              break;
            case AppRoutes.editFacture:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute<Map<String, dynamic>>(
                  builder: (_) => EditFactureScreen(
                    factureToEdit: args,
                    factureId: args['id'] ?? '',
                  ),
                );
              }
              break;

            // --- Relance ---
            case AppRoutes.detailRelance:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute(
                  builder: (_) => DetailRelanceScreen(relance: args),
                );
              }
              break;
            case AppRoutes.addRelance:
              return MaterialPageRoute<Map<String, dynamic>>(
                builder: (_) => const AddRelanceScreen(),
              );
            case AppRoutes.editRelance:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute<Map<String, dynamic>>(
                  builder: (_) =>
                      EditRelanceScreen(relanceToEdit: args, relance: {}),
                );
              }
              break;

            // --- Recouvrement ---
            case AppRoutes.detailRecouvrement:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute(
                  builder: (_) => DetailRecouvrementScreen(recouvrement: args),
                );
              }
              break;
            case AppRoutes.editRecouvrement:
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute<Map<String, dynamic>>(
                  builder: (_) => EditRecouvrementScreen(
                    recouvrementToEdit: args,
                    recouvrement: {},
                  ),
                );
              }
              break;

            // --- Test Backend ---
            case AppRoutes.testBackend:
              return MaterialPageRoute(
                builder: (_) => const TestBackendScreen(),
              );

            // --- Test Database ---
            case AppRoutes.testDatabase:
              return MaterialPageRoute(
                builder: (_) => const ServiceTestScreen(),
              );

            // --- Test Appels d'Offre ---
            case AppRoutes.testAppelOffre:
              return MaterialPageRoute(
                builder: (_) => const TestAppelOffreScreen(),
              );
          }

          // Route par défaut
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        },
      ),
    );
  }
}
