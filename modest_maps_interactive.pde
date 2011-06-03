
//
// This is a test of the interactive Modest Maps library for Processing
// the modestmaps.jar in the code folder of this sketch might not be 
// entirely up to date - you have been warned!
//

// this is the only bit that's needed to show a map:
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
ArrayList trackpointstemp;
ArrayList amountbubbles;
boolean showgui = true; //showing all the buttons/points/tracks
boolean showmap = true; //show map
boolean tracking = false; //true: Malte Spitz moving

void setup() {
  size(800, 600);
  smooth();
  //frameRate(20);
  
  amountbubbles = new ArrayList(); //create empty ArrayList

  //load the csv-file with Malte Spitz' location data
  trackdata = loadStrings("ex_data.csv");
  trackpoints = new ArrayList(); //create empty ArrayList
  for (int i = 0; i < trackdata.length; i++) {
    String[] pieces = split(trackdata[i], ";"); //load each location into array
    //time | service | latitude | longitude
    trackpoints.add(new Trackpoint (pieces));
  }

  // create a new map, optionally specify a provider
  map = new InteractiveMap(this, new OpenStreetMapProvider());
  // TODO: maybe change the appearance of OpenStreetMap to something less distractive
  // Microsoft.RoadProvider
  // others would be "new Microsoft.HybridProvider()" or "new Microsoft.AerialProvider()"
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

//Class for storing time, service and location of Malte Spitz
class Trackpoint {
  GregorianCalendar time;
  String service;
  Location location;

  //time | service | latitude | longitude
  public Trackpoint(String[] pieces) {
    //8/31/09 8:09
    String[] datetime = split(pieces[0], " "); //datetime[0]=8/31/09 datetime[1]=8:09
    String[] date = split(datetime[0], "/"); //date[0]=8 date[1]=31
    String[] hoursminutes = split(datetime[1], ":"); //hoursminutes[0]=8 [1]=09

    // new GregorianCalendar(YEAR, MONTH, DAY, HOUR, MINUTE)
    this.time = new GregorianCalendar(int(date[2])+2000, int(date[0])-1, int(date[1]), int(hoursminutes[0]), int(hoursminutes[1]));
    this.service = pieces[1];
    this.location = new Location(float(pieces[2]), float(pieces[3]));
  }
}


//everything that should be drawn comes in here
void draw() {
  background(0);

  if (showmap) {
    // draw the map:
    map.draw();
  }

  smooth();
  
  // draw all the buttons and check for mouse-over
  boolean hand = false;
  if (showgui) {
    for (int i = 0; i < buttons.length; i++) {
      buttons[i].draw();
      hand = hand || buttons[i].mouseOver();
    }
  }

  // if we're over a button, use the finger pointer
  // otherwise use the cross
  // (I wish Java had the open/closed hand for "move" cursors)
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

    // grab the lat/lon location under the mouse point:
    Location location = map.pointLocation(mouseX, mouseY);

    // draw the mouse location, bottom left:
    fill(0);
    noStroke();
    rect(5, height-5-g.textSize, textWidth("mouse: " + location), g.textSize+textDescent());
    fill(255,255,0);
    textAlign(LEFT, BOTTOM);
    text("mouse: " + location, 5, height-5);

    // grab the center
    location = map.pointLocation(width/2, height/2);

    fill(0);
    noStroke();
    float rw = textWidth("map: " + location);
    rect(width-5-rw, height-5-g.textSize, rw, g.textSize+textDescent());
    fill(255,255,0);
    textAlign(RIGHT, BOTTOM);
    //show number trackpoints in trackpoints[]
    text("# trackpoints: " + str(trackpoints.size()), width-5, height-5);

    //draw point at a location.
    /* Location location2 = new Location(52.52944444, 13.39611111);
     Point2f punkt = map.locationPoint(location2);
     fill(0,255,255);
     stroke(255,255,0);
     ellipse(punkt.x, punkt.y, 10, 10);*/


    //Iterate through the trackpoints and show them on the map
    //problem: showing all point (more than 17000 in total) slows zooming down extremely)

    
//
//    for (int i = 0; i <= trackpoints.size()-1; i++) { 
//       // An ArrayList doesn't know what it is storing so we have 
//       // to cast the object coming out
//       Trackpoint trackpoint = (Trackpoint) trackpoints.get(i);
//       Point2f punkt = map.locationPoint(trackpoint.location);
//       fill(0,255,255);
//       stroke(255,255,0);
//       
//       Amountbubble amountbubble = new Amountbubble(round(punkt.x*1000)/1000, round(punkt.y*1000)/1000);
//       //ellipse(punkt.x, punkt.y, 8, 8);
//       //amountbubble.draw();
//       
//       if(amountbubbles.size() == 0) {
//           amountbubbles.add(amountbubble);
//       }
//       
//       for (int j = 0; j < amountbubbles.size(); j++) {
//         Amountbubble bubbletemp = (Amountbubble) amountbubbles.get(j);
//         if(bubbletemp.x == amountbubble.x && bubbletemp.y == amountbubble.y) {
//           bubbletemp.increaseSize();
//         }
//         else {
//           amountbubbles.add(amountbubble);
//         }
//       }
//       
//    }


    //zuerst zeichnen, aus array löschen, beim nächsten schauen ob in der nähe von einem bestehenden
  
    //TODO: Zeiteingabe von wann bis wann er durchlaufen soll





  //TODO: copy Arraylist - here i point to the same object:
  trackpointstemp = trackpoints;

  if (tracking) {
    //show and connect five points in order of appearance
    //for (int i = 0; i <= trackpointstemp.size()-1; i++) {  
    int i = 0;
    Trackpoint trackpoint1 = (Trackpoint) trackpointstemp.get(i);
    Trackpoint trackpoint2 = (Trackpoint) trackpointstemp.get(i+1);
    Trackpoint trackpoint3 = (Trackpoint) trackpointstemp.get(i+2);
    Trackpoint trackpoint4 = (Trackpoint) trackpointstemp.get(i+3);
    Trackpoint trackpoint5 = (Trackpoint) trackpointstemp.get(i+4);

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
    stroke(102,102,102, 90);
    line(punkt1.x, punkt1.y, punkt2.x, punkt2.y);
    line(punkt2.x, punkt2.y, punkt3.x, punkt3.y);
    line(punkt3.x, punkt3.y, punkt4.x, punkt4.y);
    line(punkt4.x, punkt4.y, punkt5.x, punkt5.y);


    fill(0,0,0);
    text(trackpoint1.time.getTime().getDate() + " " + trackpoint1.location, punkt1.x - 4, punkt1.y + 5);
    trackpointstemp.remove(0);
  }
}  

//Printing the current mouse position to stdout
//println((float)map.sc);
//println((float)map.tx + " " + (float)map.ty);

}

void keyReleased() {
  //g for switching between map and map with controls and points
  if (key == 'g' || key == 'G') {
    showgui = !showgui;
  }
  else if (key == 's' || key == 'S') {
    save("screenshot.png");
  }
  else if (key == 'z' || key == 'Z') {
    map.sc = pow(2, map.getZoom());
  }
  else if (key == ' ') {
    map.sc = 2.0;
    map.tx = -128;
    map.ty = -128;
  }
  else if (key == 'm') {
    showmap = !showmap;
  }
  else if (key == '+') {
    //faster speed
  }
  else if (key == '-') {
    //slower speed
  }
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

