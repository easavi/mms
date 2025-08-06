package com.mms.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mms.dto.storage.StorageCreateRequest;
import com.mms.dto.storage.StorageResponse;
import com.mms.dto.storage.StorageUpdateRequest;
import com.mms.service.StorageServiceImpl;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/storage")
public class StorageController {
    
    private final StorageServiceImpl storageService;
    
    public StorageController(StorageServiceImpl storageService) {
        this.storageService = storageService;
    }
    
    @PostMapping
    public ResponseEntity<StorageResponse> createStorage(@Valid @RequestBody StorageCreateRequest request, 
                                                       Authentication authentication) {
        String username = authentication.getName(); // Extract username from JWT token
        StorageResponse response = storageService.createStorage(request, username);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }
    
    @GetMapping
    public ResponseEntity<List<StorageResponse>> getAllStorages(Authentication authentication) {
        String username = authentication.getName(); // Filter by authenticated user
        List<StorageResponse> storages = storageService.getStoragesByUsername(username);
        return ResponseEntity.ok(storages);
    }
    
    @GetMapping("/user/{username}")
    public ResponseEntity<List<StorageResponse>> getStoragesByUsername(@PathVariable String username) {
        List<StorageResponse> storages = storageService.getStoragesByUsername(username);
        return ResponseEntity.ok(storages);
    }
    
    @GetMapping("/type/{type}")
    public ResponseEntity<List<StorageResponse>> getStoragesByType(@PathVariable String type) {
        List<StorageResponse> storages = storageService.getStoragesByType(type);
        return ResponseEntity.ok(storages);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<StorageResponse> getStorageById(@PathVariable UUID id) {
        StorageResponse storage = storageService.getStorageById(id);
        return ResponseEntity.ok(storage);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<StorageResponse> updateStorage(
            @PathVariable UUID id,
            @Valid @RequestBody StorageUpdateRequest request) {
        StorageResponse response = storageService.updateStorage(id, request);
        return ResponseEntity.ok(response);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteStorage(@PathVariable UUID id) {
        storageService.deleteStorage(id);
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/user/{username}/total-size")
    public ResponseEntity<Long> getTotalSizeByUsername(@PathVariable String username) {
        Long totalSize = 0L;//storageService.getTotalSizeByUsername(username);
        return ResponseEntity.ok(totalSize != null ? totalSize : 0L);
    }
    
    @GetMapping("/user/{username}/total-items")
    public ResponseEntity<Long> getTotalItemsQuantityByUsername(@PathVariable String username) {
        Long totalItems = 0L;//storageService.getTotalItemsQuantityByUsername(username);
        return ResponseEntity.ok(totalItems != null ? totalItems : 0L);
    }
    
    @GetMapping("/{bucket}/quantity")
    public ResponseEntity<Integer> getStorageQuantity(@PathVariable String bucket) {
        Integer quantity = storageService.getStorageQuantity(bucket);
        return ResponseEntity.ok(quantity);
    }
    
    @GetMapping("/{bucket}/size")
    public ResponseEntity<Long> getStorageSize(@PathVariable String bucket) {
        Long size = storageService.getStorageSize(bucket);
        return ResponseEntity.ok(size);
    }
}
