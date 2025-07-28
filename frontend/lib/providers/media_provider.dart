import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class MediaProvider extends ChangeNotifier {
  final MediaService _mediaService = MediaService();
  
  List<Media> _media = [];
  bool _isLoading = false;
  String? _error;
  
  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  Set<String> _selectedTags = {};
  Set<MediaType> _selectedMediaTypes = {};
  MediaSortBy _sortBy = MediaSortBy.createdAt;
  bool _sortAscending = false;
  MediaGroupBy? _groupBy;
  String? _searchQuery;
  String? _activeDateFilter;

  // Getters
  List<Media> get media => _media;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  Set<String> get selectedTags => _selectedTags;
  Set<MediaType> get selectedMediaTypes => _selectedMediaTypes;
  MediaSortBy get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  MediaGroupBy? get groupBy => _groupBy;
  String? get searchQuery => _searchQuery;

  bool get hasActiveFilters =>
      _startDate != null ||
      _endDate != null ||
      _selectedTags.isNotEmpty ||
      _selectedMediaTypes.isNotEmpty ||
      _searchQuery != null;

  Future<void> loadMedia() async {
    _setLoading(true);
    _error = null;

    try {
      final request = MediaFilterRequest(
        startDate: _startDate,
        endDate: _endDate,
        tagNames: _selectedTags.isNotEmpty ? _selectedTags.toList() : null,
        sortBy: _sortByToString(_sortBy),
        sortDirection: _sortAscending ? 'asc' : 'desc',
        groupBy: _groupBy != null ? _groupByToString(_groupBy!) : null,
        search: _searchQuery,
      );

      _media = await _mediaService.filterMedia(request);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading media: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Date filter methods
  void filterByToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    setDateRange(today, tomorrow);
    _activeDateFilter = 'today';
    loadMedia();
  }

  void filterByWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    setDateRange(weekStart, weekEnd);
    _activeDateFilter = 'week';
    loadMedia();
  }

  void filterByMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);
    setDateRange(monthStart, monthEnd);
    _activeDateFilter = 'month';
    loadMedia();
  }

  void filterByYear() {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final yearEnd = DateTime(now.year + 1, 1, 1);
    setDateRange(yearStart, yearEnd);
    _activeDateFilter = 'year';
    loadMedia();
  }

  bool isDateFilterActive(String filter) {
    return _activeDateFilter == filter;
  }

  void clearDateFilter() {
    _startDate = null;
    _endDate = null;
    _activeDateFilter = null;
    notifyListeners();
    loadMedia();
  }

  // Media type filter methods
  void toggleMediaTypeFilter(MediaType type) {
    if (_selectedMediaTypes.contains(type)) {
      _selectedMediaTypes.remove(type);
    } else {
      _selectedMediaTypes.add(type);
    }
    notifyListeners();
    loadMedia();
  }

  // Tag filter methods
  void addTagFilter(String tag) {
    _selectedTags.add(tag);
    notifyListeners();
    loadMedia();
  }

  void removeTagFilter(String tag) {
    _selectedTags.remove(tag);
    notifyListeners();
    loadMedia();
  }

  // Sort methods
  void setSortBy(MediaSortBy sortBy) {
    _sortBy = sortBy;
    notifyListeners();
    loadMedia();
  }

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    notifyListeners();
    loadMedia();
  }

  // Group methods
  void setGroupBy(MediaGroupBy? groupBy) {
    _groupBy = groupBy;
    notifyListeners();
    loadMedia();
  }

  Future<void> searchMedia(String query) async {
    _searchQuery = query.isEmpty ? null : query;
    await loadMedia();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _activeDateFilter = null; // Clear quick filter when setting custom range
    notifyListeners();
  }

  void setTagFilter(List<String> tags) {
    _selectedTags = tags.toSet();
    notifyListeners();
  }

  void setSorting(String sortBy, String direction) {
    _sortBy = _stringToSortBy(sortBy);
    _sortAscending = direction == 'asc';
    notifyListeners();
  }

  void setGrouping(String groupBy) {
    _groupBy = _stringToGroupBy(groupBy);
    notifyListeners();
  }

  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _selectedTags.clear();
    _selectedMediaTypes.clear();
    _searchQuery = null;
    _sortBy = MediaSortBy.createdAt;
    _sortAscending = false;
    _groupBy = null;
    _activeDateFilter = null;
    loadMedia();
  }

  String getFiltersDescription() {
    List<String> filters = [];
    
    if (_startDate != null || _endDate != null) {
      String dateRange = '';
      if (_startDate != null) {
        dateRange += 'From ${_formatDate(_startDate!)}';
      }
      if (_endDate != null) {
        if (dateRange.isNotEmpty) dateRange += ' ';
        dateRange += 'To ${_formatDate(_endDate!)}';
      }
      filters.add(dateRange);
    }
    
    if (_selectedTags.isNotEmpty) {
      filters.add('Tags: ${_selectedTags.join(', ')}');
    }

    if (_selectedMediaTypes.isNotEmpty) {
      filters.add('Types: ${_selectedMediaTypes.map((t) => t.displayName).join(', ')}');
    }
    
    if (_searchQuery != null) {
      filters.add('Search: $_searchQuery');
    }
    
    filters.add('Sort: ${_sortByToString(_sortBy)} (${_sortAscending ? 'ASC' : 'DESC'})');
    
    if (_groupBy != null) {
      filters.add('Group: ${_groupByToString(_groupBy!)}');
    }
    
    return filters.join(' • ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper methods for enum conversion
  String _sortByToString(MediaSortBy sortBy) {
    switch (sortBy) {
      case MediaSortBy.createdAt:
        return 'createdAt';
      case MediaSortBy.name:
        return 'name';
      case MediaSortBy.uploadedAt:
        return 'uploadedAt';
    }
  }

  MediaSortBy _stringToSortBy(String sortBy) {
    switch (sortBy) {
      case 'name':
        return MediaSortBy.name;
      case 'uploadedAt':
        return MediaSortBy.uploadedAt;
      default:
        return MediaSortBy.createdAt;
    }
  }

  String _groupByToString(MediaGroupBy groupBy) {
    switch (groupBy) {
      case MediaGroupBy.month:
        return 'month';
      case MediaGroupBy.day:
        return 'day';
      case MediaGroupBy.tag:
        return 'tag';
    }
  }

  MediaGroupBy? _stringToGroupBy(String groupBy) {
    switch (groupBy) {
      case 'day':
        return MediaGroupBy.day;
      case 'tag':
        return MediaGroupBy.tag;
      case 'month':
        return MediaGroupBy.month;
      default:
        return null;
    }
  }

  // Media CRUD operations
  Future<void> createMedia(CreateMediaRequest request) async {
    try {
      await _mediaService.createMedia(request);
      await loadMedia(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMedia(String id, UpdateMediaRequest request) async {
    try {
      await _mediaService.updateMedia(id, request);
      await loadMedia(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMedia(String id) async {
    try {
      await _mediaService.deleteMedia(id);
      _media.removeWhere((media) => media.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
