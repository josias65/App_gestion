import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../routes/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  bool isDarkTheme = false;
  bool notificationsEnabled = true;
  String currency = 'EUR';
  String language = 'Français';
  bool autoLock = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    _scrollController.dispose();
    super.dispose();
  }

  void toggleTheme(bool value) {
    setState(() => isDarkTheme = value);
    HapticFeedback.lightImpact();
  }

  void toggleNotifications(bool value) {
    setState(() => notificationsEnabled = value);
    HapticFeedback.lightImpact();
  }

  void showCurrencySelector() {
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
            ...['EUR', 'USD', 'CFA', 'CAD'].map(
              (curr) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: currency == curr
                      ? const Color.fromARGB(255, 37, 33, 243)
                      : Colors.grey[300],
                  child: Text(
                    curr,
                    style: TextStyle(
                      color: currency == curr ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(curr),
                trailing: currency == curr
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() => currency = curr);
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

  void showLanguageSelector() {
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
              'Choisir la langue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...['Français', 'Anglais', 'Espagnol'].map(
              (lang) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: language == lang
                      ? const Color.fromARGB(255, 29, 3, 173)
                      : Colors.grey[300],
                  child: Text(
                    lang.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: language == lang ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(lang),
                trailing: language == lang
                    ? const Icon(
                        Icons.check,
                        color: Color.fromARGB(255, 28, 3, 128),
                      )
                    : null,
                onTap: () {
                  setState(() => language = lang);
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
            Colors.blue.withOpacity(0.1),
            const Color.fromARGB(255, 16, 1, 98).withOpacity(0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600], size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.dashboard,
              (route) => false,
            );
          },
        ),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSectionHeader("Préférences générales", Icons.settings),
          _buildAnimatedTile(
            child: SwitchListTile(
              title: const Text("Thème sombre"),
              value: isDarkTheme,
              onChanged: toggleTheme,
              secondary: const Icon(Icons.brightness_6),
            ),
            index: 0,
          ),
          _buildAnimatedTile(
            child: SwitchListTile(
              title: const Text("Notifications"),
              value: notificationsEnabled,
              onChanged: toggleNotifications,
              secondary: const Icon(Icons.notifications),
            ),
            index: 1,
          ),
          _buildSectionHeader("Paramètres commerciaux", Icons.business_center),
          _buildAnimatedTile(
            child: ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text("Devise"),
              subtitle: Text(currency),
              onTap: showCurrencySelector,
            ),
            index: 2,
          ),
          _buildAnimatedTile(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Langue"),
              subtitle: Text(language),
              onTap: showLanguageSelector,
            ),
            index: 3,
          ),
          _buildSectionHeader("Sécurité", Icons.lock),
          _buildAnimatedTile(
            child: SwitchListTile(
              title: const Text("Verrouillage automatique"),
              value: autoLock,
              onChanged: (val) => setState(() => autoLock = val),
              secondary: const Icon(Icons.lock_clock),
            ),
            index: 4,
          ),
        ],
      ),
    );
  }
}
