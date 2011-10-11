class DialogLine {
  String what;
  String when;
  Character[] who;
  
  DialogLine(String when_, Character[] who_, String what_)
  {
    when = when_;
    who = who_;
    what = what_;
  }
}

class Episode extends TSVBase {
  DialogLine[] dialogs;
  int season;
  int number;
  String title;
  TreeMap charLineCount;
  int totalLineCount;
  Animator activeTotal;
  
  Episode(String filename) {
    super(filename, false);  // this loads the data
    String[] groups = match(filename, "S(\\d+)E(\\d+) (.*)\\.txt");
    season = parseInt(groups[1]);
    number = parseInt(groups[2]);
    title = groups[3];
    activeTotal = new Animator();
    updateActiveTotal();
  }
  
  void allocateData(int rows)
  {
    dialogs = new DialogLine[rows];
    charLineCount = new TreeMap();
  }
  
  boolean createItem(int i, String[] pieces)
  {
    String[] names = pieces[1].split(";");
    Character[] chars = new Character[names.length];
    for (int j = 0; j < names.length; j++) {
      chars[j] = characters.get(names[j]);
      charLineCount.put(chars[j], getLineCount(chars[j]) + 1);
      totalLineCount++;
    }
    dialogs[i] = new DialogLine(pieces[0], chars, pieces[2]);
    return true;
  }
  
  void resizeData(int rows)
  {
    dialogs = (DialogLine[]) subset(dialogs, 0, rows);
  }
  
  int getLineCount(Character c)
  {
    Integer n = (Integer)charLineCount.get(c);
    if (n == null) return 0;
    else return n;
  }
  
  void updateActiveTotal() {
    if (allActive) {
      activeTotal.target(totalLineCount);
    } else {
      int newActiveTotal = 0;
      Iterator i = charLineCount.entrySet().iterator();
      while (i.hasNext()) {
        Map.Entry entry = (Map.Entry)i.next();
        Character character = (Character)entry.getKey();
        int count = (Integer)entry.getValue();
        if (character.active) newActiveTotal += count;
      }
      activeTotal.target(newActiveTotal);
    }
  }
}
