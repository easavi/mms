package com.mms.dto.media;

import java.time.OffsetDateTime;

public class MediaUpdateRequest {
    
    private String name;
    private String mediaType;
    private String fileName;
    private String fileUrl;
    private OffsetDateTime createdAt;
    private String[] tagNames;
    
    public MediaUpdateRequest() {
    }
    
    public MediaUpdateRequest(String name, String mediaType, String fileName, 
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
    
    public String getMediaType() {
        return mediaType;
    }
    
    public void setMediaType(String mediaType) {
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
