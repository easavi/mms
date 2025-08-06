import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../config/storage_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  // Mock data for now - will be replaced with real API data later
  final List<MediaGroup> _mediaGroups = [
    MediaGroup(
      title: 'January/2024',
      items: _generateMockItems(7),
    ),
    MediaGroup(
      title: 'February/2024',
      items: _generateMockItems(12),
    ),
    MediaGroup(
      title: 'April/2024',
      items: _generateMockItems(2),
    ),
    MediaGroup(
      title: 'May/2024',
      items: _generateMockItems(15),
    ),
    MediaGroup(
      title: 'June/2024',
      items: _generateMockItems(8),
    ),
  ];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Generate mock media items
  static List<MediaItem> _generateMockItems(int count) {
    final types = [MediaItemType.image, MediaItemType.video, MediaItemType.document];
    return List.generate(count, (index) {
      final type = types[index % types.length];
      return MediaItem(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}_$index',
        title: '${_getTypeDisplayName(type)} ${index + 1}',
        type: type,
        thumbnailUrl: type == MediaItemType.image 
            ? 'https://picsum.photos/200/200?random=$index'
            : null,
      );
    });
  }

  static String _getTypeDisplayName(MediaItemType type) {
    switch (type) {
      case MediaItemType.image:
        return 'Photo';
      case MediaItemType.video:
        return 'Video';
      case MediaItemType.document:
        return 'Document';
    }
  }

  void _onScroll() {
    // Infinite scroll logic - load more when reaching bottom
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadMoreData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock adding more data
    setState(() {
      _mediaGroups.add(MediaGroup(
        title: 'July/2024', 
        items: _generateMockItems(6),
      ));
      _isLoading = false;
    });
  }

  void _performSearch() {
    final searchTerm = _searchController.text.trim();
    // TODO: Implement search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for: $searchTerm'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter by Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _FilterOption(title: 'All', isSelected: true, onTap: () => Navigator.pop(context)),
            _FilterOption(title: 'Images', isSelected: false, onTap: () => Navigator.pop(context)),
            _FilterOption(title: 'Videos', isSelected: false, onTap: () => Navigator.pop(context)),
            _FilterOption(title: 'Documents', isSelected: false, onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  void _navigateToConfig() {
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
        title: const Text('Media Gallery'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main content with infinite scroll
          RefreshIndicator(
            onRefresh: () async {
              // TODO: Implement refresh functionality
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 100), // Space for floating buttons
              itemCount: _mediaGroups.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _mediaGroups.length) {
                  // Loading indicator at bottom
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: AppTheme.accentColor,
                      ),
                    ),
                  );
                }

                final group = _mediaGroups[index];
                return _MediaGroupWidget(group: group);
              },
            ),
          ),
          
          // Floating buttons at bottom right
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Configuration button
                FloatingActionButton(
                  heroTag: "config",
                  onPressed: _navigateToConfig,
                  backgroundColor: AppTheme.accentColor,
                  child: const Icon(Icons.settings, color: Colors.black),
                ),
                const SizedBox(height: 12),
                
                // Filter button
                FloatingActionButton(
                  heroTag: "filter",
                  onPressed: _showFilters,
                  backgroundColor: AppTheme.accentColor,
                  child: const Icon(Icons.filter_list, color: Colors.black),
                ),
                const SizedBox(height: 12),
                
                // Search box
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: AppTheme.accentColor),
                        onPressed: _performSearch,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Mock data class
class MediaGroup {
  final String title;
  final List<MediaItem> items;

  MediaGroup({required this.title, required this.items});
  
  int get itemCount => items.length;
}

class MediaItem {
  final String id;
  final String title;
  final MediaItemType type;
  final String? thumbnailUrl;
  
  MediaItem({
    required this.id,
    required this.title,
    required this.type,
    this.thumbnailUrl,
  });
}

enum MediaItemType {
  image,
  video,
  document,
}

// Widget for displaying each media group
class _MediaGroupWidget extends StatelessWidget {
  final MediaGroup group;

  const _MediaGroupWidget({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group title with separator line
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Text(
            '${group.title} (${group.itemCount})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Grid of media items (3 columns)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: group.itemCount,
            itemBuilder: (context, index) {
              return _MediaItemWidget(item: group.items[index]);
            },
          ),
        ),
      ],
    );
  }
}

// Widget for individual media items (squares)
class _MediaItemWidget extends StatelessWidget {
  final MediaItem item;

  const _MediaItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Content based on media type
            _buildMediaContent(),
            
            // Type indicator overlay
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _getIconForType(item.type),
                  color: _getColorForType(item.type),
                  size: 16,
                ),
              ),
            ),
            
            // Title overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    switch (item.type) {
      case MediaItemType.image:
        if (item.thumbnailUrl != null) {
          return Image.network(
            item.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildPlaceholder();
            },
          );
        }
        return _buildPlaceholder();
      case MediaItemType.video:
        return Container(
          color: Colors.black54,
          child: Icon(
            Icons.play_circle_outline,
            color: AppTheme.accentColor,
            size: 48,
          ),
        );
      case MediaItemType.document:
        return Container(
          color: Colors.grey[800],
          child: Icon(
            Icons.description,
            color: AppTheme.confirmColor,
            size: 48,
          ),
        );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Icon(
        Icons.image,
        color: Colors.grey[600],
        size: 32,
      ),
    );
  }

  IconData _getIconForType(MediaItemType type) {
    switch (type) {
      case MediaItemType.image:
        return Icons.image;
      case MediaItemType.video:
        return Icons.videocam;
      case MediaItemType.document:
        return Icons.description;
    }
  }

  Color _getColorForType(MediaItemType type) {
    switch (type) {
      case MediaItemType.image:
        return AppTheme.confirmColor;
      case MediaItemType.video:
        return AppTheme.dangerColor;
      case MediaItemType.document:
        return AppTheme.accentColor;
    }
  }
}

// Filter option widget
class _FilterOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.confirmColor : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected 
          ? Icon(Icons.check, color: AppTheme.confirmColor)
          : null,
      onTap: onTap,
    );
  }
}
