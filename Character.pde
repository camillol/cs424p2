class Character implements Comparable {
  String name;
  int totalLines;
  int totalEps;
  color keyColor;
  PImage img;
  
  Character(String name_, int totalLines_, int totalEps_, color keyColor_, PImage img_)
  {
    name = name_;
    totalLines = totalLines_;
    totalEps = totalEps_;
    keyColor = keyColor_;
    img = img_;
  }
  
  int compareTo(Object o) {
    Character other = (Character)o;
    if (totalLines > other.totalLines) return -1;
    else if (totalLines < other.totalLines) return 1;
    else return name.compareTo(other.name);
  }
}

class CharacterList extends TSVBase {
  TreeMap characters;
  
  CharacterList(String filename) {
    super(filename, false);  // this loads the data
  }
  
  void allocateData(int rows)
  {
    characters = new TreeMap();
  }
  
  void resizeData(int rows) {}
  
  boolean createItem(int i, String[] pieces)
  {
    color keycolor;
    try {
      keycolor =  color(unhex("FF"+pieces[3]));
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

