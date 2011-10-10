class PieChart extends View
{

	//input list of angles that sum up to 360
	ArrayList angles=new ArrayList();//format charactername:angle
	float centerX,centerY;
	float diameter;

        CharacterList characters;
	

	PieChart(float x_,float y_, float w_,float h_, ArrayList angles,CharacterList characters)
	{
		super(x_,y_,w_,h_);
		this.angles=angles;
		centerX= w_/2;
		centerY= h_/2;
		diameter=min(w_,h_);
                this.characters=characters;
	}
	
        void replaceAnglesList(ArrayList newAngles)
        {
          this.angles=newAngles;
        }
	void drawContent()
	{
		float prevAngle=0;
                color prevColor=#FFFFFF;
		for(int i=0;i<angles.size();i++)
		{
  
                        String[] anglesParts=((String)angles.get(i)).split(":");
                        
                        String characterName=anglesParts[0];
  			float thisAngle=Float.parseFloat(anglesParts[1]);
  			Character thisCharacter=characters.get(characterName);
  
                        //character not matching with characters list
                        if(thisCharacter!=null)
                        {
                          prevColor=thisCharacter.keyColor;
                          fill(thisCharacter.keyColor);
                        }
                        else
                        {
                            //need to fill characters color
                            if(prevColor!=#FFFFFF)
                            {
                              prevColor=#FFFFFF;
                              fill(#FFFFFF);
                            }
                            else
                            {
                              prevColor=#000000;
                              fill(#000000);
                                
                            }
                        }
               			
                        arc(centerX,centerY,diameter,diameter,prevAngle,prevAngle+radians(thisAngle));
			prevAngle+=radians(thisAngle);
			
		}
	}



}
