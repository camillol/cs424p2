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
  
  Button(float x_, float y_, float w_, float h_, int element, int fontSize, String theLabel)
  {

    super(x_,y_,w_,h_);
    level = 1;
    hasText = true;
    myLabel = theLabel;
    myFontSize = fontSize;
    fontA = loadFont("Helvetica-Light-"+myFontSize+".vlw");
    textFont(fontA, myFontSize);
    fill(0,239,1);
    rect(x,y,w,h);
    fill(123,9,2);
    text(myLabel, x, y+h-5);
    myElement = element;
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
      if (myFlag){
         fill(0,220,68);
         rect(0,0,w,h);
         fill(0,60,68);
      }
      else{
         fill(0,239,1);
         rect(0,0,w,h);
         fill(123,9,2);
      }   
      text(myLabel,0,0+h-30);
    }
  }

  boolean contentClicked(float lx, float ly)
  {
    myFlag = !myFlag;
    buttonClicked(myElement);
    return true;
  }
}
