class StatsView extends View{
  


StatsView (float x_, float y_, float w_, float h_, Season season_, CharacterList characters_){
  super(x_,y_,w_,h_);
}

void drawContent(){
  fill(255);
  rect(0,0,w,h);
}
}
