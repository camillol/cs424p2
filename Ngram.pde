class Ngram {
  String words;
  int count;
  Occurrence[] occurrences;
  
  Ngram(String words_, int count_, Occurrence[] occ)
  {
    words = words_;
    count = count_;
    occurrences = occ;
  }
}

class Occurrence {
  int season;
  int episode;
  int lineno;
  Character[] chars;
  
  Occurrence(int s, int e, int l, Character[] c)
  {
    season = s;
    episode = e;
    lineno = l;
    chars = c;
  }
}

class NgramTable extends TSVBase {
  HashMap<String,Ngram> ngramMap;
  
  NgramTable(String filename) {
    super(filename, false);  // this loads the data
  }
  
  void allocateData(int rows)
  {
    ngramMap = new HashMap<String,Ngram>(rows);
  }
  
  boolean createItem(int i, String[] pieces)
  {
    int count = parseInt(pieces[0]);
    String words = pieces[1];
    String[] occStrs = pieces[2].split(":");
    Occurrence[] occs = new Occurrence[occStrs.length];
    
    for (int j = 0; j < occStrs.length; j++) {
      String[] groups = match(occStrs[j], "S(\\d+)E(\\d+)L(\\d+)-(.*)");
      int season = parseInt(groups[0]);
      int episode = parseInt(groups[1]);
      int lineno = parseInt(groups[2]);
      
      String[] names = groups[3].split(";");
      Character[] chars = new Character[names.length];
      for (int n = 0; n < names.length; n++) {
        chars[n] = characters.get(names[n]);
      }
      
      occs[j] = new Occurrence(season, episode, lineno, chars);
    }
    
    ngramMap.put(words, new Ngram(words, count, occs));
    return true;
  }
  
  void resizeData(int rows) {}
}
