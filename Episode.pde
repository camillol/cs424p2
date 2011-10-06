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
  HashMap charLineCount;
  
  Episode(String filename) {
    super(filename, false);  // this loads the data
    String[] groups = match(filename, "S(\\d+)E(\\d+) (.*)\\.txt");
    season = parseInt(groups[0]);
    number = parseInt(groups[1]);
    title = groups[2];
  }
  
  void allocateData(int rows)
  {
    dialogs = new DialogLine[rows];
    charLineCount = new HashMap(characters.size());
  }
  
  boolean createItem(int i, String[] pieces)
  {
    Character c = getCharacter(pieces[1]);
    dialogs[i] = new DialogLine(pieces[0],
      c,
      pieces[2]);
    charLineCount.put(c, getLineCount(c)+1);
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
}
