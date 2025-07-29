package com.mms.dto.storage;

public class StorageUpdateRequest {
    
    private String name;
    private String bucket;
    
    public StorageUpdateRequest() {
    }
    
    public StorageUpdateRequest(String name, String bucket) {
        this.name = name;
        this.bucket = bucket;
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
}
