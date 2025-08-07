import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_upload_provider.dart';
import '../services/file_upload_service.dart';
import '../theme/app_theme.dart';

class UploadStatusScreen extends StatelessWidget {
  const UploadStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Upload Status'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<FileUploadProvider>(
            builder: (context, uploadProvider, child) {
              return IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: () {
                  uploadProvider.uploadService?.clearCompletedUploads();
                },
                tooltip: 'Clear completed uploads',
              );
            },
          ),
        ],
      ),
      body: Consumer<FileUploadProvider>(
        builder: (context, uploadProvider, child) {
          final uploadService = uploadProvider.uploadService;
          
          if (uploadService == null || !uploadService.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Upload service not initialized',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          final allTasks = [
            ...uploadService.uploadQueue,
            ...uploadService.activeUploads.values,
          ];
          
          if (allTasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_done, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No uploads in progress',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: allTasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = allTasks[index];
              return _UploadTaskCard(task: task);
            },
          );
        },
      ),
    );
  }
}

class _UploadTaskCard extends StatelessWidget {
  final UploadTask task;
  
  const _UploadTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with filename and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.fileName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusChip(status: task.status),
              ],
            ),
            const SizedBox(height: 8),
            
            // Storage path
            Text(
              'Storage: ${task.storage.path}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            // Progress bar for uploading tasks
            if (task.status == UploadStatus.uploading) ...[
              LinearProgressIndicator(
                value: task.progress,
                backgroundColor: Colors.grey[700],
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
              ),
              const SizedBox(height: 4),
              Text(
                '${(task.progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
            
            // Error message for failed tasks
            if (task.status == UploadStatus.failed && task.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Actions
            if (task.status == UploadStatus.failed) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      final uploadService = context.read<FileUploadProvider>().uploadService;
                      uploadService?.retryUpload(task.id);
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final UploadStatus status;
  
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (status) {
      case UploadStatus.pending:
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case UploadStatus.uploading:
        color = AppTheme.accentColor;
        icon = Icons.cloud_upload;
        break;
      case UploadStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case UploadStatus.failed:
        color = Colors.red;
        icon = Icons.error;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
