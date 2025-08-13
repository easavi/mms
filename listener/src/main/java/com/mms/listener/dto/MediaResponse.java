package com.mms.listener.dto;

public class MediaResponse {
    private String id;          // Changed to String to match backend
    private String name;        // Changed from title to name to match backend
    private String description;
    private String mediaType;
    private String fileName;
    private String fileUrl;     // Added fileUrl field from backend
    private String mimeType;
    private Long fileSize;
    private String createdAt;   // Changed from LocalDateTime to String
    private String uploadedAt;  // Changed from updatedAt to uploadedAt to match backend
    private String username;
    private String[] tags;      // Changed from List<TagResponse> to String[] to match backend
    
    // Default constructor
    public MediaResponse() {}
    
    // Getters and setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    // Compatibility getter for title (maps to name)
    public String getTitle() { return name; }
    public void setTitle(String title) { this.name = title; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getMediaType() { return mediaType; }
    public void setMediaType(String mediaType) { this.mediaType = mediaType; }
    
    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    
    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }
    
    public String getMimeType() { return mimeType; }
    public void setMimeType(String mimeType) { this.mimeType = mimeType; }
    
    public Long getFileSize() { return fileSize; }
    public void setFileSize(Long fileSize) { this.fileSize = fileSize; }
    
    // Parse bucket from fileUrl
    public String getBucket() { 
        if (fileUrl != null && fileUrl.contains("bucket=")) {
            int bucketIndex = fileUrl.indexOf("bucket=") + 7;
            int endIndex = fileUrl.indexOf("&", bucketIndex);
            if (endIndex == -1) endIndex = fileUrl.length();
            return fileUrl.substring(bucketIndex, endIndex);
        }
        return null;
    }
    
    public void setBucket(String bucket) { 
        // This is a no-op since bucket is derived from fileUrl
    }
    
    // Parse fileId from fileUrl
    public String getFileId() { 
        if (fileUrl != null && fileUrl.contains("fileId=")) {
            int fileIdIndex = fileUrl.indexOf("fileId=") + 7;
            int endIndex = fileUrl.indexOf("&", fileIdIndex);
            if (endIndex == -1) endIndex = fileUrl.length();
            return fileUrl.substring(fileIdIndex, endIndex);
        }
        return null;
    }
    
    public void setFileId(String fileId) { 
        // This is a no-op since fileId is derived from fileUrl
    }
    
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    
    public String getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(String uploadedAt) { this.uploadedAt = uploadedAt; }
    
    // Compatibility getter for updatedAt (maps to uploadedAt)
    public String getUpdatedAt() { return uploadedAt; }
    public void setUpdatedAt(String updatedAt) { this.uploadedAt = updatedAt; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String[] getTags() { return tags; }
    public void setTags(String[] tags) { this.tags = tags; }
}
