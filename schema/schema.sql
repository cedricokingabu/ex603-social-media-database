
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

-- -------------------------------------------------------------------
-- 1. USERS TABLE
-- USERS: parent entity; recursive referral FK stays on this table.
-- -------------------------------------------------------------------
CREATE TABLE social_media.users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(50)   NOT NULL,
    email VARCHAR(255)  NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    bio TEXT,
    profile_image_url VARCHAR(500),
    is_active BOOLEAN not null DEFAULT TRUE,
    created_at TIMESTAMP not null DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    referred_by INTEGER,
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT fk_users_referrer FOREIGN KEY (referred_by)
        REFERENCES social_media.users(id) ON DELETE SET NULL,
    CONSTRAINT chk_users_no_self_referral
        CHECK (referred_by IS DISTINCT FROM id)

);

-- -------------------------------------------------------------------
-- 2. POSTS TABLE
-- POSTS: depends on users because each post has an author.
-- -------------------------------------------------------------------
CREATE TABLE social_media.posts (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    video_url VARCHAR(500),
    is_edited BOOLEAN NOT NULL DEFAULT FALSE,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
   ,
  CONSTRAINT fk_posts_user FOREIGN KEY (user_id)
        REFERENCES social_media.users(id) ON DELETE CASCADE
);

-- -------------------------------------------------------------------
-- 3. LIKES TABLE
-- LIKES: depends on users and posts; one like per user/post pair.
-- -------------------------------------------------------------------

CREATE TABLE  social_media.likes (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INTEGER NOT NULL,
    post_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT uq_likes_user_post UNIQUE (user_id, post_id),
    CONSTRAINT fk_likes_user FOREIGN KEY (user_id)
        REFERENCES social_media.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_likes_post FOREIGN KEY (post_id)
        REFERENCES social_media.posts(id) ON DELETE CASCADE
);

-- -------------------------------------------------------------------
-- 4. HASHTAGS TABLE
-- HASHTAGS: independent catalog of tag names.
-- -------------------------------------------------------------------

CREATE TABLE  social_media.hashtags (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tag_name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT uq_hashtags_tag_name UNIQUE (tag_name)
);

-- -------------------------------------------------------------------
-- 5. POST_HASHTAGS - resolves the M:N between posts and hashtags.
-- The primary key is the pair of foreign keys,  no surrogate ID is needed.
-- -------------------------------------------------------------------

CREATE TABLE  social_media.post_hashtags (
    post_id INTEGER NOT NULL,
    hashtag_id INTEGER NOT NULL,
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     CONSTRAINT pk_post_hashtags PRIMARY KEY (post_id, hashtag_id),
    CONSTRAINT fk_post_hashtags_post FOREIGN KEY (post_id)
        REFERENCES social_media.posts(id) ON DELETE CASCADE,
    CONSTRAINT fk_post_hashtags_hashtag FOREIGN KEY (hashtag_id)
        REFERENCES social_media.hashtags(id) ON DELETE RESTRICT
);

-- -------------------------------------------------------------------
-- 6. DWELL_MS TABLE (Engagement/Time Tracking)
-- DWELL_MS: engagement events depend on an existing user and post.
-- -------------------------------------------------------------------

CREATE TABLE  social_media.dwell_ms (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INTEGER NOT NULL,
    post_id INTEGER NOT NULL,
    dwell_time_ms INTEGER NOT NULL,  -- Milliseconds spent viewing
    view_count INTEGER NOT NULL DEFAULT 1,
    viewed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     CONSTRAINT chk_dwell_ms_nonnegative CHECK (dwell_time_ms >= 0),
    CONSTRAINT chk_dwell_ms_positive_views CHECK (view_count > 0),
    CONSTRAINT fk_dwell_ms_user FOREIGN KEY (user_id)
        REFERENCES social_media.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_dwell_ms_post FOREIGN KEY (post_id)
        REFERENCES social_media.posts(id) ON DELETE CASCADE
);


-- 7. INDEXES FOR PERFORMANCE
CREATE INDEX idx_posts_user_id ON  social_media.posts(user_id);
CREATE INDEX idx_posts_created_at ON  social_media.posts(created_at);
CREATE INDEX idx_likes_user_id ON  social_media.likes(user_id);
CREATE INDEX idx_likes_post_id ON  social_media.likes(post_id);
CREATE INDEX idx_post_hashtags_hashtag_id ON social_media.post_hashtags(hashtag_id);
CREATE INDEX idx_dwell_user_post ON  social_media.dwell_ms(user_id, post_id);


