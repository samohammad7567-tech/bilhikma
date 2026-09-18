    

<sup>**Fix UI**</sup> 

 Add     

**NOT STARTED**  



<!-- Start of picture text -->
 Status<br><!-- End of picture text -->

 Action required 



<!-- Start of picture text -->
RH<br><!-- End of picture text -->

 Not scheduled 

The sidebar/menu toggle icon position is inconsistent across different screens in the mobile app. The icon must follow the correct directional layout based on the app's language setting. 



<!-- Start of picture text -->
MA<br><!-- End of picture text -->

 Assigned to  All fields 

> MA Mohammad AlKhat…      



<!-- Start of picture text -->
H<br><!-- End of picture text -->



<!-- Start of picture text -->
 Users RH MA H<br><!-- End of picture text -->

- In **Screenshot 1** (Live Broadcast screen): The menu icon appears on the **top-left** (incorrect for Arabic/RTL) 

- In **Screenshot 2** (Dashboard screen): The menu icon appears on the **top-right** ✅ (correct for Arabic/RTL) 

|**Language**|**Layout Direction**|**Menu Icon Position**|
|---|---|---|
|Arabic|RTL (Right-to-Left)|**Top-Right**corner|
|English|LTR (Left-to-Right)|**Top-Left**corner|

1. **Audit all screens** in the mobile app to identify where the menu/sidebar icon is incorrectly positioned 

2. **Update the menu icon placement** to be dynamically based on the app's current language/direction: 

   - When app language = **Arabic** → icon on the **right** 

   - When app language = **English** → icon on the **left** 

3. **Apply the fix across ALL interfaces/screens** — not just the Live Broadcast screen 

4. Ensure the fix uses proper RTL/LTR layout directives (e.g., `start` / `end` instead of `left` / `right` in layout code) so it automatically adapts when the language changes 

Live Broadcast screen ( المباشر البث ) — **confirmed incorrect** All other screens must be reviewed and corrected if needed 

Use layout direction-aware properties (e.g., `marginStart` / `marginEnd` , 

- `gravity="start"` ) instead of hardcoded left/right values 

- Test with both Arabic and English language settings to verify correct behavior on all screens 

When the application language is switched to English (LTR layout), the decorative background images/patterns in various frames and cards are not properly adjusted for the left-to-right layout direction. 

The decorative Islamic geometric pattern images appear in the following locations and need LTR adjustment: 

**Header section** - Left and right corner decorative patterns 

- **Subject cards** - Left and right side decorative patterns (visible in pink highlighted areas) 

When app language = **English (LTR)** : 

1. Decorative pattern images should be **horizontally flipped/mirrored** to match LTR direction 

2. OR positions should be **swapped** (left patterns move to right, right patterns move to left) 

3. Visual balance and aesthetic should be maintained for LTR layout 

- ✅ Dashboard header section (institute name area) 

- ✅ Subject cards (all subject items in the list) 

- ✅ All other cards/frames with similar decorative patterns 

1. **Detect layout direction** (RTL/LTR) based on current language 

2. **Apply transformation** to decorative images: 

   - Option A: Use `scaleX: -1` transform for LTR to mirror images 

   - Option B: Swap image sources based on direction 

   - Option C: Use direction-aware image assets 

3. **Test** in both Arabic (RTL) and English (LTR) modes 

4. **Apply to all screens** that use these decorative patterns 

**Add Decorative Islamic Pattern Images to Sidebar Drawer Menu** 

The sidebar/drawer menu is missing decorative Islamic geometric pattern images in specific locations. These patterns need to be added to match the design system used across the rest of the application. 

As shown in the screenshot (pink highlighted boxes), the sidebar drawer menu is missing decorative pattern images in **two locations** around the user profile card section: 

1. **Left side** of the user profile card (beige/tan card area) 

2. **Right side** of the user profile card (beige/tan card area) 

These decorative patterns are visible in other parts of the app (dashboard header, subject cards) but are **not rendered** in the sidebar menu. 

Decorative Islamic geometric pattern images should appear on **both sides** of the user profile card in the sidebar drawer 

Patterns should match the style and opacity used in other screens 

Patterns should be **subtle/background-level** (not obstructing content) 

|**Language**|**Layout**|**Pattern Position**|
|---|---|---|
|Arabic|RTL|Patterns on both sides,<br>mirrored appropriately|
|English|LTR|Patterns on both sides,<br>mirrored appropriately|

1. **Add decorative pattern images** to the two highlighted areas in the sidebar: 

   - Left edge of the user profile card container Right edge of the user profile card container 

2. **Use the same pattern assets** already used in the dashboard header and subject cards for design consistency 

3. **Apply proper RTL/LTR handling** : 

Use `start` / `end` positioning instead of hardcoded `left` / `right` 

   - Mirror/flip patterns when switching between Arabic and English 

4. **Ensure patterns are positioned correctly** relative to the profile card and do not overlap with text or interactive elements 

5. **Set appropriate opacity** so patterns appear as subtle background decorations 

**Display "Coming Soon" Notification Drawer for All Unavailable Features** 

Currently, when users tap on features that are not yet available in the application (e.g., the Exam/Quiz feature after completing a lesson), nothing happens or the behavior is unclear. A **"Coming Soon" drawer/modal** should be displayed to inform users that the feature will be available in the future. 

Features that are not yet implemented have **no user feedback** when tapped 

- Users may be confused about why nothing happens 

- No communication about future feature availability 

When a user taps on any **unavailable/not-yet-implemented feature** , a **bottom drawer or modal popup** should appear with: 

1. **Illustration/Icon** — A friendly visual (e.g., rocket, clock, or construction icon) 

2. **Title** — " ًقريبا " / "Coming Soon" 

3. **Description** — A brief message explaining the feature will be available soon 

4. **Close button** — To dismiss the drawer 

**Maintain Consistent Subject Numbering Between Subjects List and Subject Details Pages** 

The subject numbering is inconsistent between the subjects list page (Home) and the subject details page. When a user navigates from the subjects list to a specific subject's 



details page, the subject number resets to **1** instead of retaining its original number from the list. 

The subjects are numbered as follows: 

|**Subject**|**Number**|
|---|---|
|السيرة<br>النبوية|**1**|
|النحو|**2**|
|التفسير|**6**|
|العقيدة|**7**|
|الحديث|**8**|

When navigating to the العقيدة subject details page, the number displayed is **1** ❌ — but it should remain **7** ✅ as shown in the subjects list. 

The subject number must be **consistent and persistent** across all pages: 

|**Page**<br>**Subject**|**Expected**<br>**Number**|
|---|---|
|Subjects<br>العقيدة|**7**|
|List||
|Subject<br>Details<br>العقيدة|**7** ✅|
|Any other<br>page<br>referencing<br>the subject<br>العقيدة|**7** ✅|
|**Implementation Details**<br>photo_2026-08-25_0<br>photo|_2026-08-25_0<br>photo_2026-08-24_2<br>photo_2026-08-24_2|
|photo_2026-08-24_2<br>photo<br>Show less|_2026-08-24_2|

|H|**Hadeel** created the task|Yesterday|
|---|---|---|
|MA|Pending reply 14 minutes||
|H|**Hadeel**|Yesterday|
||Action required by Rafat Haroub||
||**Hadeel**|Yesterday|
||New Task (Task 5)<br>Mohammad AlKhateeb<br>MA<br>AlMouayad Shwin<br>AS||





