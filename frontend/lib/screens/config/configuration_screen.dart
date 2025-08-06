import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'storage_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {

  void _logout() async {
    try {
      await context.read<AuthService>().logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  void _synchronize() {
    // Mock synchronization - in a real app this would sync with backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Synchronization started...'),
        backgroundColor: AppTheme.confirmColor,
      ),
    );

    // Simulate sync process
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Synchronization completed successfully!'),
            backgroundColor: AppTheme.confirmColor,
          ),
        );
      }
    });
  }

  void _goBack() {
    Navigator.pop(context);
  }

  void _openStorageConfiguration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StorageScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Configuration'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Storage Configuration Card
            Card(
              color: AppTheme.cardColor,
              child: ListTile(
                leading: Icon(Icons.storage, color: AppTheme.accentColor),
                title: const Text(
                  'Storage Configuration',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Manage local folder synchronization',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                onTap: _openStorageConfiguration,
              ),
            ),
            const SizedBox(height: 16),
            
            // Other configuration options can go here
            const Spacer(),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _goBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _synchronize,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.confirmColor,
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.dangerColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
