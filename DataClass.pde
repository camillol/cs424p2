class DataClass
{
        //stores list of episodes in each season
	HashMap seasonMap=new HashMap();
        //stores each characters dialog count by season and episode
	HashMap episodeMap=new HashMap();


	HashMap transcriptMap=new HashMap();

        //statistics of each season based on key:(seasonname) value:(hashmap)
        HashMap seasonStatsMap=new HashMap();
        
        //statistics of whole season key:character value:count
        HashMap wholeStatsMap=new HashMap();
        
        
        //ArrayList wholeStats=new ArrayList();
        int totalLines;
        
        java.io.File file;

        DataClass(String folderName)
        {
          processWholeStats(folderName);
          
          System.out.println(wholeStatsMap.keySet().size()+" "+totalLines);
          processSeasonStats(folderName+"/seasonaggregate");
          
          processEpisodeStats(folderName+"/individualseasons");
        }
        

        
        
        void processEpisodeStats(String folderName)
        {
          file=new File(dataPath(folderName));
          ArrayList files=new ArrayList();
          
          listFiles(file,files);
          
          for(int i=0;i<files.size();i++)
          {
            File episodeFile=(File)files.get(i);
            System.out.println(episodeFile.getAbsolutePath());
            String inputFileName=episodeFile.getAbsolutePath();
                    
            
            String[] inputFileNameParts=episodeFile.getAbsolutePath().split("/");
            String fileName=inputFileNameParts[10];
            String seasonName=inputFileNameParts[9];
            String keyPart=fileName.split(" ")[0];
            
            if(seasonMap.containsKey(seasonName))
            {
              ArrayList listEpisodes=seasonMap.get(seasonName);
              listEpisodes.add(fileName);
              seasonMap.put(seasonName,listEpisodes);
            }
            else
            {
              ArrayList listEpisodes=new ArrayList();
              listEpisodes.add(fileName);
              seasonMap.put(seasonName,listEpisodes);
              
            }
            seasonMap.put(seasonName,keyPart);
            String[] episodeFileLines=loadStrings(inputFileName);
            
            HashMap tempEpisodeMap=new HashMap();
            
            for(int j=0;j<episodeFileLines.length;j++)
            {
              String[] episodeFileLineParts=episodeFileLines[j].split("###");
              
              tempEpisodeMap.put(episodeFileLineParts[0],episodeFileLineParts[1]);
            }
            episodeMap.put(keyPart,tempEpisodeMap);
          }
        }        
        
        void processSeasonStats(String folderName)
        {
          
          file=new File(dataPath(folderName));
          ArrayList files=new ArrayList();
          

          listFiles(file,files);
          
          for(int j=0;j<files.size();j++)
          {
            File episodeFile=(File)files.get(j);
            String inputFileName=folderName+"/"+episodeFile.getName();
            System.out.println(inputFileName);
            String[] inputFileNameSplit=inputFileName.split("/");
            String statsFileName=inputFileNameSplit[2];
            String[] statsFileNameSplit=statsFileName.split(":");
            String keyPart=statsFileNameSplit[0];


            String[] seasonFileLines=loadStrings(inputFileName);
            HashMap tempSeasonMap=new HashMap();
            
            for(int k=0;k<seasonFileLines.length;k++)
            {
              String[] seasonLineParts=seasonFileLines[k].split("###");
              tempSeasonMap.put(seasonLineParts[0],seasonLineParts[1]);
              System.out.println("in season "+seasonFileLines[k]);
            }
            
            seasonStatsMap.put(keyPart,tempSeasonMap);
          }
        }
        
        
        
        void listFiles(File file,ArrayList files)
        {
          if(file.isDirectory())
          {
            File[] childrenFiles=file.listFiles();
            for(int j=0;j<childrenFiles.length;j++)
            {
                listFiles(childrenFiles[j],files);
            }
          }
          else
          {
            files.add(file);
          }
        }
        
        void processWholeStats(String folderName)
        {
          String [] inputRows=loadStrings(folderName+"/wholeStats:sorted");
          totalLines=0;
          for(int i=0;i<inputRows.length;i++)
          {
            String inputRow=inputRows[i];
            
            //wholeStats.add(inputRow);
            String[] inputRowParts=inputRow.split("###");
            String role=inputRowParts[0];
            int count=Integer.parseInt(inputRowParts[1]);
            
            wholeStatsMap.put(role,count);
            totalLines+=count;
            //System.out.println(inputRow);
          }
        }
       
        //returns list of episdoes in a season
        getListOfEpisodes(String seasonName)
        {
          
          return seasonMap.get(seasonName);
          
        }
        
        //returns hashmap of character:dialogcount for each season
        getSeasonData(String seasonName)
        {
          return seasonStatsMap.get(seasonName);
        }
        
        //returns hashmap of character:dialogcount for each episode
        getEpisodeData(String episodeName)
        {
          return episodeMap.get(episodeName);
        }
}
