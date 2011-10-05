View rootView;

void setup()
{
  size(1024, 768);
  smooth();
  rootView = new View(0, 0, 1024, 768);
  
  // test
  rootView.subviews.add(new HBarTest(100, 200, 200, 20));
  rootView.subviews.add(new HBarTest(300, 100, 200, 20));
}

void draw()
{
  background(30, 30, 30);
  fill(#779999);
  noStroke();
  rect(0,0,width,height);
  rootView.draw();
}

void mousePressed()
{
  rootView.mousePressed(mouseX, mouseY);
}

void mouseDragged()
{
  rootView.mouseDragged(mouseX, mouseY);
}

void mouseClicked()
{
  rootView.mouseClicked(mouseX, mouseY);
}

