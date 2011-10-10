import java.awt.Graphics2D;
import java.awt.Shape;

Graphics2D g2;
Shape[] clipStack;
int clipIdx;

DataClass data;

View rootView;

Object viewTarget;  // null when overall, Season when season, Episode when episode
Animator viewTotalLines;

CharacterList characters;
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
final int seasonEpsTop = 38;

SeasonEpsView seasonViews[];
Animator seasonY[];
Button overallButton;

PieChart pieChart;

NgramTable ngrams;
HashMap<Character,CharNgramTable> charNgrams;

ListBox ngramList;

void setupG2D()
{
  g2 = ((PGraphicsJava2D)g).g2;
  clipStack = new Shape[32];
  clipIdx = 0;
}

void setup()
{
  data=new DataClass("files");
  
  loadCharacters();
  loadSeasons();
  loadNgrams();
  characters.setAllActive(true);
  viewTotalLines = new Animator();
  
  size(1024, 768);
  setupG2D();
  
  smooth();
  
  background(shipMain);
  
  rootView = new View(0, 0, width, height);
  
  overallButton = new Button(30, 10, 100, 20, "overall", 18, false, "Overall");
  overallButton.myFlag = true;
  rootView.subviews.add(overallButton);
  
  seasonViews = new SeasonEpsView[seasons.length];
  seasonY = new Animator[seasons.length];
  for (int i = 0; i < seasons.length; i++) {
    float y = seasonEpsTop + (seasonEpsViewHeight + seasonEpsViewVGap)*i;
    seasonViews[i] = new SeasonEpsView(30, y, seasonEpsViewWidth, seasonEpsViewHeight, seasons[i]);
    rootView.subviews.add(seasonViews[i]);
    seasonY[i] = new Animator(y);
  }

  PImage myImage;
  
  Iterator i = characters.iterator();
  for (int n=0; n < 8 && i.hasNext();) {
    Character character = (Character)i.next();
    myImage = character.img;
    if (character.img == null) continue;
    if(n <= 3){
    rootView.subviews.add(new Button(680+n*(60),50,50,50,character,myImage,false));
    }
    else{
    rootView.subviews.add(new Button(680+(n-4)*(60),120,50,50,character,myImage,false));  
    }
    n++;
  }
  
  rootView.subviews.add(new ListBox(680,220,300,200, characters));


  pieChart=new PieChart(750,500,200,200);
  rootView.subviews.add(pieChart);
  
  ngramList = new ListBox(100, 500, 200, 200, new MissingListDataSource("select a character"));
  rootView.subviews.add(ngramList);
  
  //rootView.subviews.add(new InteractionChart(750,520,400,500,episodeCharacters,characters));
  //uncomment the following two lines to add the interaction chart(basically a chart that has char coded color lines for each dialog he has in the episode)
//  ArrayList episodeCharacters=data.getEpisodeCharactersList("S01E01");
//  rootView.subviews.add(new InteractionChart(40,150,700,150,episodeCharacters));



  dropMenuView();

  setViewTarget(null);
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
  Arrays.sort(names);
  seasons = new Season[names.length];
  for (int i = 0; i < names.length; i++) {
    String[] groups = match(names[i], "S(\\d+)");
    if (groups == null) continue;
    seasons[i] = new Season(parseInt(groups[1]), "transcripts/"+names[i]);
  }
}

void loadNgrams()
{
  ngrams = new NgramTable("ngrams/sign-ngrams.txt");
  charNgrams = new HashMap<Character,CharNgramTable>(characters.count());
  Iterator it = characters.iterator();
  while (it.hasNext()) {
    Character c = (Character)it.next();
    println(c.name);
    String path = "ngrams/characters/"+c.name+"-sign-ngrams.txt";
    File f = new File(dataPath(path));
    if (f.exists()) {
      CharNgramTable cngt = new CharNgramTable(path);
      charNgrams.put(c, cngt);
    }
  }
}

void draw()
{
  background(shipMain);    /* seems to be needed to actually clear the frame */
  Animator.updateAll();
  
  for (int i = 0; i < seasons.length; i++) {
    seasonViews[i].y = seasonY[i].value;
  }
    
  //tint(255,255);
  noStroke();
  rootView.draw();
}

/* I can't believe this is not part of the Processing API! */
void clipRect(int x, int y, int w, int h)
{
  g2.clipRect(x, y, w, h);
}

void clipRect(float x, float y, float w, float h)
{
  g2.clipRect((int)x, (int)y, (int)w, (int)h);
}

void noClip()
{
  g2.setClip(null);
}

void pushClip()
{
  clipStack[clipIdx++] = g2.getClip();
}

void popClip()
{
  g2.setClip(clipStack[--clipIdx]);
  clipStack[clipIdx] = null;
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

void setViewTarget(Object target)
{
  viewTarget = target;
  if (target == null) {
    viewTotalLines.target(data.getWholeStatsTotal()); // for vivek: total lines over all series
    pieChart.updateCharAnimators();
  } else if (seasons[0].getClass().isInstance(target)) {
    Season season = (Season)target;
    float total=data.getSeasonStatsTotal("S0"+season.number);
    viewTotalLines.target(total); // for vivek: total lines over this season
    pieChart.updateCharAnimators();
  }
}

void buttonClicked(Object element)
{
  if (characters.iterator().next().getClass().isInstance(element)) {
    Character character = (Character)element;
    character.setActive(!character.active);
    characters.setAllActive(countActive == 0);
    updateActiveTotals();
  } else if (seasons[0].getClass().isInstance(element)) {
    Season season = (Season)element;
    int idx = season.number - 1;
    setViewTarget(season);
    overallButton.myFlag = false;
    for (int i = 0; i < idx; i++) {
      seasonY[i].target((i-idx)*(seasonEpsViewHeight + seasonEpsViewVGap));
      seasonViews[i].button.myFlag = false;
    }
    seasonY[idx].target(seasonEpsTop);
    for (int i = idx+1; i < seasons.length; i++) {
      seasonY[i].target(height + (i-idx-1)*(seasonEpsViewHeight + seasonEpsViewVGap));
      seasonViews[i].button.myFlag = false;
    }
  } else if ("".getClass().isInstance(element)) {
    if (element.equals("overall")) {
      for (int i = 0; i < seasons.length; i++) {
        float y = seasonEpsTop + (seasonEpsViewHeight + seasonEpsViewVGap)*i;
        seasonY[i].target(y);
        seasonViews[i].button.myFlag = false;
        setViewTarget(null);
      }
    }
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
  
/*  fill(100);
   rect(50, 50, 658, 380);
  int myY = 410;

  for (int i = 1; i<7; i++){
    rootView.subviews.add(new Button(50+myDivNum*(i-1),410,myDivNum,40,i+8,32,true, "S"+i));
  }
  rootView.subviews.add(new Button(50+myDivNum*(6),410,myDivNum,40,16,32, false, "  All"));

  for(int j = myY; j >= 50; j--){
     
  } */
}

