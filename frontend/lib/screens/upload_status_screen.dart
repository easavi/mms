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
      appBar: AppBar(
        title: const Text('Upload Status'),
        backgroundColor: AppTheme.darkGray,
        actions: [
          Consumer<FileUploadProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear_history':
                      provider.clearHistory();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Upload history cleared')),
                      );
                      break;
                    case 'stop_service':
                      _showStopServiceDialog(context, provider);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear_history',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Clear History'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'stop_service',
                    child: Row(
                      children: [
                        Icon(provider.isRunning ? Icons.stop : Icons.play_arrow),
                        const SizedBox(width: 8),
                        Text(provider.isRunning ? 'Stop Service' : 'Start Service'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<FileUploadProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildStatusHeader(provider),
              Expanded(
                child: _buildUploadsList(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(FileUploadProvider provider) {
    final summary = provider.getUploadStatusSummary();
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                provider.isRunning ? Icons.cloud_upload : Icons.cloud_off,
                color: provider.isRunning ? Colors.green : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'File Upload Service',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.isRunning ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  provider.isRunning ? 'Running' : 'Stopped',
                  style: TextStyle(
                    color: provider.isRunning ? Colors.green : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            provider.getUploadProgressText(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusChip('Pending', summary[UploadStatus.pending] ?? 0, Colors.orange),
              const SizedBox(width: 8),
              _buildStatusChip('Uploading', summary[UploadStatus.uploading] ?? 0, Colors.blue),
              const SizedBox(width: 8),
              _buildStatusChip('Completed', summary[UploadStatus.completed] ?? 0, Colors.green),
              const SizedBox(width: 8),
              _buildStatusChip('Failed', summary[UploadStatus.failed] ?? 0, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadsList(BuildContext context, FileUploadProvider provider) {
    final uploads = provider.uploadItems;
    
    if (uploads.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No uploads yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add files to monitored folders to see uploads here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Sort uploads: active first, then by date
    uploads.sort((a, b) {
      final aActive = a.status == UploadStatus.pending || a.status == UploadStatus.uploading;
      final bActive = b.status == UploadStatus.pending || b.status == UploadStatus.uploading;
      
      if (aActive && !bActive) return -1;
      if (!aActive && bActive) return 1;
      
      return b.addedAt.compareTo(a.addedAt);
    });
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: uploads.length,
      itemBuilder: (context, index) {
        final upload = uploads[index];
        return _buildUploadItem(context, upload, provider);
      },
    );
  }

  Widget _buildUploadItem(BuildContext context, UploadItem upload, FileUploadProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusIcon(upload.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upload.fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      upload.filePath,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildUploadActions(context, upload, provider),
            ],
          ),
          if (upload.status == UploadStatus.uploading) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: upload.progress,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
          if (upload.errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      upload.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Type: ${upload.mediaType}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Added: ${_formatDateTime(upload.addedAt)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(UploadStatus status) {
    switch (status) {
      case UploadStatus.pending:
        return const Icon(Icons.schedule, color: Colors.orange, size: 20);
      case UploadStatus.uploading:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
      case UploadStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case UploadStatus.failed:
        return const Icon(Icons.error, color: Colors.red, size: 20);
      case UploadStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.grey, size: 20);
    }
  }

  Widget _buildUploadActions(BuildContext context, UploadItem upload, FileUploadProvider provider) {
    if (upload.status == UploadStatus.failed) {
      return IconButton(
        icon: const Icon(Icons.refresh, size: 20),
        onPressed: () => provider.retryUpload(upload.id),
        tooltip: 'Retry upload',
      );
    }
    
    return const SizedBox(width: 20);
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showStopServiceDialog(BuildContext context, FileUploadProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(provider.isRunning ? 'Stop Upload Service' : 'Start Upload Service'),
        content: Text(
          provider.isRunning
              ? 'Are you sure you want to stop the file upload service? Pending uploads will be cancelled.'
              : 'Start the file upload service to monitor folders and automatically upload new files.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              if (provider.isRunning) {
                await provider.stop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upload service stopped')),
                  );
                }
              } else {
                try {
                  await provider.initialize();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upload service started')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to start service: $e')),
                    );
                  }
                }
              }
            },
            child: Text(provider.isRunning ? 'Stop' : 'Start'),
          ),
        ],
      ),
    );
  }
}
