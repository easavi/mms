package com.mms.entity;

import jakarta.persistence.*;

import java.time.OffsetDateTime;
import java.util.Objects;
import java.util.UUID;

@Entity
@Table(name = "storage")
public class Storage {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 8)
    private String bucket; // First 8 digits of UUID, auto-generated

    @Column(nullable = false, length = 1024)
    private String path; // Path to local folder on device

    @Column(nullable = false, columnDefinition = "VARCHAR(255) DEFAULT 'server'")
    private String type = "server"; // Only "server" option, default value

    @Column(nullable = false)
    private OffsetDateTime updated;

    @Column(nullable = false)
    private String username;
    
    @Column(name = "device_id", nullable = false)
    private String deviceId;

    public Storage() {
    }

    public Storage(String path, String username, String deviceId) {
        this.path = path;
        this.username = username;
        this.deviceId = deviceId;
        this.type = "server"; // Default value
        // Bucket will be auto-generated in @PrePersist
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getBucket() {
        return bucket;
    }

    public void setBucket(String bucket) {
        this.bucket = bucket;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public OffsetDateTime getUpdated() {
        return updated;
    }

    public void setUpdated(OffsetDateTime updated) {
        this.updated = updated;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    @PrePersist
    protected void onCreate() {
        updated = OffsetDateTime.now();
        // Auto-generate bucket as first 8 digits of UUID if not set
        if (bucket == null || bucket.isEmpty()) {
            bucket = UUID.randomUUID().toString().replace("-", "").substring(0, 8);
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updated = OffsetDateTime.now();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Storage storage = (Storage) o;
        return Objects.equals(id, storage.id) &&
               Objects.equals(bucket, storage.bucket) &&
               Objects.equals(path, storage.path) &&
               Objects.equals(type, storage.type) &&
               Objects.equals(username, storage.username) &&
               Objects.equals(deviceId, storage.deviceId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, bucket, path, type, username, deviceId);
    }

    @Override
    public String toString() {
        return "Storage{" +
                "id=" + id +
                ", bucket='" + bucket + '\'' +
                ", path='" + path + '\'' +
                ", type='" + type + '\'' +
                ", updated=" + updated + '\'' +
                ", username='" + username + '\'' +
                ", deviceId='" + deviceId + '\'' +
                '}';
    }
}
