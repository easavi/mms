package com.mms.dto.media;

import com.mms.entity.MediaType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.OffsetDateTime;

public class MediaCreateRequest {
    
    @NotBlank(message = "Name is required")
    private String name;
    
    @NotNull(message = "Media type is required")
    private MediaType mediaType;
    
    @NotBlank(message = "File name is required")
    private String fileName;
    
    @NotBlank(message = "File URL is required")
    private String fileUrl;
    
    @NotNull(message = "Created at is required")
    private OffsetDateTime createdAt;
    
    private String[] tagNames;
    
    public MediaCreateRequest() {
    }
    
    public MediaCreateRequest(String name, MediaType mediaType, String fileName, 
                             String fileUrl, OffsetDateTime createdAt, String[] tagNames) {
        this.name = name;
        this.mediaType = mediaType;
        this.fileName = fileName;
        this.fileUrl = fileUrl;
        this.createdAt = createdAt;
        this.tagNames = tagNames;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public MediaType getMediaType() {
        return mediaType;
    }
    
    public void setMediaType(MediaType mediaType) {
        this.mediaType = mediaType;
    }
    
    public String getFileName() {
        return fileName;
    }
    
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }
    
    public String getFileUrl() {
        return fileUrl;
    }
    
    public void setFileUrl(String fileUrl) {
        this.fileUrl = fileUrl;
    }
    
    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public String[] getTagNames() {
        return tagNames != null ? tagNames.clone() : null;
    }
    
    public void setTagNames(String[] tagNames) {
        this.tagNames = tagNames != null ? tagNames.clone() : null;
    }
}
