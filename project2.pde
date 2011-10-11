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

final int ngramListH = 200;
final int overallButtonH = 20;
final int ngramViewH = 20 + ngramListH + 10 + overallButtonH;

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


Button allActiveButton;

StatsView statsView;
Animator statsViewY;

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
  viewTotalLines = new Animator();
  ngramModeAnimator = new Animator(0);
  
  size(1024, 768);
  setupG2D();
  
  smooth();
  
  background(shipMain);
  
  rootView = new View(0, 0, width, height);
  
  overallButton = new Button(30, overallY(), 140, overallButtonH, "overall", 18, false, "Appearances",true);
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
  
  ngramButton = new Button(0, ngramViewH-overallButtonH, 140, overallButtonH, "n-grams", 18, false, "n-grams", true);
  ngramView.subviews.add(ngramButton);

  ngramList = new ListBox(0, 20, 600, ngramViewH-20-overallButtonH-10, new MissingListDataSource("select a character"));
  ngramView.subviews.add(ngramList);
  
  PImage myImage;
  
  Iterator i = characters.iterator();
  for (int n=0; n < 8 && i.hasNext(); n++) {
    Character character = (Character)i.next();
    myImage = character.img;;

    assert (character.img != null);
    rootView.subviews.add(new CharacterButton(680+(n%4)*(80),90+(20+50)*(n/4),50,50,character));
  }
  
  rootView.subviews.add(new ListBox(680,260,300,200, characters));
  allActiveButton = new Button(680 ,50, 160, 15, "View All Characters", 18, false, "View All Characters",true);
  allActiveButton.myFlag = true;
  rootView.subviews.add(allActiveButton);

  characters.setAllActive(true);

  pieChart=new PieChart(750,500,200,200);
  rootView.subviews.add(pieChart);
  
  //rootView.subviews.add(new InteractionChart(750,520,400,500,episodeCharacters,characters));
  //uncomment the following two lines to add the interaction chart(basically a chart that has char coded color lines for each dialog he has in the episode)
//  ArrayList episodeCharacters=data.getEpisodeCharactersList("S01E01");
//  rootView.subviews.add(new InteractionChart(40,150,700,150,episodeCharacters));

  statsView = new StatsView(30, height, 600, 400, null);
  statsViewY = new Animator(height);
  rootView.subviews.add(statsView);

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
  statsView.y = statsViewY.value;
  
  drawLabels();
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
    statsViewY.target(seasonEpsTop() + seasonEpsViewHeight + seasonEpsViewVGap);
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
    statsViewY.target(height);
  }
}

void setNgramMode(boolean ngmode)
{
  ngramMode = ngmode;
  overallButton.myFlag = !ngmode;
  ngramButton.myFlag = ngmode;
  ngramModeAnimator.target(ngramMode ? 1.0 : 0.0);
  retargetSeasonYs();
}

void buttonClicked(Object element)
{
  PImage myImage;
  if (Character.class.isInstance(element)) {
    Character character = (Character)element;
    character.setActive(!character.active);
    characters.setAllActive(countActive == 0);
    updateActiveTotals();
    CharNgramTable cng = charNgrams.get(character);
    ngramList.data = cng != null ? cng : new MissingListDataSource("(no significant n-grams for this character)");
  } else if (Season.class.isInstance(element)) {
    Season season = (Season)element;
    int idx = season.number - 1;
    setViewTarget(season);
    retargetSeasonYs();
    
    statsView.mySeason = season.number;
  } else if (String.class.isInstance(element)) {
    if (element.equals("overall")) {
      setViewTarget(null);
      setNgramMode(false);
    } else if (element.equals("n-grams")) {
      setNgramMode(true);
    }  else if (element.equals("View All Characters")){
      characters.setAllActive(true); 
      updateActiveTotals();
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

void drawLabels(){
    text("Fry", 680+0*(80),142);
    text("Bender", 680+1*(80),142);
    text("Leela", 680+2*(80),142);
    text("Farnsworth", 680+3*(80),142);
    text("Zoidberg", 680+0*(80),215);
    text("Amy", 680+1*(80),215);
    text("Hermes", 680+2*(80),215);
    text("Zapp", 680+3*(80),215);
}




