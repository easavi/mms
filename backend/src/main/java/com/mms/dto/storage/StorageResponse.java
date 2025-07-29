package com.mms.dto.storage;

public class StorageResponse {
    
    private String id;
    private String type;
    private String name;
    private String bucket;
    private String updated;
    private String username;
    
    public StorageResponse() {
    }
    
    public StorageResponse(String id, String type, String name, String bucket, 
                          String updated, String username) {
        this.id = id;
        this.type = type;
        this.name = name;
        this.bucket = bucket;
        this.updated = updated;
        this.username = username;
    }
    
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
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
    
    public String getUpdated() {
        return updated;
    }
    
    public void setUpdated(String updated) {
        this.updated = updated;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
}
