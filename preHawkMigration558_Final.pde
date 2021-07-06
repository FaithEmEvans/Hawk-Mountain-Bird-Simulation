// preHawkMigration558Final, Faith Evans, finalized on April 24
// Sketch preHawkMigration558Apr23A, Faith Evans, update 1 on April 23.
//    Hid debugging ellipses on top of birds, added Perlin noise in flight paths X.
// Sketch preHawkMigration558Apr19B, Faith Evans, update 2 on April 19.
// This preHawkMigration558Faith11Apr2020 has trig functions
// getDisplayPath() and findEndpoints() from the HawkTrig tab
// integrated to call getDisplayPath() in IntervalInitialFlightDemo()
// below, which is essentially the draw() function. FlightDIR now works
// correctly for the data, and WindDir can move clouds using the same approach.
// Color coding or otherwise coding distinct bird species is an excellent
// idea, and a Celsius thermometer or similar would be nice.

import java.util.Scanner ;  // needed to read the .csv file
import java.io.FileInputStream ; // get at .csv file via the file system
import java.util.HashMap ;  // map attribute name to position & vice versa
import java.util.LinkedList ; // sequence of instances from .csv file
import java.util.Arrays ;   // for sorting
import java.time.LocalDateTime ;  // for parsing & storing YYYY-MM-DD HH:MM[:SS]

/*****************  START OF ARFF DATABASE STUFF        ******************/
// Hard code these for now to get a quick start.
final String datafile = "HMS_F2017_2018_NUMERIC_DECOMMAS.csv";
final String dateformat = "date 'yyyy-MM-dd HH:mm'";
String [][] datatypes = {
    {"Start","yyyy-MM-ddTHH:mm"},
    {"End","yyyy-MM-ddTHH:mm"},
    {"Duration","numeric"},
    {"Observer","numeric"},
    {"BV","numeric"},
    {"TV","numeric"},
    {"UV","numeric"},
    {"MK","numeric"},
    {"OS","numeric"},
    {"BE","numeric"},
    {"NH","numeric"},
    {"SS","numeric"},
    {"CH","numeric"},
    {"NG","numeric"},
    {"UA","numeric"},
    {"RS","numeric"},
    {"BW","numeric"},
    {"SW","numeric"},
    {"RT","numeric"},
    {"RL","numeric"},
    {"UB","numeric"},
    {"GE","numeric"},
    {"UE","numeric"},
    {"AK","numeric"},
    {"ML","numeric"},
    {"PG","numeric"},
    {"UF","numeric"},
    {"UR","numeric"},
    {"TOTAL","numeric"},
    {"WindSpd","numeric"}, // Average kph derived from a nominal range
    {"WindDir","numeric"},
    // WindDir {Variable,WNW,NW,SE,E,S,ESE,SW,SSW,N,NNW,NE,ENE,W,WSW,NNE,SSE}
    // 0 is N, 90 is E, 180 is S, 270 is W, intermediate steps by 22.5
    {"Temp","numeric"},
    {"CloudCover","numeric"},
    {"Visibility","numeric"},
    {"FlightDIR","numeric"},
    // 0 is N, 90 is E, 180 is S, 270 is W, intermediate steps by 22.5
    {"FlightHT","{'7: Variable','4: Binoculars (to 10X)','3: At limit of unaided vision','1: Eye level to 30m',(none),'2: Unaided eye','0: Below eye level','5: At limit of binoculars (10X)'}"},
    {"SkyCode","string"},
    {"Counter","string"},
    {"Observer1","string"},
    {"Observer2","string"},
    {"Observer3","string"},
    {"Observer4","string"},
    {"HawkYear","string"}
};
LinkedList<Object []> instances = new LinkedList<Object []>();
// Objects in each instance-list are of type Float or String for now, deal
// with date type later
HashMap<String, Integer> attrNameToIndex = new HashMap<String, Integer>();
HashMap<Integer, String> attrIndexToName = new HashMap<Integer, String>();
HashMap<String, String> attrNameToType = new HashMap<String, String>();

/** LocalDateTimeComparator used to Arrays.sort instances on a datetime field */
class LocalDateTimeComparator implements java.util.Comparator<Object[]> {
  final int datetimeIndex ;
  LocalDateTimeComparator(int attrindex) {
    datetimeIndex = attrindex ;
  }
  int compare(Object[] instance1, Object [] instance2) {
    // sort based on the primary datetime attribute
    return ((LocalDateTime)(instance1[datetimeIndex])).compareTo(
      (LocalDateTime)(instance2[datetimeIndex]));
  }
}

/* fetch a Float object for attrName, returning null if it is not a Float */
Float fetchFloat(String attrName, Object [] instance, float useForNaN) {
  Integer index = attrNameToIndex.get(attrName);
  if (index != null) {
    Object obj = instance[index.intValue()];
    if (obj instanceof Float) {
      Float result = ((Float)obj);
      if (result.isNaN()) {
        // treat unknown data as 0 for now
        result = new Float(useForNaN);
      }
      return result ;
    }
  }
  return null ;
}
/* fetchFloat when we have already cached attribute index to avoid lookup */
Float fetchFloat(int index, Object [] instance, float useForNaN) {
  Object obj = instance[index];
  if (obj instanceof Float) {
    Float result = ((Float)obj);
      if (result.isNaN()) {
        // treat unknown data as 0 for now
        result = new Float(useForNaN);
      }
    return result ;
  }
  return null ;
}
/* fetch a LocalDateTime object for attrName, returning null if it is not one */
LocalDateTime fetchDateTime(String attrName, Object [] instance) {
  Integer index = attrNameToIndex.get(attrName);
  if (index != null) {
    Object obj = instance[index.intValue()];
    if (obj instanceof LocalDateTime) {
      return ((LocalDateTime)obj);
    }
  }
  return null ;
}
/* fetch a LocalDateTime when we have already cached its attrindex */
LocalDateTime fetchDateTime(int index, Object [] instance) {
  Object obj = instance[index];
  if (obj instanceof LocalDateTime) {
    return ((LocalDateTime)obj);
  }
  return null ;
}
/* fetch a String object for attrName, returning null if it is not a String */
String fetchString(String attrName, Object [] instance) {
  Integer index = attrNameToIndex.get(attrName);
  if (index != null) {
    Object obj = instance[index.intValue()];
    if (obj instanceof String) {
      return ((String)obj);
    }
  }
  return null ;
}
/* fetchString when we have already cached attribute index to avoid lookup */
String fetchString(int index, Object [] instance) {
  Object obj = instance[index];
  if (obj instanceof String) {
    return ((String)obj);
  }
  return null ;
}

void initializeDatabase() {
  /** START INITIALIZING DATABASE **/
  for (int i = 0 ; i < datatypes.length ; i++) {
    attrNameToType.put(datatypes[i][0], datatypes[i][1]);
  }
  Scanner scanner = null ;
  Object [][] preinstances = new Object [0][];
  try {
    scanner = new Scanner(new FileInputStream(dataPath("") + "/" + datafile));
    String topline = scanner.nextLine().trim();
    // topline has the attribute names
    String [] fieldnames = topline.split(",");
    for (int i = 0 ; i < fieldnames.length ; i++) {
      String fld = fieldnames[i].trim();
      String mytype = attrNameToType.get(fld);
      if (mytype == null) {
        throw new RuntimeException("ERROR, unknown attribute name: " + fld);
      } else if (attrNameToIndex.get(fld) != null) {
        throw new RuntimeException("ERROR, duplicate attribute name: " + fld);
      }
      attrNameToIndex.put(fld, i);
      attrIndexToName.put(i, fld);
    }
    int lineno = 0 ;
    while (scanner.hasNextLine()) {
      String instanceline = scanner.nextLine().trim();
      lineno++ ;
      String [] rawfields = instanceline.split(",");
      if (rawfields.length != fieldnames.length) {
        throw new RuntimeException("ERROR, line " + lineno + " has " + rawfields.length
          + " fields, declaration has " + fieldnames.length + " fields, "
            + instanceline);
      }
      Object [] instance = new Object [ rawfields.length ];
      for (int fldix = 0 ; fldix < rawfields.length ; fldix++) {
        String datum = rawfields[fldix].trim();
        String mytype = attrNameToType.get(attrIndexToName.get(fldix));
        if (mytype.equals("numeric")) {
          if (datum.equals("?") || datum.equals("")) {
            instance[fldix] = Float.NaN ;  // not a number used for unknown
          } else {
            try {
              instance[fldix] = Float.parseFloat(datum) ;
            } catch (NumberFormatException nex) {
              throw new RuntimeException("ERROR, invalid number on line " + lineno
                + ": " + datum, nex);
            }
          }
        } else if (mytype.startsWith("yyyy-")) {
          instance[fldix] = LocalDateTime.parse(
            datum.replace(' ', 'T').substring(1, datum.length()-1));
          //println("DEBUG DATETIME " + attrIndexToName.get(fldix) + ": " + instance[fldix]);
        } else {
          // treat all non-numerics as strings for now
          instance[fldix] = datum ;
        }
      }
      // instances.add(instance);
      preinstances = (Object [][]) append(preinstances, instance);
    }
    // instances.sort(new LocalDateTimeComparator(0));
    Arrays.sort(preinstances, new LocalDateTimeComparator(0));
    for (Object [] instance : preinstances) {
      instances.add(instance);
      //println("DEBUG SORTED DATETIME: " + instance[0]);
    }
    preinstances = null ;  // garbage collection
  } catch (Exception xxx) {
    println("ERROR, Runtime Exception : " + xxx.getMessage());
    exit();
  } finally {
    if (scanner != null) {
      scanner.close();
    }
  }
  /** END INITIALIZING DATABASE **/
}
/*****************  END OF ARFF DATABASE STUFF        ******************/

PImage NorthLookout ;
PImage hawk;
PImage eagle;
PImage falcon;
PImage vulture;
PImage accipiter;
PImage unid;
Raptor raptor;
int StartIndex = 0 ;          // from attrNameToIndex
int DurationIndex = 0 ;       // from attrNameToIndex
int TOTALIndex = 0 ;          // from attrNameToIndex
int instanceIndex = 0 ;       // into instances
Object [] currentInstance = null ;
int framesUntilAdvance = 0 ;  // how many frames remain until next instance?
final int NorthLookoutX = 640 ;
final int NorthLookoutY = 360 ;
float flightDir = 180 ;    // assume south when unknown
// North Lookout at x=640,y=360 pixels from upper left corner on 1280p png

void setup() {
  size(1280, 720, P2D);
  setupSpeciesToImage();  // pre-load PNGs into memory
  frameRate(30);
  initializeDatabase();
  NorthLookout = loadImage("NorthLookout.jpg");
  hawk = loadImage("hawk.png");
  eagle = loadImage("eagle.png");
  falcon = loadImage("falcon.png");
  vulture = loadImage("vulture.png");
  accipiter = loadImage("accipiter.png");
  unid = loadImage("unid.png");
  // Parson comment - I am going to plot Duration (60 mins = 60 frames)
  // against a vertical of TOTAL raptors. A full implementation needs
  // to color-code and/or PShape-code each species separately so
  // you can see distinct species. Also use FlightDIR to plot the
  // path crossing North Lookout (mine just goes due North-to-South),
  // display cloud cover semi-transparent, and use WindDir to set
  // direction of clouds and maybe make the leaves blow in an advanced
  // version. I am adding one keyboard command 'S' for now to skip over
  // TOTAL=0 frames, and am plotting the timestamp in the lower left
  // in white. I can extend the file reader into a full ARFF reader
  // some day. For now it is .csv with no commas allowed in strings.
  // "NorthLookout.png" is 1920 X 1080 (1080p), try to keep that aspect
  // ratio to avoid distortion (better: make a better map image that
  // fits the eventual display, although this is good for now), with
  StartIndex = attrNameToIndex.get("Start").intValue();  // datetime
  DurationIndex = attrNameToIndex.get("Duration").intValue(); // numeric
  TOTALIndex = attrNameToIndex.get("TOTAL").intValue(); // numeric
  instanceIndex = 0 ;
  currentInstance = instances.get(instanceIndex);
  framesUntilAdvance = round(fetchFloat(DurationIndex, currentInstance, 60));
  raptor = new Raptor();
  noiseSeed(42);  //add for noise() calls(s) below.
}

void draw() {
  image(NorthLookout, 0, 0, width, height);
  IntervalInitialFlightDemo();
}

// We need to display leftover birds from previous "Interval frame"
// that are approaching the bottom of screen after plotting the
// arriving newcomers behind them in an evenly spaced stream.
// Once we start rotating for flightDir and windDir, we will have
// to buffer those values from the last "Interval frame" as well.

// PARSON 19Apr change variable names to reflect time interval of 0 or 1, where they alternate
int IntervalFrame = 0 ;      // cycles 0,1,0, etc.
int IntervalLastInstanceIndex = -1 ;
float [] IntervalTotal = {-1, -1};
float [] IntervalDurationTotal = {-1, -1};
float [] IntervalDurationRemaining = {-1, -1};
float [][] IntervalPerlinxOffset = { null, null }; // PARSON 23Apr

final float IntervalDurationSlowdown = 1 ; // don't plot too fast
// TO BE REPLACED BY SOMTHING MUCH BETTER!!!

void IntervalInitialFlightDemo() {
  // At start of an observation period, start raptor trace at top
  // of display. During one observation period, stream them along
  // flightDir, clouds along windDir. This function does not do these
  // directions, to be added. See comments below.
  if (IntervalLastInstanceIndex != instanceIndex) {
    IntervalFrame = 1 - IntervalFrame ;
    IntervalTotal[IntervalFrame] = fetchFloat(TOTALIndex, currentInstance, 0);
    IntervalDurationTotal[IntervalFrame]
      = fetchFloat(DurationIndex, currentInstance, 60)
        * IntervalDurationSlowdown ;
    IntervalDurationRemaining[IntervalFrame]
      = IntervalDurationTotal[IntervalFrame] ;
    IntervalLastInstanceIndex = instanceIndex ;
    // println("DEBUG IntervalDurationTotal[IntervalFrame] " + IntervalDurationTotal[IntervalFrame]);
    // 23Apr PARSON add new Perlin noise offsets at start of each observation interval
    float poffset = 100.0 ; // Faith, make this bigger to spread them out.
    IntervalPerlinxOffset[IntervalFrame] = new float [ ceil(IntervalTotal[IntervalFrame]) ];
    for (int i = 0 ; i < IntervalPerlinxOffset[IntervalFrame].length ; i++) {
      IntervalPerlinxOffset[IntervalFrame][i] = noise(i) * poffset*2.0 - poffset ;
      // noise returns 0..1, spread it across -poffset...poffset
    }
  }
  push();  // THIS IS THE OUTER LEVEL push()
  
   // changed opacity on how much Cloud Cover there is that day
   float CloudCover = fetchFloat("CloudCover", currentInstance, -10000);
   //if(CloudCover != 0 && CloudCover < 95){
     noStroke();
     fill(255,CloudCover);
     rect(0,0,1280,720);
   //} else if(CloudCover > 95) {
   // -5 so if it hits 100 the whole thing wont be completely white 
     //fill(255,(CloudCover-5));
   //}
  
  fill(255);      // my silly birds are white dots for contrast
  stroke(255);
  strokeWeight(1);
  
  // from here on, the center point is (0,0)
  translate(NorthLookoutX, NorthLookoutY);
  // PARSON ADD 4/11 Above translate applies before both FlightDIR's rotate and
  // WindDir's rotate, but those rotates are separate, and should each be surrounded
  // by their own respective push()/pop() pairs. Both run under the scope of
  // the above translate(), which should not be pop()d until they are done.
  push();  // PARSON 4/11 START OF FlightDIR push()/pop() pair
  
  flightDir = fetchFloat("FlightDIR", currentInstance, flightDir); // PARSON ADD 4/11
  //only place to call the trig func
  rotate(radians(flightDir+180.0)); // PARSON ADD 4/11, +180 because I drew them opposite way
  float [] path = getDisplayPath(NorthLookoutX, NorthLookoutY, flightDir, true);
  //first half of bird path before observation site
  float pathlenBefore = dist(NorthLookoutX, NorthLookoutY, path[0], path[1]);
  //second half of bird path after observation site
  float pathlenAfter = dist(NorthLookoutX, NorthLookoutY, path[2], path[3]);
  float pathTotal = pathlenBefore + pathlenAfter  ;
  //float windDir = fetchFloat("WindDir", currentInstance, -10000);
  //windDir = windDir - 90;

  // IMPORTANT: to use flightDir, do a nested push(), then rotate per
  // flightDir, then plot the birds, then pop(). Do this under the
  // scope of the above translate so that rotate is around NorthLook.
  // The path will then be *longer* than the vertical height, so use
  // trig to find the vertical length. We can go over that. For now
  // IntervalInitialFlightDemo assume flightDir is North, 0 degrees.
  // Also, after this nested pop, do another push()-pop() pair,
  // in between which move the clouds based on windDir.
  float durationPast = (IntervalDurationTotal[IntervalFrame]
    - IntervalDurationRemaining[IntervalFrame]);
  int birdsToPlot = round(IntervalTotal[IntervalFrame]) ;
  
  //int flightLength = height ;
  //int topLength = NorthLookoutY ;  
  //int pixelsPerBird = (birdsToPlot <= 0) ? 0 : (flightLength/birdsToPlot) ;
  
  // START OF PARSON ADD LENGTH OF ROTATE PATH
  int flightLength = round(pathTotal) ;
  int topLength = round(pathlenBefore);
  int pixelsPerBird = (birdsToPlot <= 0) ? 0 : (flightLength/birdsToPlot) ;
  pushMatrix();  // AFTER any rotation for flightDir, draw down from top.
  translate(0, (-topLength*2)
    + (flightLength*durationPast/IntervalDurationTotal[IntervalFrame]));
  //println("DEBUG NEW birdsToPlot = " + birdsToPlot + " pixelsPerBird = " + pixelsPerBird);
  
  for (int i = 0 ; i < birdsToPlot ; i++) {
    // 23Apr PARSON added perlixix
    int perlinix = i % IntervalPerlinxOffset[IntervalFrame].length ;
    int perlinXoffset = round(IntervalPerlinxOffset[IntervalFrame][perlinix]);
    raptor.display(0+perlinXoffset, i * pixelsPerBird); // PARSON 19Apr use same coordinates as ellipse
    // PARSON 23Apr hide DEBUGGING: ellipse(0+perlinXoffset, i * pixelsPerBird, 10, 10);
  }

  
  // END OF PARSON ADD LENGTH OF ROTATE PATH
  int priorIntervalFrame = 1 - IntervalFrame ;
  if (IntervalTotal[priorIntervalFrame] > 0) {
    // In this case don't make the last observation just disappear! Show them.
    durationPast = (IntervalDurationTotal[priorIntervalFrame]
      - IntervalDurationRemaining[priorIntervalFrame]);
    //flightLength = height ;
    //topLength = NorthLookoutY ;
    birdsToPlot = round(IntervalTotal[priorIntervalFrame]) ;
    pixelsPerBird = (birdsToPlot <= 0) ? 0 : (flightLength/birdsToPlot) ;
    //println("DEBUG OLD birdsToPlot = " + birdsToPlot + " pixelsPerBird = " + pixelsPerBird);
    fill(0); // PARSON 19Apr make departing dots black for debugging
    for (int i = 0 ; i < birdsToPlot ; i++) {
      // 23Apr PARSON added perlixix
      int perlinix = i % IntervalPerlinxOffset[priorIntervalFrame].length ;
      int perlinXoffset = round(IntervalPerlinxOffset[priorIntervalFrame][perlinix]);
      raptor.display(0+perlinXoffset, (i+birdsToPlot) * pixelsPerBird); // PARSON 19Apr use same coordinates as ellipse
      // PARSON 23Apr hide DEBUGGING: ellipse(0+perlinXoffset, (i+birdsToPlot) * pixelsPerBird, 10, 10);
    }
    IntervalDurationRemaining[priorIntervalFrame] -= 1 ;
    
  }
  /*
  println(" DEBUG IntervalTotal = " + IntervalTotal + " birdsToPlot = "
    + birdsToPlot + " pixelsPerBird = " + pixelsPerBird);
  */
  popMatrix();
  pop() ; // // PARSON 4/11 END OF FlightDIR push()/pop() pair
  
  // PARSON to FAITH: I recommend doing a push() here, then rotating by
  // either rotate(radians(WindDir)) or rotate(radians(Windir+180.0)), which ever
  // works, and then drawing clouds DUE north-to-south or south-to-north,
  // i.e., 0 degrees or 180 degrees, and let the rotate take care of direction
  // of travel. Finish it up with a pop(). Also, I think a Celsius thermometer off
  // to the side would be cool; maybe we should have 4? of them to show prior days'
  // temp per csc458 lagged temperatures, since we know that to be important?
  
  //temperature 
  float temp = fetchFloat("Temp", currentInstance, -10000);
  float fahren = (temp * 9/5) + 32;
  
  strokeWeight(15);
  if (temp > 30){
    stroke(255, 0, 0); 
    line(width/2.25, height/3.75, width/2.25, height/2.25); 
  } else if (temp > 19 && temp < 31){
    stroke(255, 102, 0); 
    line(width/2.25, height/3.5, width/2.25, height/2.25); 
  } else if (temp > 9 && temp < 21){
    stroke(255, 255, 153); 
    line(width/2.25, height/3.25, width/2.25, height/2.25); 
  } else if (temp > -1 && temp < 11){
    stroke(230, 255, 255); 
    line(width/2.25, height/3, width/2.25, height/2.25); 
  } else if (temp > -10 && temp < 1){
    stroke(102, 204, 255); 
    line(width/2.25, height/2.75, width/2.25, height/2.25); 
  } else if (temp < -10 ){
    stroke(0, 153, 204); 
    line(width/2.25, height/2.5, width/2.25, height/2.25); 
  } 
  
  //draw the themometer lines + values
  strokeWeight(1);
  stroke(255);
  textSize(15); 
  text("> 30", width/2.17, height/3.80);
  line(width/2.2, height/3.75, width/2.3, height/3.75); 
  text("> 20", width/2.17, height/3.54);
  line(width/2.2, height/3.5, width/2.3, height/3.5);   
  text("> 10", width/2.17,height/3.29);
  line(width/2.2, height/3.25, width/2.3, height/3.25);  
  text("> 0", width/2.17, height/3.04);
  line(width/2.2, height/3, width/2.3, height/3); 
  text("> -10", width/2.17, height/2.80);
  line(width/2.2, height/2.75, width/2.3, height/2.75); 
  text("> -20", width/2.17, height/2.55);
  line(width/2.2, height/2.5, width/2.3, height/2.5); 
  text("< -20", width/2.17, height/2.30);
  
  // calculate C to F
  if (temp == -10000) {
    fahren = 0.0;
  }
  
  float printTemp = fetchFloat("Temp", currentInstance, -10000);
  text("degrees in C : " + ((printTemp> -10000) ? (""+printTemp) : "?") + "  F : " + fahren, width/3, height/2.1);
  
  //wind vane   
  float windDir = fetchFloat("WindDir", currentInstance, -10000);
  push(); //push for winddir wind vane 
  stroke(255);
  strokeWeight(4);
  
  text("N", -width/2.70, -height/2.15);
  text("E", -width/3.25, -height/2.85);
  text("S", -width/2.70, -height/4.1);
  text("W", -width/2.30, -height/2.85);

  if (windDir != -10000 || windDir > 0){  
    translate(-width/2.75, -height/2.75);
    // rotate(radians(-windDir+180.0)); // PARSON 19April I think there is a rotation bug
    // 0 on compass is North, rotation clockwise; Processing rotation also clockwise.
    // So, just rotate by windDir to point red line into the wind.
    rotate(radians(windDir));  // PARSON 19April
    line(0, height/12, 0, 0);        //vertical white line
    line(width/22, 0, -width/22, 0); //horizontal line
    stroke(255, 0, 0); 
    line(0, 0, 0, -height/12);       // vertical red line
  } if (windDir == -10000 || windDir < 0){ 
    //if there is no windDir data, default to N
    translate(-width/2.75, -height/2.75);
    line(0, height/12, 0, 0);        //vertical white line
    line(width/22, 0, -width/22, 0); //horizontal line
    stroke(255); 
    line(0, 0, 0, -height/12);       // vertical red line
  }   
  
  pop(); //pop for winddir wind vane 
  
  pop();  // outer push() for this function
  
  //print bird numbers
  raptorInfo(); 
  
  textSize(20);
  textAlign(LEFT);
  String dtime = fetchDateTime(StartIndex, currentInstance).toString() ;
  dtime = dtime.replace('T', ' ');  // anoying T separator
  
  float printCloudCover = fetchFloat("CloudCover", currentInstance, -10000) ;
  float printWindDir = fetchFloat("WindDir", currentInstance, -10000) ;
  float printFlightDIR = fetchFloat("FlightDIR", currentInstance, -10000) ;
  // PARSON ADD CHANGE -10000 PRINTOUT TO "?"
  text(dtime + ", CloudCover = " + ((printCloudCover > -10000) ? (""+printCloudCover) : "?")
    + ", WindDir = " + ((printWindDir > -10000) ? (""+printWindDir) : "?")
    + ", FlightDIR = " + ((printFlightDIR > -10000) ? (""+printFlightDIR) : "?"), 32, height-64) ;
    
  //bird image key
  image(hawk, 10, height-35);
  text("hawk", 55, height-20);
  image(eagle, 115, height-35);
  text("eagle", 165, height-20);
  image(accipiter, 225, height-35);
  text("accipiter", 275, height-20);
  image(falcon, 365, height-35);
  text("falcon", 405, height-20);
  image(vulture, 475, height-35);
  text("vulture", 525, height-20);
  image(unid, 600, height-35);
  text("unidentified raptor",650, height-20);
  
  IntervalDurationRemaining[IntervalFrame] -= 1 ;
  if (IntervalDurationRemaining[IntervalFrame] <= 0) {
    instanceIndex = (instanceIndex + 1) % instances.size();
    currentInstance = instances.get(instanceIndex);
  }
}

void raptorInfo(){
  
  float hawkNum;
  float eagleNum;
  float vulNum;
  float falNum;
  float accNum;
 
   hawkNum = fetchFloat("SS", currentInstance, -10000) + fetchFloat("CH", currentInstance, -10000) +
             fetchFloat("BW", currentInstance, -10000) +  fetchFloat("RS", currentInstance, -10000) +
             fetchFloat("NH", currentInstance, -10000) + fetchFloat("SW", currentInstance, -10000) +
             fetchFloat("UB", currentInstance, -10000) + fetchFloat("RT", currentInstance, -10000) +
             fetchFloat("RL", currentInstance, -10000) + fetchFloat("OS", currentInstance, -10000);
             
   eagleNum = fetchFloat("GE", currentInstance, -10000) + fetchFloat("BE", currentInstance, -10000) +
              fetchFloat("UE", currentInstance, -10000);
              
   falNum = fetchFloat("ML", currentInstance, -10000) + fetchFloat("UF", currentInstance, -10000) + 
            fetchFloat("PG", currentInstance, -10000) + fetchFloat("AK", currentInstance, -10000);
                     
   accNum = fetchFloat("MK", currentInstance, -10000) + fetchFloat("UA", currentInstance, -10000) + 
            fetchFloat("NG", currentInstance, -10000);
            
   vulNum = fetchFloat("BV", currentInstance, -10000) + fetchFloat("UV", currentInstance, -10000) +
           fetchFloat("TV", currentInstance, -10000);

       textSize(18);
       text("Hawks: " +  hawkNum, 32, height-250);
       text("Eagles: " +  eagleNum, 32, height-225);
       text("Falcons: " +  falNum, 32, height-200);
       text("Vultures: " + vulNum, 32, height-175);
       text("Accipiters: " +  accNum, 32, height-150);
       text("Unidentified: " + fetchFloat("UR", currentInstance, -10000), 32, height-125);
       text("TOTAL: " + fetchFloat("TOTAL", currentInstance, -10000), 32, height-100);
               
}

void keyPressed() {
  if (key == 'S') {
    // skip ahead to a non-0 TOTAL.
    while (fetchFloat(TOTALIndex, currentInstance, 0) == 0) {
      instanceIndex = (instanceIndex + 1) % instances.size();
      currentInstance = instances.get(instanceIndex);
    }
    framesUntilAdvance = round(fetchFloat(DurationIndex, currentInstance, 60));
  }
   if (key == 'F') {
    // skip ahead to a flash mob on 9/10/17
    while (fetchFloat(TOTALIndex, currentInstance, 0) < 150) {
      instanceIndex = (instanceIndex + 1) % instances.size();
      currentInstance = instances.get(instanceIndex);
    }
    framesUntilAdvance = round(fetchFloat(DurationIndex, currentInstance, 60));
  }
  
  
}
