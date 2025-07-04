// TODO: Implementer le code pour presentation/screens/settings/settings_screen
// presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import '../../../services/background_service.dart';
import 'widgets/theme_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoCleanupEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final cleanupEnabled = await BackgroundService.isCleanupEnabled();
    setState(() {
      _autoCleanupEnabled = cleanupEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          _buildSection(title: 'Apparence', children: [const ThemeSelector()]),
          _buildSection(
            title: 'Stockage',
            children: [
              SwitchListTile(
                title: const Text('Nettoyage automatique'),
                subtitle: const Text(
                  'Supprime automatiquement les articles non favoris après 24h',
                ),
                value: _autoCleanupEnabled,
                onChanged: (value) async {
                  setState(() {
                    _autoCleanupEnabled = value;
                  });
                  await BackgroundService.setCleanupEnabled(value);
                },
              ),
              ListTile(
                title: const Text('Nettoyer maintenant'),
                subtitle: const Text(
                  'Supprime les anciens articles non favoris',
                ),
                leading: const Icon(Icons.cleaning_services),
                onTap: () => _showCleanupDialog(context),
              ),
            ],
          ),
          _buildSection(
            title: 'Cache',
            children: [
              ListTile(
                title: const Text('Vider le cache'),
                subtitle: const Text('Supprime tous les articles mis en cache'),
                leading: const Icon(Icons.delete_sweep),
                onTap: () => _showClearCacheDialog(context),
              ),
            ],
          ),
          _buildSection(
            title: 'À propos',
            children: [
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
                leading: Icon(Icons.info_outline),
              ),
              ListTile(
                title: const Text('Code source'),
                subtitle: const Text('Voir le projet sur GitHub'),
                leading: const Icon(Icons.code),
                onTap: () {
                  // Open GitHub link
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  void _showCleanupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nettoyer les anciens articles'),
          content: const Text(
            'Cette action supprimera tous les articles non favoris de plus de 24h. '
            'Les articles favoris seront conservés.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performCleanup();
              },
              child: const Text('Nettoyer'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vider le cache'),
          content: const Text(
            'Cette action supprimera tous les articles mis en cache, '
            'y compris les favoris. Êtes-vous sûr ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearCache();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Vider'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performCleanup() async {
    try {
      await BackgroundService.performCleanup();
      _showSuccessSnackBar('Nettoyage terminé avec succès');
    } catch (e) {
      _showErrorSnackBar('Erreur lors du nettoyage: $e');
    }
  }

  Future<void> _clearCache() async {
    try {
      await BackgroundService.clearAllCache();
      _showSuccessSnackBar('Cache vidé avec succès');
    } catch (e) {
      _showErrorSnackBar('Erreur lors du vidage du cache: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
