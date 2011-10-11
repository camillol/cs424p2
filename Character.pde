boolean allActive = true;
int countActive = 0;

class Character implements Comparable {
  String name;
  int totalLines;
  int totalEps;
  color keyColor;
  PImage img;
  boolean active;
  Animator activeAnimator;
  
  Character(String name_, int totalLines_, int totalEps_, color keyColor_, PImage img_)
  {
    name = name_;
    totalLines = totalLines_;
    totalEps = totalEps_;
    keyColor = keyColor_;
    img = img_;
    activeAnimator = new Animator();
    setActive(false);
  }
  
  int compareTo(Object o) {
    Character other = (Character)o;
    if (totalLines > other.totalLines) return -1;
    else if (totalLines < other.totalLines) return 1;
    else return name.compareTo(other.name);
  }
  
  void setActive(boolean act)
  {
    if (active != act) {
      countActive += act ? 1 : -1;
    }
    active = act;
    activeAnimator.target(active || allActive ? 1.0 : 0.0);
  }
}

class CharacterList extends TSVBase implements ListDataSource {
  HashMap charMap;
  ArrayList charList;
  
  CharacterList(String filename) {
    super(filename, false);  // this loads the data
  }
  
  void allocateData(int rows)
  {
    charMap = new HashMap(rows);
    charList = new ArrayList(rows);
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

    Character character = new Character(pieces[0],
      parseInt(pieces[1]),
      parseInt(pieces[2]),
      keycolor,
      pieces[4].equals("") ? null : loadImage(pieces[4])
      );
    charMap.put(pieces[0], character);
    charList.add(character);
    return true;
  }
  
  Iterator iterator() {
    return charList.iterator();
  }
  
  Character get(String name)
  {
    return (Character)charMap.get(name);
  }
  
  Character get(int index)
  {
    return (Character)charList.get(index);
  }
  
  int count()
  {
    return charList.size();
  }
  
  void setAllActive(boolean act)
  {
    allActive = act;
    Iterator it = iterator();
    while (it.hasNext()) {
      Character character = (Character)it.next();
      character.setActive(character.active);  /* force animator targeting */
    }
  }
  
  String getText(int index)
  {
    return get(index).name;
  }
  
  boolean selected(int index)
  {
    return get(index).active;
  }
}

