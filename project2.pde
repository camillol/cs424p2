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
final int seasonEpsViewHeightNgram = 60;

final int ngramViewH = 240;
final int overallButtonH = 20;

SeasonEpsView seasonViews[];
Animator seasonY[];
Button overallButton;

PieChart pieChart;

NgramTable ngrams;
HashMap<Character,CharNgramTable> charNgrams;
boolean ngramMode = false;
Animator ngramModeAnimator;
Ngram activeNgram = null;

View ngramView;
Button ngramButton;
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
  ngramModeAnimator = new Animator(0);
  
  size(1024, 768);
  setupG2D();
  
  smooth();
  
  background(shipMain);
  
  rootView = new View(0, 0, width, height);
  
  overallButton = new Button(30, overallY(), 140, overallButtonH, "overall", 18, false, "Appearances");
  overallButton.myFlag = true;

  seasonViews = new SeasonEpsView[seasons.length];
  seasonY = new Animator[seasons.length];
  for (int i = 0; i < seasons.length; i++) {
    float y = seasonEpsTop() + (seasonEpsViewHeight + seasonEpsViewVGap)*i;
    seasonViews[i] = new SeasonEpsView(30, y, seasonEpsViewWidth, seasonEpsViewHeight, seasons[i]);
    rootView.subviews.add(seasonViews[i]);
    seasonY[i] = new Animator(y);
  }
  rootView.subviews.add(overallButton);
  
  ngramView = new View(30, ngramY(), seasonEpsViewWidth, ngramViewH);
  rootView.subviews.add(ngramView);
  
  ngramButton = new Button(0, ngramViewH-overallButtonH, 140, overallButtonH, "n-grams", 18, false, "n-grams");
  ngramView.subviews.add(ngramButton);

  ngramList = new ListBox(0, 20, 200, ngramViewH-20-overallButtonH-10, new MissingListDataSource("select a character"));
  ngramView.subviews.add(ngramList);
  
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

float seasonViewHeight()
{
  return map(ngramModeAnimator.value, 0.0, 1.0, seasonEpsViewHeight, seasonEpsViewHeightNgram);
}

float ngramY()
{
  return map(ngramModeAnimator.value, 0.0, 1.0, overallButtonH + 10 - ngramViewH, 0);
//  return map(ngramModeAnimator.value, 0.0, 1.0, height - 30, seasonEpsTop + (seasonViewHeight() + seasonEpsViewVGap)*seasons.length);
//  return seasonEpsTop + (seasonViewHeight() + seasonEpsViewVGap)*seasons.length;
}

float overallY()
{
  return ngramY() + ngramViewH + 10;
}

float seasonEpsTop()
{
  if (ngramMode) {
    return ngramViewH + 10 + overallButtonH + seasonEpsViewVGap;
  } else {
    return 30 + 10 + overallButtonH + seasonEpsViewVGap;
  }
}

void draw()
{
  background(shipMain);    /* seems to be needed to actually clear the frame */
  Animator.updateAll();
  
  for (int i = 0; i < seasons.length; i++) {
    seasonViews[i].y = seasonY[i].value;
    seasonViews[i].setHeight(seasonViewHeight());
  }
  ngramView.y = ngramY();
  overallButton.y = overallY();
  
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
  } else if (Season.class.isInstance(target)) {
    Season season = (Season)target;
    float total=data.getSeasonStatsTotal("S0"+season.number);
    viewTotalLines.target(total); // for vivek: total lines over this season
    pieChart.updateCharAnimators();
  }
}

void retargetSeasonYs()
{
  if (!ngramMode && Season.class.isInstance(viewTarget)) {
    Season season = (Season)viewTarget;
    int idx = season.number - 1;
    for (int i = 0; i < idx; i++) {
      seasonY[i].target((i-idx)*(seasonEpsViewHeight + seasonEpsViewVGap));
      seasonViews[i].button.myFlag = false;
    }
    seasonY[idx].target(seasonEpsTop());
    seasonViews[idx].button.myFlag = true;
    for (int i = idx+1; i < seasons.length; i++) {
      seasonY[i].target(height + (i-idx-1)*(seasonEpsViewHeight + seasonEpsViewVGap));
      seasonViews[i].button.myFlag = false;
    }
  } else {
    for (int i = 0; i < seasons.length; i++) {
      float y = seasonEpsTop() + ((ngramMode ? seasonEpsViewHeightNgram : seasonEpsViewHeight) + seasonEpsViewVGap)*i;
      seasonY[i].target(y);
      seasonViews[i].button.myFlag = false;
    }
  }
}

void setNgramMode(boolean ngmode)
{
  ngramMode = ngmode;
  ngramModeAnimator.target(ngramMode ? 1.0 : 0.0);
  retargetSeasonYs();
}

void buttonClicked(Object element)
{
  if (Character.class.isInstance(element)) {
    Character character = (Character)element;
    character.setActive(!character.active);
    characters.setAllActive(countActive == 0);
    updateActiveTotals();
    ngramList.data = charNgrams.get(character);
  } else if (Season.class.isInstance(element)) {
    Season season = (Season)element;
    int idx = season.number - 1;
    setViewTarget(season);
    retargetSeasonYs();
  } else if (String.class.isInstance(element)) {
    if (element.equals("overall")) {
      setViewTarget(null);
      setNgramMode(false);
    } else if (element.equals("n-grams")) {
      setNgramMode(true);
    }
  } else if (CharNgram.class.isInstance(element)) {
    CharNgram charNgram = (CharNgram)element;
    activeNgram = charNgram.ngram;
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

