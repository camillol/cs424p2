class TSVBase {
  boolean hasHeader;
  int rowCount = 0;
  int columnCount = 0;
  String[] columnNames;  // valid if hasHeader
  
  TSVBase(String filename, boolean hasHeader) {
    String[] rows = loadStrings(filename);  // actually text lines
    int i;
    
    columnNames = split(rows[0], TAB);
    columnCount = columnNames.length;
    if (hasHeader) {
      i = 1;
    } else {
      columnNames = null;
      i = 0;
    }

    allocateData(rows.length-i);
    
    for (; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }

      String[] pieces = split(rows[i], TAB);
      
      if (createItem(rowCount, pieces)) rowCount++;      
    }
    
    resizeData(rowCount);
  }
  
  void allocateData(int rows)
  {
    println("UNIMPLEMENTED");
  }
  
  boolean createItem(int i, String[] pieces)
  {
    println("UNIMPLEMENTED");
    return false;
  }
  
  void resizeData(int rows)
  {
    println("UNIMPLEMENTED");
  }
  
  int getRowCount() {
    return rowCount;
  }
  
  int getColumnCount() {
    return columnCount;
  }
  
  
  String getColumnName(int colIndex) {
    return columnNames[colIndex];
  }
  
  String[] getColumnNames() {
    return columnNames;
  }
}

