class Button extends View{
  
  float level;
  color myColor = color(255,255,255,0);
  boolean myFlag = false;
  PImage myImage;
  boolean hasImage = false;
  
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
    return true;
  }
}
