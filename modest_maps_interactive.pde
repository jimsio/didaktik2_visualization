/*
 
 ## Visualisierung der Handydaten von Malte Spitz ##
 
 Interaktionen:
 
 
 Pfeiltasten zum Bewegen der Karte
 +/-/Mausrad - Ein/Auszoomen
 M - Karte ein/ausschalten
 G - Menüs ein/ausschalten
 P/O - schnellerer/langsamerer Durchlauf
 S - Screenshot speichern
 
 */


/*
 2 Modi: (schnelldurchlauf, playbutton + live-durchlauf)
 amountbubble-anzeige-modi (heatmap, normal, mit highlight, mit tortendiagramm)
 
 
 Häufigkeit an einem frei gewählten Punkt - z.B. Reichstag (mit Angabe von Radius um diesen Punkt)
 
 Telefon zeichnen, wenn Telefoniert wurde - 01001 bei Daten, Brief bei SMS
 
 
 Framework - Cheatsheet
 + Kartendarstellung auswählbar
 
 + Kuchendiagramm für die Services
 + Farben, Formen auswählen
 
 */


// Landkarte
InteractiveMap map;

// Bühnengröße einstellen
int stageWidth = 800;
int stageHeight = 600;

// buttons take x,y and width,height:
ZoomButton out = new ZoomButton(5, 5, 14, 14, false);
ZoomButton in = new ZoomButton(22, 5, 14, 14, true);
PanButton up = new PanButton(14, 25, 14, 14, UP);
PanButton down = new PanButton(14, 57, 14, 14, DOWN);
PanButton left = new PanButton(5, 41, 14, 14, LEFT);
PanButton right = new PanButton(22, 41, 14, 14, RIGHT);
PlayButton play = new PlayButton(stageWidth, stageHeight);

// Steuerungsbuttons
Button[] buttons = { 
  in, out, up, down, left, right, play
};

PFont font;
String[] trackdata;
ArrayList trackpoints;
ArrayList amountbubbles;
boolean showgui = true; // true: Zeigt die Bedienoberfläche an
boolean showmap = true; // true: Zeigt die Karte an
boolean increaseBubbles = true; // true: Bubbles werden vergrößert
boolean tracking = false; // true: Malte Spitz bewegt sich
int trackpointsCounter = 0;
SimpleDateFormat dateformat = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");
Date startoffset = new Date();
Date endoffset = new Date();
int speed = 20;

// 1 = Datumsfilter
// 2 = Stundenfilter
// 3 = kein Filter
int filterSwitch = 1;

// 1- Datumsfilter - Zeitspanne von-bis
String beginnDate = "01.12.2009 04:05:06";
String endDate = "28.01.2010 00:00:00";

// 2- Stundenfilter - Stundengrenzen von-bis 
int beginnHour = 23;
int endHour = 2;







/* ################ */
/*       Setup      */
/* ################ */


void setup() {
  size(stageWidth, stageHeight);
  smooth();

  amountbubbles = new ArrayList(); //create empty ArrayList

    try {
    startoffset = dateformat.parse(beginnDate);
    endoffset = dateformat.parse(endDate);
  }
  catch(ParseException e) {
  }

  //load the csv-file with Malte Spitz' location data
  trackdata = loadStrings("ex_data.csv");
  trackpoints = new ArrayList(); //create empty ArrayList
  for (int i = 0; i < trackdata.length; i++) {
    String[] pieces = split(trackdata[i], ";"); //load each location into array
    //time | service | latitude | longitude
    Trackpoint t = new Trackpoint (pieces);
    switch(filterSwitch) {
    case 1: 
      if (t.time.after(startoffset) && t.time.before(endoffset)) {
        trackpoints.add(t);
      }
      break;
    case 2:
      if (beginnHour > endHour) {
        if (t.time.getHours() >= beginnHour || t.time.getHours() < endHour) {
          trackpoints.add(t);
        }
      }
      else {
        if (t.time.getHours() >= beginnHour && t.time.getHours() < endHour) {
          trackpoints.add(t);
        }
      }
      break;

    case 3:
      trackpoints.add(t);
      break;
    }
  }

  // Karte erzeugen und Darstellungsart/Anbieter auswählen
  map = new InteractiveMap(this, new Microsoft.RoadProvider());
  //map = new InteractiveMap(this, new OpenStreetMapProvider());
  //map = new InteractiveMap(this, new Microsoft.HybridProvider());
  //map = new InteractiveMap(this, new Microsoft.AerialProvider());

  // Startposition auf Berlin setzten (latitude/longitude), zoomlevel
  map.setCenterZoom(new Location(52.497832, 13.412933), 11);
  // zoomlevel 0 ist die ganze Welt, 19 ist Straßenniveau
  // Koordinaten für Berlin gefunden unter: www.getlatlon.com

  // Standardschriftart und Größe
  font = createFont("Helvetica", 12);

  // Mausrad für Zoomen aktivieren
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


// Klasse um die Handydaten von Malte Spitz zu speichern
class Trackpoint {
  Date time;
  String service;
  Location location;

  //time | service | latitude | longitude
  public Trackpoint(String[] pieces) {
    //8/31/09 8:09
    SimpleDateFormat track_format = new SimpleDateFormat("MM/dd/yy HH:mm");

    try {
      this.time = track_format.parse(pieces[0]);
    }
    catch(ParseException e) {
    }
    this.service = pieces[1];
    this.location = new Location(float(pieces[2]), float(pieces[3]));
  }
}


/* ################ */
/*      Drawing     */
/* ################ */


void draw() {

  //println("Geschwindigkeit: " +speed + "Framerate" + frameRate);

  // Geschwindigkeit des Durchlaufs
  frameRate(speed);

  // Hintergrundfarbe
  background(230);

  // Karte anzeigen/verbergen
  if (showmap) {
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
  fill(102, 102, 102, 80);
  noStroke();

  ellipse(punkt1.x, punkt1.y, 15, 15);
  ellipse(punkt2.x, punkt2.y, 10, 10);
  ellipse(punkt3.x, punkt3.y, 10, 10);
  ellipse(punkt4.x, punkt4.y, 10, 10);
  ellipse(punkt5.x, punkt5.y, 10, 10);


  strokeWeight(2);
  stroke(102, 102, 102, 80);
  line(punkt1.x, punkt1.y, punkt2.x, punkt2.y);
  line(punkt2.x, punkt2.y, punkt3.x, punkt3.y);
  line(punkt3.x, punkt3.y, punkt4.x, punkt4.y);
  line(punkt4.x, punkt4.y, punkt5.x, punkt5.y);


  
  // Text neben dem sich bewegenden Trackpoint
  
  //fill(0, 0, 0);
  //text(trackpoint1.time.getHours()+ "", punkt1.x - 4, punkt1.y + 5);
  //text(dateformat.format(trackpoint1.time.getTime()) +" "+trackpoint1.location, punkt1.x - 4, punkt1.y + 5);

  boolean found = false;

  if (increaseBubbles) {
    for (int j = 0; j < amountbubbles.size(); j++) {
      Amountbubble bubbletemp = (Amountbubble) amountbubbles.get(j);
      if (bubbletemp.equalsOther(trackpoint1.location)) {
        bubbletemp.increaseSize();
        if (trackpoint1.service.contains("Telefonie")) {
          bubbletemp.increaseCallCounter();
        }
        else if (trackpoint1.service.contains("GPRS")) {
          bubbletemp.increaseGprsCounter();
        }
        else if (trackpoint1.service.contains("SMS")) {
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
  }
  for (int i = 0; i < amountbubbles.size(); i++) {
    Amountbubble bubbletemp = (Amountbubble) amountbubbles.get(i);
    bubbletemp.draw(map, bubbletemp.equalsOther(trackpoint1.location));
  }

  // Trackpointzähler erhöhen bis alle Trackpoints angezeigt wurden
  if (trackpointsCounter < trackpoints.size()-5 && tracking) {
    trackpointsCounter++;
    increaseBubbles = true;
  }
  else {
    increaseBubbles = false;
  }

  // show buttons and gui-bar
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
    text("Koordinaten " + location, 3, height-3);

    // draw date of current trackoint, bottom center
    fill(129, 80, 80);
    textAlign(CENTER, BOTTOM);
    text(dateformat.format(trackpoint1.time.getTime()) +"", width/2, height-3);

    // show number trackpoints in trackpoints[], bottom right
    fill(50);
    textAlign(RIGHT, BOTTOM);
    text("Trackpointzähler " + trackpointsCounter, width-3, height-3);

    // grab the center
    /*location = map.pointLocation(width/2, height/2);*/
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
  // Drücke "S" um einen Screenshot im Ordner "modest_maps_interactive" zu speichern
  else if (key == 's' || key == 'S') {
    save("screenshot_"+timestamp()+".jpg");
  }
  else if (key == 'm') {
    showmap = !showmap;
  }
  //"P" und "O" um Trackpoints schneller oder langsamer zu durchlaufen
  else if (key == 'p') {
    if (speed < 100) {
      speed += 10;
    }
  }
  else if (key == 'o') {
    if (speed > 10) {
      speed -= 10;
    }
  }
  // noch nicht fertig!!
  else if (key == 'b') {
    Location currentMouseLocation = map.pointLocation(mouseX, mouseY);
    LocationBubble reichstag = new LocationBubble(currentMouseLocation, "cell_phone.svg");
    reichstag.draw(map, false);
  }
  /*else if (key == 'z' || key == 'Z') {
   map.sc = pow(2, map.getZoom());
   }
   else if (key == ' ') {
   map.sc = 2.0;
   map.tx = -128;
   map.ty = -128;
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

// Mausrad für Ein- und Auszoomen
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
  else if (play.mouseOver()) {
    tracking = !tracking;
  }
}


/* #################################### */
/*     Additional Userful Functions     */
/* #################################### */

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

