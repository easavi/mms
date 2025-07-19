package com.mms.dto.auth;

public class AuthResponse {
    private String token;
    private String type = "Bearer";
    private String username;

    public AuthResponse() {
    }

    public AuthResponse(String token, String type, String username) {
        this.token = token;
        this.type = type;
        this.username = username;
    }

    public AuthResponse(String token, String username) {
        this.token = token;
        this.username = username;
        this.type = "Bearer";
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        AuthResponse that = (AuthResponse) o;

        if (!token.equals(that.token)) return false;
        if (!type.equals(that.type)) return false;
        return username.equals(that.username);
    }

    @Override
    public int hashCode() {
        int result = token.hashCode();
        result = 31 * result + type.hashCode();
        result = 31 * result + username.hashCode();
        return result;
    }

    @Override
    public String toString() {
        return "AuthResponse{" +
                "token='" + token + '\'' +
                ", type='" + type + '\'' +
                ", username='" + username + '\'' +
                '}';
    }
}
