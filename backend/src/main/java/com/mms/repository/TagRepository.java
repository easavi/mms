package com.mms.repository;

import com.mms.entity.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TagRepository extends JpaRepository<Tag, UUID> {
    Optional<Tag> findByName(String name);
    Optional<Tag> findByNameIgnoreCase(String name);
    List<Tag> findByNameContainingIgnoreCase(String name);
    boolean existsByName(String name);
    
    @Query("SELECT t FROM Tag t ORDER BY t.name ASC")
    List<Tag> findAllOrderByName();
    
    @Query("SELECT t.name FROM Tag t ORDER BY t.name ASC")
    List<String> findAllTagNames();
}
