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

    @Column(nullable = false)
    private String type;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String bucket;

    @Column(nullable = false)
    private OffsetDateTime updated;

    @Column(nullable = false)
    private String username;

    public Storage() {
    }

    public Storage(String type, String name, String bucket, String username) {
        this.type = type;
        this.name = name;
        this.bucket = bucket;
        this.username = username;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getBucket() {
        return bucket;
    }

    public void setBucket(String bucket) {
        this.bucket = bucket;
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

    @PrePersist
    protected void onCreate() {
        updated = OffsetDateTime.now();
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
               Objects.equals(name, storage.name) &&
               Objects.equals(type, storage.type) &&
               Objects.equals(username, storage.username);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, type, name, username);
    }

    @Override
    public String toString() {
        return "Storage{" +
                "id=" + id +
                ", type='" + type + '\'' +
                ", name='" + name + '\'' +
                ", bucket='" + bucket + '\'' +
                ", updated=" + updated + '\'' +
                ", username='" + username + '\'' +
                '}';
    }
}
