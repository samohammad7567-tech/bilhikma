

<!-- Start of picture text -->
BilHikma<br> App version check & forced update<br> Details   824  Add  Actions   <br>How it works<br>On every launch the app sends its  build number  (the  3000  in  1.0.1+3000  ). The server answers with one of 4 statuses. Builds<br>are compared by  build number only ; the version string is for display.<br>1. Mobile app (Flutter)<br>Endpoint  (no login needed):<br>1 GET /api/public/app-version?platform=android&build=3000<br>platform  and  build  can also be sent as the headers  Platform  and  Build-Number  . Read the build number with<br>package_info_plus  →  buildNumber  .<br>Response:<br>1 {<br>2   "status": "force_update",<br>3   "latest_version": "1.0.1",<br>4   "latest_build": 3000,<br>5   "minimum_version": "1.0.1",<br>6   "minimum_build": 3000,<br>7   "message": " لالستمرار التطبيق تحديث يرجى ",<br>8   "store_url": "https://drive.google.com/file/d/1B35AgUffUY-HJLYN4ugft_l-JLiU9B8g/view?<br>9 usp=drive_link"<br>}<br>status What the app shows<br>ok Continue normally<br>optional_update Dialog with  Update  +  Later  buttons<br>force_update Full screen,  no close button , only  Update  (opens  store_url  )<br>maintenance Full maintenance screen with  message  ; the app can't be used<br>Call it  before  the splash/login, on every launch.<br>message  comes in the app language (send  Accept-Language: ar  or  en  ).<br>If the request fails (no internet), continue normally. Never block on a network error.<br>Build numbers:<br>Next release:  version: 1.0.1+3000  .<br>Every release after that increases it (3001, 3002…).<br>Always build the same way:  flutter build apk --release  , with the same keystore.<br>2. Dashboard<br>One row per platform ( android  ,  ios  ). Requires  view_settings  to read and  manage_settings  to edit.<br>Action Endpoint<br>List GET /api/admin/app-versions<br>Show GET /api/admin/app-versions/{id}<br>Create POST /api/admin/app-versions<br>Edit PUT /api/admin/app-versions/{id}  (or  POST  to the same URL)<br>Delete DELETE /api/admin/app-versions/{id}<br>Fields:<br>Field Type Notes<br>platform android  /  ios One row each<br>latest_version string Shown to users, e.g.  1.0.1<br>minimum_version string Shown to users<br>latest_build integer Newest build<br>minimum_build integer Below this, the update is forced. Must be ≤  latest_build<br>store_url URL APK download link<br>message[ar]  ,  string Optional<br>message[en]<br>maintenance_mode boolean Optional<br>On edit, send only the changed fields.<br>Suggested screen:  a card per platform showing the current values, an edit form, a  Maintenance mode  toggle, and a hint:<br>"Set minimum build = latest build to force everyone to update."<br>Releasing a new build:<br>1. Upload the APK.<br>2. Set  latest_build  and  store_url  .<br>3. To force the update, also set  minimum_build  to the same number.<br>Show less  <br>Messages<br><!-- End of picture text -->



<!-- Start of picture text -->
IN PROGRESS <br><!-- End of picture text -->



<!-- Start of picture text -->
 Status<br><!-- End of picture text -->



<!-- Start of picture text -->
MA Mohammad AlKhateeb<br> Not scheduled<br><!-- End of picture text -->



<!-- Start of picture text -->
 Action required<br><!-- End of picture text -->



<!-- Start of picture text -->
 Assigned to OA Omar Al-Rifai<br> All fields      <br><!-- End of picture text -->



<!-- Start of picture text -->
Time Reports<br><!-- End of picture text -->



<!-- Start of picture text -->
 Users OA MA AS<br><!-- End of picture text -->

   

Today 

AS **AlMouayad Shwin** created the task AS **AlMouayad Shwin** 

Today 

 

MA 

Action required by Mohammad AlKhateeb 

Action is required by **Mohammad AlKhateeb** (19 hours) 

Reply / Comment 



