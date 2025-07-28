import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/services.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final StorageService _storageService = StorageService();
  List<Storage> _storages = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStorages();
  }

  Future<void> _loadStorages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _storages = await _storageService.getAllStorage();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStorageDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Storage',
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading storages',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStorages,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_storages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No storage configured',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Add a storage to get started'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAddStorageDialog,
              child: const Text('Add Storage'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStorages,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _storages.length,
        itemBuilder: (context, index) {
          final storage = _storages[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  _getStorageIcon(storage.type),
                  color: Colors.white,
                ),
              ),
              title: Text(storage.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type: ${storage.type.displayName}'),
                  Text('Bucket: ${storage.bucket}'),
                  Text('Items: ${storage.itemsQuantity}'),
                  Text('Size: ${storage.formattedSize}'),
                  Text('Updated: ${storage.updated.toLocal().toString().split(' ')[0]}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditStorageDialog(storage);
                      break;
                    case 'delete':
                      _confirmDeleteStorage(storage);
                      break;
                    case 'test':
                      _testStorageConnection(storage);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'test',
                    child: Row(
                      children: [
                        Icon(Icons.wifi_tethering),
                        SizedBox(width: 8),
                        Text('Test Connection'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getStorageIcon(StorageType type) {
    switch (type) {
      case StorageType.Minio:
        return Icons.cloud_queue;
      case StorageType.AWS:
        return Icons.cloud;
    }
  }

  void _showAddStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => _StorageDialog(
        onSave: (request) async {
          try {
            await _storageService.createStorage(request);
            await _loadStorages();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage added successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding storage: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditStorageDialog(Storage storage) {
    showDialog(
      context: context,
      builder: (context) => _StorageDialog(
        storage: storage,
        onSave: (request) async {
          try {
            final updateRequest = UpdateStorageRequest(
              name: request.name,
              storageType: request.storageType,
              accessKey: request.accessKey,
              secretKey: request.secretKey,
              bucketName: request.bucketName,
              region: request.region,
              endpoint: request.endpoint,
            );
            await _storageService.updateStorage(storage.id, updateRequest);
            await _loadStorages();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage updated successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating storage: $e')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _confirmDeleteStorage(Storage storage) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Storage'),
        content: Text('Are you sure you want to delete "${storage.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteStorage(storage.id);
        await _loadStorages();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting storage: $e')),
          );
        }
      }
    }
  }

  Future<void> _testStorageConnection(Storage storage) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Testing connection...'),
            ],
          ),
        ),
      );

      final result = await _storageService.testStorageConnection(storage.id);
      Navigator.of(context).pop(); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Test'),
          content: Text(
            result['success'] == true 
                ? 'Connection successful!' 
                : 'Connection failed: ${result['message'] ?? 'Unknown error'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if still open
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error testing connection: $e')),
        );
      }
    }
  }
}

class _StorageDialog extends StatefulWidget {
  final Storage? storage;
  final Function(CreateStorageRequest) onSave;

  const _StorageDialog({
    this.storage,
    required this.onSave,
  });

  @override
  State<_StorageDialog> createState() => _StorageDialogState();
}

class _StorageDialogState extends State<_StorageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bucketController = TextEditingController();
  
  StorageType _selectedType = StorageType.Minio;

  @override
  void initState() {
    super.initState();
    if (widget.storage != null) {
      final storage = widget.storage!;
      _nameController.text = storage.name;
      _bucketController.text = storage.bucket;
      _selectedType = storage.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.storage == null ? 'Add Storage' : 'Edit Storage'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<StorageType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Storage Type',
                  border: OutlineInputBorder(),
                ),
                items: StorageType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _bucketController,
                decoration: const InputDecoration(
                  labelText: 'Bucket Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bucket name';
                  }
                  return null;
                },
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
          onPressed: _saveStorage,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveStorage() {
    if (_formKey.currentState!.validate()) {
      final request = CreateStorageRequest(
        name: _nameController.text,
        storageType: _selectedType,
        accessKey: 'default-access-key', // TODO: Add proper access key field
        secretKey: 'default-secret-key', // TODO: Add proper secret key field
        bucketName: _bucketController.text,
        endpoint: 'http://localhost:9000', // TODO: Add proper endpoint field
      );
      
      widget.onSave(request);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bucketController.dispose();
    super.dispose();
  }
}
