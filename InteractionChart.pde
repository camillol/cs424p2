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
	
	void drawContent()
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
