package com.mms.controller;

import com.mms.dto.user.UserCreateRequest;
import com.mms.dto.user.UserResponse;
import com.mms.dto.user.UserUpdateRequest;
import com.mms.service.UserServiceNew;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    private final UserServiceNew userService;
    
    public UserController(UserServiceNew userService) {
        this.userService = userService;
    }
    
    @PostMapping
    public ResponseEntity<UserResponse> createUser(@Valid @RequestBody UserCreateRequest request) {
        UserResponse response = userService.createUser(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }
    
    @GetMapping
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        List<UserResponse> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }
    
    @GetMapping("/{username}")
    public ResponseEntity<UserResponse> getUserByUsername(@PathVariable String username) {
        UserResponse user = userService.getUserByUsername(username);
        return ResponseEntity.ok(user);
    }
    
    @GetMapping("/by-email")
    public ResponseEntity<UserResponse> getUserByEmail(@RequestParam String email) {
        UserResponse user = userService.getUserByEmail(email);
        return ResponseEntity.ok(user);
    }
    
    @PutMapping("/{username}")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable String username,
            @Valid @RequestBody UserUpdateRequest request) {
        UserResponse response = userService.updateUser(username, request);
        return ResponseEntity.ok(response);
    }
    
    @DeleteMapping("/{username}")
    public ResponseEntity<Void> deleteUser(@PathVariable String username) {
        userService.deleteUser(username);
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/{username}/exists")
    public ResponseEntity<Boolean> checkUsernameExists(@PathVariable String username) {
        boolean exists = userService.existsByUsername(username);
        return ResponseEntity.ok(exists);
    }
    
    @GetMapping("/email-exists")
    public ResponseEntity<Boolean> checkEmailExists(@RequestParam String email) {
        boolean exists = userService.existsByEmail(email);
        return ResponseEntity.ok(exists);
    }
}
