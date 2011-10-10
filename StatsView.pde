class StatsView extends View{
   int mySeason = 0;
   boolean isActive;
   int active;
   String characterName;
   String[] charList = new String[30];
   int myLines;
   CharacterList myCharacters;


StatsView (float x_, float y_, float w_, float h_, Season season_, CharacterList characters_){
  super(x_,y_,w_,h_);
  mySeason = season_.number;
  myCharacters = characters_;
}

void drawContent(){
  fill(255);
  rect(0,0,w,h);
  fill(0);
  text("Season "+mySeason +" Stats:", 0,0);
  checkActive();
  for(int i = 0; i < charList.length;i++){
    if(charList[i] != null){
    text(charList[i] , 20, 20*i);
    Character myCharacter = myCharacters.get(charList[i]);
    myLines = myCharacter.totalLines;
    text("Lines: "+myLines, 200, 20*i);
    }
  }
  for(int i = 0; i < charList.length;i++){
    charList[i] =null;
  }
}

void checkActive(){
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
