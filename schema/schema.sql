
-- =================================================================
-- EX 603 Assignment 2 — schema.sql
-- Theme: social media
-- Author: Cedric Huma Okinga Panguiepona
-- Target: PostgreSQL 16.13
-- =================================================================
-- Reset. Reverse creation order, so no dependency blocks a drop.


-- create schema
CREATE SCHEMA IF NOT EXISTS social_media;
-- Drop tables if they exist
DROP TABLE IF EXISTS social_media.dwell_ms CASCADE;
DROP TABLE IF EXISTS social_media.post_hashtags CASCADE;
DROP TABLE IF EXISTS social_media.likes CASCADE;
DROP TABLE IF EXISTS social_media.hashtags CASCADE;
DROP TABLE IF EXISTS social_media.posts CASCADE;
DROP TABLE IF EXISTS social_media.users CASCADE;


-- 1. USERS TABLE
CREATE TABLE social_media.users (
    id INTEGER PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    bio TEXT,
    profile_image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP
);


-- 2. POSTS TABLE
CREATE TABLE social_media.posts (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    video_url VARCHAR(500),
    is_edited BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   Constraint fk_posts_referral FOREIGN KEY (user_id) REFERENCES  social_media.users(id) ON DELETE CASCADE
);


-- 3. LIKES TABLE
CREATE TABLE  social_media.likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    post_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Constraint uq_likes UNIQUE(user_id, post_id),
   Constraint fk_likes_referral FOREIGN KEY (user_id) REFERENCES  social_media.users(id) ON DELETE CASCADE,
   Constraint fk_likes_referral_2 FOREIGN KEY (post_id) REFERENCES  social_media.posts(id) ON DELETE CASCADE
);


-- 4. HASHTAGS TABLE
CREATE TABLE  social_media.hashtags (
    id INTEGER PRIMARY KEY,
    tag_name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 5. POST_HASHTAGS TABLE (Junction/Bridge Table)
CREATE TABLE  social_media.post_hashtags (
    id INTEGER PRIMARY KEY,
    post_id INTEGER NOT NULL,
    hashtag_id INTEGER NOT NULL,
    Constraint uq_posts_hashtags UNIQUE(post_id, hashtag_id),
    Constraint fk_posts_hashtags_referral FOREIGN KEY (post_id) REFERENCES  social_media.posts(id) ON DELETE CASCADE,
    Constraint fk_posts_hashtags_referral_2 FOREIGN KEY (hashtag_id) REFERENCES social_media.hashtags(id) ON DELETE CASCADE
);


-- 6. DWELL_MS TABLE (Engagement/Time Tracking)
CREATE TABLE  social_media.dwell_ms (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    post_id INTEGER NOT NULL,
    dwell_time_ms INTEGER NOT NULL,  -- Milliseconds spent viewing
    view_count INTEGER DEFAULT 1,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   Constraint fk_dwells_ms_referral FOREIGN KEY (user_id) REFERENCES  social_media.users(id) ON DELETE CASCADE,
   Constraint fk_posts_dwells_ms_referral_2 FOREIGN KEY (post_id) REFERENCES  social_media.posts(id) ON DELETE CASCADE
);


-- 7. INDEXES FOR PERFORMANCE
CREATE INDEX idx_posts_user_id ON  social_media.posts(user_id);
CREATE INDEX idx_posts_created_at ON  social_media.posts(created_at);
CREATE INDEX idx_likes_user_id ON  social_media.likes(user_id);
CREATE INDEX idx_likes_post_id ON  social_media.likes(post_id);
CREATE INDEX idx_post_hashtags_hashtag_id ON social_media.post_hashtags(hashtag_id);
CREATE INDEX idx_dwell_user_post ON  social_media.dwell_ms(user_id, post_id);


