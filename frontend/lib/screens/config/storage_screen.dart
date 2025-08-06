import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final StorageService _storageService = StorageService();
  List<Storage> _storages = [];
  bool _isLoading = true;
  Map<String, int> _storageQuantities = {};
  Map<String, int> _storageSizes = {};

  @override
  void initState() {
    super.initState();
    _loadStorages();
  }

  Future<void> _loadStorages() async {
    setState(() => _isLoading = true);
    try {
      final storages = await _storageService.getAllStorage();
      setState(() {
        _storages = storages;
        _isLoading = false;
      });
      
      // Load quantities and sizes for each storage
      for (var storage in storages) {
        _loadStorageStats(storage.bucket);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load storages: ${e.toString()}'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  Future<void> _loadStorageStats(String bucket) async {
    try {
      final quantity = await _storageService.getStorageQuantity(bucket);
      final size = await _storageService.getStorageSize(bucket);
      
      setState(() {
        _storageQuantities[bucket] = quantity;
        _storageSizes[bucket] = size;
      });
    } catch (e) {
      // Handle errors silently for individual storage stats
      print('Failed to load stats for $bucket: $e');
    }
  }

  Future<void> _addStorage() async {
    // Show folder picker dialog
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    
    if (selectedDirectory != null) {
      try {
        final request = CreateStorageRequest(path: selectedDirectory);
        final newStorage = await _storageService.createStorage(request);
        
        setState(() {
          _storages.add(newStorage);
        });
        
        // Load stats for the new storage
        _loadStorageStats(newStorage.bucket);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Storage added successfully'),
              backgroundColor: AppTheme.confirmColor,
            ),
          );
          
          // TODO: Start file monitoring and upload for this path
          _startFileUploadMonitoring(selectedDirectory);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add storage: ${e.toString()}'),
              backgroundColor: AppTheme.dangerColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteStorage(Storage storage) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Delete Storage',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will erase the files on the server too. Are you sure?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.dangerColor),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteStorage(storage.id);
        setState(() {
          _storages.removeWhere((s) => s.id == storage.id);
          _storageQuantities.remove(storage.bucket);
          _storageSizes.remove(storage.bucket);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Storage deleted successfully'),
              backgroundColor: AppTheme.confirmColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete storage: ${e.toString()}'),
              backgroundColor: AppTheme.dangerColor,
            ),
          );
        }
      }
    }
  }

  void _toggleStorage(Storage storage) {
    setState(() {
      // Update the enabled state (this would typically be persisted)
      final index = _storages.indexWhere((s) => s.id == storage.id);
      if (index != -1) {
        _storages[index] = Storage(
          id: storage.id,
          bucket: storage.bucket,
          path: storage.path,
          type: storage.type,
          updated: storage.updated,
          size: storage.size,
          itemsQuantity: storage.itemsQuantity,
          username: storage.username,
          isEnabled: !storage.isEnabled,
        );
      }
    });
  }

  void _startFileUploadMonitoring(String path) {
    // TODO: Implement file monitoring and auto-upload
    // This would typically:
    // 1. Watch the directory for file changes
    // 2. Upload new files to the server
    // 3. Handle file deletion/modification
    // 4. Update storage stats in real-time
    print('Starting file upload monitoring for: $path');
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Storage Configuration'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentColor,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16).copyWith(bottom: 80),
              itemCount: _storages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final storage = _storages[index];
                return _StorageItemCard(
                  storage: storage,
                  quantity: _storageQuantities[storage.bucket] ?? 0,
                  size: _storageSizes[storage.bucket] ?? 0,
                  onToggle: () => _toggleStorage(storage),
                  onDelete: () => _deleteStorage(storage),
                  formatSize: _formatSize,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStorage,
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class _StorageItemCard extends StatelessWidget {
  final Storage storage;
  final int quantity;
  final int size;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final String Function(int) formatSize;

  const _StorageItemCard({
    required this.storage,
    required this.quantity,
    required this.size,
    required this.onToggle,
    required this.onDelete,
    required this.formatSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with bucket and actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    storage.bucket.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    storage.isEnabled ? Icons.pause_circle : Icons.play_circle,
                    color: storage.isEnabled ? AppTheme.confirmColor : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete,
                    color: AppTheme.dangerColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Path
            Row(
              children: [
                Icon(Icons.folder, size: 16, color: AppTheme.accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    storage.path,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stats
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.folder_outlined,
                    label: 'Items',
                    value: quantity.toString(),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.storage,
                    label: 'Size',
                    value: formatSize(size),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.schedule,
                    label: 'Updated',
                    value: _formatDate(storage.updated),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
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
