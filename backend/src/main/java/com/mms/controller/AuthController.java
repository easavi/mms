package com.mms.controller;

import com.mms.dto.auth.AuthResponse;
import com.mms.dto.auth.LoginRequest;
import com.mms.dto.auth.SignUpRequest;
import com.mms.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/signup")
    public ResponseEntity<AuthResponse> signup(@Valid @RequestBody SignUpRequest request) {
        return ResponseEntity.ok(authService.signup(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        // TODO: Consider implementing rate limiting to prevent brute force attacks
        // TODO: Consider adding CAPTCHA after failed attempts
        // TODO: Consider logging failed login attempts for security monitoring
        
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (Exception ex) {
            // The GlobalExceptionHandler will catch this and return a generic error message
            throw ex;
        }
    }
}
