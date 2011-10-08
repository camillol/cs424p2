View rootView;

CharacterList characters;
boolean allActive = true;
Season[] seasons;

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
  
  background(shipMain);
  
  rootView = new View(0, 0, width, height);
  
  for (int i = 0; i < seasons.length; i++) {
    rootView.subviews.add(new SeasonEpsView(30, 30 + (seasonEpsViewHeight + seasonEpsViewVGap)*i, seasonEpsViewWidth, seasonEpsViewHeight, seasons[i]));
  }

  PImage myImage;
  
  Iterator i = characters.iterator();
  for (int n=0; n < 8 && i.hasNext();) {
    Character character = (Character)i.next();
    myImage = character.img;
    if (character.img == null) continue;
    if(n <= 3){
    rootView.subviews.add(new Button(740+n*(60),50,50,50,character,myImage));
    }
    else{
    rootView.subviews.add(new Button(740+(n-4)*(60),120,50,50,character,myImage));  
    }
    n++;
  }
  
 

  dropMenuView();

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
    seasons[i] = new Season(parseInt(groups[1]), "transcripts/"+names[i]);
  }
}

void draw()
{
  //tint(255,255);
  noStroke();
  rootView.draw();
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

void buttonClicked(Object element)
{
  if (characters.iterator().next().getClass().isInstance(element)) {
    Character character = (Character)element;
    allActive = false;
    character.active = !character.active;
    updateActiveTotals();
  }
}

void updateActiveTotals()
{
  for (int i = 0; i < seasons.length; i++) {
    seasons[i].updateActiveTotals();
  }
}

void dropMenuView(){
  text("Overall", 30, 10);
  int myDivNum = ((650-84)/6);
  
//  fill(100);
//  rect(50, 50, 658, 380);

  int myY = 410;
/*
  for (int i = 1; i<7; i++){
    rootView.subviews.add(new Button(50+myDivNum*(i-1),410,myDivNum,40,i+8,32,true, "S"+i));
  }
  rootView.subviews.add(new Button(50+myDivNum*(6),410,myDivNum,40,16,32, false, "  All"));
*/
  for(int j = myY; j >= 50; j--){
     
  }
}

