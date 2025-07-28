import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';

class MediaCard extends StatelessWidget {
  final Media media;

  const MediaCard({
    super.key,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showMediaDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media preview
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: _buildMediaPreview(),
              ),
            ),
            
            // Media info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      media.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Date
                    Text(
                      media.formattedCreatedAt,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Tags and type
                    Row(
                      children: [
                        // Media type icon
                        Icon(
                          _getMediaIcon(),
                          size: 16,
                          color: _getMediaColor(),
                        ),
                        const SizedBox(width: 4),
                        
                        // Tags count
                        if (media.tags.isNotEmpty) ...[
                          Icon(
                            Icons.local_offer,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${media.tags.length}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildMediaPreview() {
    if (media.isImage) {
      return CachedNetworkImage(
        imageUrl: media.fileUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey,
          ),
        ),
      );
    } else if (media.isVideo) {
      return Container(
        color: Colors.black87,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video thumbnail would go here
            Container(
              color: Colors.grey[800],
              child: const Icon(
                Icons.videocam,
                size: 48,
                color: Colors.white70,
              ),
            ),
            // Play button overlay
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 32,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      // File type
      return Container(
        color: Colors.grey[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              media.fileExtension.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }

  IconData _getMediaIcon() {
    if (media.isImage) return Icons.image;
    if (media.isVideo) return Icons.video_file;
    return Icons.insert_drive_file;
  }

  Color _getMediaColor() {
    if (media.isImage) return Colors.green;
    if (media.isVideo) return Colors.blue;
    return Colors.orange;
  }

  void _showMediaDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(media.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${media.mediaType.displayName}'),
            Text('File: ${media.fileName}'),
            Text('Created: ${media.dayMonthYear}'),
            if (media.uploadedAt != null)
              Text('Uploaded: ${media.uploadedAt!.toLocal().toString().split('.')[0]}'),
            if (media.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Tags:'),
              Wrap(
                spacing: 4,
                children: media.tags.map((tag) => Chip(
                  label: Text(tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open media viewer
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}
