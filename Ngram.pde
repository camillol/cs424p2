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
  
  boolean precedes(Episode ep)
  {
    return (season < ep.season || (season == ep.season && episode < ep.number));
  }
  
  boolean within(Episode ep)
  {
    return (season == ep.season && episode == ep.number);
  }
}

class CharNgram {
  Ngram ngram;
  int count;
  float pvalue;
  
  CharNgram(Ngram ngram_, int count_, float pvalue_)
  {
    ngram = ngram_;
    count = count_;
    pvalue = pvalue_;
  }
}

class CharNgramTable extends TSVBase implements ListDataSource {
  ArrayList<CharNgram> charNgramList;
  HashMap<String,CharNgram> charNgramMap;
  
  CharNgramTable(String filename) {
    super(filename, false);  // this loads the data
  }
  
  void allocateData(int rows)
  {
    charNgramMap = new HashMap<String,CharNgram>(rows);
    charNgramList = new ArrayList<CharNgram>(rows);
  }
  
  boolean createItem(int i, String[] pieces)
  {
    String words = pieces[0];
    int count = parseInt(pieces[1]);
    float pvalue = parseFloat(pieces[2]);
    Ngram ng = ngrams.get(words);
    if (ng == null) return false;  /* we're skipping common ones */
    CharNgram cng = new CharNgram(ng, count, pvalue);
    charNgramMap.put(words, cng);
    charNgramList.add(cng);
    return true;
  }
  
  void resizeData(int rows) {}
  
  int count() {
    return charNgramList.size();
  }
  
  CharNgram get(int index) {
    return charNgramList.get(index);
  }
  
  String getText(int index) {
    return charNgramList.get(index).ngram.count + "  "+ charNgramList.get(index).ngram.words;
  }
  
  boolean selected(int index) {
    return get(index).ngram == activeNgram;
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
    boolean common = pieces[2].equals("C");
    if (common) return false;  /* skip ngrams that are common in general english */
    String[] occStrs = pieces[3].split(":");
    Occurrence[] occs = new Occurrence[occStrs.length];
    
    for (int j = 0; j < occStrs.length; j++) {
      String[] groups = match(occStrs[j], "S(\\d+)E(\\d+)L(\\d+)");
      int season = parseInt(groups[1]);
      int epnum = parseInt(groups[2]);
      int lineno = parseInt(groups[3]);
      occs[j] = new Occurrence(season, epnum, lineno);
    }
    ngramMap.put(words, new Ngram(words, count, occs));
    return true;
  }
  
  void resizeData(int rows) {}
  
  Ngram get(String words)
  {
    return (Ngram)ngramMap.get(words);
  }
}
