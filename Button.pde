class Button extends View
{
  color myColor = color(255,255,255,0);
  boolean myFlag = false;
  PImage myImage;
  boolean hasImage = false;
  String myLabel;
  boolean hasText = false;
  PFont fontA;
  Object myElement;
  int myFontSize;
  boolean myVertical = false;
  boolean isDirectional = false;
  boolean hasDirection;
  boolean selectButton = false;
  boolean hasSelect;

  Button(float x_, float y_, float w_, float h_, Object element)
  {
    super(x_,y_,w_,h_);
  }
  
  Button(float x_, float y_, float w_, float h_, Object element, PImage theImage, boolean isDirectional)
  {
    super(x_,y_,w_,h_);
    hasImage = true;
    myImage = theImage;
    if(!isDirectional){
      theImage.resize(50, 50);
    }
    else if(isDirectional){
      theImage.resize(14,14);
    }
    myElement = element;
    hasDirection = isDirectional;
  }
  
  Button(float x_, float y_, float w_, float h_, Object element, int fontSize, boolean vertical, String theLabel, boolean selectButton)
  {
    super(x_,y_,w_,h_);
    hasText = true;
    myLabel = theLabel;
    myFontSize = fontSize;
    fontA = loadFont("Helvetica-Light-"+myFontSize+".vlw");
    myElement = element;
    myVertical = vertical;
    hasSelect = selectButton;
  }
  
  boolean selected()
  {
    return myFlag;
  }
  
  void drawContent()
  {
    if (hasImage && !hasDirection && !hasSelect) {
      if (selected()) tint(0, 153, 204, 126);
      else noTint();
      image(myImage,0,0);
    }
    else if (hasImage && hasDirection && !hasSelect) {
      noTint(); 
      fill(0);
      stroke(1);
      // bounding box for the directional buttons
      // makes it pop out a bit easier
      rect(0-1,0-1,w+1,h+1);
      image(myImage,0,0);
    }

    if (hasText){
      textFont(fontA, myFontSize);
      fill(selected() ? shipRed : shipLight);
      noStroke();
      rect(0,0,w,h);
      fill(selected() ? 255 : shipRedDark);

      if (myVertical) {
        textAlign(LEFT, TOP);
        pushMatrix();
        translate(0,h);
        rotate(3*HALF_PI);
        text(myLabel, 0, 0);
        popMatrix();
      } 

      if(hasText && !myVertical){
        text(myLabel,0,0);
      }
    }
  }
  

  boolean contentClicked(float lx, float ly)
  {
    if(hasDirection){
      tint(0, 130,109,200);
      image(myImage,x,y);
    }
        
    buttonClicked(myElement);
    return true;
  }
  
}

class CharacterButton extends Button {
  final int highlightWidth = 4;
  
  CharacterButton(float x_, float y_, float w_, float h_, Character character)
  {
    super(x_,y_,w_,h_, character, character.img, false);
  }
  
  boolean selected()
  {
    Character character = (Character)myElement;
    return character.active;
  }
  
  void drawContent()
  {
    Character character = (Character)myElement;
    if (selected()) {
      fill(character.keyColor);
      noStroke();
      rect(-highlightWidth, -highlightWidth, w+highlightWidth*2, h+highlightWidth*2);
    }
    image(myImage,0,0);
  }
}
