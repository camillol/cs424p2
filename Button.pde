class Button extends View{
  
  float level;
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

  Button(float x_, float y_, float w_, float h_, Object element)
  {
    super(x_,y_,w_,h_);
    level = 1;
  }
  
  Button(float x_, float y_, float w_, float h_, Object element, PImage theImage,boolean isDirectional)
  {
    super(x_,y_,w_,h_);
    level = 1;
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
  
  Button(float x_, float y_, float w_, float h_, Object element, int fontSize, boolean vertical, String theLabel)
  {
    super(x_,y_,w_,h_);
    level = 1;
    hasText = true;
    myLabel = theLabel;
    myFontSize = fontSize;
    fontA = loadFont("Helvetica-Light-"+myFontSize+".vlw");
    myElement = element;
    myVertical = vertical;
  }
  

  
  void drawContent()
  {
    if (hasImage && !hasDirection) {
      if (myFlag) tint(0, 153, 204, 126);
      else noTint();
      image(myImage,0,0);
    }
    else if (hasImage && hasDirection) {
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
      fill(myFlag ? ship2Light : shipLight);
      rect(0,0,w,h);
      fill(myFlag ? shipRed : shipRedDark);
      if (myVertical) {
        textAlign(LEFT, TOP);
        pushMatrix();
        translate(0,h);
        rotate(3*HALF_PI);
        text(myLabel, 0, 0);
        popMatrix();
      } else {
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
    myFlag = !myFlag;
    buttonClicked(myElement);
    return true;
  }
  
}
