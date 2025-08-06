package com.mms.service;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.mms.dto.storage.StorageCreateRequest;
import com.mms.dto.storage.StorageResponse;
import com.mms.dto.storage.StorageUpdateRequest;
import com.mms.entity.Storage;
import com.mms.exception.ApiException;
import com.mms.repository.StorageRepository;

@Service
public class StorageServiceImpl {
    
    private final StorageRepository storageRepository;
    
    public StorageServiceImpl(StorageRepository storageRepository) {
        this.storageRepository = storageRepository;
    }
    
    @Transactional
    public StorageResponse createStorage(StorageCreateRequest request, String username) {
        // Check if storage with same path exists for user
        if (storageRepository.findByUsernameAndPath(username, request.getPath()).isPresent()) {
            throw new ApiException(HttpStatus.CONFLICT, "Storage with this path already exists for user");
        }
        
        Storage storage = new Storage();
        storage.setPath(request.getPath());
        storage.setUsername(username);
        storage.setType("server"); // Always server
        // Bucket will be auto-generated in @PrePersist
        
        storage = storageRepository.save(storage);
        return convertToResponse(storage);
    }
    
    @Transactional(readOnly = true)
    public List<StorageResponse> getAllStorages() {
        return storageRepository.findAll()
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<StorageResponse> getStoragesByUsername(String username) {
        return storageRepository.findByUsernameOrderByUpdatedDesc(username)
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<StorageResponse> getStoragesByType(String type) {
        return storageRepository.findByType(type)
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public StorageResponse getStorageById(UUID id) {
        Storage storage = storageRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Storage not found"));
        return convertToResponse(storage);
    }
    
    @Transactional
    public StorageResponse updateStorage(UUID id, StorageUpdateRequest request) {
        Storage storage = storageRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Storage not found"));
        
        if (request.getPath() != null) {
            storage.setPath(request.getPath());
        }
        
        storage = storageRepository.save(storage);
        return convertToResponse(storage);
    }
    
    @Transactional
    public void deleteStorage(UUID id) {
        if (!storageRepository.existsById(id)) {
            throw new ApiException(HttpStatus.NOT_FOUND, "Storage not found");
        }
        storageRepository.deleteById(id);
    }
    
    @Transactional(readOnly = true)
    public Integer getStorageQuantity(String bucket) {
        // TODO: Implement actual media count for this storage bucket
        // This would typically query the media table for files in this bucket
        return 0;
    }
    
    @Transactional(readOnly = true)
    public Long getStorageSize(String bucket) {
        // TODO: Implement actual size calculation for this storage bucket
        // This would typically sum up file sizes from media table for this bucket
        return 0L;
    }    
    
    private StorageResponse convertToResponse(Storage storage) {
        StorageResponse response = new StorageResponse();
        response.setId(storage.getId().toString());
        response.setBucket(storage.getBucket());
        response.setPath(storage.getPath());
        response.setType(storage.getType());
        response.setUpdated(storage.getUpdated().format(DateTimeFormatter.ISO_OFFSET_DATE_TIME));
        response.setUsername(storage.getUsername());
        
        // TODO: Calculate actual size and items quantity from media files
        response.setSize(0L);
        response.setItemsQuantity(0);
        
        return response;
    }
}
