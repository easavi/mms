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
    type storage_type NOT NULL,
    name VARCHAR(255) NOT NULL,
    bucket VARCHAR(255) NOT NULL,
    updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    size BIGINT NOT NULL DEFAULT 0,
    items_quantity INTEGER NOT NULL DEFAULT 0,
    username VARCHAR(50) NOT NULL REFERENCES users(username)
);

-- Media table
CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    media_type media_type NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(1024) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
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
CREATE INDEX idx_storage_type ON storage(type);
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
