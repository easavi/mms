package com.mms.dto.media;

import com.mms.entity.MediaType;

public class MediaResponseNew {
    
    private String id;
    private String name;
    private MediaType mediaType;
    private String fileName;
    private String fileUrl;
    private String createdAt;
    private String uploadedAt;
    private String[] tags;
    
    public MediaResponseNew() {
    }
    
    public MediaResponseNew(String id, String name, MediaType mediaType, String fileName, 
                           String fileUrl, String createdAt, String uploadedAt, String[] tags) {
        this.id = id;
        this.name = name;
        this.mediaType = mediaType;
        this.fileName = fileName;
        this.fileUrl = fileUrl;
        this.createdAt = createdAt;
        this.uploadedAt = uploadedAt;
        this.tags = tags != null ? tags.clone() : null;
    }
    
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
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
    
    public String getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
    
    public String getUploadedAt() {
        return uploadedAt;
    }
    
    public void setUploadedAt(String uploadedAt) {
        this.uploadedAt = uploadedAt;
    }
    
    public String[] getTags() {
        return tags != null ? tags.clone() : null;
    }
    
    public void setTags(String[] tags) {
        this.tags = tags != null ? tags.clone() : null;
    }
}
