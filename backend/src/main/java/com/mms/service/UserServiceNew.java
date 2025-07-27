package com.mms.service;

import com.mms.dto.user.UserCreateRequest;
import com.mms.dto.user.UserResponse;
import com.mms.dto.user.UserUpdateRequest;
import com.mms.entity.User;
import com.mms.exception.ApiException;
import com.mms.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserServiceNew {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    public UserServiceNew(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }
    
    @Transactional
    public UserResponse createUser(UserCreateRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new ApiException(HttpStatus.CONFLICT, "Username already exists");
        }
        
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ApiException(HttpStatus.CONFLICT, "Email already exists");
        }
        
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setEmail(request.getEmail());
        
        user = userRepository.save(user);
        return convertToResponse(user);
    }
    
    @Transactional(readOnly = true)
    public List<UserResponse> getAllUsers() {
        return userRepository.findAll()
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public UserResponse getUserByUsername(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found"));
        return convertToResponse(user);
    }
    
    @Transactional(readOnly = true)
    public UserResponse getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found"));
        return convertToResponse(user);
    }
    
    @Transactional
    public UserResponse updateUser(String username, UserUpdateRequest request) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found"));
        
        if (request.getEmail() != null) {
            if (userRepository.existsByEmail(request.getEmail()) && 
                !user.getEmail().equals(request.getEmail())) {
                throw new ApiException(HttpStatus.CONFLICT, "Email already exists");
            }
            user.setEmail(request.getEmail());
        }
        
        if (request.getPassword() != null) {
            user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        }
        
        user = userRepository.save(user);
        return convertToResponse(user);
    }
    
    @Transactional
    public void deleteUser(String username) {
        if (!userRepository.existsByUsername(username)) {
            throw new ApiException(HttpStatus.NOT_FOUND, "User not found");
        }
        userRepository.deleteById(username);
    }
    
    @Transactional(readOnly = true)
    public boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }
    
    @Transactional(readOnly = true)
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }
    
    private UserResponse convertToResponse(User user) {
        UserResponse response = new UserResponse();
        response.setUsername(user.getUsername());
        response.setEmail(user.getEmail());
        return response;
    }
}
