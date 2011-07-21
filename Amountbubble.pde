class Amountbubble {
  
  //Trackpoint trackpoint = (Trackpoint) trackpoints.get(i);
   //= map.locationPoint(trackpoint.location)
  //Point2f punkt;
  Location location;
  float radius;
  int counter;
  int callCounter;
  int gprsCounter;
  int smsCounter;

  public Amountbubble(Location punkt) {
    this.location = punkt;
    this.radius = 10;
    this.counter = 1;
  }

  void increaseSize() {
    this.radius = radius+0.05;
    this.counter++;
  }
  
  void increaseCallCounter() {
    this.callCounter++;
  }

  void increaseGprsCounter() {
    this.gprsCounter++;
  }

  void increaseSmsCounter() {
    this.smsCounter++;
  }  

  
  public boolean equalsOther(Location that) {
    float distance = (float)Math.sqrt(Math.pow((that.lat - this.location.lat), 2) + Math.pow((that.lon - this.location.lon), 2));
    return distance < 0.002;
  }
  
  void draw(InteractiveMap map, boolean highlight){
       Point2f punkt = map.locationPoint(location);
       draw(punkt.x, punkt.y, highlight);
  }

  void draw(float x, float y, boolean highlight) {
    noStroke();
    fill(176,37,68, 100);
    ellipse(x,y,radius,radius);
    
    // Bubble mit Zähler in der Mitte und Highlight-Funktion um die aktuelle Bubble zu markieren
    
    if(!highlight){
      fill(0, 0, 0, 60);
    }else{
      fill(255,0,0, 90);
    }
    
    ellipse(x,y,radius,radius);
    
    fill(255,255,255, 100);
    textSize(round(1.5 * this.radius));
    textAlign(LEFT);
    text(this.counter +"", x - 0.1 * this.radius, y + 0.5 * this.radius);
    

    // Bubble als Kuchendiagramm aufgeschlüsselt nach den Services
    /*noStroke();
    float diameter = 2*radius;
    float z = max(this.callCounter + this.smsCounter + this.gprsCounter, 1);
    int[] angs = {round((this.callCounter/z)*360), round((this.smsCounter/z)*360), round((this.gprsCounter/z)*360)};
    color[] pieColors = {color(196,36,55), color(249,255,137), color(146,189,76)};
    float lastAng = 0;
    
    for (int i = 0; i < angs.length; i++) {
      fill(pieColors[i]);
      arc(x, y, diameter, diameter, lastAng, lastAng+radians(angs[i]));
      lastAng += radians(angs[i]);
    }*/
    
    
    // bubble with x-mark in the center
    /*stroke(255,255,255, 40);
    int l = 2;
    line(x-l, y-l, x+l, y+l);
    line(x-l, y+l, x+l, y-l);*/
    
    
  }
}
