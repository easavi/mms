package com.mms.controller;

import com.mms.dto.tag.TagCreateRequest;
import com.mms.dto.tag.TagResponse;
import com.mms.dto.tag.TagUpdateRequest;
import com.mms.service.TagService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/tags")
public class TagController {
    
    private final TagService tagService;
    
    public TagController(TagService tagService) {
        this.tagService = tagService;
    }
    
    @PostMapping
    public ResponseEntity<TagResponse> createTag(@Valid @RequestBody TagCreateRequest request) {
        TagResponse response = tagService.createTag(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }
    
    @GetMapping
    public ResponseEntity<List<TagResponse>> getAllTags() {
        List<TagResponse> tags = tagService.getAllTags();
        return ResponseEntity.ok(tags);
    }
    
    @GetMapping("/names")
    public ResponseEntity<List<String>> getAllTagNames() {
        List<String> tagNames = tagService.getAllTagNames();
        return ResponseEntity.ok(tagNames);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<TagResponse> getTagById(@PathVariable UUID id) {
        TagResponse tag = tagService.getTagById(id);
        return ResponseEntity.ok(tag);
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<TagResponse>> searchTags(@RequestParam String name) {
        List<TagResponse> tags = tagService.searchTags(name);
        return ResponseEntity.ok(tags);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<TagResponse> updateTag(
            @PathVariable UUID id,
            @Valid @RequestBody TagUpdateRequest request) {
        TagResponse response = tagService.updateTag(id, request);
        return ResponseEntity.ok(response);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTag(@PathVariable UUID id) {
        tagService.deleteTag(id);
        return ResponseEntity.noContent().build();
    }
}
