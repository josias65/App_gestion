// ignore_for_file: unused_import, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

// Import de tous les écrans principaux
import 'login/login.dart';
import 'login/dashboard_screen.dart'
    hide StockListScreen, StockDetailScreen, StockEditScreen;
import 'login/settings.dart';
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

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Gestion Commerciale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
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
        AppRoutes.settings: (context) => const SettingsScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.profil: (context) => const ProfileScreen(),
        AppRoutes.clients: (context) => const ClientListScreen(),
        AppRoutes.addClient: (context) => const AddClientScreen(),
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
                  appel: args['appel'] ?? {},
                  marcheId: args['marcheId'] ?? '',
                  appelId: args['appelId'] ?? '',
                ),
              );
            } else {
              return MaterialPageRoute(
                builder: (_) => const SoumissionScreen(
                  appel: {},
                  marcheId: '',
                  appelId: '',
                ),
              );
            }
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

            break;
          // --- Relances ---
          case AppRoutes.detailRelance:
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => DetailRelanceScreen(relance: args),
              );
            }
            break;
          case AppRoutes.editRelance:
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => EditRelanceScreen(relance: args),
              );
            }
            break;
          case AppRoutes.addRelance:
            final relanceToEdit = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => AddRelanceScreen(relanceToEdit: relanceToEdit),
            );
          // --- Recouvrements ---
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
              return MaterialPageRoute(
                builder: (_) => EditRecouvrementScreen(recouvrement: args),
              );
            }
            break;
          // --- Commandes ---
          case AppRoutes.detailCommande:
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => DetailCommandeScreen(
                  commande: args,
                  commandeId: args['id']?.toString() ?? '',
                ),
              );
            }
            break;
          case AppRoutes.editCommande:
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => EditCommandeScreen(
                  commandeId: args['id']?.toString() ?? '',
                ),
              );
            }
            break;
          // --- Factures ---
          case AppRoutes.detailFacture:
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => DetailFactureScreen(
                  factureId: args['id']?.toString() ?? '',
                ),
              );
            }
            break;
          case AppRoutes.editFacture:
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) =>
                    EditFactureScreen(factureId: args['id']?.toString() ?? ''),
              );
            }
            break;
        }
        return null;
      },
    );
  }
}
