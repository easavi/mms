package com.mms.controller;

import com.mms.dto.storage.StorageCreateRequest;
import com.mms.dto.storage.StorageResponse;
import com.mms.dto.storage.StorageUpdateRequest;
import com.mms.entity.StorageType;
import com.mms.service.StorageServiceImpl;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/storage")
public class StorageController {
    
    private final StorageServiceImpl storageService;
    
    public StorageController(StorageServiceImpl storageService) {
        this.storageService = storageService;
    }
    
    @PostMapping
    public ResponseEntity<StorageResponse> createStorage(@Valid @RequestBody StorageCreateRequest request) {
        StorageResponse response = storageService.createStorage(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }
    
    @GetMapping
    public ResponseEntity<List<StorageResponse>> getAllStorages() {
        List<StorageResponse> storages = storageService.getAllStorages();
        return ResponseEntity.ok(storages);
    }
    
    @GetMapping("/user/{username}")
    public ResponseEntity<List<StorageResponse>> getStoragesByUsername(@PathVariable String username) {
        List<StorageResponse> storages = storageService.getStoragesByUsername(username);
        return ResponseEntity.ok(storages);
    }
    
    @GetMapping("/type/{type}")
    public ResponseEntity<List<StorageResponse>> getStoragesByType(@PathVariable StorageType type) {
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
        Long totalSize = storageService.getTotalSizeByUsername(username);
        return ResponseEntity.ok(totalSize != null ? totalSize : 0L);
    }
    
    @GetMapping("/user/{username}/total-items")
    public ResponseEntity<Long> getTotalItemsQuantityByUsername(@PathVariable String username) {
        Long totalItems = storageService.getTotalItemsQuantityByUsername(username);
        return ResponseEntity.ok(totalItems != null ? totalItems : 0L);
    }
}
