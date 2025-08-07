import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../providers/file_upload_provider.dart';
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
    // Show add storage form dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddStorageDialog(),
    );
    
    if (result != null && result['path'] != null) {
      try {
        final request = CreateStorageRequest(path: result['path']);
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
          _startFileUploadMonitoring(result['path'], newStorage);
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
        
        // Remove from upload service
        final uploadProvider = context.read<FileUploadProvider>();
        uploadProvider.uploadService?.removeStorage(storage.id).catchError((error) {
          debugPrint('Failed to remove storage from upload service: $error');
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
        
        // Update upload service
        if (mounted) {
          final uploadProvider = context.read<FileUploadProvider>();
          uploadProvider.uploadService?.updateStorage(_storages[index]).catchError((error) {
            debugPrint('Failed to update storage in upload service: $error');
          });
        }
      }
    });
  }

  void _startFileUploadMonitoring(String path, Storage storage) {
    // Add storage to the upload service
    final uploadProvider = context.read<FileUploadProvider>();
    uploadProvider.uploadService?.addStorage(storage).catchError((error) {
      debugPrint('Failed to add storage to upload service: $error');
    });
    
    debugPrint('Starting file upload monitoring for: $path');
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

// Dialog for manually entering path on web platforms
class _PathInputDialog extends StatefulWidget {
  @override
  State<_PathInputDialog> createState() => _PathInputDialogState();
}

class _PathInputDialogState extends State<_PathInputDialog> {
  final _pathController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_pathController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      title: const Text(
        'Enter Folder Path',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the full path to the folder you want to sync:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _pathController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Folder Path',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'e.g., /home/user/Documents or C:\\Users\\User\\Documents',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.folder, color: Colors.white70),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.accentColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a folder path';
                  }
                  return null;
                },
                autofocus: true,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              
              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Note: On web platforms, you need to manually enter the folder path. Make sure the path exists and is accessible.',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.confirmColor,
            foregroundColor: Colors.black,
          ),
          child: const Text('Use Path'),
        ),
      ],
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

// Dialog for adding new storage
class _AddStorageDialog extends StatefulWidget {
  @override
  State<_AddStorageDialog> createState() => _AddStorageDialogState();
}

class _AddStorageDialogState extends State<_AddStorageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pathController = TextEditingController();

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _selectFolder() async {
    if (kIsWeb) {
      // On web, show a dialog to enter path manually
      final result = await showDialog<String>(
        context: context,
        builder: (context) => _PathInputDialog(),
      );
      if (result != null && result.isNotEmpty) {
        setState(() {
          _pathController.text = result;
        });
      }
    } else {
      // On desktop/mobile, use native folder picker
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        setState(() {
          _pathController.text = selectedDirectory;
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'path': _pathController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      title: const Text(
        'Add New Storage',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a local folder to sync with the server:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              
              // Path field with folder picker
              TextFormField(
                controller: _pathController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Folder Path',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: kIsWeb ? 'Enter folder path...' : 'Select a folder...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.folder, color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: Icon(
                      kIsWeb ? Icons.edit : Icons.folder_open, 
                      color: AppTheme.accentColor
                    ),
                    onPressed: _selectFolder,
                    tooltip: kIsWeb ? 'Enter path' : 'Browse for folder',
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.accentColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please ${kIsWeb ? "enter" : "select"} a folder path';
                  }
                  return null;
                },
                readOnly: !kIsWeb,
                onTap: kIsWeb ? null : _selectFolder,
              ),
              const SizedBox(height: 12),
              
              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.accentColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        kIsWeb 
                          ? 'Files in this folder will be synced to the server. Enter the full path to your local folder.'
                          : 'Files in this folder will be automatically synced to the server.',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.confirmColor,
            foregroundColor: Colors.black,
          ),
          child: const Text('Add Storage'),
        ),
      ],
    );
  }
}
