class AppRoutes {
  // Authentication
  static const String login = '/login';
  static const String forgotPassword = '/mot_de_passe';
  static const String changePassword = '/change-password';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Clients
  static const String clients = '/clients';
  static const String addClient = '/add-client';
  static const String clientDetail = '/client-detail';
  static String getClientDetail(String id) => '$clientDetail/$id';

  // Quotes (Devis)
  static const String devis = '/devis';
  static const String devisDetail = '/devis/detail';
  static const String createDevis = '/devis-create';
  static String getDevisDetail(String id) => '$devisDetail/$id';

  // Stock
  static const String stock = '/stock';
  static const String addStock = '/addstock';
  static const String stockDetail = '/stockdetail';
  static const String stockEdit = '/stockedit';
  static String getStockDetail(String id) => '$stockDetail/$id';
  static String getStockEdit(String id) => '$stockEdit/$id';

  // Tenders (Appels d’Offres)
  static const String listAppelsOffres = '/AppelsOffresScreen';
  static const String addAppelOffre = '/appelcreate';
  static const String detailAppelOffre = '/appeldetail';
  static String getAppelOffreDetail(String id) => '$detailAppelOffre/$id';

  // Markets (Marché)
  static const String marcheList = '/marcheList';
  static const String marcheAdd = '/marcheadd';
  static const String marcheDetail = '/marchedetail';
  static const String marcheSoumission = '/marchesoumission';
  static const String marcheHistorique = '/marchehistorique';
  static String getMarcheDetail(String id) => '$marcheDetail/$id';
  static String getMarcheSoumission(String id) => '$marcheSoumission/$id';

  // Reminders (Relances)
  static const String relances = '/relances';
  static const String addRelance = '/addrelance';
  static const String detailRelance = '/relancedetail';
  static const String editRelance = '/relanceedit';
  static String getDetailRelance(String id) => '$detailRelance/$id';
  static String getEditRelance(String id) => '$editRelance/$id';

  // Recoveries (Recouvrements)
  static const String recouvrements = '/recouvrements';
  static const String addRecouvrement = '/addrecouvrement';
  static const String detailRecouvrement = '/recouvrementdetail';
  static const String editRecouvrement = '/recouvrementedit';
  static String getDetailRecouvrement(String id) => '$detailRecouvrement/$id';
  static String getEditRecouvrement(String id) => '$editRecouvrement/$id';

  // Orders (Commandes)
  static const String commandes = '/commandes';
  static const String addCommande = '/addCommande';
  static const String detailCommande = '/commandedetail';
  static const String editCommande = '/commandeedit';
  static String getDetailCommande(String id) => '$detailCommande/$id';
  static String getEditCommande(String id) => '$editCommande/$id';

  // Invoices (Factures)
  static const String factures = '/factures';
  static const String addFacture = '/addfacture';
  static const String detailFacture = '/facturedetail';
  static const String editFacture = '/factureedit';
  static String getDetailFacture(String id) => '$detailFacture/$id';
  static String getEditFacture(String id) => '$editFacture/$id';

  // Settings and Profile
  static const String profil = '/profil';
  static const String settings = '/settings';
  
  // Test Backend
  static const String testBackend = '/test-backend';
  
  // Test Database
  static const String testDatabase = '/test-database';
}
