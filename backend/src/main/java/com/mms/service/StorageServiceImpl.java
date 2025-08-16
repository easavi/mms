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
import com.mms.repository.MediaRepository;

@Service
public class StorageServiceImpl {
    
    private final StorageRepository storageRepository;
    private final MediaRepository mediaRepository;
    
    public StorageServiceImpl(StorageRepository storageRepository, MediaRepository mediaRepository) {
        this.storageRepository = storageRepository;
        this.mediaRepository = mediaRepository;
    }
    
    @Transactional
    public StorageResponse createStorage(StorageCreateRequest request, String username) {
        // Check if storage with same path exists for user on this device
        if (storageRepository.findByUsernameAndDeviceIdAndPath(username, request.getDeviceId(), request.getPath()).isPresent()) {
            throw new ApiException(HttpStatus.CONFLICT, "Storage with this path already exists for user on this device");
        }
        
        Storage storage = new Storage();
        storage.setPath(request.getPath());
        storage.setUsername(username);
        storage.setDeviceId(request.getDeviceId());
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
    public List<StorageResponse> getStoragesByUsernameAndDeviceId(String username, String deviceId) {
        return storageRepository.findByUsernameAndDeviceIdOrderByUpdatedDesc(username, deviceId)
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
        // Find storage by bucket to get the storage ID
        Storage storage = storageRepository.findByBucket(bucket)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Storage not found"));
        
        // Count media files associated with this storage
        return mediaRepository.countByStorageId(storage.getId().toString());
    }
    
    @Transactional(readOnly = true)
    public Long getStorageSize(String bucket) {
        // Find storage by bucket to get the storage ID  
        Storage storage = storageRepository.findByBucket(bucket)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Storage not found"));
        
        // Sum file sizes for media files associated with this storage
        Long totalSize = mediaRepository.sumFileSizesByStorageId(storage.getId().toString());
        return totalSize != null ? totalSize : 0L;
    }    
    
    private StorageResponse convertToResponse(Storage storage) {
        StorageResponse response = new StorageResponse();
        response.setId(storage.getId().toString());
        response.setBucket(storage.getBucket());
        response.setPath(storage.getPath());
        response.setType(storage.getType());
        response.setUpdated(storage.getUpdated().format(DateTimeFormatter.ISO_OFFSET_DATE_TIME));
        response.setUsername(storage.getUsername());
        response.setDeviceId(storage.getDeviceId());
        
        // Calculate actual size and items quantity from media files
        Integer quantity = mediaRepository.countByStorageId(storage.getId().toString());
        Long size = mediaRepository.sumFileSizesByStorageId(storage.getId().toString());
        
        response.setSize(size != null ? size : 0L);
        response.setItemsQuantity(quantity != null ? quantity : 0);
        
        return response;
    }
}
