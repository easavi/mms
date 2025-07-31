package com.mms.service;

import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;

public interface StorageService {
    String store(String bucket, MultipartFile file, String path);
    InputStream retrieve(String bucket, String path);
    void delete(String bucket, String path);
    String getUrl(String bucket, String path);
}
