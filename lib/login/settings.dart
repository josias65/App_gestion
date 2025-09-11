import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../routes/app_routes.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  late Settings _settings;
  late final SettingsService _settingsService;
  late String _language;
  late bool _autoLock;

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsService();
    _settings = _settingsService.settings;
    _language = _settings.language;
    _autoLock = _settings.autoLock;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _initSettings();
  }

  Future<void> _initSettings() async {
    await _settingsService.init();
    _settingsService.settingsStream.listen((settings) {
      if (mounted) {
        setState(() {
          _settings = settings;
          _language = _settings.language;
          _autoLock = _settings.autoLock;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _settingsService.dispose();
    super.dispose();
  }

  Future<void> _toggleTheme(bool value) async {
    final success = await _settingsService.updateSetting('isDarkTheme', value);
    if (success && mounted) {
      setState(() {
        _settings = _settings.copyWith(isDarkTheme: value);
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final success = await _settingsService.updateSetting('notificationsEnabled', value);
    if (success && mounted) {
      setState(() {
        _settings = _settings.copyWith(notificationsEnabled: value);
      });
      HapticFeedback.lightImpact();
    }
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
            ...['EUR', 'USD', 'CFA', 'CAD'].map(
              (curr) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: _settings.currency == curr
                      ? const Color.fromARGB(255, 37, 33, 243)
                      : Colors.grey[300],
                  child: Text(
                    curr,
                    style: TextStyle(
                      color: _settings.currency == curr ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(curr),
                trailing: _settings.currency == curr
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () async {
                  final success = await _settingsService.updateSetting('currency', curr);
                  if (success && mounted) {
                    setState(() {
                      _settings = _settings.copyWith(currency: curr);
                    });
                    Navigator.pop(context);
                    HapticFeedback.selectionClick();
                  }
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
                      ? const Color.fromARGB(255, 29, 3, 173)
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
                    ? const Icon(
                        Icons.check,
                        color: Color.fromARGB(255, 28, 3, 128),
                      )
                    : null,
                onTap: () async {
                  final success = await _settingsService.updateSetting('language', lang);
                  if (success && mounted) {
                    setState(() {
                      _language = lang;
                      _settings = _settings.copyWith(language: lang);
                    });
                    Navigator.pop(context);
                    HapticFeedback.selectionClick();
                  }
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
      position: Tween<Offset>(
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
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: child,
      ),
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
              value: _settings.isDarkTheme,
              onChanged: _toggleTheme,
              secondary: Switch.adaptive(
                value: _settings.isDarkTheme,
                onChanged: _toggleTheme,
                activeColor: const Color.fromARGB(255, 37, 33, 243),
              ),
            ),
            index: 0,
          ),
          _buildAnimatedTile(
            child: SwitchListTile(
              title: const Text("Notifications"),
              value: _settings.notificationsEnabled,
              onChanged: _toggleNotifications,
              secondary: Switch.adaptive(
                value: _settings.notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: const Color.fromARGB(255, 37, 33, 243),
              ),
            ),
            index: 1,
          ),
          _buildSectionHeader("Paramètres commerciaux", Icons.business_center),
          _buildAnimatedTile(
            child: ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text("Devise"),
              subtitle: Text(_settings.currency),
              onTap: _showCurrencySelector,
            ),
            index: 2,
          ),
          _buildAnimatedTile(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Langue"),
              subtitle: Text(_language),
              onTap: _showLanguageSelector,
            ),
            index: 3,
          ),
          _buildSectionHeader("Sécurité", Icons.lock),
          _buildAnimatedTile(
            child: SwitchListTile(
              title: const Text("Verrouillage automatique"),
              value: _autoLock,
              onChanged: (val) {
                _settingsService.updateSetting('autoLock', val);
                setState(() => _autoLock = val);
              },
              secondary: const Icon(Icons.lock_clock),
            ),
            index: 4,
          ),
        ],
      ),
    );
  }
}
