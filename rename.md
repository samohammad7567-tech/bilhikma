    

# 584  BilHikma  Development  Mobile 

 Add     

**NOT STARTED**  

- <sup>**Rename Content Type Labels Across the Entir**</sup> **e Application** 

# **Task Title** 

**Replace Content Type Constants: "** مسموع **" → "** صوتي **" and "** مرئي **" → "** فيديو **"** 

## **Description** 

The application currently uses the terms **"** صوتي **"** (Audio) and **"** فيديو **"** (Video) to label content types. These terms need to be replaced globally across all screens and interfaces with more appropriate terminology: **"** مسموع **"** and **"** مرئي **"** respectively. 

## **Changes Required** 

 Status 



<!-- Start of picture text -->
RH<br><!-- End of picture text -->

 Action required 

> RH Rafat Haroub 

 Not scheduled 



<!-- Start of picture text -->
MA<br><!-- End of picture text -->

 Assigned to MA Mohammad AlKhat…  All fields      

#### **Time Reports** 



<!-- Start of picture text -->
H<br><!-- End of picture text -->



<!-- Start of picture text -->
 Users RH MA H<br><!-- End of picture text -->

|**Current**|**New Label**|**English Equivalent**|
|---|---|---|
|**Label**|||
|صوتي|مسموع|Audio → Audible/Listening|
|فيديو|مرئي|Video → Visual|



## **Affected Areas** 

This change must be applied **everywhere** these terms appear in the application, including but not limited to: 

- ✅ **Subject/Material cards** — content type labels 

- ✅ **Lesson detail screens** — media type indicators 

- ✅ **Filters and search** — content type filter options 

- ✅ **Sidebar/Menu items** — if any reference these types 

- ✅ **Live broadcast screens** — session type labels 

- ✅ **Saved/Bookmarks section** — content type tags 

- ✅ **Settings** — any content type preferences 

- ✅ **Notifications** — content type references 

- ✅ **API response mappings** — if constants are used for backend mapping 

- ✅ **All other screens** where these terms appear 

## **Implementation Notes** 

### **For Developers** 

1. **Search the entire codebase** for the strings `" صوتي "` and `" فيديو "` (and their English equivalents `"Audio"` and `"Video"` if applicable) 

2. **Update all constant definitions** , enum values, label texts, and string resources 

3. **Check localization files** — update both Arabic and English string resources if these terms exist in translation files 

4. **Check database/API mappings** — if these values are stored or returned from the backend, ensure consistency (may require backend coordination if values are hardcoded on the server side) 

5. **Update any icons or visual indicators** associated with these labels if needed 

Show less  

### **Messages** 

H **Hadeel** created the task Yesterday MA Pending reply H **Hadeel** Yesterday Action required by Rafat Haroub  RH Action is required by **Rafat Haroub** (a day) 



<!-- Start of picture text -->
H<br><!-- End of picture text -->



<!-- Start of picture text -->
RH<br><!-- End of picture text -->

Reply / Comment 



