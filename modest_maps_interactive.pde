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
ab 10. Klassenstufe (15/16-Jährige)
Di. - 10 bis 14 plus 2h

 Einführung:
 
 Phase 4 - Sandra
 Andere Handy/Positionsdaten Visualisierungen untersuchen (Welche Daten gibt es hier, wie werden sie angezeigt
 Welche Daten + Wie Visualisiert
 http://crowdflow.net/blog/2011/07/12/fireflies-hd/
 http://vimeo.com/14009407
 http://www.zeit.de/datenschutz/malte-spitz-vorratsdaten
 
 
 
 Framework - Cheatsheet
 ++ Oberfläche-GUI
 + Playbutton zum Starten
 ++ Code
 + Kartendarstellung auswählbar
 + Amountbubble-Anzeige-modi (heatmap, normal, mit highlight, mit tortendiagramm)
 + Datum-, Stundenfilter
 + 
 
 Sandra
 + Positionsdaten wichtig zu erwähnen woher diese kommen.
 
 Fragestelllungen herausarbeiten (3 Fragen - wie diese Fragen bekommen von Schülern)
 + Was ist in dieser Zeit passiert und was hat Malte zu dieser Zeit gemacht?
 + Ein Stalker versucht Malte Spitz abzupassen. Wo wäre eine günstige Gelegenheit? (Zeitpunkt x)
 + Die Ex will wissen wo er schläft oder ob er sich im Rotlichtmileu aufhält.
 + Fliegt er häufig (Umweltschutz)
 + Ein Mobilfunkanbieter will ein Profil seines Telefonverhaltens aufstellen: Wieviele SMS verschickt er? Wieviele Telefonate führt er? Wie lange gehen die Telefonate?
 + Ehemaliges Ost- oder Westberlin
 + Firma, wo geht er oft vorbei, sodass ich dort mein Restaurant eröffnen kann (bei sehr vielen ~5000 Datensätzen interessant)

 Antworten in den Visualisierungen finden
 Wenn sie eine Antwort finden haben sie gezeigt, dass aus den Daten Informationen werden können
 
 
 creative flow!!! wenn sie in den cf reinkommen, würden sie selbstständig weiterarbeiten (auch ohne extrinsische motivation)
 
 
 ++ Beobachtung der Unterrichtsdurchführung
 SuS
 + Was haben die SuS aus den vorhergehenden Einheiten
 + Motivation der SuS
 + Vorwissen der SuS
 Lehrer
 + Funktioniert das so wie wir uns das gedacht haben?
 + Wie werden Medien eingesetzt?
 + Zeitliche Planung
 + Fachliche Kompetenz (geht er auf die Fragen der SuS ein? Kennt er sich aus?)
 
 Unsere Ziele - wurden sie erfüllt
 + Unterschied zw. Informationen und Daten verstanden
 Verbindung mit anderen Services (z.B. Twitter, Facebook, Blog,..) lässt sich ein umfassendes Personenprofil erstellen
 
 */


// 1 = Datumsfilter
// 2 = Stundenfilter
// 3 = kein Filter
int filterSwitch = 2;

// Datumsfilter - Zeitspanne von-bis
String beginnDate = "01.01.2010 04:05:06";
String endDate = "28.01.2010 00:00:00";

// Stundenfilter - Stundengrenzen von-bis 
int beginnHour = 8;
int endHour = 9;



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
Trackpoint trackpoint1;
String[] trackdata;
ArrayList trackpoints;
ArrayList amountbubbles;
boolean showgui = true; // true: Zeigt die Buttons und das Menü an
boolean showmap = true; // true: Zeigt die Karte an
boolean increaseBubbles = true; // true: Bubbles werden vergrößert
boolean playing = false; // true: Malte Spitz bewegt sich
int trackpointsCounter = 0; // Zeigt die Trackpoints an
SimpleDateFormat dateformat = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss"); // Zur Anzeige von Datum
Date startoffset = new Date();
Date endoffset = new Date();
int speed = 20;






/* ################ */
/*       Setup      */
/* ################ */


void setup() {
  //Größe der Bühne setzen
  size(stageWidth, stageHeight);

  // Karte erzeugen und Darstellungsart/Anbieter auswählen
  map = new InteractiveMap(this, new Microsoft.RoadProvider());
  //map = new InteractiveMap(this, new OpenStreetMapProvider());
  //map = new InteractiveMap(this, new Microsoft.HybridProvider());
  //map = new InteractiveMap(this, new Microsoft.AerialProvider());


  // Geglättete Darstellung
  smooth();

  // ArrayList um Amountbubbles zu speichern
  amountbubbles = new ArrayList(); 

  try {
    startoffset = dateformat.parse(beginnDate);
    endoffset = dateformat.parse(endDate);
  }
  catch(ParseException e) {
  }

  // CSV-Datei mit Vorratsdaten von Malte Spitz laden
  trackdata = loadStrings("ex_data.csv");
  trackpoints = new ArrayList();
  for (int i = 0; i < trackdata.length; i++) {
    String[] pieces = split(trackdata[i], ";"); // jede Zeile in Array laden
    
    //time | service | latitude | longitude
    // neuen Trackpoint erzeugen
    Trackpoint t = new Trackpoint (pieces);
    
    // Auswahl welcher Filter aktiviert ist
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
/*      Zeichnen     */
/* ################ */

/* Alles was gezeichnet werden soll kommt hier */


void draw() {

  // Geschwindigkeit des Durchlaufs
  frameRate(speed);

  // Hintergrundfarbe
  background(230);

  // Karte anzeigen/verbergen
  if (showmap) {
    map.draw();
  }

  // Anzeigen von fünf Trackpoints hintereinander
  if (trackpoints.size() != 0)
  {
    trackpoint1 = (Trackpoint) trackpoints.get(trackpointsCounter);
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

    // Für jeden der fünf Trackpoints einen Kreis zeichnen
    ellipse(punkt1.x, punkt1.y, 15, 15);
    ellipse(punkt2.x, punkt2.y, 10, 10);
    ellipse(punkt3.x, punkt3.y, 10, 10);
    ellipse(punkt4.x, punkt4.y, 10, 10);
    ellipse(punkt5.x, punkt5.y, 10, 10);

    // Diese Kreise mit Linien verbinden
    // sodass eine Art Kette entsteht
    strokeWeight(2);
    stroke(102, 102, 102, 80);
    line(punkt1.x, punkt1.y, punkt2.x, punkt2.y);
    line(punkt2.x, punkt2.y, punkt3.x, punkt3.y);
    line(punkt3.x, punkt3.y, punkt4.x, punkt4.y);
    line(punkt4.x, punkt4.y, punkt5.x, punkt5.y);


    // Text neben dem sich bewegenden Trackpoint
    fill(0, 0, 0);
    //text(dateformat.format(trackpoint1.time) +" "+trackpoint1.location, punkt1.x - 4, punkt1.y + 5);



    // Amountbubble erzeugten, wenn es an einem Punkt noch keine gibt
    // sonst den Zähler der bestehenden erhöhen
    // selbes für die Zähler von Telefonie-, Internet- und SMS-Gebrauch
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

    // Alle Amountbubbles zeichnen
    for (int i = 0; i < amountbubbles.size(); i++) {
      Amountbubble bubbletemp = (Amountbubble) amountbubbles.get(i);
      bubbletemp.draw(map, bubbletemp.equalsOther(trackpoint1.location));
    }

    // Trackpointzähler erhöhen bis alle Trackpoints angezeigt wurden
    // playing sagt ob abgespielt oder pausiert wird
    if (trackpointsCounter < trackpoints.size()-5 && playing) {
      trackpointsCounter++;
      increaseBubbles = true;
    }
    else {
      increaseBubbles = false;
    }
  }
  else {
    println("Error: Keine Trackpoints gefunden. Könnte daran liegen, dass der Datumsbereich falsch gewählt wurde.");
  }




  /* Menü + Buttons */

  // Alle Buttons zeichnen und überprüfen ob Maus darüber
  boolean hand = false;
  if (showgui) {
    for (int i = 0; i < buttons.length; i++) {
      buttons[i].draw();
      hand = hand || buttons[i].mouseOver();
    }
  }

  // Wenn die Maus über einem Button ist soll der Zeiger als 
  // Hand dargestellt werden sonst als Kreuz
  cursor(hand ? HAND : CROSS);

  // Überprüfen ob bestimmte Taste gedrückt worden ist
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

  // Button und Menü anzeigen
  if (showgui) {

    // Schriftart + Größe einstellen
    textFont(font, 12);

    // Menübalken zeichnen
    fill(200);
    noStroke();
    rect(0, height-g.textSize-8, width, g.textSize+8);

    // Menüstrich zeichnen
    stroke(150);
    strokeWeight(1);
    line(0, height-g.textSize-8, width, height-g.textSize-8) ;

    // Länge- und Breite-Koordinaten der Maus-Position anzeigen
    Location location = map.pointLocation(mouseX, mouseY);

    // Mauskoordinaten links unten hinschreiben 
    fill(50);
    textAlign(LEFT, BOTTOM);
    text("Koordinaten " + location, 3, height-3);

    // Datum+Zeit des derzeitigen Trackpoints unten mittig hinschreiben
    fill(129, 80, 80);
    textAlign(CENTER, BOTTOM);
    if (trackpoints.size() != 0)
    {
      text(dateformat.format(trackpoint1.time.getTime()) +"", width/2, height-3);
    }
    // Anzahl der schon angezeigten Trackpoints recht unten hinschreiben
    fill(50);
    textAlign(RIGHT, BOTTOM);
    text("Trackpointzähler " + trackpointsCounter, width-3, height-3);

    // Zentrum der Karte
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
  //Drücke "G" um das Menü und die Buttons angezeigt zu bekommen
  if (key == 'g' || key == 'G') {
    showgui = !showgui;
  }
  // Drücke "S" um einen Screenshot im Ordner "modest_maps_interactive" zu speichern
  else if (key == 's' || key == 'S') {
    save("screenshot_"+timestamp()+".jpg");
  }
  // Drücke "M" um die Landkarte ein- bzw. auszublenden
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
  /*
  else if (key == 'b') {
    Location currentMouseLocation = map.pointLocation(mouseX, mouseY);
    LocationBubble reichstag = new LocationBubble(currentMouseLocation, "cell_phone.svg");
    reichstag.draw(map, false);
  }*/
  /*else if (key == 'z' || key == 'Z') {
   map.sc = pow(2, map.getZoom());
   }
   else if (key == ' ') {
   map.sc = 2.0;
   map.tx = -128;
   map.ty = -128;
   }*/
}


// Schauen ob über einem Button sonst die Karten draggen lassen
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

// Schauen ob über einem Button und entsprechend bei Klick reagieren
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
    playing = !playing;
  }
}


/* ######################################### */
/*     Zusätzliche brauchbare Funktionen     */
/* ######################################### */

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
