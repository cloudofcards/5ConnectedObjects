// Note: As of today, the hat needed for the PaPirus is not compatible with
// the GrovePi+ hat. Both work independently. You may choose to use either
// one depending on your project. Further compatibility may come...

// If you want to add the motion sensor, please refer to To_Freeze.pde and adapt the script to call grove_pir_motion_sensor.py

import java.util.Arrays;
import java.util.Date;
import java.math.BigInteger;
import java.security.SecureRandom;
import ch.fabric.processing.owncloud.OCServer;

// Defining cloud folder
final String DIR = "cloudofcards/TO_CARE";
String [] lastContentPoll;
int listener_check, ten_seconds_check, one_minute_check;
int listener_interval = 24 * 60 * 60 * 1000; // defining checking intervals at 24h (24 * 60 * 60 * 1000)
int ten_seconds = 10000;
int one_minute = 60000; // 60000

boolean no_detection = true;
boolean upright = true;

// My main access to the Owncloud server
OCServer OC;
boolean resB = false;

// Init random
private SecureRandom random = new SecureRandom();

// Socket
Socket s;
PrintWriter out;
int port = 5204;

void setup() {
  // Creating a new access to an OwnCloud server
  OC = new OCServer(this, "X"); // insert your key instead of "X"

  // Define the targeted OwnCloud server
  resB = OC.setServer("X", 443); // insert your server name instead of "X", ie owncloud.cyberschnaps.com

  // Define my Owncloud server login/password
  OC.setAccess("X", "X"); // insert your login and password instead of "X"

  // Get current content
  lastContentPoll = OC.getContentList(DIR);

  // Init values
  listener_check = millis();
  ten_seconds_check = millis();
  one_minute_check = millis();

  // Init socket
  try{
    s = new Socket("localhost", port);
    out = new PrintWriter(s.getOutputStream(), true);
  }catch(Exception e){}
}

// Forcing the script to loop
void draw() {
  if( millis() > (listener_check + listener_interval)) {
    listener_check = millis();
    println("Reset to 0 (new day)");
    no_detection = true;
  }

  if( millis() > (ten_seconds_check + ten_seconds)) {
    ten_seconds_check = millis();
    listenChange();
  }

  if(!upright && no_detection) {
     if( millis() > (one_minute_check + one_minute)) {
      one_minute_check = millis();
      rename();
    }
  }
}

// For debug purposes you can simulate sensor inputs using the keystrokes below
void keyPressed() {
 switch(key) {
  case 'v':
    println("\nVERTICAL");
    vertical();
    break;
  case 'm':
    println("\nMOVEMENT");
    movement();
    break;
  case 'n':
    println("\nNO MOVEMENT");
    nm();
    break;
  case 'u':
    println("\nUPSIDE DOWN");
    upsidedown();
    break;
  default:
    println("\nPress v, m or u");
    break;
 }
}

void listenChange() {
  println("Checking server");
  String [] currentContent = OC.getContentList(DIR);
  if(!Arrays.deepEquals(currentContent, lastContentPoll)) {
   println("Activity on server side detected");
  }
  lastContentPoll = currentContent;
}

void movement() {
  // Simulating movement detection
 no_detection = false;
 // Starting timer again
 listener_check = millis();
}

void vertical() {
  upright = true;
}

// Listing number of files in the folder while no movement is detected
void nm() {
  if(!no_detection) {
    String [] content = OC.getContentList(DIR);
    println("To Care");
    println("Number of files in the folder "+ DIR + " : " + (content.length - 1));
// Activate lines below to display informations to the PaPirus screen
    // print("List of files : ");
    // exec("/home/pi/processing/sketchbook/scripts/textWrite.py");
  } else  {
    upright = false;
  }
}

void upsidedown() {
 println("Object is upside down");
}

void rename() {
  vertical();
     // Get content list of the directory
     String [] content = OC.getContentList(DIR);
     int lgth = content.length;

     // For each file in the directory
     String oldest = null;
     Date oldest_date = OC.getFileDateCreated(content[1]);
     for(int i = 1; i < lgth; i =i+1) {
       // Getting this file's creation date
       Date date = OC.getFileDateCreated(content[i]);

        // Up to now, is it the oldest file which hasn't been renamed?
       // All renamed files are prefixed with "rd"
       String filename = content[i].split("/")[2];
       if(!filename.substring(0,2).equals("rd") && (date.before(oldest_date) || date.equals(oldest_date))) {
         // If yes, then it is considered the oldest file (actually)
        oldest =  content[i];
        oldest_date = date;
       }
     }

     // Renaming files
     if(oldest != null) {
       String filename = oldest.split("/")[2];
       String ext = filename.split("\\.")[1];
       String randomString = new BigInteger(64, random).toString(32);
       String new_name = "rd" + randomString + "." + ext; // All renamed files are prefixed with "rd"
       int res = OC.fileMove(oldest, "/" + DIR + "/" + new_name, true);
       println("RESULT : " + res);
       if(res == 1) {
         println(filename + " has been renamed to " + new_name);
       } else{
        println("Impossible to rename this file");
       }
     } else {
      println("No file to rename");
     }
}
