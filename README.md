# flightgear-flight-simulator-scripts
Simulated plane landing drill assistance

These scripts help players of the FlightGear open source flight simulator.  They are written for the Boeing 777 (200-ER I think), but they should generalize.

Goal 1 was to allow you to do landing drills quickly, over and over.  You appear in the air 1 - 3 (nautical) miles from the runway and land, over and over.  My scripts set the flaps, gear, and some other items so that you don't have to stop and do that over and over. 

Goal 2 was to "score" each landing like a gymnastics routine.  Your maximum z-axis (up / down) deceleration upon touchdown is displayed.  As I remember, if you go over 58 fps/s you damage the gear.  

Goal 3 was to time how long it takes from touchdown to exiting the runway.

I wrote these around 2011.  These currently used files are dated 2017 only because it's a different computer. I haven't touched them in years.  

In Linux, scripts are activated by saving them to /home/[user]/.fgfs/Nasal

git remote set-url origin git@github.com:kwynncom/flightgear-flight-simulator-scripts.git

