// Note: As of today, the hat needed for the PaPirus is not compatible with
// the GrovePi+ hat. Both work independently. You may choose to use either
// one depending on your project. Further compatibility may come...

// If you want to add the gyro sensor, please refer to the sensor integration below and adapt the script to call the python code corresponding to the gyroscope of your choice.

import java.util.Arrays;
import java.util.Date;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import ch.fabric.processing.owncloud.OCServer;

// Defining cloud folder
final String DIR = "cloudofcards/TO_FREEZE";
String [] lastContentPoll;
int listener_check, ten_seconds_check, one_minute_check;
int one_minute = 60000;
int listener_interval = 24 * 60 * one_minute; // defining checking intervals at 24h (24 * 60 * 60 * 1000)
int ten_seconds = 10000;

boolean temp_sup_10 = false;
boolean upright = true;

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
  listener_check = millis();
  ten_seconds_check = millis();
  one_minute_check = millis();

  // Start temperature thread
  temp_pass_10();

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
    temp_sup_10 = false;
  }

  if( millis() > (ten_seconds_check + ten_seconds)) {
    ten_seconds_check = millis();
    listenChange();
  }

  if(!upright && temp_sup_10) {
     if( millis() > (one_minute_check + one_minute)) {
      one_minute_check = millis();
      uncompress();
    }
  }
}

// For debug purposes you can simulate sensor inputs using the keystrokes below
void keyPressed() {
 switch(key) {
  case 't':
    println("\nTEMPERATURE > 10°C");
    temp_pass_10();
    break;
    case 'i': // This updates the folder information
      println("\nUpdating folder info");
      folderinfos();
      break;
  default:
    println("\nPress t or i");
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

void temp_pass_10() {
  println("Start Thread");
  LoopTemperature lp = new LoopTemperature();
  lp.start();
}

void folderinfos() {
  if(!temp_sup_10) {
    String [] content = OC.getContentList(DIR);
    println("To Freeze");
    println("Number of files in the folder "+ DIR + " : " + (content.length - 1));
// Activate lines below to display informations to the PaPirus screen
    // print("List of files : ");
    // exec("/home/pi/processing/sketchbook/scripts/textWrite.py");
  } else  {
    uncompress();
  }
}

void uncompress() {
  String [] content = OC.getContentList(DIR);

 // Decompressing files
 boolean res = OC.ext_melt();
 if(res) {
   println("Melted");
   println("Number of files decompressed in the folder : " + content.length);
// Activate lines below to display informations to the PaPirus screen
   // print("List of files : ");
   // exec("/home/pi/processing/sketchbook/scripts/textWrite.py");
 } else{
   println("ERROR : Decompression impossible. Please check if the addon was correctly installed on the owncloud server.");
 }
}

// This detects temperature from the sensor
class LoopTemperature extends Thread{
  int timeWait = 24 * 60 * 60 * 1000;
  int timeLoop = 10 * 60 * 1000;
  int tempThreshold = 10;
  public void run(){
    boolean activatedCold = false;
    boolean activatedHot = true;
    long timeStart = System.currentTimeMillis();
    while(true){
      String tempStr = getSensor("getTemp"); // Getting sensor info from getTemp.py
      float temp = Float.parseFloat(tempStr);
      // Defining what to do when it's "cold"
      if(temp < tempThreshold){
        activatedHot = false;
        if(!activatedCold) // If it's cold then do this
          timeStart = System.currentTimeMillis();
        activatedCold = true;
        if( (System.currentTimeMillis() - timeStart) > timeWait){
          activatedCold = false;
          println("Cold");
        }
      }
      // Defining what to do when it's "hot"
      else if(temp > tempThreshold){
        activatedCold = false;
        if(!activatedHot)
          timeStart = System.currentTimeMillis();
        activatedHot = true;
        if( (System.currentTimeMillis() - timeStart) > timeWait){
          activatedHot = false;
          println("Hot");
          uncompress(); // If it's hot for more than 1 day, then start uncompressing files.
        }
      }else{
        activatedHot = false;
        activatedCold = false;
      }
      try{
        Thread.sleep(timeLoop);
      }catch(Exception e){
        println(e);
      }
    }
  }


  String getSensor(String method) { // Running Python script from Processing
    String commandToRun = "python "+method+".py";

    // where to do it - should be full path
    File workingDir = new File(sketchPath(""));

    // run the script!
    String returnedValues = "";
    String ret = "";
    try {
      Process p = Runtime.getRuntime().exec(commandToRun, null, workingDir);
      int i = p.waitFor();
      if (i == 0) {
        BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
        while ( (returnedValues = stdInput.readLine ()) != null) {
          ret += returnedValues;
        }
      }

      // if there are any error messages but we can still get an output, they print here
      else {
        BufferedReader stdErr = new BufferedReader(new InputStreamReader(p.getErrorStream()));
        while ( (returnedValues = stdErr.readLine ()) != null) {
          ret += returnedValues;
        }
      }
      return ret;
    }catch (Exception e) {
      println("Error running command!");
      println(e);
      // e.printStackTrace(); // a more verbosed debug line, if needed in your project
    return "500";
    }
  }
}
