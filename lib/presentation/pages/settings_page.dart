import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Général'),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Activer les rappels d\'examens'),
            value: _notificationsEnabled,
            secondary: const Icon(Icons.notifications_active_outlined),
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              // TODO: Persist preference and cancel/schedule notifications accordingly
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? 'Notifications activées' : 'Notifications désactivées'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Mode Sombre'),
            subtitle: const Text('Utiliser le thème sombre'),
            value: _darkMode,
            secondary: const Icon(Icons.dark_mode_outlined),
            onChanged: (value) {
              setState(() => _darkMode = value);
              // TODO: Implement ThemeProvider
            },
          ),
          
          const Divider(),
          _buildSectionHeader('Données'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Exporter les données'),
            subtitle: const Text('Sauvegarder vos filières et épreuves'),
            onTap: () {
              // TODO: Implement Export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: const Text('Importer les données'),
            subtitle: const Text('Restaurer une sauvegarde'),
            onTap: () {
              // TODO: Implement Import
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
          ),

          const Divider(),
          _buildSectionHeader('À propos'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Développeur'),
            subtitle: Text('Flutter Expert'),
          ),
          
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showResetDialog(context),
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text('Réinitialiser toutes les données', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attention'),
        content: const Text(
          'Voulez-vous vraiment effacer toutes les filières et épreuves ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement Reset
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Données effacées (Simulation)')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Effacer tout'),
          ),
        ],
      ),
    );
  }
}
