class Amountbubble {
  
  //Trackpoint trackpoint = (Trackpoint) trackpoints.get(i);
   //= map.locationPoint(trackpoint.location)
  //Point2f punkt;
  Location location;
  float size;

  public Amountbubble(Location punkt) {
    this.location = punkt;
    this.size = 10;
  }

  void increaseSize() {
    this.size = size+0.05;

  }

//  void decreaseSize() {
//    this.size = size-0.002;
//    this.draw();
//  }
  
  public boolean equalsOther(Location that) {
    
    float distance = (float)Math.sqrt(Math.pow((that.lat - this.location.lat), 2) + Math.pow((that.lon - this.location.lon), 2));
    return distance < 0.002;
  }
  
  void draw(InteractiveMap map){
       Point2f punkt = map.locationPoint(location);
       draw(punkt.x, punkt.y);
  }

  void draw(float x, float y) {
    noStroke();
    fill(0,255,255, 80);
    ellipse(x,y,size,size);
    stroke(255,255,255, 40);
    int l = 2;
    line(x-l, y-l, x+l, y+l);
    line(x-l, y+l, x+l, y-l);
    
  }
}
