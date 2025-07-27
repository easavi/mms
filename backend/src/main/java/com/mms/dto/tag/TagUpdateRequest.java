package com.mms.dto.tag;

public class TagUpdateRequest {
    
    private String name;
    
    public TagUpdateRequest() {
    }
    
    public TagUpdateRequest(String name) {
        this.name = name;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
}
