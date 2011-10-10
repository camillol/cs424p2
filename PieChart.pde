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

        void updateCharAnimators()
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
	
	void drawContent()
	{
		float prevAngle=0;
                color prevColor=#FFFFFF;
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
                            if(prevColor!=#FFFFFF)
                            {
                              fill(#FFFFFF);
                              prevColor=#FFFFFF;
                            }
                            else
                            {
                              fill(#000000);
                              prevColor=#000000;
                                                
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
