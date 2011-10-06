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

class EpisodeTranscript extends TSVBase {
  DialogLine[] dialogs;
  int season;
  int number;
  String title;
  
  EpisodeTranscript(String filename) {
    super(filename, false);  // this loads the data
    String[] groups = match(filename, "S(\\d+)E(\\d+) (.*)\\.txt");
    season = parseInt(groups[0]);
    number = parseInt(groups[1]);
    title = groups[2];
  }
  
  void allocateData(int rows)
  {
    dialogs = new DialogLine[rows];
  }
  
  boolean createItem(int i, String[] pieces)
  {
    dialogs[i] = new DialogLine(pieces[0],
      getCharacter(pieces[1]),
      pieces[2]);
    return true;
  }
  
  void resizeData(int rows)
  {
    dialogs = (DialogLine[]) subset(dialogs, 0, rows);
  }
}
