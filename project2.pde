import controlP5.*;
View rootView;

CharacterList characters;
Season[] seasons;

ControlP5 controlP5;
Button mainB1;
ListBox otherChars;
ListBox episodes;

color shipMain = #73D689;
color shipDark = #3D7C52;
color shipLight = #A9F597;
color ship2Main = #25684D;
color ship2Dark = #153D39;
color ship2Light = #39A27F;
color shipRed = #9B342D;
color shipRedDark = #4C1819;

final int seasonEpsViewWidth = 600;
final int seasonEpsViewHeight = 100;
final int seasonEpsViewVGap = 8;

void setup()
{
  loadCharacters();
  loadSeasons();
  
  size(1024, 768);
  smooth();
  
  background(shipDark);
  rect(50,480,650,768-50-480);
  
  rootView = new View(0, 0, 1024, 768);
  controlP5 = new ControlP5(this);
  
  for (int i = 0; i < seasons.length; i++) {
    rootView.subviews.add(new SeasonEpsView(40, 100 + (seasonEpsViewHeight + seasonEpsViewVGap)*i, seasonEpsViewWidth, seasonEpsViewHeight, seasons[i]));
  }

  PImage leelaImg = loadImage("leela.png");
  PImage zappImg = loadImage("zapp.png");
  PImage benderImg = loadImage("bender.png");
  PImage wongImg = loadImage("wong.png");
  PImage farnsworthImg = loadImage("farnsworth.png");
  PImage fryImg = loadImage("fry.png");
  PImage hermesImg = loadImage("hermes.png");
  PImage zoidbergImg = loadImage("zoidberg.png");
  PImage myImage;
  
  Iterator i = characters.iterator();
  for (int n=0; n < 8 && i.hasNext();) {
    Character character = (Character)i.next();
    myImage = character.img;
    if (character.img == null) continue;
    rootView.subviews.add(new Button(700+n*(40),50,50,50,n,myImage));
    n++;
  }
  rootView.subviews.add(new Button(740,50,50,50,1,leelaImg));
  rootView.subviews.add(new Button(800,50,50,50,2,zappImg));
  rootView.subviews.add(new Button(860,50,50,50,3,benderImg));
  rootView.subviews.add(new Button(920,50,50,50,4,wongImg));
  rootView.subviews.add(new Button(740,130,50,50,5,farnsworthImg));
  rootView.subviews.add(new Button(800,130,50,50,6,fryImg));
  rootView.subviews.add(new Button(860,130,50,50,7,hermesImg));
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
  for(int j=1;j<8;j++) {
    otherChars.addItem("Character "+j,j);
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
  for(int k=1;k<15;k++) {
    episodes.addItem("Episode "+k,k);
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
  characters = new CharacterList("characters.txt");
}

String[] namesMatching(String[] names, String re)
{
  int count = 0;
  String[] matches = new String[names.length];
  for (int i = 0; i < names.length; i++) {
    if (match(names[i], re) != null) {
      matches[count] = names[i];
      count++;
    }
  }
  return (String[]) subset(matches, 0, count);
}

void loadSeasons()
{
  File dir = new File(dataPath("transcripts"));
  String[] names = namesMatching(dir.list(), "S(\\d+)");
  seasons = new Season[names.length];
  for (int i = 0; i < names.length; i++) {
    String[] groups = match(names[i], "S(\\d+)");
    if (groups == null) continue;
    seasons[i] = new Season(parseInt(groups[0]), "transcripts/"+names[i]);
  }
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

  int myY = 410;

  rootView.subviews.add(new Button(50,410,myDivNum,40,9,"   S1"));
  for (int i = 2; i<7; i++){
    rootView.subviews.add(new Button(50+myDivNum*(i-1),410,myDivNum,40,i+8,"   S"+i));
  }
  rootView.subviews.add(new Button(50+myDivNum*(6),410,myDivNum,40,16,"  All"));
  
  for(int j = myY; j >= 50; j--){
     
  }
}

