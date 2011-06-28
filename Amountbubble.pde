class Amountbubble {
  float x, y, size;

  public Amountbubble(float x, float y) {
    this.x = x;
    this.y = y;
    this.size = 40;
  }

  void increaseSize() {
    this.size = size+5;
  }

  void decreaseSize() {
    this.size = size-0.2;
  }

  void draw() {
    noStroke();
    fill(0,255,255, 4);
    ellipse(x,y,size,size);
  }
}
