class Button extends View{
  
  float level;
  color myColor = color(255,255,255,0);
  boolean myFlag = false;
  PImage myImage;
  boolean hasImage = false;
  String myLabel;
  boolean hasText = false;
  PFont fontA;


  Button(float x_, float y_, float w_, float h_, int element)
  {
    super(x_,y_,w_,h_);
    level = 1;
  }
  
  Button(float x_, float y_, float w_, float h_, int element, PImage theImage)
  {
    super(x_,y_,w_,h_);
    level = 1;
    hasImage = true;
    myImage = theImage;
  }
  
  Button(float x_, float y_, float w_, float h_, int element, String theLabel)
  {

    super(x_,y_,w_,h_);
    level = 1;
    hasText = true;
    myLabel = theLabel;
    fontA = loadFont("Helvetica-Light-36.vlw");
    textFont(fontA, 36);
    fill(0,239,1);
    rect(x,y,w,h);
    fill(123,9,2);
    text(myLabel, x, y+h-5);
  }
  

  boolean contentClicked(float lx, float ly)
  {

    if(hasImage == true){
      if(myFlag == false){
         myFlag = true;
         tint(0, 153, 204, 126);
         image(myImage, x, y);
      }
      else if (myFlag == true){
        myFlag = false;
        tint(255,255);
        image(myImage,x,y);
      }
    }
    if(hasText == true){
      if(myFlag == false){
         myFlag = true;
         tint(0, 153, 204, 126);
         fill(0,239,1);
         stroke(1);
         rect(x,y,w,h);
         fill(123,9,2);
         text(myLabel,x,y+h-5);

      }
      else if (myFlag == true){
         myFlag = false;
         tint(255,255);
         fill(0,239,1);
         stroke(1);
         rect(x,y,w,h);
         fill(123,9,2);
         text(myLabel,x,y+h-5);
      }
    }
    return true;
  }
}
