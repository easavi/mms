import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/media_provider.dart';
import '../widgets/media_card.dart';
import '../widgets/media_filters.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaProvider>().loadMedia();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const MediaFilters(),
    );
  }

  Future<void> _refresh() async {
    await context.read<MediaProvider>().loadMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),         
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'config':
                  Navigator.of(context).pushNamed('/config');
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'config',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Configuration'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<MediaProvider>(
        builder: (context, mediaProvider, child) {
          if (mediaProvider.isLoading && mediaProvider.media.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mediaProvider.error != null) {
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
                    'Error loading media',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mediaProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (mediaProvider.media.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.perm_media,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No media found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Upload some media to get started'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement media upload
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Upload feature coming soon')),
                      );
                    },
                    child: const Text('Upload Media'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Filters summary
                if (mediaProvider.hasActiveFilters)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mediaProvider.getFiltersDescription(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              mediaProvider.clearFilters();
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Media grid
                SliverPadding(
                  padding: EdgeInsets.zero,
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final media = mediaProvider.media[index];
                        return MediaCard(media: media);
                      },
                      childCount: mediaProvider.media.length,
                    ),
                  ),
                ),

                // Loading indicator for pagination
                if (mediaProvider.isLoading && mediaProvider.media.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
