package com.mms.service;

import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;

public interface StorageService {
    String store(MultipartFile file, String path);
    InputStream retrieve(String path);
    void delete(String path);
    String getUrl(String path);
}
