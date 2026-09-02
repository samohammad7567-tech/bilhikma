    

# 567  BilHikma  Development  Mobile 

 Add     

**IN PROGRESS**  

<sup>**Lesson Locking and Checkpoint Progress**</sup> 

**Two things changed. Lesson access is now decided by the** 

**server instead of the lesson-list widget, and playback progress** 

**is reported four times per lesson instead of on a rolling timer.** 

# **1. What changed in the backend** 

## **1.1 New field:** **`is_locked`** 

Returned on every lesson, in both the list and the detail response. A lesson is unlocked when the previous lesson in the same subject is completed. The first lesson of a subject is always unlocked. Articles are part of the sequence. 



<!-- Start of picture text -->
 Status<br><!-- End of picture text -->



<!-- Start of picture text -->
MA<br><!-- End of picture text -->

 Action required 

> MA Mohammad AlKhat… 

 Not scheduled 



<!-- Start of picture text -->
MA<br><!-- End of picture text -->

 Assigned to MA Mohammad AlKhat…  All fields       

### **Time Reports** 



<!-- Start of picture text -->
AS<br><!-- End of picture text -->



<!-- Start of picture text -->
 Users MA AS<br><!-- End of picture text -->

## **1.2 New field:** **`checkpoints`** 

Array of second offsets at 25%, 50%, 75% and 100% of the duration. These are the only points at which the app should report progress. 

- `1 "duration_seconds": 7200, 2 "checkpoints": [1800, 3600, 5400, 7200]` 

Empty for articles and for locked lessons. On very short clips two quarters can round to the same second, so the array may hold fewer than four values — read its length. 

## **1.3 Locked lessons are refused, not just flagged** 

These three return **403** with a localized `message` when the lesson is locked: 

```
GET /user/content/{id}
```

```
POST /user/content/{id}/access-token
```

```
POST /user/content/{id}/progress
```

The access-token refusal is the one that matters — no token means no playable URL. 

## **1.4** **`article_body` removed from the list** 

The list returns card data only. Article text comes from `GET /user/content/{id}` , and only when that lesson is unlocked. 

## **1.5 Seek guard** 

`POST /progress` returns **422** if the reported position moved further than real elapsed time allows. The body carries `allowed_position_seconds` . 

## **1.6 Not changed** 

Media URLs are still never returned in any content response — audio and video remain reachable only through the access token. Posting `position_seconds = 0` against an article still marks it complete, so the read button needs no new endpoint. 

# **2. What the app has to do** 

## **2.1 Delete the periodic timer** 

The current build posts to `/progress` every 3–5 seconds. Remove it and every call site that is not a checkpoint. 

## **2.2 Count locally in Hive** 

Keep the one-second tick and persist it to a Hive box keyed by content 

id: `content_id` , `position_seconds` , `watched_delta_seconds` , `next_checkpoint_index` . Write on every tick, send nothing in between. Between checkpoints the player produces zero requests. 

## **2.3 Report at the four checkpoints** 

When the local position reaches `checkpoints[next_checkpoint_index]` , send one request, increment the index, reset the delta. In order — never checkpoint 3 before checkpoint 2. Do not compute the offsets yourself. 

- `1 POST /api/user/content/{id}/progress 2 position_seconds       int   the checkpoint value 3 watched_delta_seconds  int   seconds actually played since the last report` 



`watched_delta_seconds` is played duration, not the difference between positions. Send it every time — without it the server derives attendance from position movement and credits a rewatch as zero. 

Response — use these values for the UI rather than the local counter: 

- `1 { 2 "allowed_position_seconds": 1800, 3 "max_position_seconds": 1800, 4 "watched_seconds": 1800, 5 "progress_percent": 25, 6 "is_completed": false 7 }` 

## **2.4 Send the last checkpoint when the video ends** 

The player stops on its own at the end. Do not gate the send on `isPlaying` — that is what previously left lessons stuck below completion. 

## **2.5 Cap the seek bar at** **`max_position_seconds`** 

Rewinding and rewatching are fine. Dragging forward past the watched point must be blocked in the UI, not corrected after the fact. 

## **2.6 Treat 422 as a correction** 

Seek to `allowed_position_seconds` and carry on. No dialog, no error state, no retry of the same value. 

## **2.7 Draw the lock from** **`is_locked`** 

Delete the ordering and completion comparison in the lesson list widget. One source of truth. 

## **2.8 Do not sign the user out on 403** 

Show the `message` from the response body — it is already localized, do not hardcode a string. Check that the global Dio interceptor does not treat 403 as an expired session. 

## **2.9 Open lessons through the detail endpoint** 

`GET /user/content/{id}` returns `article_body` , `checkpoints` and `attachments` . The list no longer carries the body. 

## **2.10 Article read button** 

At the bottom of the article screen, only when `type = "article"` . Disabled or replaced by a read indicator when `progress.is_completed` is already true. 

- `1 POST /api/user/content/{id}/progress 2 position_seconds = 0` 

Reload the subject lesson list on success so the next lesson opens. 

## **2.11 Refresh lock state after any completion** 

`is_locked` is not cacheable. Reload the list whenever a lesson finishes or an article is marked read. 

## **2.12 Resume, do not replay** 

On reopening a lesson, restore position and checkpoint index from Hive and continue. A checkpoint crossed while the app was closed is not re-sent — the server rejects it as a skip. Clear the Hive entry after the fourth checkpoint is acknowledged. 

# **3. Fields** 

|**`Field`**|**Type**|**List**|**Detail**|**Notes**|
|---|---|---|---|---|
|`is_locked`|bool|yes|yes|New|
|`checkpoints`|int[]|yes|yes|New. Empt<br>articles and<br>lessons|
|`article_body`|string|—|yes|Removed f<br>list|
|`attachments`|array|—|yes|Metadata o|
|`subject_name`|string|—|yes|Unchanged|
|`progress`|object|null|yes|yes|Unchanged|



# **4. Worked example — a two-hour video** 

**Report position_seconds watched_delta_s progress_perce is_comple econds nt ted** 

|1st|1800|1800|25|false|
|---|---|---|---|---|
|2nd|3600|1800|50|false|
|3rd|5400|1800|75|false|
|4th|7200|1800|100|true|



The delta equals a full quarter only when the student watched it straight through. A pause makes it smaller, a rewatch makes it larger. Report what the counter actually accumulated. Never send two reports back to back to catch up — the server measures each against real elapsed time and rejects the second. 

# **5. Edge cases** 

|**Situation**|**Expected behaviour**|
|---|---|
|Clip shorter than four seconds|Fewer than four checkpoints.<br>Iterate the array, do not index a<br>fixed<br>`[3]`.|
|Lesson has no duration|`checkpoints`is empty. No<br>reporting.|
|App closed mid-quarter|Unreported seconds are lost.<br>Acceptable — do not buffer<br>and flush later.|
|Student rewatches an earlier part|Report the real<br>delta.<br>`max_position_seconds`d<br>oes not move backwards.|
|Access token expires mid-lesson|Request a new one. Hive state<br>is untouched.|
|Locked lesson opened by deep link|403 from the detail endpoint.<br>Show the message, stay on the<br>list.|



# **6. Test data** 

Seeded under `category_subject_id = 20` : 

|**Content**|**Type**|**State**|**Unlocked by**|
|---|---|---|---|
|10|video, 10s, checkpoints<br>[2,5,7,10]|unlocked|First in subject|
|11|article|locked|Completing 10|
|12|audio, 12s, checkpoints<br>[3,6,9,12]|locked|Marking 11 read|



Lesson 10 runs ten seconds, so the whole four-report cycle is observable in under a minute. 

Show less  

## **Messages** 

|AS<br>**AlMouayad Shwin** created the task|6 days|
|---|---|
|Action required by Mohammad AlKhateeb<br>AS<br>**AlMouayad Shwin**|6 days|
|**Mohammad AlKhateeb**|5 days|
|Action is required by **Mohammad AlKhateeb** (6 days)<br>Changed status to**IN PROGRESS**<br><br>MA||





<!-- Start of picture text -->
MA<br><!-- End of picture text -->



Reply / Comment 

