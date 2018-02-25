// Note: As of today, the hat needed for the PaPirus is not compatible with
// the GrovePi+ hat. Both work independently. You may choose to use either
// one depending on your project. Further compatibility may come...

import java.util.Date;
import java.util.Arrays;
import ch.fabric.processing.owncloud.OCServer;

// Defining cloud folder
final String DIR = "cloudofcards/TO_IMPROVE";
final String PATH_TO_USB = "/tmp";
String [] lastContentPoll;
int lastTimeCheck;
int timeInterval = 10000;

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
  case 'a':
    println("\nOBJECTS ACTIVATED");
    active();
    break;
  case 'i':
    println("\nOBJECTS DEACTIVATED");
    deactivated();
    break;
  default:
    println("Press i or a");
    break;
 }
}

void listenChange() {
  String [] currentContent = OC.getContentList(DIR);
  if(!Arrays.deepEquals(currentContent, lastContentPoll)) {
   println("Activity on server side detected");
  }
  lastContentPoll = currentContent;
}

void active() {
  String [] content = OC.getContentList(DIR);
  println("To Improve");
  println("Number of files in the folder "+ DIR + " : " + (content.length - 1) );
// Activate lines below to display informations to the PaPirus screen
  // print("List of files : ");
  // exec("/home/pi/processing/sketchbook/scripts/textWrite.py");
}

void deactivated() {
 println("Files are being improved.");
 println("Number of files in the folder : " + 42);
// Activate lines below to display informations to the PaPirus screen
 // print("List of files : ");
 // exec("/home/pi/processing/sketchbook/scripts/textWrite.py");
}
