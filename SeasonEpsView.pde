class SeasonEpsView extends View {
  final int maxEps = 26;
  final int barGap = 8;
  int barWidth;
  Season season;
  
  SeasonEpsView(float x_, float y_, float w_, float h_, Season season_)
  {
    super(x_, y_, w_, h_);
    season = season_;
    barWidth = floor((w + barGap) / season.episodes.length) - barGap;  // / maxEps
  }
  
  void drawEpBar(int epnum)
  {
    int epidx = epnum - 1;
    pushMatrix();
    translate(epidx * (barWidth + barGap), 0);
    
    noFill();
    stroke(0);
    rect(0, 0, barWidth, h);
    
    noStroke();
    
    Episode episode = season.episodes[epidx];
    Iterator i = episode.charLineCount.entrySet().iterator();
    int total = episode.totalLineCount;
    float slicey = 0, sliceh;
    
    while (i.hasNext()) {
      Map.Entry entry = (Map.Entry)i.next();
      Character character = (Character)entry.getKey();
      int count = (Integer)entry.getValue();
      
      sliceh = (float)count/total*h;
      fill(character.keyColor);
      rect(0,slicey,barWidth,sliceh);
      slicey += sliceh;
    }
    
    popMatrix();
  }
  
  void drawContent()
  {
    fill(shipDark);
    rect(0,0,w,h);
    for (int n = 1; n <= season.episodes.length; n++) {
      drawEpBar(n);
    }
  }
  
  boolean contentPressed(float lx, float ly)
  {
    return true;
  }
  
  boolean contentDragged(float lx, float ly)
  {
    return true;
  }
}

