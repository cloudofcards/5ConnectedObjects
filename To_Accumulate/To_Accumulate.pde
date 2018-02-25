// Note: As of today, the hat needed for the PaPirus is not compatible with
// the GrovePi+ hat. Both work independently. You may choose to use either
// one depending on your project. Further compatibility may come...

// If you want to add the gyro sensor, please refer to To_Freeze.pde and adapt the script to call the python code corresponding to the gyroscope of your choice.

import java.util.Date;
import java.util.Arrays;
import ch.fabric.processing.owncloud.OCServer;
import java.net.Socket;

// Defining cloud folder
final String DIR = "cloudofcards/TO_ACCUMULATE";
final String PATH_TO_USB = "/tmp"; // defining path to copy the last file to USB thumb drive
String [] lastContentPoll;
int lastTimeCheck;
int timeInterval = 10000;
boolean first = true;

// My main access to the Owncloud server
OCServer OC;
boolean resB = false;

// Socket
Socket s;
PrintWriter out;
int port = 5204;

void setup() {
  // Creating a new access to an OwnCloud server
  OC = new OCServer(this, "X"); // insert your key instead of "X"
  OC.setDebug(true);

  // Define the targeted OwnCloud server
  resB = OC.setServer("X", 443); // insert your server name instead of "X", ie owncloud.cyberschnaps.com

  // Define my Owncloud server login/password
  OC.setAccess("X", "X"); // insert your login and password instead of "X"

  // Get current content
  lastContentPoll = OC.getContentList(DIR);

  // Init values
  lastTimeCheck = millis();

  // Init socket
  try{
    s = new Socket("localhost", port);
    out = new PrintWriter(s.getOutputStream(), true);
  }catch(Exception e){}
}

// Forcing the script to loop
void draw() {
  if( millis() > (lastTimeCheck + timeInterval)) {
    lastTimeCheck = millis();
    println("Checking server");
    listenChange();
  }
}

// For debug purposes you can simulate sensor inputs using the keystrokes below
void keyPressed() {
 switch(key) {
  case 'h':
    println("Deleting folder contents! Only one last file was saved to the USB drive.");
    horizontal();
    break;
  case 'v':
    println("VERTICAL POSITION");
    vertical();
    break;
  case 'e':
    println("UPSIDE DOWN");
    updsidedown();
    break;
  default:
    println("Press h, v or e");
    break;
 }
}

// Checking server for activity
void listenChange() {
  String [] currentContent = OC.getContentList(DIR);
  if(!Arrays.deepEquals(currentContent, lastContentPoll)) {
   println("Activity on server side detected");
  }
  lastContentPoll = currentContent;
}

// When the object is in vertical position, do this
void vertical() {
  String [] myContent = OC.getContentList(DIR);
  println("Number of files in the folder "+ DIR + " : " + (myContent.length - 1) );
  print("List of files : ");
  exec("/home/pi/processing/sketchbook/scripts/textWrite.py"); // Sending infos to the PaPirus screen
}

void updsidedown() {
 println("Object is upside down.");
}

// When the object has fallen to a horizontal position, do this
void horizontal() {
     // Get content list of To_Delete directory
     String [] myContent = OC.getContentList(DIR);
     int lgth = myContent.length;

     // For each file in the directory
     String oldest = null;
     Date oldest_date = OC.getFileDateCreated(myContent[1]);
     for(int i = 1; i < lgth; i =i+1) {
       // Getting this file's creation date
       Date date = OC.getFileDateCreated(myContent[i]);

       // Up to now, is it the oldest file?
       if(date.before(oldest_date) || date.equals(oldest_date)) {
         // If yes, then it is considered the oldest
        oldest =  myContent[i];
        oldest_date = date;
       }
     }

     // Downloading of oldest file to the USB drive
     new File(PATH_TO_USB + DIR).mkdirs();
     int dlResult = OC.fileDownload(oldest, PATH_TO_USB + oldest);
     if(dlResult == -110) { // No destination folder
      println("Download error. Try creating a destination folder.");
     }
     if(dlResult != 1) {
       println("ERROR ON DOWNLOAD : " + dlResult);
     }

     // Suppression of all files except the oldest
     for(int i = 1; i < lgth; i =i+1) {
       if(!myContent[i].equals(oldest)){
         OC.fileDelete(myContent[i]);
       }
      }
      myContent = OC.getContentList(DIR);

      // Printing infos on screen
      println("Deleted");
      println("Number of files in the folder "+ DIR + " : " + (myContent.length - 1) );
      println("File " + oldest + " saved on USB drive");
      // Activate line below to display informations to the PaPirus screen
      // exec("/home/pi/processing/sketchbook/scripts/textWrite.py");
}
