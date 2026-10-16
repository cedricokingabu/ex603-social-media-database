# Unit 2 — Design Reasoning

**Course:** EX603 — Data and Algorithms for Scalable Systems  
**Assignment:** 2: From Diagram to Database  
**Theme:** Social media  
**Database:** PostgreSQL 16.13  
**DDL:** `schema.sql`

## Task 2.2 — Constraints table

The table below covers every foreign key in the social media schema. The `ON DELETE` action applies when a row in the **referenced (parent)** table is physically deleted.

| Foreign key | ON DELETE choice | Reason |
|---|---|---|
| `fk_users_referrer`: `users.referred_by → users.id` | `SET NULL` | A deleted referrer must not cause the accounts they invited to be deleted, so only their referral attribution is cleared. |
| `fk_posts_user`: `posts.user_id → users.id` | `CASCADE` | When an author's account is physically removed, their posts should not remain with a nonexistent owner. |
| `fk_likes_user`: `likes.user_id → users.id` | `CASCADE` | Removing an account also removes likes performed by that account, preventing orphaned interactions. |
| `fk_likes_post`: `likes.post_id → posts.id` | `CASCADE` | Likes on a deleted post have no meaningful target and should be removed with that post. |
| `fk_post_hashtags_post`: `post_hashtags.post_id → posts.id` | `CASCADE` | A deleted post must lose its hashtag assignments without deleting the reusable hashtags themselves. |
| `fk_post_hashtags_hashtag`: `post_hashtags.hashtag_id → hashtags.id` | `RESTRICT` | A hashtag in use cannot be deleted accidentally while posts still depend on its classification. |
| `fk_dwell_ms_user`: `dwell_ms.user_id → users.id` | `CASCADE` | Viewing records belonging to a deleted account must be removed rather than attributed to a nonexistent viewer. |
| `fk_dwell_ms_post`: `dwell_ms.post_id → posts.id` | `CASCADE` | Viewing records for a deleted post must be removed because the content they measure no longer exists. |

### Why these deletion policies fit the platform

**Deleting a referrer (`SET NULL`).** Suppose Alice invites Bob to join the platform and `Bob.referred_by` stores Alice's user ID. If Alice permanently deletes her account, Bob remains a valid user with his own profile, posts, and interactions; only `Bob.referred_by` becomes `NULL`. `CASCADE` would wrongly delete Bob merely because he was invited by Alice. `RESTRICT` would prevent Alice's deletion until Bob's referral link was changed, even though Bob's account does not depend on Alice's continued membership. This action can also apply to several referred users at once.

**Deleting a post author (`CASCADE`).** If Alice's user row is physically deleted, all posts she authored are deleted automatically. This affects her published content and, through other foreign keys, the likes, hashtag assignments, and viewing records attached to those posts. Without cascading, a default `NO ACTION` or `RESTRICT` policy would block account deletion while authored posts exist, requiring manual cleanup; setting `posts.user_id` to `NULL` would also conflict with its `NOT NULL` requirement and leave content without an author. This is a deliberate hard-deletion policy, not a claim that setting `users.is_active = FALSE` deletes anything.

**Deleting the user who liked a post (`CASCADE`).** If Bob deletes his account after liking Alice's post, Bob's like row disappears, while Alice's post and likes from other users remain. `RESTRICT` would unnecessarily block Bob's account deletion, and `SET NULL` would be invalid for the non-nullable `likes.user_id` and would make it impossible to identify who performed the like.

**Deleting a liked post (`CASCADE`).** If Alice removes a post that has 50 likes, the 50 associated like records are removed; the users who liked it are unaffected. `RESTRICT` would stop a normal content-deletion operation until every like was separately removed, while `SET NULL` would preserve interactions with no identifiable post and violate `likes.post_id NOT NULL`.

**Deleting a post with hashtags (`CASCADE`).** If Alice deletes a post tagged `#travel` and `#photography`, its rows in `post_hashtags` disappear. The `#travel` and `#photography` rows in `hashtags` remain available for other posts. `RESTRICT` would force manual removal of every assignment before deleting a post; `SET NULL` would violate the junction table's non-nullable, composite-key columns and make the association meaningless.

**Deleting a hashtag (`RESTRICT`).** If a moderator tries to delete the `#travel` hashtag while one or more posts still reference it, PostgreSQL rejects the deletion. This protects existing post classifications from an accidental catalog cleanup. Under `CASCADE`, deleting the hashtag would silently remove all of its post-to-hashtag assignments, changing discoverability for potentially many authors. Under `SET NULL`, the non-nullable `hashtag_id` and composite primary key would be violated. To intentionally retire a hashtag, an administrator must first remove or migrate its assignments and then delete it. `RESTRICT` protects the association, not the hashtag against all possible administrative changes.

**Deleting a viewer (`CASCADE`).** If Bob permanently deletes his account, his rows in `dwell_ms`—which track time spent viewing posts and view counts—are deleted. Other users' viewing records and the posts themselves remain. `RESTRICT` would prevent account deletion while engagement events exist; `SET NULL` would violate `dwell_ms.user_id NOT NULL` and leave records with no accountable viewer. This choice prioritizes referential integrity and account-level deletion over preserving historical per-user analytics.

**Deleting a viewed post (`CASCADE`).** If Alice's post is physically removed, all `dwell_ms` records referencing it disappear, regardless of who viewed it. The viewers' accounts and their activity on other posts remain intact. `RESTRICT` would require manual deletion of every viewing record before removing content, while `SET NULL` would violate `dwell_ms.post_id NOT NULL` and leave viewing measurements without the post being measured.

**Interaction between policies.** Deleting Alice's account can trigger multiple cascades: her posts are deleted, their likes, hashtag assignments, and dwell records are deleted, and Alice's own likes and dwell records on other people's posts are also deleted. Other users and shared hashtag catalog entries survive. Users who named Alice as their referrer survive with `referred_by = NULL`. These effects follow foreign-key relationships; they do not run merely because a post is marked `is_deleted = TRUE` or a user is marked `is_active = FALSE`.

## CHECK constraints

| CHECK constraint | Invalid state prevented | How the invalid state could otherwise arise |
|---|---|---|
| `chk_users_no_self_referral`: `referred_by IS DISTINCT FROM id` | A user cannot list their own account as the account that referred them. | A signup bug, erroneous import, or manual SQL update could assign a user's own ID to `referred_by`; the foreign key alone would accept it because that user exists. |
| `chk_dwell_ms_nonnegative`: `dwell_time_ms >= 0` | A viewing event cannot record a negative elapsed duration. | A client timer bug, reversed timestamp subtraction, or malformed ingestion payload could produce a negative number. |
| `chk_dwell_ms_positive_views`: `view_count > 0` | An engagement record cannot claim zero or a negative number of views. | An API bug, a bad batch import, or an incorrect decrement could write `0` or `-1` even though the row represents recorded viewing activity. |

### Why these checks belong in the database

**No self-referral.** The `users` table contains a recursive foreign key because one existing user can refer another. Referential integrity alone ensures only that `referred_by` points to an existing user; it does not ensure the referring user is different from the referred user. `IS DISTINCT FROM` rejects equal IDs while allowing `NULL` when a user joined without a referral or their referrer was deleted. This check prevents *direct* self-referral, but it does not prevent longer referral cycles such as Alice referring Bob and Bob referring Alice; detecting those would require additional logic.

**Nonnegative dwell time.** The `dwell_ms` table stores elapsed viewing time in milliseconds. Negative durations have no valid meaning for this measurement and would corrupt engagement totals or averages. The `NOT NULL` declaration ensures the value is present, and the CHECK ensures that its numeric value is at least zero. Zero is allowed because an instantaneous or immediately terminated view can legitimately have no measurable elapsed time.

**Positive view count.** Each `dwell_ms` row represents recorded viewing activity, so `view_count` must be at least one. The default is `1`, but a default does not prevent an application from explicitly inserting `0` or a negative value; the CHECK does. `NOT NULL` separately prevents a missing count. Together, these constraints keep counts meaningful for analytics.

**Scope of validation.** The CHECK constraints enforce rules that can be evaluated from values in the same row. The foreign keys enforce existence and deletion behavior across rows and tables. Both are necessary: a foreign key cannot prohibit self-referral by itself, and a CHECK on a dwell duration cannot verify that the referenced post exists.
