class Season {
  Episode[] episodes;
  int number;
  
  Season(int number_, String dirname)
  {
    number = number_;
    File dir = new File(dataPath(dirname));
    String[] names = dir.list();
    episodes = new Episode[names.length];
    for (int i = 0; i < names.length; i++) {
      episodes[i] = new Episode(dirname+"/"+names[i]);
    }
  }
}
