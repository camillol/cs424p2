class VBar extends View {
  float level;
  float start = 0;
  float end = 15;
  float myHeight;
  
  VBar(float x_, float y_, float w_, float h_)
  {
    super(x_, y_, w_, h_);
    myHeight = h_;
    level = 0.5;
  }
  
  void drawContent()
  {
    noFill();
    stroke(0);
    rect(0, 0, w, h);
    fill(128);
    rect(0, start, w, end-start);
  }
  
  boolean contentPressed(float lx, float ly)
  {
    if(ly <= h-15){
    level = ly/h;
    start = ly;
    end = start + 15;
    }

    println(start);
    println(end);
        
    return true;
  }
  
  boolean contentDragged(float lx, float ly)
  {
    
    if(ly <= h -15){
    level = ly/h;
    start = ly;
    end = start + 15;}
    println(start);
    println(end);
  
    return true;
  }
}
