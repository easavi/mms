package com.mms.dto.auth;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String token;
    private String type = "Bearer";
    private String username;

    public AuthResponse(String token, String username) {
        this.token = token;
        this.username = username;
        this.type = "Bearer";
    }
}
