interface ListDataSource {
  String getText(int index);
  Object get(int index);
  int count();
}

class MissingListDataSource implements ListDataSource {
  String msg;
  
  MissingListDataSource(String msg_) { msg = msg_; }
  String getText(int index) { return msg; }
  Object get(int index) { return null; }
  int count() { return 1; }
}

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
      myList.scrollTo(myList.myListCounter - 1);
    else if (myElement == "downarrow")
      myList.scrollTo(myList.myListCounter + 1);

    println(myList.myListCounter);
    return true;
  }
}

class ListBox extends View{
  final int rowHeight = 20;
  final int barSize = 14;
  
  ListDataSource data;
  color myColor = color(255,255,255);
  int myListCounter = 0;
  
  ListBox(float x_, float y_, float w_, float h_, ListDataSource data_)
  {
    super(x_,y_,w_,h_);
    data = data_;
    PImage uparrow = loadImage("uparrow.png");
    PImage downarrow = loadImage("downarrow.png");
    subviews.add(new ArrowButton(w-barSize, 0, barSize, barSize, "uparrow", uparrow, true,  this)); 
    subviews.add(new ArrowButton(w-barSize, h-barSize, barSize, barSize, "downarrow", downarrow, true, this));
    subviews.add(new VBar(w-barSize-1, barSize, barSize+1, h-barSize*2, this));
  }
  
  int maxScroll()
  {
    return data.count() - int(h/rowHeight);
  }
  
  void scrollTo(int index)
  {
    myListCounter = min(max(index, 0), maxScroll());
  }

  void drawContent()
  {
    fill(myColor);
    rect(0,0,w,h);
    fill(0);
   
    for(int i = myListCounter; i < myListCounter+(h/rowHeight) && i < data.count(); i++) {
      text(data.getText(i), 0, (i-myListCounter)*rowHeight); 
    }
  }
  
  boolean contentClicked(float lx, float ly)
  {
    int index = int(ly/rowHeight) + myListCounter;
    buttonClicked(data.get(index));
    return true;
  }
}
