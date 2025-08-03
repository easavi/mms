package com.mms.controller;

import com.mms.dto.media.MediaCreateRequest;
import com.mms.dto.media.MediaResponse;
import com.mms.dto.media.MediaUpdateRequest;
import com.mms.dto.media.MediaUploadRequest;
import com.mms.service.MediaService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.OffsetDateTime;
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
            @RequestParam(defaultValue = "month") String group,
            @RequestParam(defaultValue = "desc") String sortDirection,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) String start,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) String end,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) List<String> tags,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        // Convert string dates to OffsetDateTime if provided
        OffsetDateTime startDate = null;
        OffsetDateTime endDate = null;
        
        if (start != null && !start.isEmpty()) {
            startDate = OffsetDateTime.parse(start + "T00:00:00Z");
        }
        if (end != null && !end.isEmpty()) {
            endDate = OffsetDateTime.parse(end + "T23:59:59Z");
        }
        
        Pageable pageable = PageRequest.of(page, size);
        Page<MediaResponse> media = mediaService.getMediaWithFilters(
                startDate, endDate, tags, type, sortDirection, pageable);
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
}
