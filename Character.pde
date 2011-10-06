class Character {
  String name;
  int totalLines;
  int totalEps;
  
  Character(String name_, int totalLines_, int totalEps_)
  {
    name = name_;
    totalLines = totalLines_;
    totalEps = totalEps_;
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
  
  boolean createItem(int i, String[] pieces)
  {
    characters.put(pieces[0], new Character(pieces[0], parseInt(pieces[1]), parseInt(pieces[2])));
    return true;
  }
}

