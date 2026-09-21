Task 1.1: Define the relation schema
For each of the five roles in your theme, write the relation schema: the relation name, its attributes, and the domain of each attribute.
State which attribute or attributes form the primary key.


Schema - Definition

┌──────────────────────────────────────────────────────────────────────────┐
│           SOCIAL MEDIA DATABASE - ENTITY RELATIONSHIPS                   │
└──────────────────────────────────────────────────────────────────────────┘


                    ┌─────────────────────────┐
                    │        USERS            │
                    ├─────────────────────────┤
                    │ id (PK, SERIAL)         │
                    │ username (UNIQUE)       │
                    │ email (UNIQUE)          │
                    │ password_hash           │
                    │ display_name            │
                    │ bio                     │
                    │ profile_image_url       │
                    │ is_active               │
                    │ created_at              │
                    │ updated_at              │
                    │ last_login_at           │
                    └─────────────────────────┘
                            │
                ┌───────────┼───────────┬──────────┐
                │           │           │          │
            1:Many      1:Many      1:Many    1:Many
                │           │           │          │
    ┌───────────▼──┐  ┌─────▼────────┐│  ┌───────▼────────┐
    │    POSTS     │  │    LIKES     │└─>│   DWELL_MS     │
    ├──────────────┤  ├──────────────┤│  ├────────────────┤
    │ id (PK)      │  │ id (PK)      ││  │ id (PK)        │
    │ user_id (FK) │  │ user_id (FK) ││  │ user_id (FK)   │
    │ content      │  │ post_id (FK) ││  │ post_id (FK)   │
    │ image_url    │  │ created_at   ││  │ dwell_time_ms  │
    │ video_url    │  │              ││  │ view_count     │
    │ is_edited    │  │ UNIQUE       ││  │ viewed_at      │
    │ is_deleted   │  │ (user_post)  ││  └────────────────┘
    │ created_at   │  └──────────────┘│   (Engagement
    │ updated_at   │           │      │    Tracking)
    └──────────────┘       1:Many     │
            │                 │       │
            │                 │   0..1:1 (Many:1)
            │                 │       │
            │         ┌───────┴───────┘
            │         │
        1:Many    Many:1
            │         │
            ▼         ▼
    ┌──────────────────────┐
    │  POST_HASHTAGS       │
    │  (Junction Table)    │
    ├──────────────────────┤
    │ id (PK)              │
    │ post_id (FK)         │
    │ hashtag_id (FK)      │
    │ UNIQUE               │
    │ (post_hashtag)       │
    └──────────────────────┘
            │
            │ Many:1
            │
            ▼
    ┌──────────────────────┐
    │   HASHTAGS           │
    ├──────────────────────┤
    │ id (PK, SERIAL)      │
    │ tag_name (UNIQUE)    │
    │ created_at           │
    └──────────────────────┘


    ↕ 1:Many Relationship
    | 0..1 Optional Relationship
    ● Primary Key (PK)
    ◆ Foreign Key (FK)
    ■ Unique Constraint



