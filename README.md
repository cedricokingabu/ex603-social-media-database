Cedric Huma Okinga Panguiepona  / Social Media database project

This is a project of a social media database handling  post creation , rating and hashtags.


# Social Media Database Schema

**Assignment:** EX 603
**Author:** Cedric Huma Okinga Panguiepona  
**Target:** PostgreSQL 16.13  
**Theme:** Social Media Platform Database

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Schema Design](#schema-design)
3. [Tables](#tables)
4. [Design Decisions](#design-decisions)
5. [Installation](#installation)
6. [Usage](#usage)
7. [Sample Queries](#sample-queries)

---

## 🎯 Project Overview

This database schema models a **social media platform** similar to Twitter/X, Instagram, or LinkedIn. It supports:
- User accounts with profiles
- Creating and sharing posts with media
- Liking posts
- Hashtag management
- User engagement tracking (time spent viewing posts)

The schema is normalized to ensure data integrity and optimal performance while maintaining flexibility for social media features.

---

## 🏗️ Schema Design

### Database Organization




<img width="1325" height="678" alt="ERD_Assignement2" src="https://github.com/user-attachments/assets/1cc78ee3-5309-4bc7-9d6e-9eb388b1789d" />


### Data Model Summary

| Table | Records | Purpose | Key Relationship |
|-------|---------|---------|------------------|
| **users** | 7 | User accounts & profiles | PK: id |
| **posts** | 10 | User-generated content | FK: user_id → users |
| **likes** | 33 | Post engagement | FK: user_id, post_id |
| **hashtags** | 16 | Unique tags | PK: id |
| **post_hashtags** | 17 | Posts ↔ Hashtags (M:M) | FK: post_id, hashtag_id |
| **dwell_ms** | 18 | Time tracking | FK: user_id, post_id |

---

## 📊 Tables

### 1. USERS Table

**Purpose:** Stores user account information and authentication data.

```sql
CREATE TABLE social_media.users (
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

```

### 2. POSTS Table

**Purpose:** Stores post  messages.
```
CREATE TABLE social_media.posts (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    video_url VARCHAR(500),
    is_edited BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES social_media.users(id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX idx_posts_user_id ON social_media.posts(user_id);
CREATE INDEX idx_posts_created_at ON social_media.posts(created_at);

```
### 3. LIKES Table

**Purpose:** Stores likes linked to  messages.
```
CREATE TABLE social_media.likes (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES social_media.users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES social_media.posts(id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX idx_likes_user_id ON social_media.likes(user_id);
CREATE INDEX idx_likes_post_id ON social_media.likes(post_id);
```
### 4. HASHTAGS Table

**Purpose:** Stores hashtags linked to  messages.
```
CREATE TABLE social_media.hashtags (
    id SERIAL PRIMARY KEY,
    tag_name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
### 5. POSTS_HASHTAGS Junction Table

**Purpose:** Stores posts_hashtags .
```
CREATE TABLE social_media.post_hashtags (
    id SERIAL PRIMARY KEY,
    post_id INT NOT NULL,
    hashtag_id INT NOT NULL,
    UNIQUE(post_id, hashtag_id),
    FOREIGN KEY (post_id) REFERENCES social_media.posts(id) ON DELETE CASCADE,
    FOREIGN KEY (hashtag_id) REFERENCES social_media.hashtags(id) ON DELETE CASCADE
);

-- Index for trending hashtags queries
CREATE INDEX idx_post_hashtags_hashtag_id ON social_media.post_hashtags(hashtag_id);
```
### 6. DWELL_MS Table

**Purpose:** Stores metric data related to the database .
```
CREATE TABLE social_media.dwell_ms (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    dwell_time_ms INT NOT NULL,
    view_count INT DEFAULT 1,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES social_media.users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES social_media.posts(id) ON DELETE CASCADE
);

-- Index for engagement queries
CREATE INDEX idx_dwell_user_post ON social_media.dwell_ms(user_id, post_id);

```


## 🎨 Design Decisions
### 1. Schema Segregation
Decision: All tables placed in social_media schema, not in default public schema.

sql
CREATE SCHEMA IF NOT EXISTS social_media;
CREATE TABLE social_media.users (...)
Benefits:

✅ Organizational clarity - related tables grouped together
✅ Multi-application support - multiple apps can coexist in same database
✅ Access control - can grant permissions per schema
✅ Naming flexibility - different schemas can have "users" table
Trade-off: Must prefix queries: SELECT * FROM social_media.users;

Shortcut: Use SET search_path TO social_media; to omit prefix


### 2. Surrogate Keys (SERIAL PRIMARY KEY)
Decision: Use auto-incrementing integers as primary keys, not natural keys.

sql
id SERIAL PRIMARY KEY  -- ✅ Surrogate key
-- NOT: username VARCHAR(50) PRIMARY KEY  -- ❌ Natural key
Benefits:

✅ Small Size: 4 bytes (int) vs 50+ bytes (varchar)
✅ Fast Lookups: Small keys = faster indexes and joins
✅ Immutable: User IDs don't change if username changes
✅ Standard Practice: Industry best practice for relational databases
✅ Foreign Keys: Smaller foreign keys improve performance
Trade-off: Need to query by username separately when needed

### 3. Soft Deletes (is_deleted flag)
Decision: Mark posts as deleted rather than permanently removing them.

sql
is_deleted BOOLEAN DEFAULT FALSE,
-- Query: WHERE is_deleted = FALSE
Alternative: Hard delete (physically remove rows)

Benefits of Soft Deletes:

✅ Data Preservation: Keep data for analytics, auditing, recovery
✅ Undo Functionality: Can restore accidentally deleted posts
✅ Referential Integrity: Related data (likes, comments) remains valid
✅ Legal/Compliance: Some regulations require keeping historical data
✅ Performance: No cascading deletes needed
Trade-off: Must filter WHERE is_deleted = FALSE in queries

### 4. Cascade Deletes
Decision: When a user is deleted, automatically delete all their posts, likes, and engagement records.

sql
FOREIGN KEY (user_id) REFERENCES social_media.users(id) ON DELETE CASCADE
How It Works:

sql
DELETE FROM users WHERE id = 1;
-- AUTOMATICALLY deletes:
-- - All posts by user 1
-- - All likes by user 1
-- - All dwell_ms records for user 1
-- - All post_hashtags associations for those posts
Benefits:

✅ Referential Integrity: No orphaned records
✅ Automatic Cleanup: No manual intervention needed
✅ Data Consistency: Database stays clean
Caution: Combined with soft-delete, prevents permanent data loss

### 5. Unique Constraints
Decision: Enforce uniqueness at database level for critical fields.

sql
username VARCHAR(50) UNIQUE NOT NULL,
email VARCHAR(255) UNIQUE NOT NULL,
tag_name VARCHAR(100) UNIQUE NOT NULL,
UNIQUE(user_id, post_id),  -- Composite unique
UNIQUE(post_id, hashtag_id)
What It Prevents:

❌ Two users with same username
❌ Two users with same email
❌ Two hashtags with same name
❌ One user liking the same post twice
❌ Same hashtag tagged on same post twice
Benefits:

✅ Data Quality: Prevents duplicates at database level
✅ Performance: Unique indexes are fast for lookups
✅ Business Rules: Enforces requirements automatically


### 6. Junction Table (post_hashtags)
Decision: Use many-to-many junction table instead of storing hashtags in JSON.

Option A: Junction Table (CHOSEN)

sql
CREATE TABLE post_hashtags (
    post_id INT,
    hashtag_id INT,
    UNIQUE(post_id, hashtag_id)
);
Option B: JSON Denormalization (NOT CHOSEN)

sql
CREATE TABLE posts (
    ...
    hashtags JSONB DEFAULT '[]'  -- e.g., '[1, 2, 5]'
);
Comparison:

| Aspect |	Junction Table	| JSON |
|-------|---------|---------|
| **Query Speed**	| ⭐⭐⭐⭐⭐ Optimized |	⭐⭐ Slower |
| **Data Consistency**	| ⭐⭐⭐⭐⭐ ACID compliant |	⭐⭐⭐ Application-level |
| **Hashtag Analytics**|	⭐⭐⭐⭐⭐ Easy |	⭐⭐ Complex |
| **Indexing Support**	| ⭐⭐⭐⭐⭐ Full |	⭐⭐⭐ Limited |
| **Flexibility**	| ⭐⭐⭐⭐ Rigid structure |	⭐⭐⭐⭐⭐ Flexible |

Why Junction Table? Better performance, analytics, and consistency for this use case.

### 7. Timestamps (created_at, updated_at)
Decision: Track creation and modification times for all critical tables.

sql
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
Benefits:

✅ Chronological Sorting: Show newest posts first
✅ Audit Trail: Know when things changed
✅ Analytics: Understand user activity patterns
✅ Feed Algorithms: Sort by recency
✅ Debugging: Identify timing issues
Sample Uses:

sql
-- Get posts from last 24 hours
SELECT * FROM posts WHERE created_at > NOW() - INTERVAL '24 hours';

-- Show newest posts first
SELECT * FROM posts ORDER BY created_at DESC;

### 8. Engagement Tracking (dwell_ms)
Decision: Separate table for time-series engagement data.

Why Separate Table?

✅ Scalability: Engagement data grows much faster than posts
✅ Flexibility: Can track multiple views per user
✅ Performance: Won't bloat posts table
✅ Analytics: Time-series queries are cleaner
✅ Archival: Easy to archive old engagement data
Alternative: Store in posts table

sql
-- ❌ NOT CHOSEN: bloats posts table, inflexible
CREATE TABLE posts (
    ...
    total_dwell_ms INT,
    unique_viewers INT
);

### 9. Indexes for Performance
Decision: Create 6 strategic indexes for common queries.

sql
CREATE INDEX idx_posts_user_id ON social_media.posts(user_id);
CREATE INDEX idx_posts_created_at ON social_media.posts(created_at);
CREATE INDEX idx_likes_user_id ON social_media.likes(user_id);
CREATE INDEX idx_likes_post_id ON social_media.likes(post_id);
CREATE INDEX idx_post_hashtags_hashtag_id ON social_media.post_hashtags(hashtag_id);
CREATE INDEX idx_dwell_user_post ON social_media.dwell_ms(user_id, post_id);
Why These Indexes?

Index	Common Query	Speed Improvement
posts.user_id	"Get all posts by user X"	100x faster
posts.created_at	"Get newest posts (feed)"	100x faster
likes.user_id	"What has user X liked?"	50x faster
likes.post_id	"How many likes on post?"	50x faster
post_hashtags.hashtag_id	"Find posts with #ai"	100x faster
dwell_ms(user_id,post_id)	"Get engagement metrics"	50x faster
Trade-off: Indexes use disk space but make queries much faster.

### 10. Normalization Level: 3rd Normal Form (3NF)
Decision: Design follows Third Normal Form (3NF).

What is Normalization?

Level	Rule	Example
1NF	No repeating groups	✅ Can't store hashtags: [1,2,3] in posts
2NF	All non-key fields depend on entire PK	✅ No partial dependencies
3NF	No non-key field depends on another non-key	✅ hashtags table is separate
Benefits:

✅ No Redundancy: Data stored once, referenced many times
✅ Data Consistency: Can't have mismatched copies
✅ Flexible Queries: Works with joins
✅ Scalability: Easy to add new features
Trade-off: Requires joins (but indexes make it fast)

Example:

sql
-- ❌ NOT 3NF: hashtag data repeated
CREATE TABLE posts_bad (
    id INT,
    content TEXT,
    hashtag_name VARCHAR(100),
    hashtag_created_at TIMESTAMP
);

-- ✅ 3NF: separate tables
CREATE TABLE posts (id INT, content TEXT);
CREATE TABLE hashtags (id INT, tag_name VARCHAR(100), created_at TIMESTAMP);
CREATE TABLE post_hashtags (post_id INT, hashtag_id INT);


## 🚀 Installation
 Prerequisites


