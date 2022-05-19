# Safety Timer App
 
This is an android mobile application made in Flutter using Firebase cloud store to host data and Firebase Authentication to authenticate users.

This is a safety app that is designed to keep users safe by  utilizing various trigger mechanisms that will notify emergency contacts (other users) that something went wrong and then these contacts will be able to view gps data from the user who triggered the notification.

This app is currently a work in progress, so screenshots of the final version and an APK file will be available upon completion.

Also, if you plan on using this code, it will not work for you out of the gate because I have excluded some files that contain sensistive data, such as a google-services.json file that is used to connect the app to a firebase database, you will have to create your own database and add said file into android/app directory. This also applies to a SensitiveGlobals.dart file that contains other sensitive data such as a google maps API key.

Addendum: AndroidManifest.xml has also been removed because it now contains an API key.

<br>

## Login screen shown when you first open the app.

<img src="README_Assets/Login.png" alt="drawing" width="250"/>

<br>

## Default dashboard after logging in.

<img src="README_Assets/DefaultDashboard.png" alt="drawing" width="250"/>

<br>

## This is the timer duration picker.

<img src="README_Assets/TimerPicker.png" alt="drawing" width="250"/>

<br>

## Timer count down.

<img src="README_Assets/timer.gif" alt="drawing" width="250"/>

<br>

## Emergency event triggered, emergency contacts notified and GPS uploading.

<img src="README_Assets/uploading.gif" alt="drawing" width="250"/>

<br>

## Map view of an emergency dependee uploading GPS points.

<img src="README_Assets/map.gif" alt="drawing" width="250"/>