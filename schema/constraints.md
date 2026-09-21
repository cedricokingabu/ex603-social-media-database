Constraints:
POSTS:
├─ user_id → USERS.id (ON DELETE CASCADE)
└─ Constraint: user_id NOT NULL

LIKES:
├─ user_id → USERS.id (ON DELETE CASCADE)
├─ post_id → POSTS.id (ON DELETE CASCADE)
├─ UNIQUE(user_id, post_id) ← Prevents duplicate likes
└─ Both NOT NULL

POST_HASHTAGS:
├─ post_id → POSTS.id (ON DELETE CASCADE)
├─ hashtag_id → HASHTAGS.id (ON DELETE CASCADE)
├─ UNIQUE(post_id, hashtag_id) ← Prevents duplicate associations
└─ Both NOT NULL

DWELL_MS:
├─ user_id → USERS.id (ON DELETE CASCADE)
├─ post_id → POSTS.id (ON DELETE CASCADE)
└─ Both NOT NULL

UNIQUE Constraints:
USERS:
├─ username (UNIQUE)
└─ email (UNIQUE)

HASHTAGS:
└─ tag_name (UNIQUE)

LIKES:
└─ (user_id, post_id) composite UNIQUE ← User can't like same post twice

POST_HASHTAGS:
└─ (post_id, hashtag_id) composite UNIQUE ← Post can't have same hashtag twice

CASCADE DELETE BEHAVIOR :

When a USER is deleted (id=1):
├─ All POSTS by user_id=1 are deleted (CASCADE)
│ ├─ All LIKES on those posts are deleted (CASCADE)
│ ├─ All DWELL_MS records for those posts are deleted (CASCADE)
│ └─ All POST_HASHTAGS entries are deleted (CASCADE)
├─ All LIKES by user_id=1 are deleted (CASCADE)
└─ All DWELL_MS records by user_id=1 are deleted (CASCADE)

When a POST is deleted (id=100):
├─ All LIKES on post_id=100 are deleted (CASCADE)
├─ All DWELL_MS records for post_id=100 are deleted (CASCADE)
└─ All POST_HASHTAGS entries with post_id=100 are deleted (CASCADE)
└─ HASHTAGS table is NOT affected (preserved for future use)

When a HASHTAG is deleted (id=5):
└─ Only POST_HASHTAGS entries with hashtag_id=5 are deleted (CASCADE)
└─ Associated POSTS remain intact

