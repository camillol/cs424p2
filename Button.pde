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


  Button(float x_, float y_, float w_, float h_, Object element)
  {
    super(x_,y_,w_,h_);
    level = 1;
  }
  
  Button(float x_, float y_, float w_, float h_, Object element, PImage theImage)
  {
    super(x_,y_,w_,h_);
    level = 1;
    hasImage = true;
    myImage = theImage;
    theImage.resize(50, 50);
    myElement = element;
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
    if (hasImage) {
      if (myFlag) tint(0, 153, 204, 126);
      else noTint();
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
        text(myLabel,0,0+h-30);
      }
    }
  }

  boolean contentClicked(float lx, float ly)
  {
    myFlag = !myFlag;
    buttonClicked(myElement);
    return true;
  }
}
