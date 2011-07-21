
//
// This is a test of the interactive Modest Maps library for Processing
// the modestmaps.jar in the code folder of this sketch might not be 
// entirely up to date - you have been warned!
//


/*
 TODO: am schluss wird der ball immer größer!!!
 2 Modi: (schnelldurchlauf, playbutton + live-durchlauf)
 modi 2): durch tastendruck geschwindigkeit (framerate) änderbar
 amountbubble-anzeige-modi (normal, mit highlight, mit tortendiagramm
 
 
 Framework - Cheatsheet
 + Kartendarstellung auswählbar
*/


// the map
InteractiveMap map;

// buttons take x,y and width,height:
ZoomButton out = new ZoomButton(5,5,14,14,false);
ZoomButton in = new ZoomButton(22,5,14,14,true);
PanButton up = new PanButton(14,25,14,14,UP);
PanButton down = new PanButton(14,57,14,14,DOWN);
PanButton left = new PanButton(5,41,14,14,LEFT);
PanButton right = new PanButton(22,41,14,14,RIGHT);

// all the buttons in one place, for looping:
Button[] buttons = { 
  in, out, up, down, left, right
};

PFont font;
String[] trackdata;
ArrayList trackpoints;
ArrayList amountbubbles;
boolean showgui = true; //showing all the buttons/points/tracks
boolean showmap = true; //show map
boolean tracking = true; //true: Malte Spitz moving
int trackpointsCounter = 0;
SimpleDateFormat dateformat = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");
int speed = 50;

//Date startoffset;
//Date endoffset;


/* ################ */
/*       Setup      */
/* ################ */


void setup() {
  size(800, 600);
  smooth();
  frameRate(speed);

  amountbubbles = new ArrayList(); //create empty ArrayList
  //startoffset = new Date();
  
  //load the csv-file with Malte Spitz' location data
  trackdata = loadStrings("ex_data.csv");
  trackpoints = new ArrayList(); //create empty ArrayList
  for (int i = 0; i < trackdata.length; i++) {
    String[] pieces = split(trackdata[i], ";"); //load each location into array
    //time | service | latitude | longitude
    Trackpoint t = new Trackpoint (pieces);
    //if(t.time.getTime() < startoffset) {
      trackpoints.add(t);
    //}
  }

  // create a new map, optionally specify a provider
  //map = new InteractiveMap(this, new OpenStreetMapProvider());
  map = new InteractiveMap(this, new Microsoft.RoadProvider()); //OpenStreetMapProvider());
  // TODO: maybe change the appearance of OpenStreetMap to something less distractive
  // others would be "new Microsoft.RoadProvider" or "new Microsoft.HybridProvider()" or "new Microsoft.AerialProvider()"
  // the Google ones get blocked after a few hundred tiles
  // the Yahoo ones look terrible because they're not 256px squares :)

  // set the initial location and zoom level to Berlin (latitude/longitude), zoomlevel
  map.setCenterZoom(new Location(52.497832, 13.412933), 11);
  // zoom 0 is the whole world, 19 is street level
  // (try some out, or use getlatlon.com to search for more)

  // set a default font for label
  font = createFont("Helvetica", 12);

  // enable the mouse wheel, for zooming
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
    }
  }
  );
}


/* ################ */
/*      Classes     */
/* ################ */


//Class for storing time, service and location of Malte Spitz
class Trackpoint {
  Date time;
  String service;
  Location location;

  //time | service | latitude | longitude
  public Trackpoint(String[] pieces) {
    //8/31/09 8:09
    String[] datetime = split(pieces[0], " "); //datetime[0]=8/31/09 datetime[1]=8:09
    String[] date = split(datetime[0], "/"); //date[0]=8 date[1]=31
    String[] hoursminutes = split(datetime[1], ":"); //hoursminutes[0]=8 [1]=09

    // new Date(YEAR, MONTH, DAY, HOUR, MINUTE)
    this.time = new Date(int(date[2])+2000, int(date[0])-1, int(date[1]), int(hoursminutes[0]), int(hoursminutes[1]));
    this.service = pieces[1];
    this.location = new Location(float(pieces[2]), float(pieces[3]));
  }
}


/* ################ */
/*      Drawing     */
/* ################ */


void draw() {
  background(230);

  if (showmap) {
    // draw the map:
    map.draw();
  }


  // draw all the buttons and check for mouse-over
  boolean hand = false;
  if (showgui) {
    for (int i = 0; i < buttons.length; i++) {
      buttons[i].draw();
      hand = hand || buttons[i].mouseOver();
    }
  }

  // when pointer over button, use the finger pointer
  // otherwise use the cross
  cursor(hand ? HAND : CROSS);

  // see if the arrow keys or +/- keys are pressed:
  // (also check space and z, to reset or round zoom levels)
  if (keyPressed) {
    if (key == CODED) {
      if (keyCode == LEFT) {
        map.tx += 5.0/map.sc;
      }
      else if (keyCode == RIGHT) {
        map.tx -= 5.0/map.sc;
      }
      else if (keyCode == UP) {
        map.ty += 5.0/map.sc;
      }
      else if (keyCode == DOWN) {
        map.ty -= 5.0/map.sc;
      }
    }  
    else if (key == '+' || key == '=') {
      map.sc *= 1.05;
    }
    else if (key == '_' || key == '-' && map.sc > 2) {
      map.sc *= 1.0/1.05;
    }
  }

  if (showgui) {
    textFont(font, 12);

    fill(200);
    noStroke();
    rect(0, height-g.textSize-8, width, g.textSize+8);
        
    stroke(150);
    strokeWeight(1);
    line(0, height-g.textSize-8, width, height-g.textSize-8) ;

    // grab the lat/lon location under the mouse point:
    Location location = map.pointLocation(mouseX, mouseY);

    // draw the mouse location, bottom left:    
    fill(50);
    textAlign(LEFT, BOTTOM);
    text("mouse: " + location, 3, height-3);
    
    // grab the center
    location = map.pointLocation(width/2, height/2);

    fill(50);
    textAlign(RIGHT, BOTTOM);
    //show number trackpoints in trackpoints[]
    text("# trackpointcounter: " + trackpointsCounter, width-3, height-3);
  }

  if (tracking) {
    //show and connect five points in order of appearance
    Trackpoint trackpoint1 = (Trackpoint) trackpoints.get(trackpointsCounter);
    Trackpoint trackpoint2 = (Trackpoint) trackpoints.get(trackpointsCounter+1);
    Trackpoint trackpoint3 = (Trackpoint) trackpoints.get(trackpointsCounter+2);
    Trackpoint trackpoint4 = (Trackpoint) trackpoints.get(trackpointsCounter+3);
    Trackpoint trackpoint5 = (Trackpoint) trackpoints.get(trackpointsCounter+4);

    Point2f punkt1 = map.locationPoint(trackpoint1.location);
    Point2f punkt2 = map.locationPoint(trackpoint2.location);
    Point2f punkt3 = map.locationPoint(trackpoint3.location);
    Point2f punkt4 = map.locationPoint(trackpoint4.location);
    Point2f punkt5 = map.locationPoint(trackpoint5.location);

    //fill (R, G, B, alpha)
    fill(102,102,102, 80);
    noStroke();

    ellipse(punkt1.x, punkt1.y, 15, 15);
    ellipse(punkt2.x, punkt2.y, 10, 10);
    ellipse(punkt3.x, punkt3.y, 10, 10);
    ellipse(punkt4.x, punkt4.y, 10, 10);
    ellipse(punkt5.x, punkt5.y, 10, 10);


    strokeWeight(2);
    stroke(102,102,102, 80);
    line(punkt1.x, punkt1.y, punkt2.x, punkt2.y);
    line(punkt2.x, punkt2.y, punkt3.x, punkt3.y);
    line(punkt3.x, punkt3.y, punkt4.x, punkt4.y);
    line(punkt4.x, punkt4.y, punkt5.x, punkt5.y);


    fill(0,0,0);
    // text shown next to trackpoint
    //text(trackpoint1.time.getTime().getDate()  + " " + trackpoint1.location, punkt1.x - 4, punkt1.y + 5);
    text(dateformat.format(trackpoint1.time.getTime()) +"", punkt1.x - 4, punkt1.y + 5);

    boolean found = false;

    for (int j = 0; j < amountbubbles.size(); j++) {
      Amountbubble bubbletemp = (Amountbubble) amountbubbles.get(j);
      if(bubbletemp.equalsOther(trackpoint1.location)) {
        bubbletemp.increaseSize();
        if(trackpoint1.service.contains("Telefonie")) {
          bubbletemp.increaseCallCounter();
        }
        else if(trackpoint1.service.contains("GPRS")) {
          bubbletemp.increaseGprsCounter();
        }
        else if(trackpoint1.service.contains("SMS")) {
          bubbletemp.increaseSmsCounter();
        }        
        found = true;
        break;
      }
    }

    if (!found) {
      Amountbubble amountbubble = new Amountbubble(trackpoint1.location);
      amountbubbles.add(amountbubble);
    }

    for(int i = 0; i < amountbubbles.size(); i++) {
      Amountbubble bubbletemp = (Amountbubble) amountbubbles.get(i);
      bubbletemp.draw(map, bubbletemp.equalsOther(trackpoint1.location));
    }
  }
  // 
  if (trackpointsCounter < trackpoints.size()-5) {
    trackpointsCounter++;
  }
}


/* ################ */
/*     Controls     */
/* ################ */


//Printing the current mouse position to stdout
//println((float)map.sc);
//println((float)map.tx + " " + (float)map.ty);

void keyReleased() {
  //g for showing/unshowing controls and points
  if (key == 'g' || key == 'G') {
    showgui = !showgui;
  }
  // Drücke "S" um einen Screenshot zu speichern
  else if (key == 's' || key == 'S') {
    save("screenshot_"+timestamp()+".jpg");
  }
  /*else if (key == 'z' || key == 'Z') {
    map.sc = pow(2, map.getZoom());
  }
  else if (key == ' ') {
    map.sc = 2.0;
    map.tx = -128;
    map.ty = -128;
  }*/
  else if (key == 'm') {
    showmap = !showmap;
  }
  /*else if (key == '+') {
    //faster speed
  }
  else if (key == '-') {
    //slower speed
  }*/
}


// see if we're over any buttons, otherwise tell the map to drag
void mouseDragged() {
  boolean hand = false;
  if (showgui) {
    for (int i = 0; i < buttons.length; i++) {
      hand = hand || buttons[i].mouseOver();
      if (hand) break;
    }
  }
  if (!hand) {
    map.mouseDragged();
  }
}

// zoom in or out:
void mouseWheel(int delta) {
  if (delta > 0) {
    map.sc *= 1.0/1.05;
  }
  else if (delta < 0) {
    map.sc *= 1.05;
  }
}

// see if we're over any buttons, and respond accordingly:
void mouseClicked() {
  if (in.mouseOver()) {
    map.zoomIn();
  }
  else if (out.mouseOver()) {
    map.zoomOut();
  }
  else if (up.mouseOver()) {
    map.panUp();
  }
  else if (down.mouseOver()) {
    map.panDown();
  }
  else if (left.mouseOver()) {
    map.panLeft();
  }
  else if (right.mouseOver()) {
    map.panRight();
  }
}


/* #################################### */
/*     Additional Userful Functions     */
/* #################################### */

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
