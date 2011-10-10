class DataClass
{
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
            String[] episodeFileLines=loadStrings(inputFileName);
         
            
            HashMap tempEpisodeMap=new HashMap();
            
            for(int j=0;j<episodeFileLines.length;j++)
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
        
        void processSeasonStats(String folderName)
        {
          
          file=new File(dataPath(folderName));
          ArrayList files=new ArrayList();
          

          listFiles(file,files);
          
          for(int j=0;j<files.size();j++)
          {
            File episodeFile=(File)files.get(j);
            float totalLines=0;
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
