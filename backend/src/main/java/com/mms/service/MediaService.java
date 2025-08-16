package com.mms.service;

import com.mms.dto.media.MediaCreateRequest;
import com.mms.dto.media.MediaContentResponse;
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
            // Debug logging
            System.out.println("=== MediaService Debug ===");
            System.out.println("Request: " + request);
            System.out.println("Request file: " + (request.getFile() != null ? request.getFile().getOriginalFilename() : "NULL"));
            System.out.println("=========================");
            
            MultipartFile file = request.getFile();
            
            if (file == null) {
                throw new RuntimeException("File is null in MediaService");
            }
            
            // Store file using local storage service
            // The local storage service will handle creating user-specific directories
            String storedPath = storageService.store("local", file, "");
            
            // For local storage, the URL is the path that will be handled by the content API
            String fileUrl = "/api/media/content?bucket=local&fileId=" + storedPath;
            
            // Determine title (use provided title or derive from filename)
            String fileName = file.getOriginalFilename();
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
            media.setFileSize(file.getSize()); // Set file size
            media.setCreatedAt(OffsetDateTime.now());
            media.setUploadedAt(OffsetDateTime.now());
            media.setTags(tags);
            
            // Set storage ID if provided
            if (request.getStorageId() != null) {
                media.setStorageId(request.getStorageId());
            }
            
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
            String mediaType,
            String sortDirection,
            Pageable pageable) {
        
        boolean ascending = "asc".equalsIgnoreCase(sortDirection);
        Page<Media> mediaPage;
        
        // Determine which filters are active
        boolean hasDateFilter = startDate != null && endDate != null;
        boolean hasTagsFilter = tagNames != null && !tagNames.isEmpty();
        boolean hasMediaTypeFilter = mediaType != null && !mediaType.isEmpty();
        
        if (hasMediaTypeFilter && hasDateFilter && hasTagsFilter) {
            // All three filters: media type + date range + tags
            if (ascending) {
                mediaPage = mediaRepository.findByMediaTypeAndCreatedAtBetweenAndTagsNameInOrderByCreatedAtAsc(
                    mediaType, startDate, endDate, tagNames, pageable);
            } else {
                mediaPage = mediaRepository.findByMediaTypeAndCreatedAtBetweenAndTagsNameInOrderByCreatedAtDesc(
                    mediaType, startDate, endDate, tagNames, pageable);
            }
        } else if (hasMediaTypeFilter && hasDateFilter) {
            // Media type + date range
            if (ascending) {
                mediaPage = mediaRepository.findByMediaTypeAndCreatedAtBetweenOrderByCreatedAtAsc(
                    mediaType, startDate, endDate, pageable);
            } else {
                mediaPage = mediaRepository.findByMediaTypeAndCreatedAtBetweenOrderByCreatedAtDesc(
                    mediaType, startDate, endDate, pageable);
            }
        } else if (hasMediaTypeFilter && hasTagsFilter) {
            // Media type + tags
            if (ascending) {
                mediaPage = mediaRepository.findByMediaTypeAndTagsNameInOrderByCreatedAtAsc(
                    mediaType, tagNames, pageable);
            } else {
                mediaPage = mediaRepository.findByMediaTypeAndTagsNameInOrderByCreatedAtDesc(
                    mediaType, tagNames, pageable);
            }
        } else if (hasMediaTypeFilter) {
            // Only media type filter
            if (ascending) {
                mediaPage = mediaRepository.findByMediaTypeOrderByCreatedAtAsc(mediaType, pageable);
            } else {
                mediaPage = mediaRepository.findByMediaTypeOrderByCreatedAtDesc(mediaType, pageable);
            }
        } else {
            // Fall back to existing method for other combinations
            return getMediaWithFilters(startDate, endDate, tagNames, sortDirection, pageable);
        }
        
        return mediaPage.map(this::convertToResponse);
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
    
    @Transactional(readOnly = true)
    public MediaContentResponse getFileContentById(UUID mediaId) {
        // Find the media record by ID
        Media media = mediaRepository.findById(mediaId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Media not found"));
        
        try {
            // Extract file path from the stored file URL
            String filePath = extractFilePathFromUrl(media.getFileUrl());
            
            // Retrieve the file content from local storage
            var inputStream = storageService.retrieve("local", filePath);
            byte[] content = inputStream.readAllBytes();
            inputStream.close();
            
            // Determine content type
            String contentType = determineContentTypeFromMedia(media.getMediaType(), media.getFileName());
            
            return new MediaContentResponse(content, contentType, media.getFileName());
            
        } catch (Exception e) {
            throw new ApiException(HttpStatus.NOT_FOUND, "File content not found: " + e.getMessage());
        }
    }
    
    private String extractFilePathFromUrl(String fileUrl) {
        // For local storage URLs like: /api/media/content?bucket=local&fileId=username/images/filename.ext
        // We want to extract: username/images/filename.ext
        if (fileUrl.contains("fileId=")) {
            int fileIdIndex = fileUrl.indexOf("fileId=") + 7;
            String fileId = fileUrl.substring(fileIdIndex);
            // Remove any additional query parameters
            if (fileId.contains("&")) {
                fileId = fileId.substring(0, fileId.indexOf("&"));
            }
            return fileId;
        }
        
        // Fallback: if it's already a path, return as is
        return fileUrl;
    }

    @Transactional(readOnly = true)
    public MediaContentResponse getFileContent(String bucket, String fileId) {
        try {
            // Use the file ID as the path directly (it contains the full path: username/mediatype/filename)
            var inputStream = storageService.retrieve(bucket, fileId);
            byte[] content = inputStream.readAllBytes();
            inputStream.close();
            
            // Find the media record to get content type and filename info
            String contentType = "application/octet-stream"; // default
            String fileName = fileId;
            
            // Extract just the filename from the path
            if (fileId.contains("/")) {
                fileName = fileId.substring(fileId.lastIndexOf("/") + 1);
            }
            
            // Try to find media record by searching for the file path in fileUrl
            Optional<Media> mediaOpt = mediaRepository.findAll().stream()
                    .filter(media -> media.getFileUrl() != null && media.getFileUrl().contains(fileId))
                    .findFirst();
            
            if (mediaOpt.isPresent()) {
                Media media = mediaOpt.get();
                fileName = media.getFileName() != null ? media.getFileName() : fileName;
                contentType = determineContentTypeFromMedia(media.getMediaType(), fileName);
            } else {
                // Fallback: determine content type from file extension
                contentType = determineContentTypeFromExtension(fileName);
            }
            
            return new MediaContentResponse(content, contentType, fileName);
            
        } catch (Exception e) {
            throw new ApiException(HttpStatus.NOT_FOUND, "File not found: " + e.getMessage());
        }
    }

    @Transactional(readOnly = true)
    public MediaContentResponse getThumbnailById(UUID mediaId) {
        // Find the media record by ID
        Media media = mediaRepository.findById(mediaId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Media not found"));
        
        // Check if it's an image
        if (!"image".equals(media.getMediaType())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Thumbnails are only available for images");
        }
        
        try {
            // Extract file path from the stored file URL
            String filePath = extractFilePathFromUrl(media.getFileUrl());
            
            // Get thumbnail path using LocalStorageService
            LocalStorageService localStorageService = (LocalStorageService) storageService;
            String thumbnailPath = localStorageService.getThumbnailPath(filePath);
            
            if (thumbnailPath == null) {
                throw new ApiException(HttpStatus.NOT_FOUND, "Thumbnail not found for this image");
            }
            
            // Retrieve the thumbnail content
            var inputStream = storageService.retrieve("local", thumbnailPath);
            byte[] content = inputStream.readAllBytes();
            inputStream.close();
            
            // Determine content type (thumbnails are typically in the same format as original)
            String contentType = determineContentTypeFromMedia(media.getMediaType(), media.getFileName());
            
            return new MediaContentResponse(content, contentType, media.getFileName());
            
        } catch (Exception e) {
            throw new ApiException(HttpStatus.NOT_FOUND, "Thumbnail not found: " + e.getMessage());
        }
    }

    @Transactional(readOnly = true)
    public MediaContentResponse getThumbnail(String bucket, String fileId) {
        try {
            // Check if the original file is an image
            LocalStorageService localStorageService = (LocalStorageService) storageService;
            if (!localStorageService.isImageFile(fileId)) {
                throw new ApiException(HttpStatus.BAD_REQUEST, "Thumbnails are only available for images");
            }
            
            // Get thumbnail path
            String thumbnailPath = localStorageService.getThumbnailPath(fileId);
            
            if (thumbnailPath == null) {
                throw new ApiException(HttpStatus.NOT_FOUND, "Thumbnail not found for this image");
            }
            
            // Retrieve the thumbnail content
            var inputStream = storageService.retrieve(bucket, thumbnailPath);
            byte[] content = inputStream.readAllBytes();
            inputStream.close();
            
            // Extract filename for content type determination
            String fileName = fileId;
            if (fileId.contains("/")) {
                fileName = fileId.substring(fileId.lastIndexOf("/") + 1);
            }
            
            // Determine content type
            String contentType = determineContentTypeFromExtension(fileName);
            
            return new MediaContentResponse(content, contentType, fileName);
            
        } catch (Exception e) {
            throw new ApiException(HttpStatus.NOT_FOUND, "Thumbnail not found: " + e.getMessage());
        }
    }
    
    private String determineContentTypeFromMedia(String mediaType, String fileName) {
        if (fileName != null) {
            String extension = fileName.toLowerCase();
            
            // Image types
            if (extension.endsWith(".jpg") || extension.endsWith(".jpeg")) return "image/jpeg";
            if (extension.endsWith(".png")) return "image/png";
            if (extension.endsWith(".gif")) return "image/gif";
            if (extension.endsWith(".bmp")) return "image/bmp";
            if (extension.endsWith(".webp")) return "image/webp";
            if (extension.endsWith(".svg")) return "image/svg+xml";
            
            // Video types
            if (extension.endsWith(".mp4")) return "video/mp4";
            if (extension.endsWith(".avi")) return "video/x-msvideo";
            if (extension.endsWith(".mov")) return "video/quicktime";
            if (extension.endsWith(".wmv")) return "video/x-ms-wmv";
            if (extension.endsWith(".webm")) return "video/webm";
            if (extension.endsWith(".mkv")) return "video/x-matroska";
            
            // Audio types
            if (extension.endsWith(".mp3")) return "audio/mpeg";
            if (extension.endsWith(".wav")) return "audio/wav";
            if (extension.endsWith(".flac")) return "audio/flac";
            if (extension.endsWith(".aac")) return "audio/aac";
            if (extension.endsWith(".ogg")) return "audio/ogg";
            
            // Document types
            if (extension.endsWith(".pdf")) return "application/pdf";
            if (extension.endsWith(".doc")) return "application/msword";
            if (extension.endsWith(".docx")) return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            if (extension.endsWith(".txt")) return "text/plain";
        }
        
        // Fallback based on media type
        return switch (mediaType) {
            case "image" -> "image/jpeg";
            case "video" -> "video/mp4";
            case "audio" -> "audio/mpeg";
            case "document" -> "application/pdf";
            default -> "application/octet-stream";
        };
    }
    
    private String determineContentTypeFromExtension(String fileName) {
        if (fileName != null) {
            String extension = fileName.toLowerCase();
            
            if (extension.endsWith(".jpg") || extension.endsWith(".jpeg")) return "image/jpeg";
            if (extension.endsWith(".png")) return "image/png";
            if (extension.endsWith(".gif")) return "image/gif";
            if (extension.endsWith(".bmp")) return "image/bmp";
            if (extension.endsWith(".webp")) return "image/webp";
            if (extension.endsWith(".svg")) return "image/svg+xml";
            if (extension.endsWith(".mp4")) return "video/mp4";
            if (extension.endsWith(".avi")) return "video/x-msvideo";
            if (extension.endsWith(".mov")) return "video/quicktime";
            if (extension.endsWith(".mp3")) return "audio/mpeg";
            if (extension.endsWith(".wav")) return "audio/wav";
            if (extension.endsWith(".pdf")) return "application/pdf";
            if (extension.endsWith(".txt")) return "text/plain";
        }
        
        return "application/octet-stream";
    }
}
