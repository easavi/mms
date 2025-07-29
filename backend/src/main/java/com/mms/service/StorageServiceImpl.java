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
    public StorageResponse createStorage(StorageCreateRequest request) {
        // Check if storage with same name exists for user
        if (storageRepository.findByUsernameAndName(request.getUsername(), request.getName()).isPresent()) {
            throw new ApiException(HttpStatus.CONFLICT, "Storage with this name already exists for user");
        }
        
        Storage storage = new Storage();
        storage.setType(request.getType());
        storage.setName(request.getName());
        storage.setBucket(request.getBucket());
        storage.setUsername(request.getUsername());
        
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
        
        if (request.getName() != null) {
            storage.setName(request.getName());
        }
        if (request.getBucket() != null) {
            storage.setBucket(request.getBucket());
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
    
    private StorageResponse convertToResponse(Storage storage) {
        StorageResponse response = new StorageResponse();
        response.setId(storage.getId().toString());
        response.setType(storage.getType());
        response.setName(storage.getName());
        response.setBucket(storage.getBucket());
        response.setUpdated(storage.getUpdated().format(DateTimeFormatter.ISO_OFFSET_DATE_TIME));
        response.setUsername(storage.getUsername());
        return response;
    }
}
