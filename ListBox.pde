class ArrowButton extends Button {
  ListBox myList;
  
  ArrowButton(float x_, float y_, float w_, float h_, Object element, PImage theImage,boolean isDirectional, ListBox theList)
  {
    super(x_,y_,w_,h_, element,theImage,isDirectional);
    myList = theList;
  }
  

  boolean contentClicked(float lx, float ly)
  {
    if(hasDirection){
      tint(0, 130,109,200);
      image(myImage,0,0);
    }
    println("dfsfafas");

    return true;
  }
}

class ListBox extends View{
  Object myElement;
  color myColor = color(255,255,255);
  int range = 8;
  int start = 0;
  int myIndex;
  int numberOfLines = 8;
  
  ListBox(float x_, float y_, float w_, float h_, CharacterList characters)
  {
    super(x_,y_,w_,h_);
    String[] charactersArray = new String[1196];
    int counter = 0;
   // subviews.add(new VBar(w-15, 14, 15, h-14));
    PImage uparrow = loadImage("uparrow.png");
    PImage downarrow = loadImage("downarrow.png");
    color(0);
    stroke(1);
    subviews.add(new ArrowButton(w-14, 0, 14, 14, "uparrow", uparrow, true, this)); 
    subviews.add(new ArrowButton(w-14, h-14, 14, 14, "downarrow", downarrow, true, this));
    subviews.add(new VBar(w-15, 14, 15, h-14));
    Iterator i = characters.iterator();
    while(i.hasNext()) {
      Character character = (Character)i.next();
      charactersArray[counter] = character.name;
      counter++;
      // for testing
      println(counter);
      println(character.name);
    }

  }

  
  void drawContent(){
   
   fill(myColor);
   rect(0,0,w,h);
   for(int i = start; i<=start+range; i++){
     //todo  
   }
   
   }
 
  
  
  boolean contentClicked(float lx, float ly)
  {
    myIndex = int(((ly/h) * 8)); 
    return true;
  }
}
