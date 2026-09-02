    

# 585  BilHikma  Development  Mobile 

<sup>**Display Full Educational Path in Header Card**</sup> 

 Add     

 **COMPLETED** 

 



<!-- Start of picture text -->
 Status<br><!-- End of picture text -->

# **Task Title** 

**Show Complete Educational Path (Stage + Semester) in Dashboard Header Card** 

# **Description** 

The first card on the home/dashboard page currently displays only the **semester/term name** (e.g., " الثاني الفصل "). It should instead display the **full educational path** including both the **stage/level** and the **semester/term** . 



<!-- Start of picture text -->
MA<br><!-- End of picture text -->

 Assigned to 

> MA Mohammad AlKhat… 

### **Time Reports** 



<!-- Start of picture text -->
H<br><!-- End of picture text -->



<!-- Start of picture text -->
 Users RH AS MA H<br><!-- End of picture text -->

# **Current Issue** 

The header card on the dashboard shows incomplete information: 

- (e.g., " الثاني الفصل "). 

# **Expected Behavior** 

The header card should display the **complete educational path** with both the stage and semester clearly shown 

## **Example Display Format** 

|**Element**|**Example (Arabic)**|**Example (English)**|
|---|---|---|
|Institute Name|اللكتروني بالحكمة منصة معهد|Al-Hikmah Platform Institute|
|Stage/Level|الولى المرحلة|**Category**1 / Level 1|
|Semester/Term|الثاني الفصل|**Category**2 /Semester 2|



# **Implementation Details** 

## **Technical Notes** 

1. **Fetch both stage and semester data** from the user's enrollment/progress API 

2. **Display both values** in the header card with clear visual hierarchy 

3. **Handle RTL/LTR** properly: 

Arabic: الثاني الفصل ‹ األولى المرحلة 

English: Stage 1 › Semester 2 

4. **Fallback behavior** : If stage data is not available, show only semester (current behavior) with a graceful fallback 

5. **Styling** : Use appropriate font sizes and colors to distinguish between stage and semester (e.g., stage in smaller/lighter text, semester in larger/bolder text, or vice versa) 

Show less  

## **Messages** 

 1 more message  



<!-- Start of picture text -->
MA Pending reply<br>H Hadeel Today<br>Action required by Rafat Haroub<br>AlMouayad Shwin Today<br>Changed status to  IN PROGRESS<br>RH Pending reply 4 hours<br>AS AlMouayad Shwin Today<br>Changed status to  COMPLETED<br><!-- End of picture text -->



<!-- Start of picture text -->
H<br><!-- End of picture text -->



<!-- Start of picture text -->
AS<br><!-- End of picture text -->

