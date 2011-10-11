class VBar extends View {
  ListBox myList;
  
  VBar(float x_, float y_, float w_, float h_, ListBox theList)
  {
    super(x_, y_, w_, h_);
    myList = theList;
  }
  
  float start()
  {
    return map(myList.myListCounter, 0, myList.maxScroll(), 0, h-14);
  }
  
  void setStart(float start)
  {
    myList.myListCounter = (int)map(start, 0, h-14, 0, myList.maxScroll());
  }
  
  void drawContent()
  {
    noFill();
    stroke(0);
    fill(255);
    rect(0, 0, w, h);
    fill(128);
    rect(0, start(), w, 14);
  }
  
  boolean contentPressed(float lx, float ly)
  {
    if((ly <= h -7) && (ly >= 7)){
      setStart(ly - 7);
    }
    println(myList.myListCounter);
    return true;
  }
  
  boolean contentDragged(float lx, float ly)
  {
    
    if((ly <= h -7) && (ly >= 7)){
      setStart(ly - 7);
    }
    println(myList.myListCounter);
  return true;
  }
}
