import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../services/services.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final List<File> _selectedFiles = [];
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();
  String? _selectedStorageId;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  int _currentFileIndex = 0;
  int _totalFiles = 0;

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final files = await FileService.pickMediaFiles();
    if (files.isNotEmpty) {
      setState(() {
        _selectedFiles.clear();
        _selectedFiles.addAll(files);
      });
    }
  }

  Future<void> _pickImagesOnly() async {
    final files = await FileService.pickImageFiles();
    if (files.isNotEmpty) {
      setState(() {
        _selectedFiles.clear();
        _selectedFiles.addAll(files);
      });
    }
  }

  Future<void> _pickVideosOnly() async {
    final files = await FileService.pickVideoFiles();
    if (files.isNotEmpty) {
      setState(() {
        _selectedFiles.clear();
        _selectedFiles.addAll(files);
      });
    }
  }

  Future<void> _pickFromDirectory() async {
    final directoryPath = await FileService.pickDirectory(
      dialogTitle: 'Select directory containing media files',
    );
    
    if (directoryPath != null) {
      final directory = Directory(directoryPath);
      final files = <File>[];
      
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Scanning directory...'),
              ],
            ),
          ),
        );
      }

      try {
        await for (final entity in directory.list(recursive: true)) {
          if (entity is File && _isMediaFile(entity.path)) {
            files.add(entity);
          }
        }

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          
          setState(() {
            _selectedFiles.clear();
            _selectedFiles.addAll(files);
          });

          if (files.isEmpty) {
            _showSnackBar('No media files found in the selected directory');
          } else {
            _showSnackBar('Found ${files.length} media files');
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          _showSnackBar('Error scanning directory: $e');
        }
      }
    }
  }

  bool _isMediaFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    const supportedExtensions = [
      'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg',
      'mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv', '3gp'
    ];
    return supportedExtensions.contains(extension);
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _removeFile(File file) {
    setState(() {
      _selectedFiles.remove(file);
    });
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) {
      _showSnackBar('Please select files to upload');
      return;
    }

    final authService = context.read<AuthService>();
    if (!authService.isAuthenticated) {
      _showSnackBar('Please login to upload files');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _currentFileIndex = 0;
      _totalFiles = _selectedFiles.length;
    });

    try {
      final fileUploadService = FileUploadService(
        context.read<ApiService>().dio,
        authService,
      );

      final uploadedMedia = await fileUploadService.uploadFiles(
        _selectedFiles,
        tags: _tags.isNotEmpty ? _tags : null,
        storageId: _selectedStorageId,
        onProgress: (current, total) {
          setState(() {
            _currentFileIndex = current;
            _uploadProgress = current / total;
          });
        },
      );

      // Refresh media list
      if (mounted) {
        await context.read<MediaProvider>().loadMedia();
      }

      setState(() {
        _isUploading = false;
        _selectedFiles.clear();
        _tags.clear();
      });

      _showSnackBar(
        'Successfully uploaded ${uploadedMedia.length} of ${_totalFiles} files',
      );

    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showSnackBar('Upload failed: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  String _formatFileSize(int bytes) {
    return FileService.formatFileSize(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Files'),
        actions: [
          if (_selectedFiles.isNotEmpty)
            IconButton(
              onPressed: _isUploading ? null : _uploadFiles,
              icon: const Icon(Icons.cloud_upload),
              tooltip: 'Upload Files',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // File selection buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select Files',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickFiles,
                          icon: const Icon(Icons.file_open),
                          label: const Text('Pick Media Files'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickImagesOnly,
                          icon: const Icon(Icons.image),
                          label: const Text('Images Only'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickVideosOnly,
                          icon: const Icon(Icons.video_library),
                          label: const Text('Videos Only'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickFromDirectory,
                          icon: const Icon(Icons.folder),
                          label: const Text('From Directory'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Tags section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Tags (Optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              hintText: 'Add a tag',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addTag,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () => _removeTag(tag),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Upload progress
            if (_isUploading) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Uploading $_currentFileIndex of $_totalFiles files',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: _uploadProgress),
                      const SizedBox(height: 8),
                      Text('${(_uploadProgress * 100).toInt()}% complete'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Selected files list
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected Files (${_selectedFiles.length})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_selectedFiles.isNotEmpty)
                            TextButton(
                              onPressed: _isUploading ? null : () {
                                setState(() {
                                  _selectedFiles.clear();
                                });
                              },
                              child: const Text('Clear All'),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _selectedFiles.isEmpty
                          ? const Center(
                              child: Text(
                                'No files selected\nUse the buttons above to select files',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _selectedFiles.length,
                              itemBuilder: (context, index) {
                                final file = _selectedFiles[index];
                                final fileName = FileService.getFileName(file.path);
                                
                                return FutureBuilder<int>(
                                  future: FileService.getFileSize(file.path),
                                  builder: (context, snapshot) {
                                    final fileSize = snapshot.data ?? 0;
                                    final isImage = FileService.isImageFile(file.path);
                                    final isVideo = FileService.isVideoFile(file.path);
                                    
                                    return ListTile(
                                      leading: Icon(
                                        isImage ? Icons.image :
                                        isVideo ? Icons.video_file :
                                        Icons.insert_drive_file,
                                        color: isImage ? Colors.blue :
                                               isVideo ? Colors.red :
                                               Colors.grey,
                                      ),
                                      title: Text(fileName),
                                      subtitle: Text(
                                        '${file.path}\nSize: ${_formatFileSize(fileSize)}',
                                      ),
                                      trailing: _isUploading
                                          ? null
                                          : IconButton(
                                              onPressed: () => _removeFile(file),
                                              icon: const Icon(Icons.remove_circle),
                                              color: Colors.red,
                                            ),
                                      isThreeLine: true,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
