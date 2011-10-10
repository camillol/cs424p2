class SeasonEpsView extends View {
  final int maxEps = 26;
  final int barGap = 8;
  final int labelWidth = 20;
  final int labelFontSize = 18;
  int barWidth;
  Season season;
  Button button;
  int ngramOccIdx;
  
  SeasonEpsView(float x_, float y_, float w_, float h_, Season season_)
  {
    super(x_, y_, w_, h_);
    season = season_;
    barWidth = floor((w + barGap - (labelWidth + barGap)) / maxEps) - barGap;  // / maxEps or / season.episodes.length ?
    button = new Button(0,0,labelWidth,h, season, labelFontSize, true, "Season "+season.number);
    subviews.add(button);
  }
  
  void drawEpBar(int epnum)
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
      
      float a = 255.0;
      if (episode.activeTotal.target == 0.0) { /* none of the selected characters appear in this episode */
        a = map(episode.activeTotal.value, episode.activeTotal.oldtarget, episode.activeTotal.target, 255.0, 0.0);
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
  
  void drawLabel()
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
  
  void drawContent()
  {
    fill(shipDark);
    rect(0,0,w,h);
    
//    drawLabel();
    ngramOccIdx = 0;
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

