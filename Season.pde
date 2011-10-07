class Season {
  Episode[] episodes;
  int number;
  
  Season(int number_, String dirname)
  {
    number = number_;
    File dir = new File(dataPath(dirname));
    String[] names = namesMatching(dir.list(), "S(\\d+)E(\\d+).*");
    episodes = new Episode[names.length];
    for (int i = 0; i < names.length; i++) {
      episodes[i] = new Episode(dirname+"/"+names[i]);
    }
  }
  
  void updateActiveTotals()
  {
    for (int i = 0; i < episodes.length; i++) {
      episodes[i].updateActiveTotal();
    }
  }
}
