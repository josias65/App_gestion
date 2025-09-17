import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

// DetailFactureScreen to display and manage an invoice.
class DetailFactureScreen extends StatefulWidget {
  final String factureId;

  const DetailFactureScreen({
    super.key,
    required this.factureId,
    required Map<String, dynamic> facture,
  });

  @override
  State<DetailFactureScreen> createState() => _DetailFactureScreenState();
}

class _DetailFactureScreenState extends State<DetailFactureScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Mock invoice data. In a real app, this would be fetched from an API or database
  Map<String, dynamic> _getFactureDetails() {
    return {
      'id': widget.factureId,
      'numero': 'FAC001-2025',
      'client': 'Jean konami',
      'date': '2025-07-21',
      'statut': 'Payée',
      'montant': 1500.00,
      'articles': [
        {'nom': 'Produit A', 'quantite': 15, 'prixUnitaire': 50.00},
        {'nom': 'Produit B', 'quantite': 7, 'prixUnitaire': 100.00},
      ],
      'societe': {
        'nom': 'Ma Super Entreprise',
        'adresse': '123 Rue de la Créativité, 75001 Paris',
        'email': 'contact@monentreprise.com',
        'telephone': '01 23 45 67 89',
      },
    };
  }

  // Generates a PDF file from the invoice data.
  Future<File> generatePdf(Map<String, dynamic> facture) async {
    final pdf = pw.Document();

    final societe = facture['societe'] as Map<String, dynamic>;
    final articles = facture['articles'] as List<Map<String, dynamic>>;

    final headers = [
      'Article',
      'Quantité',
      'Prix unitaire (frcfa)',
      'Total (frcfa)',
    ];
    final data = articles.map((item) {
      final totalArticle = (item['quantite'] * item['prixUnitaire']);
      return [
        item['nom'].toString(),
        item['quantite'].toString(),
        item['prixUnitaire'].toStringAsFixed(2),
        totalArticle.toStringAsFixed(2),
      ];
    }).toList();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header section with company and invoice title
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      societe['nom']!,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(societe['adresse']!),
                    pw.Text(societe['email']!),
                    pw.Text(societe['telephone']!),
                  ],
                ),
                pw.Text(
                  "FACTURE",
                  style: pw.TextStyle(
                    fontSize: 40,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 20),
            // Invoice recipient and details
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "FACTURE À :",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(facture['client']!),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Numéro de facture : ${facture['numero']!}"),
                    pw.Text("Date d'émission : ${facture['date']!}"),
                    pw.Text("Statut : ${facture['statut']!}"),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            // Table for invoice items
            pw.Table.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
              },
            ),
            pw.SizedBox(height: 20),
            // Total amount
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  "TOTAL: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  "${(facture['montant'] as double).toStringAsFixed(2)} frcfa",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Divider(),
            // Footer message
            pw.Center(
              child: pw.Text(
                "Merci pour votre confiance !",
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );

    // Save the PDF to a temporary directory.
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/facture_${facture['numero']}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Helper to determine the color of the status chip.
  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'payée':
        return const Color(0xFF4CAF50);
      case 'impayée':
        return const Color(0xFFE53935);
      case 'en attente':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final facture = _getFactureDetails();
    final statusColor = _getStatusColor(facture['statut']!);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Facture ${facture['numero']}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          // Button to download the PDF.
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () async {
                  final file = await generatePdf(facture);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Facture téléchargée : ${file.path}"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.download, color: Colors.white),
                ),
              ),
            ),
          ),
          // Button to share the PDF.
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () async {
                  final file = await generatePdf(facture);
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text:
                        'Voici la facture ${facture['numero']} pour votre commande.',
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // General Information Section
                Hero(
                  tag: 'invoice-card',
                  child: Card(
                    elevation: 12,
                    shadowColor: Colors.black.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1E88E5,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long,
                                    color: Color(0xFF1E88E5),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Facture n°${facture['numero']}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildInfoRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Client',
                              value: facture['client']!,
                            ),
                            _buildInfoRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Date',
                              value: facture['date']!,
                            ),
                            const Divider(height: 32, thickness: 1),
                            _buildInfoRow(
                              icon: Icons.euro_rounded,
                              label: 'Montant total',
                              value:
                                  '${(facture['montant'] as double).toStringAsFixed(2)} €',
                              isTotal: true,
                            ),
                            const SizedBox(height: 16),
                            // Display the status chip.
                            _buildStatusChip(facture['statut']!, statusColor),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Articles Details Section
                Card(
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: Colors.orange.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Détails des articles',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Display the list of articles.
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (facture['articles'] as List).length,
                            itemBuilder: (context, index) {
                              final item = (facture['articles'] as List)[index];
                              final totalArticle =
                                  (item['quantite'] * item['prixUnitaire']);
                              return AnimatedContainer(
                                duration: Duration(
                                  milliseconds: 300 + (index * 100),
                                ),
                                child: _buildArticleItem(
                                  item['nom']!,
                                  item['quantite'].toString(),
                                  item['prixUnitaire'].toStringAsFixed(2),
                                  totalArticle.toStringAsFixed(2),
                                  index,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // PDF Preview Section
                Card(
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
                          Colors.purple.shade50.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: Colors.purple.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Aperçu du document',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 400,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: PdfPreview(
                                build: (format) => generatePdf(
                                  facture,
                                ).then((f) => f.readAsBytes()),
                                canChangePageFormat: false,
                                allowSharing: false,
                                allowPrinting: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build a row for general information.
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTotal
                  ? const Color(0xFF1E88E5).withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isTotal ? const Color(0xFF1E88E5) : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$label :',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isTotal ? const Color(0xFF1A1A1A) : Colors.grey[700],
            ),
          ),
          const Spacer(),
          Container(
            padding: isTotal
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                : EdgeInsets.zero,
            decoration: isTotal
                ? BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 18 : 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal
                    ? const Color(0xFF1E88E5)
                    : const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to display a status chip.
  Widget _buildStatusChip(String status, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    status.toLowerCase() == 'payée'
                        ? Icons.check
                        : Icons.schedule,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget to build an article item row.
  Widget _buildArticleItem(
    String name,
    String quantite,
    String prixUnitaire,
    String total,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (index * 200)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        quantite,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '$prixUnitaire €',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$total fr',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
