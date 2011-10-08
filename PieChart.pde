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
		centerX= x_/2;
		centerY=y_/2;
		diameter=min(w_,h_);
	}
	
	void drawContent()
	{
		float prevAngle=0;
		for(int i=0;i<angles.size();i++)
		{
                        
  			float thisAngle=Float.parseFloat(angles.get(i).toString());
        		fill(thisAngle*3.0);
                         System.out.println(thisAngle);
                        arc(centerX,centerY,diameter,diameter,prevAngle,prevAngle+radians(thisAngle));
			prevAngle+=radians(thisAngle);
			
		}
	}

}
