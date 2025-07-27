package com.mms.service;

import com.mms.dto.tag.TagCreateRequest;
import com.mms.dto.tag.TagResponse;
import com.mms.dto.tag.TagUpdateRequest;
import com.mms.entity.Tag;
import com.mms.exception.ApiException;
import com.mms.repository.TagRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class TagService {
    
    private final TagRepository tagRepository;
    
    public TagService(TagRepository tagRepository) {
        this.tagRepository = tagRepository;
    }
    
    @Transactional
    public TagResponse createTag(TagCreateRequest request) {
        if (tagRepository.existsByName(request.getName())) {
            throw new ApiException(HttpStatus.CONFLICT, "Tag with this name already exists");
        }
        
        Tag tag = new Tag(request.getName());
        tag = tagRepository.save(tag);
        return convertToResponse(tag);
    }
    
    @Transactional(readOnly = true)
    public List<TagResponse> getAllTags() {
        return tagRepository.findAllOrderByName()
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<String> getAllTagNames() {
        return tagRepository.findAllTagNames();
    }
    
    @Transactional(readOnly = true)
    public TagResponse getTagById(UUID id) {
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Tag not found"));
        return convertToResponse(tag);
    }
    
    @Transactional(readOnly = true)
    public List<TagResponse> searchTags(String name) {
        return tagRepository.findByNameContainingIgnoreCase(name)
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public TagResponse updateTag(UUID id, TagUpdateRequest request) {
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Tag not found"));
        
        if (request.getName() != null) {
            if (tagRepository.existsByName(request.getName()) && 
                !tag.getName().equals(request.getName())) {
                throw new ApiException(HttpStatus.CONFLICT, "Tag with this name already exists");
            }
            tag.setName(request.getName());
        }
        
        tag = tagRepository.save(tag);
        return convertToResponse(tag);
    }
    
    @Transactional
    public void deleteTag(UUID id) {
        if (!tagRepository.existsById(id)) {
            throw new ApiException(HttpStatus.NOT_FOUND, "Tag not found");
        }
        tagRepository.deleteById(id);
    }
    
    private TagResponse convertToResponse(Tag tag) {
        TagResponse response = new TagResponse();
        response.setId(tag.getId().toString());
        response.setName(tag.getName());
        return response;
    }
}
