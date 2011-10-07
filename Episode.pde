class DialogLine {
  String what;
  String when;
  Character who;
  
  DialogLine(String when_, Character who_, String what_)
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
  int activeTotal;
  
  Episode(String filename) {
    super(filename, false);  // this loads the data
    String[] groups = match(filename, "S(\\d+)E(\\d+) (.*)\\.txt");
    season = parseInt(groups[0]);
    number = parseInt(groups[1]);
    title = groups[2];
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
    for (int j = 0; j < names.length; j++) {
      Character c = characters.get(names[j]);
      dialogs[i] = new DialogLine(pieces[0], c, pieces[2]);
      charLineCount.put(c, getLineCount(c)+1);
      totalLineCount++;
    }
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
      activeTotal = totalLineCount;
    } else {
      activeTotal = 0;
      Iterator i = charLineCount.entrySet().iterator();
      while (i.hasNext()) {
        Map.Entry entry = (Map.Entry)i.next();
        Character character = (Character)entry.getKey();
        int count = (Integer)entry.getValue();
        if (character.active) activeTotal += count;
      }
    }
  }
}
