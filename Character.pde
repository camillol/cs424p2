class Character {
  String name;
  int totalLines;
  int totalEps;
  color keycolor;
  PImage img;
  
  Character(String name_, int totalLines_, int totalEps_, color keycolor_, PImage img_)
  {
    name = name_;
    totalLines = totalLines_;
    totalEps = totalEps_;
    keycolor = keycolor_;
    img = img_;
  }
}

class CharacterList extends TSVBase {
  HashMap characters;
  
  CharacterList(String filename) {
    super(filename, false);  // this loads the data
  }
  
  void allocateData(int rows)
  {
    characters = new HashMap(rows);
  }
  
  void resizeData(int rows) {}
  
  boolean createItem(int i, String[] pieces)
  {
    color keycolor;
    try {
      keycolor =  color(unhex(pieces[3]), 255);
    } catch (NumberFormatException e) {
      keycolor = 0;
    }

    characters.put(pieces[0], new Character(pieces[0],
      parseInt(pieces[1]),
      parseInt(pieces[2]),
      keycolor,
      pieces[4].equals("") ? null : loadImage(pieces[4])
      ));
    return true;
  }
}

