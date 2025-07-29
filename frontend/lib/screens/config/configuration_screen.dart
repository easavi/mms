import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final List<StorageItem> _storageItems = [];

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
      body: Stack(
        children: [
          // Storage items list
          ListView.separated(
            padding: const EdgeInsets.all(16).copyWith(bottom: 120), // Space for floating buttons
            itemCount: _storageItems.length,
            separatorBuilder: (context, index) => Container(
              height: 1,
              color: Colors.grey[600],
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
            itemBuilder: (context, index) {
              final item = _storageItems[index];
              return _StorageItemWidget(item: item);
            },
          ),
          
          // Floating action buttons at bottom right
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Back button
                FloatingActionButton(
                  heroTag: "back",
                  onPressed: _goBack,
                  backgroundColor: AppTheme.accentColor,
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(height: 12),
                
                // Synchronize button
                FloatingActionButton(
                  heroTag: "sync",
                  onPressed: _synchronize,
                  backgroundColor: AppTheme.confirmColor,
                  child: const Icon(Icons.sync, color: Colors.black),
                ),
                const SizedBox(height: 12),
                
                // Logout button
                FloatingActionButton(
                  heroTag: "logout",
                  onPressed: _logout,
                  backgroundColor: AppTheme.dangerColor,
                  child: const Icon(Icons.logout, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StorageItem {
  final String type;
  final String name;
  final String updated;
  final String size;
  final int items;

  StorageItem({
    required this.type,
    required this.name,
    required this.updated,
    required this.size,
    required this.items,
  });
}

class _StorageItemWidget extends StatelessWidget {
  final StorageItem item;

  const _StorageItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge and name row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(item.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.type,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Status indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.confirmColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Storage details
          Row(
            children: [
              Expanded(
                child: _InfoColumn(
                  label: 'Updated',
                  value: item.updated,
                  icon: Icons.schedule,
                ),
              ),
              Expanded(
                child: _InfoColumn(
                  label: 'Size',
                  value: item.size,
                  icon: Icons.storage,
                ),
              ),
              Expanded(
                child: _InfoColumn(
                  label: 'Items',
                  value: item.items.toString(),
                  icon: Icons.folder,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'aws':
        return Colors.orange;
      case 'server':
        return AppTheme.confirmColor;
      case 'minio':
        return AppTheme.accentColor;
      default:
        return Colors.grey;
    }
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoColumn({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: AppTheme.accentColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
