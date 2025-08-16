-- Database schema for Multimedia Sharing Service

-- Storage types enum
CREATE TYPE storage_type AS ENUM ('AWS', 'Minio');

-- Media types enum
CREATE TYPE media_type AS ENUM ('image', 'video', 'file');

-- Users table
CREATE TABLE users (
    username VARCHAR(50) PRIMARY KEY,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

-- Storage table
CREATE TABLE storage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bucket VARCHAR(8) NOT NULL UNIQUE, -- First 8 digits of UUID, auto-generated
    path VARCHAR(1024) NOT NULL,       -- Path to local folder on device
    type VARCHAR(255) NOT NULL DEFAULT 'server', -- Always 'server'
    updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    username VARCHAR(50) NOT NULL REFERENCES users(username),
    device_id VARCHAR(255) NOT NULL,   -- Device identifier
    UNIQUE(username, device_id, path) -- Prevent duplicate paths per user per device
);

-- Media table
CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    media_type VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(1024) NOT NULL,
    file_size BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    storage_id VARCHAR(255)
);

-- Tags table
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) UNIQUE NOT NULL
);

-- Media tags relation table
CREATE TABLE media_tags (
    media_id UUID REFERENCES media(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (media_id, tag_id)
);

-- Create indexes for better performance
CREATE INDEX idx_storage_username ON storage(username);
CREATE INDEX idx_storage_device_id ON storage(device_id);
CREATE INDEX idx_storage_type ON storage(type);
CREATE INDEX idx_media_storage_id ON media(storage_id);
CREATE INDEX idx_media_created_at ON media(created_at);
CREATE INDEX idx_media_uploaded_at ON media(uploaded_at);
CREATE INDEX idx_media_media_type ON media(media_type);
CREATE INDEX idx_media_tags_tag_id ON media_tags(tag_id);
CREATE INDEX idx_media_tags_media_id ON media_tags(media_id);
CREATE INDEX idx_tags_name ON tags(name);

-- Create updated_at trigger function for storage table
CREATE OR REPLACE FUNCTION update_storage_updated_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add trigger for storage updated field
CREATE TRIGGER update_storage_updated
    BEFORE UPDATE ON storage
    FOR EACH ROW
    EXECUTE FUNCTION update_storage_updated_column();
