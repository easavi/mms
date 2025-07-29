package com.mms.dto.storage;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class StorageCreateRequest {
    
    @NotNull(message = "Type is required")
    private String type;
    
    @NotBlank(message = "Name is required")
    private String name;
    
    @NotBlank(message = "Bucket is required")
    private String bucket;
    
    @NotBlank(message = "Username is required")
    private String username;
    
    public StorageCreateRequest() {
    }
    
    public StorageCreateRequest(String type, String name, String bucket, String username) {
        this.type = type;
        this.name = name;
        this.bucket = bucket;
        this.username = username;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getBucket() {
        return bucket;
    }
    
    public void setBucket(String bucket) {
        this.bucket = bucket;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
}
