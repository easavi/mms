package com.mms.service;

import java.io.InputStream;
import java.util.concurrent.TimeUnit;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import io.minio.BucketExistsArgs;
import io.minio.GetObjectArgs;
import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.RemoveObjectArgs;
import io.minio.http.Method;

@Service
@ConditionalOnProperty(name = "storage.type", havingValue = "minio")
public class MinioStorageService implements StorageService {

    private final MinioClient minioClient;

    public MinioStorageService(MinioClient minioClient) {
        this.minioClient = minioClient;        
    }
    
    private void ensureBucketExists(String bucket) {
        try {
            boolean bucketExists = minioClient.bucketExists(BucketExistsArgs.builder()
                    .bucket(bucket)
                    .build());
            
            if (!bucketExists) {
                minioClient.makeBucket(MakeBucketArgs.builder()
                        .bucket(bucket)                        
                        .build());
            }
        } catch (Exception e) {
            throw new RuntimeException("Could not create bucket: " + bucket, e);
        }
    }

    @Override
    public String store(String bucket, MultipartFile file, String path) {
        try {

            ensureBucketExists(bucket);

            minioClient.putObject(PutObjectArgs.builder()
                    .bucket(bucket)
                    .object(path)
                    .stream(file.getInputStream(), file.getSize(), -1)
                    .contentType(file.getContentType())
                    .build());
            return path;
        } catch (Exception e) {
            throw new RuntimeException("Could not store file", e);
        }
    }

    @Override
    public InputStream retrieve(String bucket, String path) {
        try {

            ensureBucketExists(bucket);

            return minioClient.getObject(GetObjectArgs.builder()
                    .bucket(bucket)
                    .object(path)
                    .build());
        } catch (Exception e) {
            throw new RuntimeException("Could not retrieve file", e);
        }
    }

    @Override
    public void delete(String bucket, String path) {
        try {

            ensureBucketExists(bucket);

            minioClient.removeObject(RemoveObjectArgs.builder()
                    .bucket(bucket)
                    .object(path)
                    .build());
        } catch (Exception e) {
            throw new RuntimeException("Could not delete file", e);
        }
    }

    @Override
    public String getUrl(String bucket, String path) {
        try {

            ensureBucketExists(bucket);
            
            return minioClient.getPresignedObjectUrl(GetPresignedObjectUrlArgs.builder()
                    .method(Method.GET)
                    .bucket(bucket)
                    .object(path)
                    .expiry(1, TimeUnit.HOURS)
                    .build());
        } catch (Exception e) {
            throw new RuntimeException("Could not generate URL", e);
        }
    }
}
