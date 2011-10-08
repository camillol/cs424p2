class PieChart extends View
{

	//input list of angles that sum up to 360
	ArrayList angles=new ArrayList();
	float centerX,centerY;
	float diameter;
	

	PieChart(float x_,float y_, float w_,float h_, ArrayList angles)
	{
		super(x_,y_,w_,h_);
		this.angles=angles;
		centerX= w_/2;
		centerY= h_/2;
		diameter=min(w_,h_);
	}
	
	void drawContent()
	{
		float prevAngle=0;
		for(int i=0;i<angles.size();i++)
		{
                        
  			float thisAngle=Float.parseFloat(angles.get(i).toString());
  			
  			//need to fill characters color
        		fill(thisAngle*3.0);
                        arc(centerX,centerY,diameter,diameter,prevAngle,prevAngle+radians(thisAngle));
			prevAngle+=radians(thisAngle);
			
		}
	}

}
