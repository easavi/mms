import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class MediaProvider extends ChangeNotifier {
  final MediaService _mediaService = MediaService();
  
  List<Media> _media = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _pageSize = 20; // API page size
  
  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  Set<String> _selectedTags = {};
  String? _selectedMediaType; // Changed to single string to match API
  MediaSortBy _sortBy = MediaSortBy.createdAt;
  bool _sortAscending = false;
  MediaGroupBy? _groupBy = MediaGroupBy.month; // Default to 'month' as per API
  String? _searchQuery;
  String? _activeDateFilter;

  // Getters
  List<Media> get media => _media;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  String? get error => _error;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  Set<String> get selectedTags => _selectedTags;
  String? get selectedMediaType => _selectedMediaType;
  MediaSortBy get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  MediaGroupBy? get groupBy => _groupBy;
  String? get searchQuery => _searchQuery;

  bool get hasActiveFilters =>
      _startDate != null ||
      _endDate != null ||
      _selectedTags.isNotEmpty ||
      _selectedMediaType != null ||
      _searchQuery != null;

  Future<void> loadMedia() async {
    _setLoading(true);
    _error = null;
    _currentPage = 0;
    _hasMoreData = true;

    try {
      // Convert dates to string format (YYYY-MM-DD)
      String? start;
      String? end;
      if (_startDate != null) {
        start = '${_startDate!.year.toString().padLeft(4, '0')}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}';
      }
      if (_endDate != null) {
        end = '${_endDate!.year.toString().padLeft(4, '0')}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}';
      }

      final result = await _mediaService.getAllMedia(
        group: _groupByToString(_groupBy ?? MediaGroupBy.month),
        sortDirection: _sortAscending ? 'asc' : 'desc',
        start: start,
        end: end,
        type: _selectedMediaType,
        tags: _selectedTags.isNotEmpty ? _selectedTags.toList() : null,
        page: _currentPage,
        size: _pageSize,
      );
      
      debugPrint('Loaded ${result.length} media items');
      _media = List<Media>.from(result); // Ensure proper list type
      _hasMoreData = result.length == _pageSize;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading media: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreMedia() async {
    if (!_hasMoreData || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      
      // Convert dates to string format (YYYY-MM-DD)
      String? start;
      String? end;
      if (_startDate != null) {
        start = '${_startDate!.year.toString().padLeft(4, '0')}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}';
      }
      if (_endDate != null) {
        end = '${_endDate!.year.toString().padLeft(4, '0')}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}';
      }

      final result = await _mediaService.getAllMedia(
        group: _groupByToString(_groupBy ?? MediaGroupBy.month),
        sortDirection: _sortAscending ? 'asc' : 'desc',
        start: start,
        end: end,
        type: _selectedMediaType,
        tags: _selectedTags.isNotEmpty ? _selectedTags.toList() : null,
        page: _currentPage,
        size: _pageSize,
      );
      
      _media.addAll(result);
      _hasMoreData = result.length == _pageSize;
      notifyListeners();
    } catch (e) {
      _currentPage--; // Revert page increment on error
      _error = e.toString();
      debugPrint('Error loading more media: $e');
      notifyListeners();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
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
  void setMediaTypeFilter(String? type) {
    _selectedMediaType = type;
    notifyListeners();
    loadMedia();
  }

  void toggleMediaTypeFilter(MediaType type) {
    String typeString = type.name.toLowerCase();
    if (_selectedMediaType == typeString) {
      _selectedMediaType = null;
    } else {
      _selectedMediaType = typeString;
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
  void setGroupBy(MediaGroupBy groupBy) {
    _groupBy = groupBy;
    notifyListeners();
    loadMedia();
  }

  Future<void> searchMedia(String query) async {
    // Note: Search functionality has been simplified in the new API
    // For now, we'll just reload the media with current filters
    // In the future, you might want to implement client-side filtering
    // or add a search parameter to the backend API
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
    _selectedMediaType = null;
    _searchQuery = null;
    _sortBy = MediaSortBy.createdAt;
    _sortAscending = false;
    _groupBy = MediaGroupBy.month;
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

    if (_selectedMediaType != null) {
      filters.add('Type: $_selectedMediaType');
    }
    
    if (_searchQuery != null) {
      filters.add('Search: $_searchQuery (client-side)');
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
