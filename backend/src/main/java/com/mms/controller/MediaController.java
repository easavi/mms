package com.mms.controller;

import com.mms.dto.media.MediaCreateRequest;
import com.mms.dto.media.MediaFilterRequest;
import com.mms.dto.media.MediaResponse;
import com.mms.dto.media.MediaUpdateRequest;
import com.mms.dto.media.MediaUploadRequest;
import com.mms.dto.media.GroupedMediaResponse;
import com.mms.service.MediaService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.OffsetDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/media")
public class MediaController {
    
    private final MediaService mediaService;
    
    public MediaController(MediaService mediaService) {
        this.mediaService = mediaService;
    }
    
    @PostMapping
    public ResponseEntity<MediaResponse> createMedia(@Valid @RequestBody MediaCreateRequest request) {
        MediaResponse response = mediaService.createMedia(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }
    
    @PostMapping("/upload")
    public ResponseEntity<MediaResponse> uploadMedia(
            @RequestParam(value = "file", required = true) MultipartFile file,
            @RequestParam(value = "title", required = true) String title,
            @RequestParam(value = "description", required = false) String description,
            @RequestParam(value = "mediaType", required = true) String mediaType,
            @RequestParam(value = "tags", required = false) String[] tags) {
        
        // Validate file
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("File is required and cannot be empty");
        }
        
        // Create MediaUploadRequest object using setters instead of constructor
        MediaUploadRequest request = new MediaUploadRequest();
        request.setTitle(title);
        request.setDescription(description);
        request.setMediaType(mediaType);
        request.setFile(file);
        request.setTags(tags);        
        
        MediaResponse response = mediaService.uploadMedia(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }
    
    @PostMapping("/test-upload")
    public ResponseEntity<Map<String, String>> testUpload(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "title", required = false) String title) {
        
        Map<String, String> response = new java.util.HashMap<>();
        response.put("fileName", file != null ? file.getOriginalFilename() : "NULL");
        response.put("fileSize", file != null ? String.valueOf(file.getSize()) : "0");
        response.put("title", title);
        response.put("contentType", file != null ? file.getContentType() : "NULL");
        response.put("status", "File received successfully");
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping
    public ResponseEntity<Page<MediaResponse>> getMedia(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) OffsetDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) OffsetDateTime endDate,
            @RequestParam(required = false) List<String> tags,
            @RequestParam(defaultValue = "desc") String sort,
            @PageableDefault(size = 20) Pageable pageable) {
        
        Page<MediaResponse> media = mediaService.getMediaWithFilters(
                startDate, endDate, tags, sort, pageable);
        return ResponseEntity.ok(media);
    }
    
    @GetMapping("/all")
    public ResponseEntity<List<MediaResponse>> getAllMedia() {
        List<MediaResponse> media = mediaService.getAllMedia();
        return ResponseEntity.ok(media);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<MediaResponse> getMediaById(@PathVariable UUID id) {
        MediaResponse media = mediaService.getMediaById(id);
        return ResponseEntity.ok(media);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<MediaResponse> updateMedia(
            @PathVariable UUID id,
            @Valid @RequestBody MediaUpdateRequest request) {
        MediaResponse response = mediaService.updateMedia(id, request);
        return ResponseEntity.ok(response);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMedia(@PathVariable UUID id) {
        mediaService.deleteMedia(id);
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/search")
    public ResponseEntity<Page<MediaResponse>> searchMedia(
            @RequestParam String query,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<MediaResponse> media = mediaService.searchMedia(query, pageable);
        return ResponseEntity.ok(media);
    }
    
    // Grouping endpoints as per requirements
    @GetMapping("/grouped/month")
    public ResponseEntity<List<Map<String, Object>>> getMediaGroupedByMonth() {
        List<Map<String, Object>> groupedData = mediaService.getMediaGroupedByMonth();
        return ResponseEntity.ok(groupedData);
    }
    
    @GetMapping("/grouped/day")
    public ResponseEntity<List<Map<String, Object>>> getMediaGroupedByDay() {
        List<Map<String, Object>> groupedData = mediaService.getMediaGroupedByDay();
        return ResponseEntity.ok(groupedData);
    }
    
    @GetMapping("/grouped/tag")
    public ResponseEntity<List<Map<String, Object>>> getMediaGroupedByTag() {
        List<Map<String, Object>> groupedData = mediaService.getMediaGroupedByTag();
        return ResponseEntity.ok(groupedData);
    }
    
    // Advanced filtering endpoint that combines all options
    @GetMapping("/filter")
    public ResponseEntity<Page<MediaResponse>> getFilteredMedia(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) OffsetDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) OffsetDateTime endDate,
            @RequestParam(required = false) List<String> tagNames,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDirection,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<MediaResponse> media = mediaService.getMediaWithFilters(
                startDate, endDate, tagNames, sortBy, sortDirection, pageable);
        return ResponseEntity.ok(media);
    }
    
    // Enhanced grouping endpoints with better response structure
    @GetMapping("/grouped/enhanced/month")
    public ResponseEntity<List<GroupedMediaResponse>> getEnhancedMediaGroupedByMonth() {
        List<GroupedMediaResponse> groupedData = mediaService.getGroupedMediaByDatePeriod("month");
        return ResponseEntity.ok(groupedData);
    }
    
    @GetMapping("/grouped/enhanced/day")
    public ResponseEntity<List<GroupedMediaResponse>> getEnhancedMediaGroupedByDay() {
        List<GroupedMediaResponse> groupedData = mediaService.getGroupedMediaByDatePeriod("day");
        return ResponseEntity.ok(groupedData);
    }
    
    @GetMapping("/grouped/enhanced/tag")
    public ResponseEntity<List<GroupedMediaResponse>> getEnhancedMediaGroupedByTag() {
        List<GroupedMediaResponse> groupedData = mediaService.getGroupedMediaByTags();
        return ResponseEntity.ok(groupedData);
    }
    
    // Advanced filter endpoint with request body
    @PostMapping("/filter")
    public ResponseEntity<Page<MediaResponse>> getFilteredMediaAdvanced(
            @Valid @RequestBody MediaFilterRequest filterRequest,
            @PageableDefault(size = 20) Pageable pageable) {
        
        Page<MediaResponse> media = mediaService.getMediaWithAdvancedFilter(filterRequest, pageable);
        return ResponseEntity.ok(media);
    }
    
    // Statistics endpoint
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getMediaStatistics() {
        Map<String, Object> statistics = mediaService.getMediaStatistics();
        return ResponseEntity.ok(statistics);
    }
    
    // Validate filtering parameters endpoint
    @GetMapping("/validate-filter")
    public ResponseEntity<Map<String, Object>> validateFilterParameters(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) OffsetDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) OffsetDateTime endDate,
            @RequestParam(required = false) List<String> tagNames) {
        
        Map<String, Object> validation = new java.util.HashMap<>();
        validation.put("hasDateFilter", startDate != null && endDate != null);
        validation.put("hasTagFilter", tagNames != null && !tagNames.isEmpty());
        validation.put("dateRangeValid", startDate == null || endDate == null || !startDate.isAfter(endDate));
        validation.put("tagCount", tagNames != null ? tagNames.size() : 0);
        
        return ResponseEntity.ok(validation);
    }
}
