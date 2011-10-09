class ArrowButton extends Button {
  ListBox myList;
  boolean isUp;
  String myElement;
  
  ArrowButton(float x_, float y_, float w_, float h_, Object element, PImage theImage, boolean isDirectional, ListBox theList)
  {
    super(x_,y_,w_,h_, element,theImage,isDirectional);
    myList = theList;
    myElement = element.toString();
  }
  
  boolean contentClicked(float lx, float ly)
  {
    if(hasDirection){
      tint(0, 130,109,200);
      image(myImage,0,0);
    }
    if (myElement == "uparrow")
      myList.myListCounter--;
      if(myList.myListCounter == -1)
        myList.myListCounter = 0;
  
    else if (myElement == "downarrow")
        myList.myListCounter++;
        if(myList.myListCounter == myList.numberOfCharacters - 7 )
          myList.myListCounter = myList.numberOfCharacters - 6;

    println(myList.myListCounter);
    return true;
  }
}

class ListBox extends View{
  Object myElement;
  color myColor = color(255,255,255);
  int range = 8;
  int start = 0;
  int myCharacter;
  int characterIndex;
  int numberOfLines = 8;
  int myListCounter = 0;
  int maxListCounter;
  int numberOfCharacters;
  String[] charactersArray = new String[1196];
  int lCounter;
  String characterName;
  Character theCharacterClicked;
  CharacterList myCharList;
  
  ListBox(float x_, float y_, float w_, float h_, CharacterList characters)
  {
    super(x_,y_,w_,h_);
    int counter = 0;
   // subviews.add(new VBar(w-15, 14, 15, h-14));
    PImage uparrow = loadImage("uparrow.png");
    PImage downarrow = loadImage("downarrow.png");
    color(0);
    stroke(1);
    subviews.add(new ArrowButton(w-14, 0, 14, 14, "uparrow", uparrow, true, this)); 
    subviews.add(new ArrowButton(w-14, h-14, 14, 14, "downarrow", downarrow, true, this));
    subviews.add(new VBar(w-15, 14, 15, h-14*2, this));
    Iterator i = characters.iterator();
    myCharList = characters;
    while(i.hasNext()) {
      Character character = (Character)i.next();
      charactersArray[counter] = character.name;
      counter++;
    }
    numberOfCharacters = charactersArray.length;
    maxListCounter = numberOfCharacters - 8;
  }

  
  void drawContent(){
   
   fill(myColor);
   rect(0,0,w,h);
   lCounter = 0;
   fill(0);
   
   for(int i = myListCounter; i< myListCounter+11; i++){
     
     text(charactersArray[i], 0, 2 + lCounter); 
     lCounter+=18;
   }
   
   }
  
  boolean contentClicked(float lx, float ly)
  {
    myCharacter = int(ly/18);
    characterIndex = myCharacter + myListCounter;
    println(charactersArray[characterIndex]);
    characterName = charactersArray[characterIndex].toString();
    theCharacterClicked = myCharList.get(characterName);
    buttonClicked(theCharacterClicked);
    return true;
  }
}
