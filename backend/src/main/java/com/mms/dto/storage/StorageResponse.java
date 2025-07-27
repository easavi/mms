package com.mms.dto.storage;

import com.mms.entity.StorageType;

public class StorageResponse {
    
    private String id;
    private StorageType type;
    private String name;
    private String bucket;
    private String updated;
    private Long size;
    private Integer itemsQuantity;
    private String username;
    
    public StorageResponse() {
    }
    
    public StorageResponse(String id, StorageType type, String name, String bucket, 
                          String updated, Long size, Integer itemsQuantity, String username) {
        this.id = id;
        this.type = type;
        this.name = name;
        this.bucket = bucket;
        this.updated = updated;
        this.size = size;
        this.itemsQuantity = itemsQuantity;
        this.username = username;
    }
    
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
    }
    
    public StorageType getType() {
        return type;
    }
    
    public void setType(StorageType type) {
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
    
    public Long getSize() {
        return size;
    }
    
    public void setSize(Long size) {
        this.size = size;
    }
    
    public Integer getItemsQuantity() {
        return itemsQuantity;
    }
    
    public void setItemsQuantity(Integer itemsQuantity) {
        this.itemsQuantity = itemsQuantity;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
}
