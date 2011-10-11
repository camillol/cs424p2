import processing.core.*; 
import processing.xml.*; 

import java.awt.Graphics2D; 
import java.awt.Shape; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class project2 extends PApplet {




Graphics2D g2;
Shape[] clipStack;
int clipIdx;

DataClass data;

View rootView;

Object viewTarget;  // null when overall, Season when season, Episode when episode
Animator viewTotalLines;

CharacterList characters;
Season[] seasons;

int shipMain = 0xff73D689;
int shipDark = 0xff3D7C52;
int shipLight = 0xffA9F597;
int ship2Main = 0xff25684D;
int ship2Dark = 0xff153D39;
int ship2Light = 0xff39A27F;
int shipRed = 0xff9B342D;
int shipRedDark = 0xff4C1819;

final int seasonEpsViewWidth = 600;
final int seasonEpsViewHeight = 100;
final int seasonEpsViewVGap = 8;
final int seasonEpsViewHeightNgram = 60;

final int ngramListH = 200;
final int overallButtonH = 20;
final int ngramViewH = 28 + ngramListH + 10 + overallButtonH;

SeasonEpsView seasonViews[];
Animator seasonY[];
Button overallButton;

PieChart pieChart;

NgramTable ngrams;
HashMap<Character,CharNgramTable> charNgrams;
boolean ngramMode = false;
Animator ngramModeAnimator;
Ngram activeNgram = null;
Character activeNgramChar = null;

NgramView ngramView;
Button ngramButton;
ListBox ngramList;


Button allActiveButton;

StatsView statsView;
Animator statsViewY;

public void setupG2D()
{
  g2 = ((PGraphicsJava2D)g).g2;
  clipStack = new Shape[32];
  clipIdx = 0;
}

public void setup()
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
  
  ngramView = new NgramView(30, ngramY(), seasonEpsViewWidth, ngramViewH);
  rootView.subviews.add(ngramView);
  
  ngramButton = new Button(0, ngramViewH-overallButtonH, 140, overallButtonH, "n-grams", 18, false, "n-grams", true);
  ngramView.subviews.add(ngramButton);

  ngramList = new ListBox(0, 28, 600, ngramListH, new MissingListDataSource("select a character"));
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

public void loadCharacters()
{
  characters = new CharacterList("characters.txt");
}

public String[] namesMatching(String[] names, String re)
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

public void loadSeasons()
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

public void loadNgrams()
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

public float seasonViewHeight()
{
  return map(ngramModeAnimator.value, 0.0f, 1.0f, seasonEpsViewHeight, seasonEpsViewHeightNgram);
}

public float ngramY()
{
  return map(ngramModeAnimator.value, 0.0f, 1.0f, overallButtonH + 10 - ngramViewH - 1, 0);
//  return map(ngramModeAnimator.value, 0.0, 1.0, height - 30, seasonEpsTop + (seasonViewHeight() + seasonEpsViewVGap)*seasons.length);
//  return seasonEpsTop + (seasonViewHeight() + seasonEpsViewVGap)*seasons.length;
}

public float overallY()
{
  return ngramY() + ngramViewH + 10;
}

public float seasonEpsTop()
{
  if (ngramMode) {
    return ngramViewH + 10 + overallButtonH + seasonEpsViewVGap;
  } else {
    return 30 + 10 + overallButtonH + seasonEpsViewVGap;
  }
}

public void draw()
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
public void clipRect(int x, int y, int w, int h)
{
  g2.clipRect(x, y, w, h);
}

public void clipRect(float x, float y, float w, float h)
{
  g2.clipRect((int)x, (int)y, (int)w, (int)h);
}

public void noClip()
{
  g2.setClip(null);
}

public void pushClip()
{
  clipStack[clipIdx++] = g2.getClip();
}

public void popClip()
{
  g2.setClip(clipStack[--clipIdx]);
  clipStack[clipIdx] = null;
}

public void mousePressed()
{
  rootView.mousePressed(mouseX, mouseY);
}

public void mouseDragged()
{
  rootView.mouseDragged(mouseX, mouseY);
}

public void mouseClicked()
{
  rootView.mouseClicked(mouseX, mouseY);
}

public void setViewTarget(Object target)
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

public void retargetSeasonYs()
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

public void setNgramMode(boolean ngmode)
{
  ngramMode = ngmode;
  overallButton.myFlag = !ngmode;
  ngramButton.myFlag = ngmode;
  ngramModeAnimator.target(ngramMode ? 1.0f : 0.0f);
  retargetSeasonYs();
}

public void buttonClicked(Object element)
{
  PImage myImage;
  if (Character.class.isInstance(element)) {
    Character character = (Character)element;
    character.setActive(!character.active);
    characters.setAllActive(countActive == 0);
    updateActiveTotals();
    CharNgramTable cng = charNgrams.get(character);
    activeNgramChar = character;
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

public void updateActiveTotals()
{
  for (int i = 0; i < seasons.length; i++) {
    seasons[i].updateActiveTotals();
  }
}

public void drawLabels(){
    text("Fry", 680+0*(80),142);
    text("Bender", 680+1*(80),142);
    text("Leela", 680+2*(80),142);
    text("Farnsworth", 680+3*(80),142);
    text("Zoidberg", 680+0*(80),215);
    text("Amy", 680+1*(80),215);
    text("Hermes", 680+2*(80),215);
    text("Zapp", 680+3*(80),215);
}




static class Animator {
  static List<Animator> allAnimators;  /* looks like we can use generics after al */
  
  final float attraction = 0.2f;
  final float reached_threshold = 10e-3f;
  
  float value;
  float target;
  float oldtarget;
  boolean targeting;
  float velocity;
  
  Animator()
  {
    if (allAnimators == null) allAnimators = new ArrayList();
    allAnimators.add(this);
    targeting = false;
  }
  
  Animator(float value_)
  {
    this();
    value = value_;
  }
  
  public void close()
  {
    allAnimators.remove(this);
  }
  
  public void set(float value_)
  {
    value = value_;
  }
  
  public void target(float target_)
  {
    if (target_ != target) oldtarget = target;
    target = target_;
    targeting = (target != value);
  }
  
  public void update()
  {
    if (!targeting) return;
    
    float a = attraction * (target - value);
    velocity = (velocity + a) / 2;
    value += velocity;
    
    if (abs(target - value) < reached_threshold) {
      value = target;
      targeting = false;
      velocity = 0;
    }
  }
  
  public static void updateAll()
  {
    for (Animator animator : allAnimators) animator.update();
  }
}

class Button extends View
{
  int myColor = color(255,255,255,0);
  boolean myFlag = false;
  PImage myImage;
  boolean hasImage = false;
  String myLabel;
  boolean hasText = false;
  PFont fontA;
  Object myElement;
  int myFontSize;
  boolean myVertical = false;
  boolean isDirectional = false;
  boolean hasDirection;
  boolean selectButton = false;
  boolean hasSelect;

  Button(float x_, float y_, float w_, float h_, Object element)
  {
    super(x_,y_,w_,h_);
  }
  
  Button(float x_, float y_, float w_, float h_, Object element, PImage theImage, boolean isDirectional)
  {
    super(x_,y_,w_,h_);
    hasImage = true;
    myImage = theImage;
    if(!isDirectional){
      theImage.resize(50, 50);
    }
    else if(isDirectional){
      theImage.resize(14,14);
    }
    myElement = element;
    hasDirection = isDirectional;
  }
  
  Button(float x_, float y_, float w_, float h_, Object element, int fontSize, boolean vertical, String theLabel, boolean selectButton)
  {
    super(x_,y_,w_,h_);
    hasText = true;
    myLabel = theLabel;
    myFontSize = fontSize;
    fontA = loadFont("Helvetica-Light-"+myFontSize+".vlw");
    myElement = element;
    myVertical = vertical;
    hasSelect = selectButton;
  }
  
  public boolean selected()
  {
    return myFlag;
  }
  
  public void drawContent()
  {
    if (hasImage && !hasDirection && !hasSelect) {
      if (selected()) tint(0, 153, 204, 126);
      else noTint();
      image(myImage,0,0);
    }
    else if (hasImage && hasDirection && !hasSelect) {
      noTint(); 
      fill(0);
      stroke(1);
      // bounding box for the directional buttons
      // makes it pop out a bit easier
      rect(0-1,0-1,w+1,h+1);
      image(myImage,0,0);
    }

    if (hasText){
      textFont(fontA, myFontSize);
      fill(selected() ? shipRed : shipLight);
      noStroke();
      rect(0,0,w,h);
      fill(selected() ? 255 : shipRedDark);

      if (myVertical) {
        textAlign(LEFT, TOP);
        pushMatrix();
        translate(0,h);
        rotate(3*HALF_PI);
        text(myLabel, 0, 0);
        popMatrix();
      } 

      if(hasText && !myVertical){
        text(myLabel,0,0);
      }
    }
  }
  

  public boolean contentClicked(float lx, float ly)
  {
    if(hasDirection){
      tint(0, 130,109,200);
      image(myImage,x,y);
    }
        
    buttonClicked(myElement);
    return true;
  }
  
}

class CharacterButton extends Button {
  final int highlightWidth = 4;
  
  CharacterButton(float x_, float y_, float w_, float h_, Character character)
  {
    super(x_,y_,w_,h_, character, character.img, false);
  }
  
  public boolean selected()
  {
    Character character = (Character)myElement;
    return character.active;
  }
  
  public void drawContent()
  {
    Character character = (Character)myElement;
    if (selected()) {
      fill(character.keyColor);
      noStroke();
      rect(-highlightWidth, -highlightWidth, w+highlightWidth*2, h+highlightWidth*2);
    }
    image(myImage,0,0);
  }
}
boolean allActive = true;
int countActive = 0;

class Character implements Comparable {
  String name;
  int totalLines;
  int totalEps;
  int keyColor;
  PImage img;
  boolean active;
  Animator activeAnimator;
  
  Character(String name_, int totalLines_, int totalEps_, int keyColor_, PImage img_)
  {
    name = name_;
    totalLines = totalLines_;
    totalEps = totalEps_;
    keyColor = keyColor_;
    img = img_;
    activeAnimator = new Animator();
    setActive(false);
  }
  
  public int compareTo(Object o) {
    Character other = (Character)o;
    if (totalLines > other.totalLines) return -1;
    else if (totalLines < other.totalLines) return 1;
    else return name.compareTo(other.name);
  }
  
  public void setActive(boolean act)
  {
    if (active != act) {
      countActive += act ? 1 : -1;
    }
    active = act;
    activeAnimator.target(active || allActive ? 1.0f : 0.0f);
  }
}

class CharacterList extends TSVBase implements ListDataSource {
  HashMap charMap;
  ArrayList charList;
  
  CharacterList(String filename) {
    super(filename, false);  // this loads the data
  }
  
  public void allocateData(int rows)
  {
    charMap = new HashMap(rows);
    charList = new ArrayList(rows);
  }
  
  public void resizeData(int rows) {}
  
  public boolean createItem(int i, String[] pieces)
  {
    int keycolor;
    try {
      keycolor =  color(unhex("FF"+pieces[3]));
    } catch (NumberFormatException e) {
      keycolor = 0;
    }

    Character character = new Character(pieces[0],
      parseInt(pieces[1]),
      parseInt(pieces[2]),
      keycolor,
      pieces[4].equals("") ? null : loadImage(pieces[4])
      );
    charMap.put(pieces[0], character);
    charList.add(character);
    return true;
  }
  
  public Iterator iterator() {
    return charList.iterator();
  }
  
  public Character get(String name)
  {
    return (Character)charMap.get(name);
  }
  
  public Character get(int index)
  {
    return (Character)charList.get(index);
  }
  
  public int count()
  {
    return charList.size();
  }
  
  public void setAllActive(boolean act)
  {
    allActive = act;
    allActiveButton.myFlag = act;
    Iterator it = iterator();
    while (it.hasNext()) {
      Character character = (Character)it.next();
      character.setActive(character.active);  /* force animator targeting */
    }
  }
  
  public String getText(int index)
  {
    return get(index).name;
  }
  
  public boolean selected(int index)
  {
    return get(index).active;
  }
}

class DataClass
{
  
        HashMap episodeCharactersMap=new HashMap();
        //stores list of episodes in each season
	HashMap seasonMap=new HashMap();
        //stores each characters dialog count by season and episode
	HashMap episodeMap=new HashMap();

        HashMap episodeTotalMap=new HashMap();


        HashMap episodeAnglesMap=new HashMap();


        //statistics of each season based on key:(seasonname) value:(hashmap)
        HashMap seasonStatsMap=new HashMap();
        
        //stores total count for each season
        HashMap seasonStatsTotalMap=new HashMap();
        
        HashMap seasonAnglesMap=new HashMap();
        //statistics of whole season key:character value:count
        HashMap wholeStatsMap=new HashMap();
        
        float wholeStatsTotal;
        
        ArrayList wholeAngles=new ArrayList();
        
        //appearance list of characters returns list of episode appearance 
        HashMap characterAppearanceMap=new HashMap();
        
        //ArrayList wholeStats=new ArrayList();

        
        java.io.File file;

        DataClass(String folderName)
        {
          processWholeStats(folderName);
          
          System.out.println(wholeStatsMap.keySet().size()+" "+wholeStatsTotal);
          processSeasonStats(folderName+"/seasonaggregate");
          
          processEpisodeStats(folderName+"/individualseasons");
          
          processCharacterAppearance(folderName);
          
//          processEpisodeCharacters(folderName);
        }
        
        
        public void processEpisodeCharacters(String folderName)
        {
          String[] episodeCharactersLines=loadStrings(folderName+"/EpisodeCharList");
          
          for(int i=0;i<episodeCharactersLines.length;i++)
          {
            String row=episodeCharactersLines[i];
            String[] rowParts=row.split("###");
            String keyPart=rowParts[0];
            String[] characters=rowParts[1].split("\t");
            ArrayList tempList=new ArrayList();
            for(int j=0;j<characters.length;j++)
            {
              tempList.add(characters[j]);
            }
            episodeCharactersMap.put(keyPart,tempList);
          }
        }
        
        public ArrayList getEpisodeCharactersList(String episodeName)
        {
          return (ArrayList)episodeCharactersMap.get(episodeName);
        }
        
        public float getWholeStatsTotal()
        {
          return wholeStatsTotal;
        }
        
        
        public void processCharacterAppearance(String folderName)
        {
          String[] characterAppearanceLines=loadStrings(folderName+"/"+"characterAppearanceStats");
          
          for(int i=0;i<characterAppearanceLines.length;i++)
          {
            if(characterAppearanceLines[i].contains("###"))
            {
              String[] characterAppearanceLineParts=characterAppearanceLines[i].split("###");
              String keyPart=characterAppearanceLineParts[0];
            
              ArrayList appearance=new ArrayList();
              for(int j=1;j<characterAppearanceLineParts.length;j++)
              {
                appearance.add(characterAppearanceLineParts[j]);
              }
              characterAppearanceMap.put(keyPart,appearance);
           }
         }
          
        }

        
        
        public void processEpisodeStats(String folderName)
        {
          file=new File(dataPath(folderName));
          ArrayList files=new ArrayList();
          
          listFiles(file,files);
          
          
          for(int i=0;i<files.size();i++)
          {
            File episodeFile=(File)files.get(i);
            String inputFileName=episodeFile.getAbsolutePath();
                    
            
            String[] inputFileNameParts=episodeFile.getAbsolutePath().split("/");
            String fileName=inputFileNameParts[inputFileNameParts.length-1];
            String seasonName=inputFileNameParts[inputFileNameParts.length-2];
            String keyPart=fileName.split(" ")[0];
            float totalLines=0;
            if(seasonMap.containsKey(seasonName))
            {
              ArrayList listEpisodes=(ArrayList)seasonMap.get(seasonName);
              listEpisodes.add(fileName);
              seasonMap.put(seasonName,listEpisodes);
            }
            else
            {
              ArrayList listEpisodes=new ArrayList();
              listEpisodes.add(fileName);
              seasonMap.put(seasonName,listEpisodes);
              
            }
            //seasonMap.put(seasonName,keyPart);
            String[] episodeFileLines=loadStrings(inputFileName);
         
            
            HashMap tempEpisodeMap=new HashMap();
            
            for(int j=0;j<episodeFileLines.length;j++)
            {
              String[] episodeFileLineParts=episodeFileLines[j].split("###");
              totalLines+=Float.parseFloat(episodeFileLineParts[1]);
              tempEpisodeMap.put(episodeFileLineParts[0],episodeFileLineParts[1]);
            }
            episodeMap.put(keyPart,tempEpisodeMap);
            episodeTotalMap.put(keyPart,totalLines);
            
            ArrayList tempList=getEpisodeDataAngles(keyPart);
            episodeAnglesMap.put(keyPart,tempList);
            
          }
        }        
        
        public void processSeasonStats(String folderName)
        {
          
          file=new File(dataPath(folderName));
          ArrayList files=new ArrayList();
          
          listFiles(file,files);
          
          for(int j=0;j<files.size();j++)
          {
            File episodeFile=(File)files.get(j);
            float totalLines=0;
            String inputFileName=folderName+"/"+episodeFile.getName();
            System.out.println(inputFileName);
            String[] inputFileNameSplit=inputFileName.split("/");
            String statsFileName=inputFileNameSplit[2];
            String[] statsFileNameSplit=statsFileName.split(":");
            String keyPart=statsFileNameSplit[0];

            String[] seasonFileLines=loadStrings(inputFileName);
            HashMap tempSeasonMap=new HashMap();
            
            for(int k=0;k<seasonFileLines.length;k++)
            {
              String[] seasonLineParts=seasonFileLines[k].split("###");
              tempSeasonMap.put(seasonLineParts[0],PApplet.parseInt(seasonLineParts[1]));
              System.out.println("in season "+seasonFileLines[k]);
              totalLines+=Float.parseFloat(seasonLineParts[1]);
            }
            seasonStatsTotalMap.put(keyPart,totalLines);
            seasonStatsMap.put(keyPart,tempSeasonMap);
            ArrayList tempAngles=getSeasonDataAngles(keyPart);
            seasonAnglesMap.put(keyPart,tempAngles);
          }
        }
        
        
        
        public void listFiles(File file,ArrayList files)
        {
          if(file.isDirectory())
          {
            File[] childrenFiles=file.listFiles();
            for(int j=0;j<childrenFiles.length;j++)
            {
                listFiles(childrenFiles[j],files);
            }
          }
          else
          {
            files.add(file);
          }
        }
        
        public void processWholeStats(String folderName)
        {
          String [] inputRows=loadStrings(folderName+"/wholeStats:sorted");
          float totalLines=0;
          for(int i=0;i<inputRows.length;i++)
          {
            String inputRow=inputRows[i];
            
            //wholeStats.add(inputRow);
            String[] inputRowParts=inputRow.split("###");
            String role=inputRowParts[0];
            int count=Integer.parseInt(inputRowParts[1]);
            
            wholeStatsMap.put(role,count);
            totalLines+=count;
            //System.out.println(inputRow);
          }
          wholeStatsTotal=totalLines;
          
          wholeAngles=getWholeDataAngles();
        }
       
        //returns list of episdoes in a season
        public ArrayList getListOfEpisodes(String seasonName)
        {
          
          return (ArrayList)seasonMap.get(seasonName);
          
        }
        
        //returns hashmap of character:dialogcount for each season
        public HashMap getSeasonData(String seasonName)
        {
          return (HashMap)seasonStatsMap.get(seasonName);
        }
        
        
        public ArrayList getSeasonDataAngles(String seasonName)
        {
          ArrayList seasonAngles=new ArrayList();
          
          HashMap thisSeasonMap=(HashMap)seasonStatsMap.get(seasonName);
          
          float total=Float.parseFloat(seasonStatsTotalMap.get(seasonName).toString());
          
          Set<String> keys=thisSeasonMap.keySet();
          
          Iterator<String> thisSeasonIterator=keys.iterator();
          
          while(thisSeasonIterator.hasNext())
          {
            String seasonCharacter=thisSeasonIterator.next();
            float count=Float.parseFloat(thisSeasonMap.get(seasonCharacter).toString());
            seasonAngles.add(seasonCharacter+":"+(count/total)*360);
            
          }
          
          return seasonAngles;
          
        }
        
        public Float getSeasonStatsTotal(String seasonName)
        {
           return (Float)seasonStatsTotalMap.get(seasonName);
        }
        
        //returns angleslist by season
        public ArrayList getSeasonAnglesList(String seasonName)
        {
          return (ArrayList) seasonAnglesMap.get(seasonName);
        }
        
        
        //returns hashmap of character:dialogcount for each episode
        public HashMap getEpisodeData(String episodeName)
        {
          return (HashMap)episodeMap.get(episodeName);
        }
        
        //retunds character:angle for each episode
        public ArrayList getEpisodeDataAngles(String episode)
        {
          ArrayList episodeAngles=new ArrayList();
          HashMap thisEpisodeMap=(HashMap)episodeMap.get(episode);
          
          float total=Float.parseFloat(episodeTotalMap.get(episode).toString());
          
          Set<String> keys=thisEpisodeMap.keySet();
          
          Iterator<String> thisEpisodeIterator=keys.iterator();
          
          while(thisEpisodeIterator.hasNext())
          {
            String thisEpisodeChar=thisEpisodeIterator.next();
            float characterCount=Float.parseFloat(thisEpisodeMap.get(thisEpisodeChar).toString());
            
            episodeAngles.add(thisEpisodeChar+":"+(characterCount/total)*360);
            
          }
          
          return episodeAngles;
        }
        
        public ArrayList getEpisodeCharacters(String episodeName)
        {
          HashMap thisEpisodeMap=(HashMap)episodeMap.get(episodeName);
          
          Set<String> characters=thisEpisodeMap.keySet();
          
          Iterator<String> charactersIterator=characters.iterator();

          ArrayList charactersList=new ArrayList();
          
          while(charactersIterator.hasNext())
          {
            String charactersItem=charactersIterator.next();
            
            charactersList.add(charactersItem);
          }
          

          
          
          return charactersList;
        }
        
        //returns angleslist by episode
        public ArrayList getEpisodeAnglesList(String episodeName)
        {
          return (ArrayList)episodeAnglesMap.get(episodeName);
        }
        
        public ArrayList getCharacterAppearance(String character)
        {
          return (ArrayList)characterAppearanceMap.get(character);
        }
        
        //returns map of whole data
        public HashMap getWholeData()
        {
          return wholeStatsMap;
        }
        
        //returns whole data list of angles
        public ArrayList getWholeAnglesList()
        {
           return wholeAngles;
        }
        
        //precomputes angles for whole dataset
        public ArrayList getWholeDataAngles()
        {
          ArrayList characterAngles=new ArrayList();
          Set<String> keys=wholeStatsMap.keySet();
          
          Iterator<String> characterKey=keys.iterator();
          
//          float total=0;
//          
//          while(characterKey.hasNext())
//          {
//            int count=Integer.parseInt(wholeStatsMap.get(characterKey.next()).toString());
//            total+=count;
//          }
          
          characterKey=keys.iterator();
          
          while(characterKey.hasNext())
          {
            String currentCharacter=characterKey.next();
            float angle;
            float count=Float.parseFloat(wholeStatsMap.get(currentCharacter).toString());
            angle=(count/wholeStatsTotal)*360;
            characterAngles.add(currentCharacter+":"+angle);
          }
          return characterAngles;
        }
   
       
}
class DialogLine {
  String what;
  String when;
  Character[] who;
  
  DialogLine(String when_, Character[] who_, String what_)
  {
    when = when_;
    who = who_;
    what = what_;
  }
}

class Episode extends TSVBase {
  DialogLine[] dialogs;
  int season;
  int number;
  String title;
  TreeMap charLineCount;
  int totalLineCount;
  Animator activeTotal;
  
  Episode(String filename) {
    super(filename, false);  // this loads the data
    String[] groups = match(filename, "S(\\d+)E(\\d+) (.*)\\.txt");
    season = parseInt(groups[1]);
    number = parseInt(groups[2]);
    title = groups[3];
    activeTotal = new Animator();
    updateActiveTotal();
  }
  
  public void allocateData(int rows)
  {
    dialogs = new DialogLine[rows];
    charLineCount = new TreeMap();
  }
  
  public boolean createItem(int i, String[] pieces)
  {
    String[] names = pieces[1].split(";");
    Character[] chars = new Character[names.length];
    for (int j = 0; j < names.length; j++) {
      chars[j] = characters.get(names[j]);
      charLineCount.put(chars[j], getLineCount(chars[j]) + 1);
      totalLineCount++;
    }
    dialogs[i] = new DialogLine(pieces[0], chars, pieces[2]);
    return true;
  }
  
  public void resizeData(int rows)
  {
    dialogs = (DialogLine[]) subset(dialogs, 0, rows);
  }
  
  public int getLineCount(Character c)
  {
    Integer n = (Integer)charLineCount.get(c);
    if (n == null) return 0;
    else return n;
  }
  
  public void updateActiveTotal() {
    if (allActive) {
      activeTotal.target(totalLineCount);
    } else {
      int newActiveTotal = 0;
      Iterator i = charLineCount.entrySet().iterator();
      while (i.hasNext()) {
        Map.Entry entry = (Map.Entry)i.next();
        Character character = (Character)entry.getKey();
        int count = (Integer)entry.getValue();
        if (character.active) newActiveTotal += count;
      }
      activeTotal.target(newActiveTotal);
    }
  }
}
class HBarTest extends View {
  float level;
  
  HBarTest(float x_, float y_, float w_, float h_)
  {
    super(x_, y_, w_, h_);
    level = 0.5f;
  }
  
  public void drawContent()
  {
    noFill();
    stroke(0);
    rect(0, 0, w, h);
    fill(128);
    rect(0, 0, w*level, h);
  }
  
  public boolean contentPressed(float lx, float ly)
  {
    level = lx/w;
    return true;
  }
  
  public boolean contentDragged(float lx, float ly)
  {
    level = lx/w;
    return true;
  }
}



class InteractionChart extends View
{
	ArrayList episodeCharacters=new ArrayList();
        

	float w,h;
		
	InteractionChart(float x_,float y_, float w_,float h_, ArrayList episodeCharacters)
	{
		super(x_,y_,w_,h_);
		this.w=w_;
		this.h=h_;
		this.episodeCharacters=episodeCharacters;

	}
	
	public void drawContent()
	{
                //rectMode(CORNERS);
                
                strokeWeight(2);
		fill(0);


		rect(0,0,w,h);
		for(int i=0;i<episodeCharacters.size();i++)
		{
			String episodeCharacter=(String)episodeCharacters.get(i);
			Character character=characters.get(episodeCharacter);
			if(character!=null)
			{
				stroke(character.keyColor);
			}
			float x=map(i,0,episodeCharacters.size()-1,0,w);
			line(x,0,x,h);
		}
            strokeWeight(1);
	}

}
interface ListDataSource {
  public String getText(int index);
  public Object get(int index);
  public int count();
  public boolean selected(int index);
}

class MissingListDataSource implements ListDataSource {
  String msg;
  
  MissingListDataSource(String msg_) { msg = msg_; }
  public String getText(int index) { return msg; }
  public Object get(int index) { return null; }
  public int count() { return 1; }
  public boolean selected(int index) { return false; }
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
  
  public boolean contentClicked(float lx, float ly)
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
  int myColor = color(255,255,255);
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
  
  public int maxScroll()
  {
    return data.count() - PApplet.parseInt(h/rowHeight);
  }
  
  public void scrollTo(int index)
  {
    myListCounter = min(max(index, 0), maxScroll());
  }

  public void drawContent()
  {
    fill(myColor);
    rect(0,0,w,h);
    fill(0);
    noStroke();
   
    for(int i = myListCounter; i < myListCounter+(h/rowHeight) && i < data.count(); i++) {
      float rowy = (i-myListCounter)*rowHeight;
      if (data.selected(i)) {
        fill(shipRed);
        rect(0, rowy, w, rowHeight);
        fill(255);
      } else {
        fill(0);
      }
      text(data.getText(i), 8, rowy);
    }
  }
  
  public boolean contentClicked(float lx, float ly)
  {
    int index = PApplet.parseInt(ly/rowHeight) + myListCounter;
    buttonClicked(data.get(index));
    return true;
  }
}
class Ngram {
  String words;
  int count;
  Occurrence[] occurrences;
  
  Ngram(String words_, int count_, Occurrence[] occ)
  {
    words = words_;
    count = count_;
    occurrences = occ;
  }
}

class Occurrence {
  int season;
  int episode;
  int lineno;
  
  Occurrence(int s, int e, int l)
  {
    season = s;
    episode = e;
    lineno = l;
  }
  
  public boolean precedes(Episode ep)
  {
    return (season < ep.season || (season == ep.season && episode < ep.number));
  }
  
  public boolean within(Episode ep)
  {
    return (season == ep.season && episode == ep.number);
  }
}

class CharNgram {
  Ngram ngram;
  int count;
  float pvalue;
  
  CharNgram(Ngram ngram_, int count_, float pvalue_)
  {
    ngram = ngram_;
    count = count_;
    pvalue = pvalue_;
  }
}

class CharNgramTable extends TSVBase implements ListDataSource {
  ArrayList<CharNgram> charNgramList;
  HashMap<String,CharNgram> charNgramMap;
  
  CharNgramTable(String filename) {
    super(filename, false);  // this loads the data
  }
  
  public void allocateData(int rows)
  {
    charNgramMap = new HashMap<String,CharNgram>(rows);
    charNgramList = new ArrayList<CharNgram>(rows);
  }
  
  public boolean createItem(int i, String[] pieces)
  {
    String words = pieces[0];
    int count = parseInt(pieces[1]);
    float pvalue = parseFloat(pieces[2]);
    Ngram ng = ngrams.get(words);
    if (ng == null) return false;  /* we're skipping common ones */
    CharNgram cng = new CharNgram(ng, count, pvalue);
    charNgramMap.put(words, cng);
    charNgramList.add(cng);
    return true;
  }
  
  public void resizeData(int rows) {}
  
  public int count() {
    return charNgramList.size();
  }
  
  public CharNgram get(int index) {
    return charNgramList.get(index);
  }
  
  public String getText(int index) {
    return charNgramList.get(index).ngram.count + "  "+ charNgramList.get(index).ngram.words;
  }
  
  public boolean selected(int index) {
    return get(index).ngram == activeNgram;
  }
}

class NgramTable extends TSVBase {
  HashMap<String,Ngram> ngramMap;
  
  NgramTable(String filename) {
    super(filename, false);  // this loads the data
  }
  
  public void allocateData(int rows)
  {
    ngramMap = new HashMap<String,Ngram>(rows);
  }
  
  public boolean createItem(int i, String[] pieces)
  {
    int count = parseInt(pieces[0]);
    String words = pieces[1];
    boolean common = pieces[2].equals("C");
    if (common) return false;  /* skip ngrams that are common in general english */
    String[] occStrs = pieces[3].split(":");
    Occurrence[] occs = new Occurrence[occStrs.length];
    
    for (int j = 0; j < occStrs.length; j++) {
      String[] groups = match(occStrs[j], "S(\\d+)E(\\d+)L(\\d+)");
      int season = parseInt(groups[1]);
      int epnum = parseInt(groups[2]);
      int lineno = parseInt(groups[3]);
      occs[j] = new Occurrence(season, epnum, lineno);
    }
    ngramMap.put(words, new Ngram(words, count, occs));
    return true;
  }
  
  public void resizeData(int rows) {}
  
  public Ngram get(String words)
  {
    return (Ngram)ngramMap.get(words);
  }
}

class NgramView extends View {
  NgramView(float x_, float y_, float w_, float h_) {
    super(x_,y_,w_,h_);
  }
  
  public void drawContent() {
    if(activeNgramChar != null) {
      fill(0);
      text("Significant n-grams for " + activeNgramChar.name, 0, 8);
    }
  }
}
class PieChart extends View
{

	float centerX,centerY;
	float diameter;

        HashMap charLineAnimators;

	PieChart(float x_,float y_, float w_,float h_)
	{
		super(x_,y_,w_,h_);
		centerX= w_/2;
		centerY= h_/2;
		diameter=min(w_,h_);
                
                charLineAnimators = new HashMap();
                Iterator it = characters.iterator();
                while (it.hasNext()) {
                  Character character = (Character)it.next();
                  charLineAnimators.put(character, new Animator());
                }
	}

        public void updateCharAnimators()
        {
          HashMap selectedStats=null;
          if (viewTarget == null) {
            selectedStats = data.getWholeData();
          } else if (seasons[0].getClass().isInstance(viewTarget)) {
            Season season = (Season)viewTarget;
            selectedStats = data.getSeasonData("S0"+season.number);
          }
            // for vivek: go through characters and do
            // 
            Set<Character> charactersActive=charLineAnimators.keySet();
            Iterator<Character> charactersActiveIterator=charactersActive.iterator();
            while(charactersActiveIterator.hasNext())
            {
              Character thisActiveCharacter=charactersActiveIterator.next();
              Animator characterAnimator=(Animator)charLineAnimators.get(thisActiveCharacter);
              if(selectedStats.containsKey(thisActiveCharacter.name))
              {
                float dialogCount=(Integer)selectedStats.get(thisActiveCharacter.name);
                characterAnimator.target(dialogCount);
              }
              else
              {
                System.out.println(thisActiveCharacter.name);
                System.out.println("mismatch");
                characterAnimator.target(0);
              

            }
          }
        }
	
	public void drawContent()
	{
		float prevAngle=0;
                int prevColor=0xffFFFFFF;
                Set<Character> characterSet=charLineAnimators.keySet();
                Iterator<Character> characterSetIterator=characterSet.iterator();
                float total = viewTotalLines.value;
                
                while(characterSetIterator.hasNext())
                {
                  Character selectedCharacter=characterSetIterator.next();
                  Animator selectedCharacterAnimator=(Animator)charLineAnimators.get(selectedCharacter);
                  float currentValue=selectedCharacterAnimator.value;
                  float currentAngle=(currentValue/total)*360;
                  if(selectedCharacter!=null)
                  {
                          fill(selectedCharacter.keyColor);
                          prevColor=selectedCharacter.keyColor;
                          if(selectedCharacter.keyColor==0)
                          {
                            if(prevColor!=0xffFFFFFF)
                            {
                              fill(0xffFFFFFF);
                              prevColor=0xffFFFFFF;
                            }
                            else
                            {
                              fill(0xff000000);
                              prevColor=0xff000000;
                                                
                            }

                          }
                          
//                          if(selectedCharacter.keyColor!=prevColor)
//                          {
//                             fill(selectedCharacter.keyColor);
//                          }
//                          else
//                          {
//                              if(prevColor!=#FFFFFF)
//                              {
//                                prevColor=#FFFFFF;
//                                fill(#FFFFFF);
//                              }
//                              else
//                              {
//                                prevColor=#000000;
//                                fill(#000000);
//                              }
//
//                          }
                  }
            
                                   
                  arc(centerX,centerY,diameter,diameter,radians(prevAngle),radians(prevAngle)+radians(currentAngle));
                  
                  prevAngle+=currentAngle;
                }
	}

}
class Season {
  Episode[] episodes;
  int number;
  
  Season(int number_, String dirname)
  {
    number = number_;
    File dir = new File(dataPath(dirname));
    String[] names = namesMatching(dir.list(), "S(\\d+)E(\\d+).*");
    Arrays.sort(names);
    episodes = new Episode[names.length];
    for (int i = 0; i < names.length; i++) {
      episodes[i] = new Episode(dirname+"/"+names[i]);
    }
  }
  
  public void updateActiveTotals()
  {
    for (int i = 0; i < episodes.length; i++) {
      episodes[i].updateActiveTotal();
    }
  }
}
class SeasonEpsView extends View {
  final int maxEps = 26;
  final int barGap = 8;
  final int labelWidth = 20;
  final int labelFontSize = 18;
  int barWidth;
  Season season;
  Button button;
  int ngramOccIdx;
  String labelLong;
  String labelShort;
  
  SeasonEpsView(float x_, float y_, float w_, float h_, Season season_)
  {
    super(x_, y_, w_, h_);
    season = season_;
    barWidth = floor((w + barGap - (labelWidth + barGap)) / maxEps) - barGap;  // / maxEps or / season.episodes.length ?
    labelLong = "Season "+season.number;
    labelShort = "S"+season.number;
    button = new Button(0,0,labelWidth,h, season, labelFontSize, true, labelLong, false);
    subviews.add(button);
  }
  
  public void setHeight(float h_)
  {
    h = h_;
    button.h = h;
    button.myLabel = h < 80 ? labelShort : labelLong;
  }
  
  public void drawEpBar(int epnum)
  {
    int epidx = epnum - 1;
    pushMatrix();
    translate(labelWidth + barGap + epidx * (barWidth + barGap), 0);
    
    noFill();
    stroke(0);
    rect(0, 0, barWidth, h);
    
    noStroke();
    
    Episode episode = season.episodes[epidx];
    
    if (ngramMode) {
      fill(255);
      rect(0,0,barWidth,h);
      
      if (activeNgram != null) {
//        strokeWeight(2);
        while (ngramOccIdx < activeNgram.occurrences.length && (activeNgram.occurrences[ngramOccIdx].precedes(episode))) ngramOccIdx++;
        while (ngramOccIdx < activeNgram.occurrences.length && (activeNgram.occurrences[ngramOccIdx].within(episode))) {
          int lineno = activeNgram.occurrences[ngramOccIdx].lineno;
          DialogLine dialog = episode.dialogs[lineno];
          float liney = (float)lineno / episode.dialogs.length * h;
          float piecew = (float)barWidth / dialog.who.length;
          /* at this scale we can really only draw one character's lines, since they tend to overlap */
          for (int i = 0; i < dialog.who.length; i++) {
            Character c = dialog.who[i];
            if (c.active) {
              stroke(c.keyColor);
              line(/*piecew*i*/0, liney, /*piecew*(i+1)*/barWidth, liney);
              break;
            }
          }
          ngramOccIdx++;
        }
//        strokeWeight(1);
      }
    } else {
      Iterator i = episode.charLineCount.entrySet().iterator();
      float total = episode.activeTotal.value;
      float slicey = 0, sliceh;
      
      float a = 255.0f;
      if (episode.activeTotal.target == 0.0f) { /* none of the selected characters appear in this episode */
        a = map(episode.activeTotal.value, episode.activeTotal.oldtarget, episode.activeTotal.target, 255.0f, 0.0f);
        fill(224);
        rect(0,0,barWidth,h);
      }
      
      pushClip();
      clipRect(0,0,barWidth,h);
      while (i.hasNext()) {
        Map.Entry entry = (Map.Entry)i.next();
        Character character = (Character)entry.getKey();
        int count = (Integer)entry.getValue();
        
        if (character.activeAnimator.value > 0) {
          sliceh = (float)count/total*h*character.activeAnimator.value;
          fill(character.keyColor, a);
          rect(0,slicey,barWidth,sliceh);
          slicey += sliceh;
        }
      }
      popClip();
    }
    
    popMatrix();
  }
  
  public void drawLabel()
  {

    fill(shipLight);
    rect(0,0,labelWidth,h);
    fill(shipRedDark);
    textSize(18);
    textAlign(LEFT, TOP);
    pushMatrix();
    translate(0,h);
    rotate(3*HALF_PI);
    text("Season " + season.number, 0, 0);
    popMatrix();
  }
  
  public void drawContent()
  {
    fill(shipDark);
    rect(0,0,w,h);
    
//    drawLabel();
    ngramOccIdx = 0;
    for (int n = 1; n <= season.episodes.length; n++) {
      drawEpBar(n);
    }
  }
  
  public boolean contentPressed(float lx, float ly)
  {
    return true;
  }
  
  public boolean contentDragged(float lx, float ly)
  {
    return true;
  }
}

class StatsView extends View{
   int mySeason = 0;
   boolean isActive;
   int active;
   String characterName;
   String[] charList = new String[30];
   int myLines;
   HashMap seasonMap;


StatsView (float x_, float y_, float w_, float h_, Season season_){
  super(x_,y_,w_,h_);
  mySeason = season_ == null ? 0 : season_.number;
  
}

public void drawContent(){
  fill(255);
  rect(0,0,w,h);
  fill(0);
  text("Season "+mySeason +" Stats:", 0,0);
  
  checkActive();
  if(mySeason!=0)
  {
      seasonMap=data.getSeasonData("S0"+mySeason);
  }
  else
  {
    seasonMap=data.getWholeData();
  }

  for(int i = 0; i < charList.length;i++){
    if(charList[i] != null){
    text(charList[i] , 20, 20*i);
    Character myCharacter = characters.get(charList[i]);
    
    //myLines = myCharacter.totalLines;
    if(seasonMap.containsKey(myCharacter.name))
    {
          myLines=PApplet.parseInt(seasonMap.get(myCharacter.name).toString());
    }
    else
    {
      myLines=0;
    }

    text("Lines: "+myLines, 200, 20*i);
    }
  }
  for(int i = 0; i < charList.length;i++){
    charList[i] =null;
  }
}

public void checkActive(){
  Iterator it2 = characters.iterator();
  active = 0;
  while (it2.hasNext()){
        Character character = (Character)it2.next();
        isActive = character.active;
        characterName = character.name;
        if (isActive) {
          active += 1;

            charList[active]= characterName;
          
        }
      
    }

}
}
class TSVBase {
  boolean hasHeader;
  int rowCount = 0;
  int columnCount = 0;
  String[] columnNames;  // valid if hasHeader
  
  TSVBase(String filename, boolean hasHeader) {
    String[] rows = loadStrings(filename);  // actually text lines
    int i;
    
    columnNames = split(rows[0], TAB);
    columnCount = columnNames.length;
    if (hasHeader) {
      i = 1;
    } else {
      columnNames = null;
      i = 0;
    }

    allocateData(rows.length-i);
    
    for (; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }

      String[] pieces = split(rows[i], TAB);
      
      if (createItem(rowCount, pieces)) rowCount++;      
    }
    
    resizeData(rowCount);
  }
  
  public void allocateData(int rows)
  {
    println("UNIMPLEMENTED");
  }
  
  public boolean createItem(int i, String[] pieces)
  {
    println("UNIMPLEMENTED");
    return false;
  }
  
  public void resizeData(int rows)
  {
    println("UNIMPLEMENTED");
  }
  
  public int getRowCount() {
    return rowCount;
  }
  
  public int getColumnCount() {
    return columnCount;
  }
  
  
  public String getColumnName(int colIndex) {
    return columnNames[colIndex];
  }
  
  public String[] getColumnNames() {
    return columnNames;
  }
}

class VBar extends View {
  ListBox myList;
  
  VBar(float x_, float y_, float w_, float h_, ListBox theList)
  {
    super(x_, y_, w_, h_);
    myList = theList;
  }
  
  public float start()
  {
    return map(myList.myListCounter, 0, myList.maxScroll(), 0, h-14);
  }
  
  public void setStart(float start)
  {
    myList.myListCounter = (int)map(start, 0, h-14, 0, myList.maxScroll());
  }
  
  public void drawContent()
  {
    noFill();
    stroke(0);
    fill(255);
    rect(0, 0, w, h);
    fill(128);
    rect(0, start(), w, 14);
  }
  
  public boolean contentPressed(float lx, float ly)
  {
    if((ly <= h -7) && (ly >= 7)){
      setStart(ly - 7);
    }
    println(myList.myListCounter);
    return true;
  }
  
  public boolean contentDragged(float lx, float ly)
  {
    
    if((ly <= h -7) && (ly >= 7)){
      setStart(ly - 7);
    }
    println(myList.myListCounter);
  return true;
  }
}
class View {
  float x, y, w, h;
  ArrayList subviews;
  
  View(float x_, float y_, float w_, float h_)
  {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    subviews = new ArrayList();
  }
  
  public void draw()
  {
    pushMatrix();
    translate(x, y);
    // draw out content, then our subviews on top
    drawContent();
    for (int i = 0; i < subviews.size(); i++) {
      View v = (View)subviews.get(i);
      v.draw();
    }
    popMatrix();
  }
  
  public void drawContent()
  {
    // override this
    // when this is called, the coordinate system is local to the view,
    // i.e. 0,0 is the top left corner of this view
  }
  
  public boolean contentPressed(float lx, float ly)
  {
    // override this
    // lx, ly are in the local coordinate system of the view,
    // i.e. 0,0 is the top left corner of this view
    // return false if the click is to "pass through" this view
    return true;
  }
  
  public boolean contentDragged(float lx, float ly)
  {
    return true;
  }
  
  public boolean contentClicked(float lx, float ly)
  {
    return true;
  }

  public boolean ptInRect(float px, float py, float rx, float ry, float rw, float rh)
  {
    return px >= rx && px <= rx+rw && py >= ry && py <= ry+rh;
  }

  public boolean mousePressed(float px, float py)
  {
    if (!ptInRect(px, py, x, y, w, h)) return false;
    float lx = px - x;
    float ly = py - y;
    // check our subviews first
    for (int i = subviews.size()-1; i >= 0; i--) {
      View v = (View)subviews.get(i);
      if (v.mousePressed(lx, ly)) return true;
    }
    return contentPressed(lx, ly);
  }

  public boolean mouseDragged(float px, float py)
  {
    if (!ptInRect(px, py, x, y, w, h)) return false;
    float lx = px - x;
    float ly = py - y;
    // check our subviews first
    for (int i = subviews.size()-1; i >= 0; i--) {
      View v = (View)subviews.get(i);
      if (v.mouseDragged(lx, ly)) return true;
    }
    return contentDragged(lx, ly);
  }

  public boolean mouseClicked(float px, float py)
  {
    if (!ptInRect(px, py, x, y, w, h)) return false;
    float lx = px - x;
    float ly = py - y;
    // check our subviews first
    for (int i = subviews.size()-1; i >= 0; i--) {
      View v = (View)subviews.get(i);
      if (v.mouseClicked(lx, ly)) return true;
    }
    return contentClicked(lx, ly);
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "project2" });
  }
}
