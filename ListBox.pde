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
    rootView.subviews.add(new VBar(x_+w_,y_,15,h_));
    Iterator i = characters.iterator();
    while(i.hasNext()) {
      Character character = (Character)i.next();
        //rootView.subviews.add(new Button(750,y_+n*(20),140,20,1000,14,false, character.name));
      charactersArray[counter] = character.name;
      counter++;
      println(counter);
      println(character.name);
    }

  }

  
  void drawContent(){
   
   fill(myColor);
   rect(0,0,w,h);
   for(int i = start; i<=start+range; i++){
   }
     
    //println(counter);
    //println(character.name);
   }
 
  
  
  boolean contentClicked(float lx, float ly)
  {
    myIndex = int(((ly/h) * 8)); 
    return true;
  }
}
