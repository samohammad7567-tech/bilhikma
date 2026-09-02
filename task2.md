    

# 569  BilHikma  Development  Mobile 

 Add     

**IN PROGRESS**  

# <sup>**QA Screen Capture Exemption**</sup> 

The testing team has to screenshot defects and pass them on. Under the current policy three captures suspend the account automatically, which has already locked testers out mid-cycle. Named accounts are now exempt: no protection is applied to them and no violation is counted. 

The exemption belongs to the account and is held on the server. The app reads it — it never claims it, and never decides it locally. 

# **1. What changed in the backend** 

## **1.1 New field:** **`can_capture_screen`** 

 Status 



<!-- Start of picture text -->
MA<br><!-- End of picture text -->

 Action required 

> MA Mohammad AlKhat… 

 Not scheduled 



<!-- Start of picture text -->
MA<br><!-- End of picture text -->

 Assigned to 

> MA Mohammad AlKhat… 

 All fields       

### **Time Reports** 



<!-- Start of picture text -->
AS<br><!-- End of picture text -->



<!-- Start of picture text -->
 Users MA AS<br><!-- End of picture text -->

A boolean returned in two places: 

`POST /login` — under `data.user` 

`GET /user/profile` — under `data` 

`true` means this account is exempt. `false` means a normal account and protection applies. Returned for student accounts only. 

It appears in both places on purpose: login establishes the value, and the profile endpoint refreshes it, so a revoked exemption takes effect without the tester having to sign out. 

# **2. What the app has to do** 

## **2.1 Read the flag at session start** 

Take `can_capture_screen` from the login response and keep it with the session state, not per screen. Refresh it from `GET /user/profile` on app resume. 

## **2.2 Apply it before any protected screen is built** 

When `can_capture_screen` is `true` : 

do not set `FLAG_SECURE` on the Activity window (Android) 

- do not register the `ScreenCaptureCallback` (Android 14+) 

- do not apply the iOS screenshot or recording blur 

do not post to `/user/security-events` 

Timing is the whole point of this requirement. `FLAG_SECURE` is a window flag: once it is set the OS blocks the capture and the app is never asked. Reading the flag after the first protected route is built leaves the window secured and the tester still unable to screenshot. 

## **2.3 Leave normal accounts exactly as they are** 

When the flag is `false` , behaviour is identical to the current build — protection applied, events reported, warnings shown. 

## **2.4 Keep the watermark in both cases** 

The watermark is not part of the exemption. A captured screen still has to be traceable to the account that captured it. 

## **2.5 Do not store the flag as a durable setting** 

Do not write it to long-lived local storage. Each login response replaces it; logout clears it. If it cannot be read for any reason — parse error, offline resume, missing key — treat it as `false` . The app must never fall open. 

# **3. Responses** 

## **Login** 

- `1 POST /api/login 2 3 { 4 "message": "Login successful", 5 "status_code": 1, 6 "data": { 7 "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc…", 8 "token_type": "Bearer", 9 "user": {` 

- `10 "id": 13, 11 "full_name": "` المؤيد `", 12 "phone": "0958953255",` 

```
13      "role":"student",
14      "status":"active",
15      "student_no":"STU-2026-00009",
16      "can_capture_screen":true,
17      "enrollments":[ … ]
18}
19}
20}
```

## **Profile** 

`1 GET /api/user/profile 2 3 { 4 "message": "Profile fetched successfully.", 5 "status_code": 1, 6 "data": { 7 "id": 9, 8 "student_no": "STU-2026-00009", 9 "name": "` المؤيد `", 10 "phone": "0958953255", 11 "institution": "` اإللكتروني بالحكمة منصة معهد `", 12 "academic_path": "` الثاني الفصل `", 13 "can_capture_screen": true 14 } 15 }` 

## **Security event** 

```
1POST/api/user/security-events
2  event_type   string   "screenshot"
3  content_id   int      optional
4  headers      X-Device-Uuid,X-App-Version
5
6{
7  "message":"Event recorded.",
8  "status_code":1,
9  "data":{
10    "event_id":31,
11    "account_suspended":false,
12    "warning_issued":null,
13    "can_capture_screen":true
14}
15}
```

The flag is echoed here so a build that reports anyway can confirm the event was filed without consequence. It is not a substitute for reading the value at session start. 

# **4. Behaviour by account type** 

|**Account**|**Protection**<br>**applied**|**Event**<br>**recorded**|**Counts as**<br>**violation**|**Warning**|**Suspensio**<br>**n**|
|---|---|---|---|---|---|
|Normal|Yes|Yes|Yes|Yes|At|
|student|||||threshold|
|Exempt<br>(QA)|No|Yes|No|No|Never|



Note the third column. An exempt account still leaves a complete trail; only the penalty is waived. 

# **5. Edge cases** 

|**Situation**|**Expected behaviour**|
|---|---|
|Exemption revoked mid-session|Applies on the next profile refresh. No<br>forced sign-out.|
|Exemption has an expiry that<br>passes|The server returns<br>`false`from that<br>moment. No date handling in the app.|
|Exempt account on a second<br>device|The exemption follows the account,<br>not the device. Session rules<br>unchanged.|
|Old build reports a capture|Recorded, not counted. No warning,<br>no suspension.|
|Field missing from the response|Treat as<br>`false`. Protection is the<br>default.|





Non-student account 

The field is not returned. Not applicable. 

# **6. Test data** 

Exempt on `bilhikma.tech` , granted until revoked: 

|**Student**|**Phone**|**Expires**|**Reason**|
|---|---|---|---|
|9|0958953255|Never|QA team|
|11|0955110022|Never|QA team|
|12|0955330044|Never|QA team|



Every other student account returns `can_capture_screen: false` and works as the control case. 

### Show less  

## **Messages** 



<!-- Start of picture text -->
AS AlMouayad Shwin created the task 6 days<br>AS AlMouayad Shwin 6 days<br>Action required by Mohammad AlKhateeb<br>Mohammad AlKhateeb 5 days<br>Changed status to  IN PROGRESS<br><br>MA Action is required by Mohammad AlKhateeb (6 days)<br>Reply / Comment<br><!-- End of picture text -->



<!-- Start of picture text -->
AS<br><!-- End of picture text -->



<!-- Start of picture text -->
MA<br><!-- End of picture text -->



