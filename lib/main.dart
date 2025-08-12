// ignore_for_file: unused_import, prefer_typing_uninitialized_variables

import 'package:appgestion/relances/add_relance.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

import 'appel_d_offre/add_app.dart';
import 'appel_d_offre/detail_app_screen.dart';
import 'appel_d_offre/list_screen.dart';
import 'client/add_screen.dart';
import 'client/detail_screen.dart';
import 'client/list_screen.dart';
import 'commande/add_commande.dart';
import 'commande/commandes_Screen.dart' hide AppRoutes;
import 'commande/detail_commande.dart';
import 'commande/edit_commande.dart';
import 'devis/create.dart';
import 'devis/detail.dart';
import 'devis/list.dart';
import 'facture/add_facture.dart';
import 'facture/detail_facture.dart';
import 'facture/edit_facture.dart';
import 'facture/factures_Screen.dart';
import 'login/dashboard_screen.dart'
    hide
        StockListScreen,
        StockDetailScreen,
        StockEditScreen,
        AppelsOffresScreen;
import 'login/login.dart';
import 'login/mot_de_passe.dart';
import 'login/settings.dart';
import 'marche/historique_marches.dart';
import 'marche/marche_add.dart';
// ignore: undefined_hidden_name
import 'marche/marche_detail.dart' hide SoumissionScreen;
import 'marche/marche_list.dart';
// ignore: undefined_hidden_name
import 'marche/soumission.dart' hide MarcheDetailScreen;
import 'models/devis_model.dart';
import 'profil/profil_screen.dart';
import 'recouvrements/Recouvrements_Screen.dart' hide DetailRecouvrementScreen;
import 'recouvrements/detail_recouvrement.dart';
import 'recouvrements/edit_recouvrement.dart';
// ignore: undefined_hidden_name
import 'relances/RelancesScreen.dart' hide AddRelanceScreen;
import 'relances/detail_relance.dart';
import 'relances/edit_relance.dart';
import 'routes/app_routes.dart';
import 'stock/addstock.dart';
import 'stock/stock_list.dart';
// ignore: undefined_hidden_name
import 'stock/stock_detail.dart' hide StockEditScreen;
import 'stock/stock_edit.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

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
        AppRoutes.marcheSoumission: (context) =>
            const SoumissionScreen(appel: {}, marcheId: '', appelId: ''),
        AppRoutes.marcheDetail: (context) =>
            const MarcheDetailScreen(appel: {}),
        AppRoutes.stock: (context) => const StockListScreen(),

        AppRoutes.relances: (context) => const RelancesScreen(),
        AppRoutes.recouvrements: (context) => const RecouvrementsScreen(),
        AppRoutes.addRecouvrement: (context) => const AddRecouvrementScreen(),
        AppRoutes.commandes: (context) => const CommandesScreen(),
        AppRoutes.addCommande: (context) => const AddCommandeScreen(),
        AppRoutes.factures: (context) => const FactureScreen(),
        AppRoutes.addFacture: (context) => const AddFACTUREScreen(),
      },
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;
        switch (settings.name) {
          case AppRoutes.detailAppelOffre:
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
          case AppRoutes.marcheDetail:
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => MarcheDetailScreen(appel: args),
              );
            }
            break;
          case AppRoutes.marcheAdd:
            final marcheToEdit = args;
            return MaterialPageRoute(
              builder: (_) => MarcheAddScreen(marcheToEdit: marcheToEdit),
            );
          case AppRoutes.marcheSoumission:
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => SoumissionScreen(
                  appel: args['appel'] ?? {},
                  marcheId: args['marcheId'] ?? '',
                  appelId: args['appelId'] ?? '',
                ),
              );
            } else {
              // Fallback si pas d'arguments
              return MaterialPageRoute(
                builder: (_) => const SoumissionScreen(
                  appel: {},
                  marcheId: '',
                  appelId: '',
                ),
              );
            }
          case AppRoutes.stockDetail:
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => StockDetailScreen(article: args),
              );
            }
            break;
          case AppRoutes.addStock:
            final articleToEdit = args;
            return MaterialPageRoute<Map<String, dynamic>>(
              builder: (_) => AddStockScreen(articleToEdit: articleToEdit),
            );
          case AppRoutes.stockEdit:
            if (args != null) {
              return MaterialPageRoute<Map<String, dynamic>>(
                builder: (_) => StockEditScreen(existingItem: args),
              );
            }
            break;
          case AppRoutes.clientDetail:
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => ClientDetailScreen(client: args),
              );
            }
            break;
          case AppRoutes.devisDetail:
            final devis = settings.arguments as DevisModel?;
            if (devis != null) {
              return MaterialPageRoute(
                builder: (_) => DevisDetailScreen(devis: devis),
              );
            }
            break;
          case AppRoutes.detailRelance:
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => DetailRelanceScreen(relance: args),
              );
            }
            break;
          case AppRoutes.editRelance:
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => EditRelanceScreen(relance: args),
              );
            }
            break;
          case AppRoutes.addRelance:
            final relanceToEdit = args;
            return MaterialPageRoute(
              builder: (_) => AddRelanceScreen(relanceToEdit: relanceToEdit),
            );
          case AppRoutes.detailRecouvrement:
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => DetailRecouvrementScreen(recouvrement: args),
              );
            }
            break;
          case AppRoutes.editRecouvrement:
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => EditRecouvrementScreen(recouvrement: args),
              );
            }
            break;
          case AppRoutes.detailCommande:
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
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) =>
                    EditCommandeScreen(commandeId: args['id'] ?? ''),
              );
            }
            break;
          case AppRoutes.detailFacture:
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) =>
                    DetailFactureScreen(factureId: args['id'] ?? ''),
              );
            }
            break;
          case AppRoutes.editFacture:
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => EditFactureScreen(factureId: args['id'] ?? ''),
              );
            }
            break;
        }

        return null;
      },
    );
  }
}
