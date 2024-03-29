class DataClass
{
  
        HashMap episodeCharactersMap=new HashMap();
        //stores list of episodes in each season
	HashMap seasonMap=new HashMap();
        //stores each characters dialog count by season and episode
	HashMap episodeMap=new HashMap();

        HashMap episodeTotalMap=new HashMap();


        HashMap episodeAnglesMap=new HashMap();


        //statistics of each season based on key:(seasonname) value:(hashmap)
        HashMap seasonStatsMap=new HashMap();
        
        //stores total count for each season
        HashMap seasonStatsTotalMap=new HashMap();
        
        HashMap seasonAnglesMap=new HashMap();
        //statistics of whole season key:character value:count
        HashMap wholeStatsMap=new HashMap();
        
        float wholeStatsTotal;
        
        ArrayList wholeAngles=new ArrayList();
        
        //appearance list of characters returns list of episode appearance 
        HashMap characterAppearanceMap=new HashMap();
        
        //ArrayList wholeStats=new ArrayList();

        
        java.io.File file;

        DataClass(String folderName)
        {
          processWholeStats(folderName);
          
          System.out.println(wholeStatsMap.keySet().size()+" "+wholeStatsTotal);
          processSeasonStats(folderName+"/seasonaggregate");
          
          processEpisodeStats(folderName+"/individualseasons");
          
          processCharacterAppearance(folderName);
          
//          processEpisodeCharacters(folderName);
        }
        
        
        void processEpisodeCharacters(String folderName)
        {
          String[] episodeCharactersLines=loadStrings(folderName+"/EpisodeCharList");
          
          for(int i=0;i<episodeCharactersLines.length;i++)
          {
            String row=episodeCharactersLines[i];
            String[] rowParts=row.split("###");
            String keyPart=rowParts[0];
            String[] characters=rowParts[1].split("\t");
            ArrayList tempList=new ArrayList();
            for(int j=0;j<characters.length;j++)
            {
              tempList.add(characters[j]);
            }
            episodeCharactersMap.put(keyPart,tempList);
          }
        }
        
        ArrayList getEpisodeCharactersList(String episodeName)
        {
          return (ArrayList)episodeCharactersMap.get(episodeName);
        }
        
        float getWholeStatsTotal()
        {
          return wholeStatsTotal;
        }
        
        
        void processCharacterAppearance(String folderName)
        {
          String[] characterAppearanceLines=loadStrings(folderName+"/"+"characterAppearanceStats");
          
          for(int i=0;i<characterAppearanceLines.length;i++)
          {
            if(characterAppearanceLines[i].contains("###"))
            {
              String[] characterAppearanceLineParts=characterAppearanceLines[i].split("###");
              String keyPart=characterAppearanceLineParts[0];
            
              ArrayList appearance=new ArrayList();
              for(int j=1;j<characterAppearanceLineParts.length;j++)
              {
                appearance.add(characterAppearanceLineParts[j]);
              }
              characterAppearanceMap.put(keyPart,appearance);
           }
         }
          
        }

        
        
        void processEpisodeStats(String folderName)
        {
          String[] seasonDirs = listDataSubdir(folderName);
          for (int j = 0; j < seasonDirs.length; j++) {
            String seasonName = seasonDirs[j];
            if (match(seasonName, "S\\d+") == null) continue;
            String[] epFiles = listDataSubdir(folderName+"/"+seasonName);
            for (int i = 0; i < epFiles.length; i++) {
              String fileName = epFiles[i];
              String keyPart=fileName.split(" ")[0];
            float totalLines=0;
            if(seasonMap.containsKey(seasonName))
            {
              ArrayList listEpisodes=(ArrayList)seasonMap.get(seasonName);
              listEpisodes.add(fileName);
              seasonMap.put(seasonName,listEpisodes);
            }
            else
            {
              ArrayList listEpisodes=new ArrayList();
              listEpisodes.add(fileName);
              seasonMap.put(seasonName,listEpisodes);
              
            }
            //seasonMap.put(seasonName,keyPart);
            String[] episodeFileLines=loadStrings(folderName+"/"+seasonName+"/"+fileName);
         
            
            HashMap tempEpisodeMap=new HashMap();
            
            for( j=0;j<episodeFileLines.length;j++)
            {
              String[] episodeFileLineParts=episodeFileLines[j].split("###");
              totalLines+=Float.parseFloat(episodeFileLineParts[1]);
              tempEpisodeMap.put(episodeFileLineParts[0],episodeFileLineParts[1]);
            }
            episodeMap.put(keyPart,tempEpisodeMap);
            episodeTotalMap.put(keyPart,totalLines);
            
            ArrayList tempList=getEpisodeDataAngles(keyPart);
            episodeAnglesMap.put(keyPart,tempList);
            
            }
          }
        }        
        
        void processSeasonStats(String folderName)
        {
          String[] files = listDataSubdir(folderName);
          for(int j=0;j<files.length;j++)
          {
            float totalLines=0;

            String inputFileName=folderName+"/"+files[j];
            String[] statsFileNameSplit=files[j].split(":");
            String keyPart=statsFileNameSplit[0];

            String[] seasonFileLines=loadStrings(inputFileName);
            HashMap tempSeasonMap=new HashMap();
            
            for(int k=0;k<seasonFileLines.length;k++)
            {
              String[] seasonLineParts=seasonFileLines[k].split("###");
              tempSeasonMap.put(seasonLineParts[0],int(seasonLineParts[1]));
              System.out.println("in season "+seasonFileLines[k]);
              totalLines+=Float.parseFloat(seasonLineParts[1]);
            }
            seasonStatsTotalMap.put(keyPart,totalLines);
            seasonStatsMap.put(keyPart,tempSeasonMap);
            ArrayList tempAngles=getSeasonDataAngles(keyPart);
            seasonAnglesMap.put(keyPart,tempAngles);
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
          float totalLines=0;
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
          wholeStatsTotal=totalLines;
          
          wholeAngles=getWholeDataAngles();
        }
       
        //returns list of episdoes in a season
        ArrayList getListOfEpisodes(String seasonName)
        {
          
          return (ArrayList)seasonMap.get(seasonName);
          
        }
        
        //returns hashmap of character:dialogcount for each season
        HashMap getSeasonData(String seasonName)
        {
          return (HashMap)seasonStatsMap.get(seasonName);
        }
        
        
        ArrayList getSeasonDataAngles(String seasonName)
        {
          ArrayList seasonAngles=new ArrayList();
          
          HashMap thisSeasonMap=(HashMap)seasonStatsMap.get(seasonName);
          
          float total=Float.parseFloat(seasonStatsTotalMap.get(seasonName).toString());
          
          Set<String> keys=thisSeasonMap.keySet();
          
          Iterator<String> thisSeasonIterator=keys.iterator();
          
          while(thisSeasonIterator.hasNext())
          {
            String seasonCharacter=thisSeasonIterator.next();
            float count=Float.parseFloat(thisSeasonMap.get(seasonCharacter).toString());
            seasonAngles.add(seasonCharacter+":"+(count/total)*360);
            
          }
          
          return seasonAngles;
          
        }
        
        Float getSeasonStatsTotal(String seasonName)
        {
           return (Float)seasonStatsTotalMap.get(seasonName);
        }
        
        //returns angleslist by season
        ArrayList getSeasonAnglesList(String seasonName)
        {
          return (ArrayList) seasonAnglesMap.get(seasonName);
        }
        
        
        //returns hashmap of character:dialogcount for each episode
        HashMap getEpisodeData(String episodeName)
        {
          return (HashMap)episodeMap.get(episodeName);
        }
        
        //retunds character:angle for each episode
        ArrayList getEpisodeDataAngles(String episode)
        {
          ArrayList episodeAngles=new ArrayList();
          HashMap thisEpisodeMap=(HashMap)episodeMap.get(episode);
          
          float total=Float.parseFloat(episodeTotalMap.get(episode).toString());
          
          Set<String> keys=thisEpisodeMap.keySet();
          
          Iterator<String> thisEpisodeIterator=keys.iterator();
          
          while(thisEpisodeIterator.hasNext())
          {
            String thisEpisodeChar=thisEpisodeIterator.next();
            float characterCount=Float.parseFloat(thisEpisodeMap.get(thisEpisodeChar).toString());
            
            episodeAngles.add(thisEpisodeChar+":"+(characterCount/total)*360);
            
          }
          
          return episodeAngles;
        }
        
        ArrayList getEpisodeCharacters(String episodeName)
        {
          HashMap thisEpisodeMap=(HashMap)episodeMap.get(episodeName);
          
          Set<String> characters=thisEpisodeMap.keySet();
          
          Iterator<String> charactersIterator=characters.iterator();

          ArrayList charactersList=new ArrayList();
          
          while(charactersIterator.hasNext())
          {
            String charactersItem=charactersIterator.next();
            
            charactersList.add(charactersItem);
          }
          

          
          
          return charactersList;
        }
        
        //returns angleslist by episode
        ArrayList getEpisodeAnglesList(String episodeName)
        {
          return (ArrayList)episodeAnglesMap.get(episodeName);
        }
        
        ArrayList getCharacterAppearance(String character)
        {
          return (ArrayList)characterAppearanceMap.get(character);
        }
        
        //returns map of whole data
        HashMap getWholeData()
        {
          return wholeStatsMap;
        }
        
        //returns whole data list of angles
        ArrayList getWholeAnglesList()
        {
           return wholeAngles;
        }
        
        //precomputes angles for whole dataset
        ArrayList getWholeDataAngles()
        {
          ArrayList characterAngles=new ArrayList();
          Set<String> keys=wholeStatsMap.keySet();
          
          Iterator<String> characterKey=keys.iterator();
          
//          float total=0;
//          
//          while(characterKey.hasNext())
//          {
//            int count=Integer.parseInt(wholeStatsMap.get(characterKey.next()).toString());
//            total+=count;
//          }
          
          characterKey=keys.iterator();
          
          while(characterKey.hasNext())
          {
            String currentCharacter=characterKey.next();
            float angle;
            float count=Float.parseFloat(wholeStatsMap.get(currentCharacter).toString());
            angle=(count/wholeStatsTotal)*360;
            characterAngles.add(currentCharacter+":"+angle);
          }
          return characterAngles;
        }
   
       
}
