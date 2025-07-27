import '../media.dart';

class GroupedMediaResponse {
  final String groupKey;
  final List<Media> medias;
  final int count;

  GroupedMediaResponse({
    required this.groupKey,
    required this.medias,
    required this.count,
  });

  factory GroupedMediaResponse.fromJson(Map<String, dynamic> json) {
    return GroupedMediaResponse(
      groupKey: json['groupKey'],
      medias: (json['medias'] as List)
          .map((media) => Media.fromJson(media))
          .toList(),
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupKey': groupKey,
      'medias': medias.map((media) => media.toJson()).toList(),
      'count': count,
    };
  }
}

class MediaStatsResponse {
  final int totalMedia;
  final int imageCount;
  final int videoCount;
  final int fileCount;
  final int totalTags;
  final Map<String, int> tagUsage;
  final Map<String, int> monthlyDistribution;

  MediaStatsResponse({
    required this.totalMedia,
    required this.imageCount,
    required this.videoCount,
    required this.fileCount,
    required this.totalTags,
    required this.tagUsage,
    required this.monthlyDistribution,
  });

  factory MediaStatsResponse.fromJson(Map<String, dynamic> json) {
    return MediaStatsResponse(
      totalMedia: json['totalMedia'],
      imageCount: json['imageCount'],
      videoCount: json['videoCount'],
      fileCount: json['fileCount'],
      totalTags: json['totalTags'],
      tagUsage: Map<String, int>.from(json['tagUsage']),
      monthlyDistribution: Map<String, int>.from(json['monthlyDistribution']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMedia': totalMedia,
      'imageCount': imageCount,
      'videoCount': videoCount,
      'fileCount': fileCount,
      'totalTags': totalTags,
      'tagUsage': tagUsage,
      'monthlyDistribution': monthlyDistribution,
    };
  }
}

class PagedResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  PagedResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResponse(
      content: (json['content'] as List)
          .map((item) => fromJsonT(item))
          .toList(),
      page: json['page'],
      size: json['size'],
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      hasNext: json['hasNext'],
      hasPrevious: json['hasPrevious'],
    );
  }
}
