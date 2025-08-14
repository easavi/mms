import 'package:flutter/material.dart';
import '../models/models.dart';
import '../config/api_config.dart';
import '../screens/media_viewer_screen.dart';
import 'authenticated_image.dart';

class MediaCard extends StatelessWidget {
  final Media media;
  final List<Media> allMedia;
  final int index;

  const MediaCard({
    super.key,
    required this.media,
    required this.allMedia,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openMediaViewer(context),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: _buildMediaPreview(),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (media.isImage) {
      // Use thumbnail URL if available, fallback to original image URL
      final imageUrl = media.thumbnailUrlFromFileUrl != null 
          ? ApiConfig.getFullUrl(media.thumbnailUrlFromFileUrl!)
          : ApiConfig.getFullUrl(media.fileUrl);
      
      return AuthenticatedImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: Container(
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

  void _openMediaViewer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaViewerScreen(
          mediaList: allMedia,
          initialIndex: index,
        ),
      ),
    );
  }
}
