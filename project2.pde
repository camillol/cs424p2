import controlP5.*;
View rootView;

HashMap characters;

ControlP5 controlP5;
Button mainB1;
ListBox otherChars;
ListBox seasons;
ListBox episodes;

void setup()
{
  size(1024, 768);
  smooth();
  
  background(30, 30, 30);
  rect(50,480,690,200);
  
  rootView = new View(0, 0, 1024, 768);
  controlP5 = new ControlP5(this);
 
  // BUTTONS FOR MAIN CHARACTERS AND OTHER CHARACTER LIST
  controlP5.addButton("",0,820,50,30,30);
  controlP5.addButton("",0,860,50,30,30);
  controlP5.addButton("",0,900,50,30,30);
  controlP5.addButton("",0,940,50,30,30);
  controlP5.addButton("",0,820,90,30,30);
  controlP5.addButton("",0,860,90,30,30);
  controlP5.addButton("",0,900,90,30,30);
  controlP5.addButton("",0,940,90,30,30);
  controlP5.addButton(" Reset",0,960,140,40,20);  
  
  otherChars = controlP5.addListBox("otherCharList",820,160,130,130);
  otherChars.setItemHeight(15);
  otherChars.setBarHeight(15);
  otherChars.captionLabel().toUpperCase(true);
  otherChars.captionLabel().set("Other Characters");
  otherChars.captionLabel().style().marginTop = 3;
  otherChars.valueLabel().style().marginTop = 3; // the +/- sign
  for(int i=1;i<8;i++) {
    otherChars.addItem("Character "+i,i);
  }
  otherChars.addItem("All Other Characters", 8);
 // otherChars.setColorBackground(color(255,128));
 // otherChars.setColorActive(color(0,0,255,128));
  otherChars.actAsPulldownMenu(true);
  
  //BUTTONS FOR SEASON SELECTION AND EPISODE LIST
  controlP5.addButton("  1",0,820,350,30,30);
  controlP5.addButton("  2",0,860,350,30,30);
  controlP5.addButton("  3",0,900,350,30,30);
  controlP5.addButton("  4",0,940,350,30,30);
  controlP5.addButton("  5",0,820,390,30,30);
  controlP5.addButton("  6",0,860,390,30,30);
  controlP5.addButton("  7",0,900,390,30,30);
  controlP5.addButton(" All",0,940,390,30,30);
  
  episodes = controlP5.addListBox("episodeList",820,460,130,130);
  episodes.setItemHeight(15);
  episodes.setBarHeight(15);
  episodes.captionLabel().toUpperCase(true);
  episodes.captionLabel().set("episodes");
  episodes.captionLabel().style().marginTop = 3;
  episodes.valueLabel().style().marginTop = 3; // the +/- sign
  for(int i=1;i<15;i++) {
    episodes.addItem("Episode "+i,i);
  }
  episodes.addItem("All Episodes", 15);
 // episodes.setColorBackground(color(255,128));
 // episodes.setColorActive(color(0,0,255,128));
  episodes.actAsPulldownMenu(true);
  
  drawSeasons();


}

void loadCharacters()
{
  String[] names = loadStrings("characters.txt");
  characters = new HashMap(names.length);
  for (int i = 0; i < names.length; i++) {
    characters.put(names[i], new Character(names[i]));
  }
}

Character getCharacter(String name)
{
  return (Character)characters.get(name);
}

void draw()
{
  fill(#779999);
  noStroke();
  rect(790,0,width-790,height);
  rootView.draw();

}

void drawSeasons(){
  fill(128);
  noStroke();
  for(int i = 50; i <= 350; i+=50){
      controlP5.addToggle("Season: " + (i/50),false,50,i,40,35);
      rect(100,i,500,40);
  }
  controlP5.addToggle("All_Seasons",false,50,400,40,35);
  rect(100,400,500,40);
}

void mousePressed()
{
  rootView.mousePressed(mouseX, mouseY);
}

void mouseDragged()
{
  rootView.mouseDragged(mouseX, mouseY);
}

void mouseClicked()
{
  rootView.mouseClicked(mouseX, mouseY);
}


