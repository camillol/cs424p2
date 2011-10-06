class Character {
  String name;
  int totalLines;
  
  Character(String name_, int totalLines_)
  {
    name = name_;
    totalLines = totalLines_;
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
    characters.put(pieces[0], new Character(pieces[0], parseInt(pieces[1])));
    return true;
  }
}

