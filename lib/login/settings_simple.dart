import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../routes/app_routes.dart';
import '../constants/app_colors.dart';

class SettingsScreenSimple extends StatefulWidget {
  const SettingsScreenSimple({super.key});

  @override
  State<SettingsScreenSimple> createState() => _SettingsScreenSimpleState();
}

class _SettingsScreenSimpleState extends State<SettingsScreenSimple>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  // Paramètres locaux
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;
  String _currency = 'FCFA';
  String _language = 'Français';
  bool _autoLock = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  void _loadSettings() {
    // Charger les paramètres depuis SharedPreferences ou utiliser les valeurs par défaut
    // Pour l'instant, on utilise les valeurs par défaut
  }

  Future<void> _saveSettings() async {
    // Sauvegarder les paramètres localement
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleTheme(bool value) async {
    setState(() {
      _isDarkTheme = value;
    });
    await _saveSettings();
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    await _saveSettings();
  }

  void _showCurrencySelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisir la devise',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...['FCFA', 'EUR', 'USD', 'CAD'].map(
              (curr) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: _currency == curr
                      ? AppColors.primaryColor
                      : Colors.grey[300],
                  child: Text(
                    curr,
                    style: TextStyle(
                      color: _currency == curr ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(curr),
                trailing: _currency == curr
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () async {
                  setState(() {
                    _currency = curr;
                  });
                  await _saveSettings();
                  Navigator.pop(context);
                  HapticFeedback.selectionClick();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisir la langue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...['Français', 'Anglais', 'Espagnol'].map(
              (lang) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: _language == lang
                      ? AppColors.primaryColor
                      : Colors.grey[300],
                  child: Text(
                    lang.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: _language == lang ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(lang),
                trailing: _language == lang
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () async {
                  setState(() {
                    _language = lang;
                  });
                  await _saveSettings();
                  Navigator.pop(context);
                  HapticFeedback.selectionClick();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTile({required Widget child, required int index}) {
    return SlideTransition(
      position:
          Tween<Offset>(
            begin: Offset(index.isEven ? -1 : 1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                (index * 0.1).clamp(0.0, 1.0),
                ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                curve: Curves.easeOutBack,
              ),
            ),
          ),
      child: FadeTransition(opacity: _fadeAnimation, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSectionHeader("Préférences générales", Icons.settings),
          _buildAnimatedTile(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text("Thème sombre"),
                subtitle: const Text("Activer le mode sombre"),
                value: _isDarkTheme,
                onChanged: _toggleTheme,
                secondary: Icon(
                  _isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.primaryColor,
                ),
                activeColor: AppColors.primaryColor,
              ),
            ),
            index: 0,
          ),
          _buildAnimatedTile(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text("Notifications"),
                subtitle: const Text("Recevoir les notifications"),
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                secondary: Icon(
                  _notificationsEnabled
                      ? Icons.notifications
                      : Icons.notifications_off,
                  color: AppColors.primaryColor,
                ),
                activeColor: AppColors.primaryColor,
              ),
            ),
            index: 1,
          ),
          _buildSectionHeader("Paramètres commerciaux", Icons.business_center),
          _buildAnimatedTile(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.monetization_on,
                  color: AppColors.primaryColor,
                ),
                title: const Text("Devise"),
                subtitle: Text("Devise actuelle: $_currency"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showCurrencySelector,
              ),
            ),
            index: 2,
          ),
          _buildAnimatedTile(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.language,
                  color: AppColors.primaryColor,
                ),
                title: const Text("Langue"),
                subtitle: Text("Langue actuelle: $_language"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showLanguageSelector,
              ),
            ),
            index: 3,
          ),
          _buildSectionHeader("Sécurité", Icons.lock),
          _buildAnimatedTile(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text("Verrouillage automatique"),
                subtitle: const Text("Verrouiller l'app après inactivité"),
                value: _autoLock,
                onChanged: (val) async {
                  setState(() {
                    _autoLock = val;
                  });
                  await _saveSettings();
                },
                secondary: const Icon(
                  Icons.lock_clock,
                  color: AppColors.primaryColor,
                ),
                activeColor: AppColors.primaryColor,
              ),
            ),
            index: 4,
          ),
          const SizedBox(height: 20),
          _buildAnimatedTile(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.info, color: AppColors.primaryColor),
                title: const Text("À propos"),
                subtitle: const Text("Version 1.0.0"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("À propos"),
                      content: const Text(
                        "AppGestion v1.0.0\n\nApplication de gestion commerciale développée avec Flutter.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Fermer"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            index: 5,
          ),
        ],
      ),
    );
  }
}
