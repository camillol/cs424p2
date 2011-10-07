import controlP5.*;
View rootView;

HashMap characters;
CharacterList charlist;
Season[] seasons;

ControlP5 controlP5;
Button mainB1;
ListBox otherChars;
ListBox episodes;

void setup()
{
  loadCharacters();
  loadSeasons();
  
  size(1024, 768);
  smooth();
  
  background(30, 30, 30);
  rect(50,480,650,768-50-480);
  
  rootView = new View(0, 0, 1024, 768);
  controlP5 = new ControlP5(this);
  
  PImage leelaImg = loadImage("leela.png");
  PImage zappImg = loadImage("zapp.png");
  PImage benderImg = loadImage("bender.png");
  PImage wongImg = loadImage("wong.png");
  PImage farnsworthImg = loadImage("farnsworth.png");
  PImage fryImg = loadImage("fry.png");
  PImage nibblerImg = loadImage("nibbler.png");
  PImage zoidbergImg = loadImage("zoidberg.png");
  
  leelaImg.resize(50, 50);
  image(leelaImg,740,50);
  rootView.subviews.add(new Button(740,50,50,50,1,leelaImg));
  zappImg.resize(50, 50);
  image(zappImg,800,50);
  rootView.subviews.add(new Button(800,50,50,50,2,zappImg));
  benderImg.resize(50,50);
  image(benderImg, 860, 50);
  rootView.subviews.add(new Button(860,50,50,50,3,benderImg));
  wongImg.resize(50, 50);
  image(wongImg, 920, 50);
  rootView.subviews.add(new Button(920,50,50,50,4,wongImg));
  farnsworthImg.resize(50, 50);
  image(farnsworthImg, 740, 130);
  rootView.subviews.add(new Button(740,130,50,50,5,farnsworthImg));
  fryImg.resize(50, 50);
  image(fryImg, 800, 130);
  rootView.subviews.add(new Button(800,130,50,50,6,fryImg));
  nibblerImg.resize(50, 50);
  image(nibblerImg, 860, 130);
  rootView.subviews.add(new Button(860,130,50,50,7,nibblerImg));
  zoidbergImg.resize(50, 50);
  image(zoidbergImg, 920, 130);
  rootView.subviews.add(new Button(920,130,50,50,8,zoidbergImg));

 
  // BUTTONS FOR MAIN CHARACTERS AND OTHER CHARACTER LIST

  controlP5.addButton(" Reset",0,930,200,40,20);  
  
  otherChars = controlP5.addListBox("otherCharList",790,220,130,130);
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
  otherChars.actAsPulldownMenu(true);
  
  //BUTTONS FOR SEASON SELECTION AND EPISODE LIST
  controlP5.addButton("  1",0,780,350,30,30);
  controlP5.addButton("  2",0,820,350,30,30);
  controlP5.addButton("  3",0,860,350,30,30);
  controlP5.addButton("  4",0,900,350,30,30);
  controlP5.addButton("  5",0,780,390,30,30);
  controlP5.addButton("  6",0,820,390,30,30);
  controlP5.addButton("  7",0,860,390,30,30);
  controlP5.addButton(" All",0,900,390,30,30);
  
  episodes = controlP5.addListBox("episodeList",790,460,130,130);
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
  dropMenuView();
 // drawSeasons();

}

void loadCharacters()
{
  charlist = new CharacterList("characters.txt");
  characters = charlist.characters;
}

void loadSeasons()
{
  File dir = new File(dataPath("transcripts"));
  String[] names = dir.list();
  seasons = new Season[names.length];
  for (int i = 0; i < names.length; i++) {
    String[] groups = match(names[i], "S(\\d+)");
    seasons[i] = new Season(parseInt(groups[0]), "transcripts/"+names[i]);
  }
}

Character getCharacter(String name)
{
  return (Character)characters.get(name);
}

void draw()
{
  tint(255,255);
  noStroke();
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

void dropMenuView(){
  text("Overall",50,48);
  int myDivNum = ((650-84)/6);
  
  fill(100);
  rect(50, 50, 658, 380);

  rootView.subviews.add(new Button(50,410,myDivNum,40,9,"   S1"));
  for (int i = 2; i<=7; i++){
    rootView.subviews.add(new Button(50+myDivNum*(i-1),410,myDivNum,40,i+8,"   S"+i));
  }
  rootView.subviews.add(new Button(50+myDivNum*(6),410,myDivNum,40,16,"  All"));
}

