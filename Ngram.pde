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
  
  Occurrence(int s, int e, int l)
  {
    season = s;
    episode = e;
    lineno = l;
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
      String[] groups = match(occStrs[j], "S(\\d+)E(\\d+)L(\\d+)");
      int season = parseInt(groups[0]);
      int epnum = parseInt(groups[1]);
      int lineno = parseInt(groups[2]);
      occs[j] = new Occurrence(season, epnum, lineno);
    }
    ngramMap.put(words, new Ngram(words, count, occs));
    return true;
  }
  
  void resizeData(int rows) {}
}
