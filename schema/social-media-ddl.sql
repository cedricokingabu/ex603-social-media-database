-- Drop tables if they exist (careful!)
DROP TABLE IF EXISTS dwell_ms CASCADE;
DROP TABLE IF EXISTS post_hashtags CASCADE;
DROP TABLE IF EXISTS likes CASCADE;
DROP TABLE IF EXISTS hashtags CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS users CASCADE;




 --CREATE SCHEMA social_media_db;


-- 1. USERS TABLE
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
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
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    video_url VARCHAR(500),
    is_edited BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES  users(id) ON DELETE CASCADE
);


-- 3. LIKES TABLE
CREATE TABLE  likes (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id),  -- Prevents duplicate likes
    FOREIGN KEY (user_id) REFERENCES  users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES  posts(id) ON DELETE CASCADE
);


-- 4. HASHTAGS TABLE
CREATE TABLE  hashtags (
    id SERIAL PRIMARY KEY,
    tag_name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 5. POST_HASHTAGS TABLE (Junction/Bridge Table)
CREATE TABLE  post_hashtags (
    id SERIAL PRIMARY KEY,
    post_id INT NOT NULL,
    hashtag_id INT NOT NULL,
    UNIQUE(post_id, hashtag_id),  -- Prevents duplicate entries
    FOREIGN KEY (post_id) REFERENCES  posts(id) ON DELETE CASCADE,
    FOREIGN KEY (hashtag_id) REFERENCES hashtags(id) ON DELETE CASCADE
);


-- 6. DWELL_MS TABLE (Engagement/Time Tracking)
CREATE TABLE  dwell_ms (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    dwell_time_ms INT NOT NULL,  -- Milliseconds spent viewing
    view_count INT DEFAULT 1,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES  users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES  posts(id) ON DELETE CASCADE
);


-- 7. INDEXES FOR PERFORMANCE
CREATE INDEX idx_posts_user_id ON  posts(user_id);
CREATE INDEX idx_posts_created_at ON  posts(created_at);
CREATE INDEX idx_likes_user_id ON  likes(user_id);
CREATE INDEX idx_likes_post_id ON  likes(post_id);
CREATE INDEX idx_post_hashtags_hashtag_id ON post_hashtags(hashtag_id);
CREATE INDEX idx_dwell_user_post ON  dwell_ms(user_id, post_id);


