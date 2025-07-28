import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/media_provider.dart';

class MediaFilters extends StatefulWidget {
  const MediaFilters({super.key});

  @override
  State<MediaFilters> createState() => _MediaFiltersState();
}

class _MediaFiltersState extends State<MediaFilters> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (mediaProvider.hasActiveFilters)
                      TextButton(
                        onPressed: () => mediaProvider.clearFilters(),
                        child: const Text('Clear All'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quick filters
                _buildQuickFilters(mediaProvider),
                const SizedBox(height: 16),

                // Media type filter
                _buildMediaTypeFilter(mediaProvider),
                const SizedBox(height: 16),

                // Date range filter
                _buildDateRangeFilter(mediaProvider),
                const SizedBox(height: 16),

                // Tag filter
                _buildTagFilter(mediaProvider),
                const SizedBox(height: 16),

                // Sort options
                _buildSortOptions(mediaProvider),
                const SizedBox(height: 16),

                // Group options
                _buildGroupOptions(mediaProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickFilters(MediaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Today'),
              selected: provider.isDateFilterActive('today'),
              onSelected: (selected) {
                if (selected) {
                  provider.filterByToday();
                } else {
                  provider.clearDateFilter();
                }
              },
            ),
            FilterChip(
              label: const Text('This Week'),
              selected: provider.isDateFilterActive('week'),
              onSelected: (selected) {
                if (selected) {
                  provider.filterByWeek();
                } else {
                  provider.clearDateFilter();
                }
              },
            ),
            FilterChip(
              label: const Text('This Month'),
              selected: provider.isDateFilterActive('month'),
              onSelected: (selected) {
                if (selected) {
                  provider.filterByMonth();
                } else {
                  provider.clearDateFilter();
                }
              },
            ),
            FilterChip(
              label: const Text('This Year'),
              selected: provider.isDateFilterActive('year'),
              onSelected: (selected) {
                if (selected) {
                  provider.filterByYear();
                } else {
                  provider.clearDateFilter();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaTypeFilter(MediaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media Type',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: MediaType.values.map((type) {
            return FilterChip(
              label: Text(type.displayName),
              selected: provider.selectedMediaTypes.contains(type),
              onSelected: (selected) {
                provider.toggleMediaTypeFilter(type);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter(MediaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => _selectStartDate(provider),
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  provider.startDate != null
                      ? 'From: ${provider.startDate!.toLocal().toString().split(' ')[0]}'
                      : 'Start Date',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                onPressed: () => _selectEndDate(provider),
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  provider.endDate != null
                      ? 'To: ${provider.endDate!.toLocal().toString().split(' ')[0]}'
                      : 'End Date',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagFilter(MediaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            IconButton(
              onPressed: () => _showTagSelector(provider),
              icon: const Icon(Icons.add),
              tooltip: 'Add tag filter',
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (provider.selectedTags.isEmpty)
          const Text(
            'No tag filters applied',
            style: TextStyle(color: Colors.grey),
          )
        else
          Wrap(
            spacing: 8,
            children: provider.selectedTags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () => provider.removeTagFilter(tag),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSortOptions(MediaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<MediaSortBy>(
                value: provider.sortBy,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: MediaSortBy.values.map((sortBy) {
                  return DropdownMenuItem(
                    value: sortBy,
                    child: Text(_getSortByDisplayName(sortBy)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.setSortBy(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => provider.toggleSortOrder(),
              icon: Icon(
                provider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              ),
              tooltip: provider.sortAscending ? 'Ascending' : 'Descending',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupOptions(MediaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group By',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<MediaGroupBy?>(
          value: provider.groupBy,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            const DropdownMenuItem<MediaGroupBy?>(
              value: null,
              child: Text('No grouping'),
            ),
            ...MediaGroupBy.values.map((groupBy) {
              return DropdownMenuItem(
                value: groupBy,
                child: Text(_getGroupByDisplayName(groupBy)),
              );
            }),
          ],
          onChanged: (value) {
            provider.setGroupBy(value);
          },
        ),
      ],
    );
  }

  String _getSortByDisplayName(MediaSortBy sortBy) {
    switch (sortBy) {
      case MediaSortBy.createdAt:
        return 'Created Date';
      case MediaSortBy.name:
        return 'Name';
      case MediaSortBy.uploadedAt:
        return 'Upload Date';
    }
  }

  String _getGroupByDisplayName(MediaGroupBy groupBy) {
    switch (groupBy) {
      case MediaGroupBy.month:
        return 'Month';
      case MediaGroupBy.day:
        return 'Day';
      case MediaGroupBy.tag:
        return 'Tag';
    }
  }

  Future<void> _selectStartDate(MediaProvider provider) async {
    final date = await showDatePicker(
      context: context,
      initialDate: provider.startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      provider.setDateRange(date, provider.endDate);
    }
  }

  Future<void> _selectEndDate(MediaProvider provider) async {
    final date = await showDatePicker(
      context: context,
      initialDate: provider.endDate ?? DateTime.now(),
      firstDate: provider.startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      provider.setDateRange(provider.startDate, date);
    }
  }

  void _showTagSelector(MediaProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _TagSelectorDialog(
        selectedTags: provider.selectedTags,
        onTagsSelected: (tags) {
          for (final tag in tags) {
            provider.addTagFilter(tag);
          }
        },
      ),
    );
  }
}

class _TagSelectorDialog extends StatefulWidget {
  final Set<String> selectedTags;
  final Function(List<String>) onTagsSelected;

  const _TagSelectorDialog({
    required this.selectedTags,
    required this.onTagsSelected,
  });

  @override
  State<_TagSelectorDialog> createState() => _TagSelectorDialogState();
}

class _TagSelectorDialogState extends State<_TagSelectorDialog> {
  final TextEditingController _controller = TextEditingController();
  List<String> _availableTags = [];
  List<String> _filteredTags = [];
  Set<String> _tempSelectedTags = {};

  @override
  void initState() {
    super.initState();
    _tempSelectedTags = Set.from(widget.selectedTags);
    _loadAvailableTags();
  }

  void _loadAvailableTags() {
    // In a real app, you would load this from your MediaProvider or API
    // For now, we'll use some example tags
    _availableTags = [
      'vacation',
      'family',
      'work',
      'friends',
      'travel',
      'food',
      'nature',
      'pets',
      'sports',
      'events',
    ];
    _filteredTags = List.from(_availableTags);
  }

  void _filterTags(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTags = List.from(_availableTags);
      } else {
        _filteredTags = _availableTags
            .where((tag) => tag.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Tags'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Search tags',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterTags,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _filteredTags.length,
                itemBuilder: (context, index) {
                  final tag = _filteredTags[index];
                  final isSelected = _tempSelectedTags.contains(tag);
                  
                  return CheckboxListTile(
                    title: Text(tag),
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _tempSelectedTags.add(tag);
                        } else {
                          _tempSelectedTags.remove(tag);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newTags = _tempSelectedTags.difference(widget.selectedTags);
            widget.onTagsSelected(newTags.toList());
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
