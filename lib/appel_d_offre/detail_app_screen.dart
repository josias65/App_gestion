import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailAppelOffreScreen extends StatefulWidget {
  final Map<String, dynamic> appel;

  const DetailAppelOffreScreen({super.key, required this.appel});

  @override
  State<DetailAppelOffreScreen> createState() => _DetailAppelOffreScreenState();
}

class _DetailAppelOffreScreenState extends State<DetailAppelOffreScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ignore: unused_field
  bool _isExpanded = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    setState(() {
      _isSubmitting = true;
    });

    // Simulation d'un appel API
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Offre soumise avec succès !',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String titre = widget.appel['titre'] as String;
    final String dateLimite = widget.appel['date'] as String;
    final String etat = widget.appel['etat'] as String;
    final bool isOpen = etat == 'Ouvert';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.blue),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            toolbarHeight: 80,
            leading: Container(
              margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            title: const Text(
              'Détail Appel d\'Offre',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 0.5,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F0465),
                    Color(0xFF3A0CA3),
                    Color(0xFF6A4C93),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF0F0465),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                    spreadRadius: -8,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8F9FF), Color(0xFFEDF2FF), Color(0xFFE8EAF6)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // En-tête avec statut
                  _buildHeader(titre, etat, isOpen),
                  const SizedBox(height: 24),

                  // Informations principales
                  _buildMainInfo(dateLimite, isOpen),
                  const SizedBox(height: 24),

                  // Description détaillée
                  _buildDescription(),
                  const SizedBox(height: 24),

                  // Spécifications techniques
                  _buildSpecifications(),
                  const SizedBox(height: 24),

                  // Critères d'évaluation
                  _buildEvaluationCriteria(),
                  const SizedBox(height: 24),

                  // Actions
                  if (isOpen) _buildActions(),
                  const SizedBox(height: 100), // Espace pour le bouton flottant
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: isOpen ? _buildFloatingActionButton() : null,
      ),
    );
  }

  Widget _buildHeader(String titre, String etat, bool isOpen) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOpen
              ? [Colors.white, const Color(0xFFFAFBFF)]
              : [const Color(0xFFFAFAFA), const Color(0xFFF5F5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isOpen
                ? const Color(0xFF0F0465).withOpacity(0.15)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: isOpen
              ? const Color(0xFF0F0465).withOpacity(0.15)
              : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0465).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'APPEL D\'OFFRES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F0465),
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: isOpen
                      ? const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade500],
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isOpen ? const Color(0xFF4CAF50) : Colors.grey)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isOpen ? Icons.check_circle : Icons.block,
                        size: 12,
                        color: isOpen ? const Color(0xFF4CAF50) : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      etat,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            titre,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isOpen ? const Color(0xFF0F0465) : Colors.grey.shade700,
              height: 1.3,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfo(String dateLimite, bool isOpen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0465).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF0F0465).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            title: 'Date limite de soumission',
            value: dateLimite,
            color: isOpen ? Colors.orange : Colors.grey,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.attach_money_rounded,
            title: 'Budget estimé',
            value: '5 000 000 FCFA',
            color: const Color(0xFF0F0465),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.category_rounded,
            title: 'Catégorie',
            value: 'Informatique',
            color: const Color(0xFF0F0465),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.people_rounded,
            title: 'Soumissions reçues',
            value: '12 offres',
            color: const Color(0xFF0F0465),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0465).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF0F0465).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0465).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Color(0xFF0F0465),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Description détaillée',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F0465),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Cet appel d\'offres vise l\'achat et l\'installation de serveurs haute performance pour notre infrastructure informatique. '
            'Les spécifications techniques détaillées incluent les processeurs, la mémoire, le stockage et la garantie. '
            'Nous recherchons des solutions robustes et évolutives pour répondre à nos besoins croissants en termes de performance et de fiabilité.',
            style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0465).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF0F0465).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0465).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: Color(0xFF0F0465),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Spécifications techniques',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F0465),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSpecItem(
            'Processeur',
            'Intel Xeon ou AMD EPYC, 16 cœurs minimum',
          ),
          _buildSpecItem('Mémoire RAM', '64 GB DDR4 minimum'),
          _buildSpecItem('Stockage', '2 TB SSD NVMe + 10 TB HDD'),
          _buildSpecItem('Réseau', '2 ports 10 GbE minimum'),
          _buildSpecItem('Garantie', '3 ans minimum'),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF0F0465),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F0465),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCriteria() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0465).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF0F0465).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0465).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assessment_rounded,
                  color: Color(0xFF0F0465),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Critères d\'évaluation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F0465),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCriteriaItem('Prix', 40, Colors.green),
          _buildCriteriaItem('Qualité technique', 30, Colors.blue),
          _buildCriteriaItem('Expérience', 20, Colors.orange),
          _buildCriteriaItem('Délai de livraison', 10, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildCriteriaItem(String title, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F0465),
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0465).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF0F0465).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0465).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.work_rounded,
                  color: Color(0xFF0F0465),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Actions disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F0465),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.download_rounded,
                  label: 'Télécharger',
                  onTap: () {
                    // TODO: Télécharger les documents
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.share_rounded,
                  label: 'Partager',
                  onTap: () {
                    // TODO: Partager l'appel d'offre
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0465).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0F0465).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF0F0465), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0F0465),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: FloatingActionButton.extended(
        onPressed: _isSubmitting ? null : _submitOffer,
        backgroundColor: const Color(0xFF0F0465),
        elevation: 12,
        highlightElevation: 16,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
        label: Text(
          _isSubmitting ? 'Soumission...' : 'Soumettre une offre',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

