package com.mms.dto.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

public class UserUpdateRequest {
    
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;
    
    @Email(message = "Email must be valid")
    private String email;
    
    public UserUpdateRequest() {
    }
    
    public UserUpdateRequest(String password, String email) {
        this.password = password;
        this.email = email;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
}
