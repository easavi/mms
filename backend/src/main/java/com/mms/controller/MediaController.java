package com.mms.controller;

import com.mms.dto.media.MediaResponse;
import com.mms.dto.media.MediaUploadRequest;
import com.mms.service.MediaService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/media")
public class MediaController {
    private final MediaService mediaService;

    public MediaController(MediaService mediaService) {
        this.mediaService = mediaService;
    }

    @PostMapping
    public ResponseEntity<MediaResponse> uploadMedia(
            @Valid @ModelAttribute MediaUploadRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(mediaService.uploadMedia(request, userDetails));
    }

    @GetMapping
    public ResponseEntity<Page<MediaResponse>> getAllMedia(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String type,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(mediaService.getAllMedia(search, type, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<MediaResponse> getMediaById(@PathVariable UUID id) {
        return ResponseEntity.ok(mediaService.getMediaById(id));
    }
}
