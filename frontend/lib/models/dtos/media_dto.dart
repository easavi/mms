import '../media_type.dart';

class CreateMediaRequest {
  final String name;
  final MediaType mediaType;
  final String fileName;
  final String fileUrl;
  final List<String> tags;

  CreateMediaRequest({
    required this.name,
    required this.mediaType,
    required this.fileName,
    required this.fileUrl,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mediaType': mediaType.apiValue,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'tags': tags,
    };
  }
}

class UpdateMediaRequest {
  final String? name;
  final MediaType? mediaType;
  final String? fileName;
  final String? fileUrl;
  final List<String>? tags;

  UpdateMediaRequest({
    this.name,
    this.mediaType,
    this.fileName,
    this.fileUrl,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (mediaType != null) json['mediaType'] = mediaType!.apiValue;
    if (fileName != null) json['fileName'] = fileName;
    if (fileUrl != null) json['fileUrl'] = fileUrl;
    if (tags != null) json['tags'] = tags;
    return json;
  }
}

class MediaFilterRequest {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? tagNames;
  final String? sortBy;
  final String? sortDirection;
  final String? groupBy;
  final String? search;
  final int? page;
  final int? size;

  MediaFilterRequest({
    this.startDate,
    this.endDate,
    this.tagNames,
    this.sortBy,
    this.sortDirection,
    this.groupBy,
    this.search,
    this.page,
    this.size,
  });

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};
    
    if (startDate != null) {
      params['startDate'] = startDate!.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      params['endDate'] = endDate!.toIso8601String().split('T')[0];
    }
    if (tagNames != null && tagNames!.isNotEmpty) {
      params['tagNames'] = tagNames!.join(',');
    }
    if (sortBy != null) params['sortBy'] = sortBy!;
    if (sortDirection != null) params['sortDirection'] = sortDirection!;
    if (groupBy != null) params['groupBy'] = groupBy!;
    if (search != null) params['search'] = search!;
    if (page != null) params['page'] = page.toString();
    if (size != null) params['size'] = size.toString();
    
    return params;
  }
}
