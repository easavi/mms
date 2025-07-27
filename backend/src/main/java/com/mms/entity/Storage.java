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

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StorageType type;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String bucket;

    @Column(nullable = false)
    private OffsetDateTime updated;

    @Column(nullable = false)
    private Long size = 0L;

    @Column(name = "items_quantity", nullable = false)
    private Integer itemsQuantity = 0;

    @Column(nullable = false)
    private String username;

    public Storage() {
    }

    public Storage(StorageType type, String name, String bucket, String username) {
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

    public StorageType getType() {
        return type;
    }

    public void setType(StorageType type) {
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

    public Long getSize() {
        return size;
    }

    public void setSize(Long size) {
        this.size = size;
    }

    public Integer getItemsQuantity() {
        return itemsQuantity;
    }

    public void setItemsQuantity(Integer itemsQuantity) {
        this.itemsQuantity = itemsQuantity;
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
               type == storage.type &&
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
                ", type=" + type +
                ", name='" + name + '\'' +
                ", bucket='" + bucket + '\'' +
                ", updated=" + updated +
                ", size=" + size +
                ", itemsQuantity=" + itemsQuantity +
                ", username='" + username + '\'' +
                '}';
    }
}
