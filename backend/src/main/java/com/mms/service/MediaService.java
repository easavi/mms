package com.mms.service;

import com.mms.dto.media.MediaCreateRequest;
import com.mms.dto.media.MediaFilterRequest;
import com.mms.dto.media.MediaResponse;
import com.mms.dto.media.MediaUpdateRequest;
import com.mms.dto.media.MediaUploadRequest;
import com.mms.dto.media.GroupedMediaResponse;
import com.mms.entity.Media;
import com.mms.entity.Tag;
import com.mms.exception.ApiException;
import com.mms.repository.MediaRepository;
import com.mms.repository.TagRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class MediaService {
    
    private final MediaRepository mediaRepository;
    private final TagRepository tagRepository;
    private final StorageService storageService;
    
    public MediaService(MediaRepository mediaRepository, TagRepository tagRepository, StorageService storageService) {
        this.mediaRepository = mediaRepository;
        this.tagRepository = tagRepository;
        this.storageService = storageService;
    }
    
    @Transactional
    public MediaResponse createMedia(MediaCreateRequest request) {
        Set<Tag> tags = processTags(request.getTagNames());
        
        Media media = new Media();
        media.setName(request.getName());
        media.setMediaType(request.getMediaType());
        media.setFileName(request.getFileName());
        media.setFileUrl(request.getFileUrl());
        media.setCreatedAt(request.getCreatedAt());
        media.setTags(tags);
        
        media = mediaRepository.save(media);
        return convertToResponse(media);
    }
    
    @Transactional
    public MediaResponse uploadMedia(MediaUploadRequest request) {
        try {
            MultipartFile file = request.getFile();
            
            // Generate unique file path
            String fileName = file.getOriginalFilename();
            String extension = fileName != null && fileName.contains(".") 
                ? fileName.substring(fileName.lastIndexOf(".")) 
                : "";
            String uniqueFileName = UUID.randomUUID().toString() + extension;
            String filePath = "media/" + uniqueFileName;
            
            // Store file in MinIO
            String storedPath = storageService.store("mms", file, filePath);
            
            // Get the public URL for the stored file
            String fileUrl = storageService.getUrl("mms", storedPath);
            
            // Determine title (use provided title or derive from filename)
            String title = request.getTitle();
            if (title == null || title.trim().isEmpty()) {
                title = fileName != null ? fileName : "Uploaded File";
                // Remove extension from title if present
                if (title.contains(".")) {
                    title = title.substring(0, title.lastIndexOf("."));
                }
            }
            
            // Determine media type (use provided type or derive from file)
            String mediaType = request.getMediaType();
            if (mediaType == null || mediaType.trim().isEmpty()) {
                mediaType = determineMediaTypeFromFile(fileName, file.getContentType());
            }
            
            // Process tags
            Set<Tag> tags = processTags(request.getTags());
            
            // Create media entity
            Media media = new Media();
            media.setName(title);
            media.setMediaType(mediaType);
            media.setFileName(fileName);
            media.setFileUrl(fileUrl);
            media.setCreatedAt(OffsetDateTime.now());
            media.setUploadedAt(OffsetDateTime.now());
            media.setTags(tags);
            
            // Save to database
            media = mediaRepository.save(media);
            return convertToResponse(media);
            
        } catch (Exception e) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, 
                "Failed to upload file: " + e.getMessage());
        }
    }
    
    private String determineMediaTypeFromFile(String fileName, String contentType) {
        if (fileName != null) {
            String extension = fileName.toLowerCase();
            if (extension.matches(".*\\.(jpg|jpeg|png|gif|bmp|webp|svg)$")) {
                return "image";
            } else if (extension.matches(".*\\.(mp4|avi|mov|wmv|flv|webm|mkv|3gp)$")) {
                return "video";
            } else if (extension.matches(".*\\.(mp3|wav|flac|aac|ogg)$")) {
                return "audio";
            } else if (extension.matches(".*\\.(pdf|doc|docx|txt|rtf)$")) {
                return "document";
            }
        }
        
        // Fallback to content type if available
        if (contentType != null) {
            if (contentType.startsWith("image/")) {
                return "image";
            } else if (contentType.startsWith("video/")) {
                return "video";
            } else if (contentType.startsWith("audio/")) {
                return "audio";
            } else if (contentType.startsWith("application/pdf") || 
                      contentType.startsWith("application/msword") ||
                      contentType.startsWith("text/")) {
                return "document";
            }
        }
        
        return "file"; // Default fallback
    }
    
    @Transactional(readOnly = true)
    public List<MediaResponse> getAllMedia() {
        return mediaRepository.findAll()
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public Page<MediaResponse> getMediaWithFilters(
            OffsetDateTime startDate, 
            OffsetDateTime endDate,
            List<String> tagNames,
            String sortDirection,
            Pageable pageable) {
        
        boolean ascending = "asc".equalsIgnoreCase(sortDirection);
        Page<Media> mediaPage;
        
        if (startDate != null && endDate != null && tagNames != null && !tagNames.isEmpty()) {
            // Both date range and tags filter
            if (ascending) {
                mediaPage = mediaRepository.findByCreatedAtBetweenAndTagsNameInOrderByCreatedAtAsc(
                    startDate, endDate, tagNames, pageable);
            } else {
                mediaPage = mediaRepository.findByCreatedAtBetweenAndTagsNameInOrderByCreatedAtDesc(
                    startDate, endDate, tagNames, pageable);
            }
        } else if (startDate != null && endDate != null) {
            // Only date range filter
            if (ascending) {
                mediaPage = mediaRepository.findByCreatedAtBetweenOrderByCreatedAtAsc(
                    startDate, endDate, pageable);
            } else {
                mediaPage = mediaRepository.findByCreatedAtBetweenOrderByCreatedAtDesc(
                    startDate, endDate, pageable);
            }
        } else if (tagNames != null && !tagNames.isEmpty()) {
            // Only tags filter
            if (ascending) {
                mediaPage = mediaRepository.findByTagsNameInOrderByCreatedAtAsc(tagNames, pageable);
            } else {
                mediaPage = mediaRepository.findByTagsNameInOrderByCreatedAtDesc(tagNames, pageable);
            }
        } else {
            // No filters, just sorting
            if (ascending) {
                mediaPage = mediaRepository.findAllByOrderByCreatedAtAsc(pageable);
            } else {
                mediaPage = mediaRepository.findAllByOrderByCreatedAtDesc(pageable);
            }
        }
        
        return mediaPage.map(this::convertToResponse);
    }
    
    @Transactional(readOnly = true)
    public Page<MediaResponse> getMediaWithFilters(
            OffsetDateTime startDate, 
            OffsetDateTime endDate,
            List<String> tagNames,
            String sortBy,
            String sortDirection,
            Pageable pageable) {
        
        // For now, delegate to the existing method since repository methods are hardcoded to createdAt
        // In the future, this could be enhanced to support dynamic sorting
        return getMediaWithFilters(startDate, endDate, tagNames, sortDirection, pageable);
    }
    
    @Transactional(readOnly = true)
    public MediaResponse getMediaById(UUID id) {
        Media media = mediaRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Media not found"));
        return convertToResponse(media);
    }
    
    @Transactional
    public MediaResponse updateMedia(UUID id, MediaUpdateRequest request) {
        Media media = mediaRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Media not found"));
        
        if (request.getName() != null) {
            media.setName(request.getName());
        }
        if (request.getMediaType() != null) {
            media.setMediaType(request.getMediaType());
        }
        if (request.getFileName() != null) {
            media.setFileName(request.getFileName());
        }
        if (request.getFileUrl() != null) {
            media.setFileUrl(request.getFileUrl());
        }
        if (request.getCreatedAt() != null) {
            media.setCreatedAt(request.getCreatedAt());
        }
        if (request.getTagNames() != null) {
            Set<Tag> tags = processTags(request.getTagNames());
            media.setTags(tags);
        }
        
        media = mediaRepository.save(media);
        return convertToResponse(media);
    }
    
    @Transactional
    public void deleteMedia(UUID id) {
        if (!mediaRepository.existsById(id)) {
            throw new ApiException(HttpStatus.NOT_FOUND, "Media not found");
        }
        mediaRepository.deleteById(id);
    }
    
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getMediaGroupedByMonth() {
        List<Object[]> results = mediaRepository.getMediaCountGroupedByMonth();
        return results.stream()
                .map(result -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("period", result[0].toString());
                    item.put("count", result[1]);
                    return item;
                })
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getMediaGroupedByDay() {
        List<Object[]> results = mediaRepository.getMediaCountGroupedByDay();
        return results.stream()
                .map(result -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("period", result[0].toString());
                    item.put("count", result[1]);
                    return item;
                })
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getMediaGroupedByTag() {
        List<Object[]> results = mediaRepository.getMediaCountGroupedByTag();
        return results.stream()
                .map(result -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("tagName", result[0]);
                    item.put("count", result[1]);
                    return item;
                })
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public Page<MediaResponse> searchMedia(String searchTerm, Pageable pageable) {
        Page<Media> mediaPage = mediaRepository.searchByNameOrFileName(searchTerm, pageable);
        return mediaPage.map(this::convertToResponse);
    }
    
    @Transactional(readOnly = true)
    public Page<MediaResponse> getMediaWithAdvancedFilter(MediaFilterRequest filter, Pageable pageable) {
        return getMediaWithFilters(
            filter.getStartDate(),
            filter.getEndDate(),
            filter.getTagNames(),
            filter.getSortDirection(),
            pageable
        );
    }
    
    @Transactional(readOnly = true)
    public List<GroupedMediaResponse> getGroupedMediaByDatePeriod(String period) {
        List<Object[]> results;
        String groupType;
        
        if ("day".equalsIgnoreCase(period)) {
            results = mediaRepository.getMediaCountGroupedByDay();
            groupType = "day";
        } else {
            results = mediaRepository.getMediaCountGroupedByMonth();
            groupType = "month";
        }
        
        return results.stream()
                .map(result -> new GroupedMediaResponse(
                    result[0].toString(),
                    groupType,
                    ((Number) result[1]).longValue()
                ))
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<GroupedMediaResponse> getGroupedMediaByTags() {
        List<Object[]> results = mediaRepository.getMediaCountGroupedByTag();
        
        return results.stream()
                .map(result -> new GroupedMediaResponse(
                    (String) result[0],
                    "tag",
                    ((Number) result[1]).longValue()
                ))
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public Map<String, Object> getMediaStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        // Total count
        long totalCount = mediaRepository.count();
        stats.put("totalCount", totalCount);
        stats.put("totalMedia", totalCount);
        
        // Monthly statistics
        List<Object[]> monthlyStats = mediaRepository.getMediaCountGroupedByMonth();
        stats.put("monthlyBreakdown", monthlyStats.stream()
                .map(result -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("period", result[0].toString());
                    item.put("count", result[1]);
                    return item;
                })
                .collect(Collectors.toList()));
        
        // Tag statistics
        List<Object[]> tagStats = mediaRepository.getMediaCountGroupedByTag();
        stats.put("topTags", tagStats.stream()
                .limit(10) // Top 10 tags
                .map(result -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("tagName", result[0]);
                    item.put("count", result[1]);
                    return item;
                })
                .collect(Collectors.toList()));
        
        return stats;
    }
    
    private Set<Tag> processTags(String[] tagNames) {
        if (tagNames == null || tagNames.length == 0) {
            return new HashSet<>();
        }
        
        return Arrays.stream(tagNames)
                .map(name -> tagRepository.findByName(name)
                        .orElseGet(() -> {
                            Tag tag = new Tag(name);
                            return tagRepository.save(tag);
                        }))
                .collect(Collectors.toSet());
    }
    
    private MediaResponse convertToResponse(Media media) {
        MediaResponse response = new MediaResponse();
        response.setId(media.getId().toString());
        response.setName(media.getName());
        response.setMediaType(media.getMediaType());
        response.setFileName(media.getFileName());
        response.setFileUrl(media.getFileUrl());
        response.setCreatedAt(media.getCreatedAt().format(DateTimeFormatter.ISO_OFFSET_DATE_TIME));
        response.setUploadedAt(media.getUploadedAt() != null ? 
            media.getUploadedAt().format(DateTimeFormatter.ISO_OFFSET_DATE_TIME) : null);
        response.setTags(media.getTags().stream()
                .map(Tag::getName)
                .toArray(String[]::new));
        return response;
    }
}
