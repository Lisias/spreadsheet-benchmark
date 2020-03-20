REM  *****  BASIC  *****


Sub calculateRunTime(oDoc as Object, oSheet as Object, rowIndex As Long, rowSize As Long)
    Dim openedDoc As Object
    Dim totalTime As Long
    Dim Max As Long
    Dim Min As Long
   
   
    Max = -1
    Min = 1000000
    totalTime = 0
   
    'RELATIVE_PATH ---> assign directory path here
    'FILE_PREFIX ---> assuming all the files in the directory have a common prefix followed by its number of rows
    FILE_PATH = RELATIVE_PATH & "/" & FILE_PREFIX & "/" & (rowSize) & ".ods"
    url = ConvertToURL(FILE_PATH)
    
    openedDoc = StarDesktop.loadComponentFromURL(url,"_Blank",0,Array()) 'open it
      
	dim openedSheet as object, oCtrl as object
		
	dim oDataRange as object, oFilter as object
	dim oFilterField(0) As New com.sun.star.sheet.TableFilterField   
		
	openedSheet = openedDoc.sheets(0)

    For j = 0 To 9
      lTick = GetSystemTicks()
      
      oDataRange = openedSheet.getCellRangeByName("A1:P" & rowSize)
	  oFilter = oDataRange.createFilterDescriptor(true)
	  oDataRange.filter(oFilter)  'Apply empty filter to reinitilize
	  with oFilter                                    
		.ContainsHeader = true                      
		.UseRegularExpressions = true               'Use Regular expression
	  end with
		
	  with oFilterField(0)
		    .Field = 2                  'Filter Col B
		    .IsNumeric = false          'Use String, not a number
		    .Operator = com.sun.star.sheet.FilterOperator.EQUAL
		    .StringValue = "LA"
	  end with    
		
	  oFilter.setFilterFields(oFilterField()) 
	  oDataRange.filter(oFilter)
       
      lTick = (GetSystemTicks() - lTick)
      
      with oFilterField(0)
		    .Field = 2                  'Filter Col A
		    .IsNumeric = false          'Use String, not a number
		    .Operator = com.sun.star.sheet.FilterOperator.EQUAL
		    .StringValue = ".*"   
	  end with    
		
	  oFilter.setFilterFields(oFilterField()) 
	  oDataRange.filter(oFilter)
       
      totalTime = totalTime + lTick
         
      If lTick > Max Then
           Max = lTick
      End If
         
      If lTick < Min Then
           Min = lTick
      End If
       
    Next j
    
    openedDoc.dispose 'close it

    totalTime = totalTime - Max - Min
    
    oSheet.getCellByPosition(0,rowIndex).String = rowSize
    oSheet.getCellByPosition(1, rowIndex).String = totalTime/8
End Sub

Sub main
   
    Dim oDoc As Object
    Dim oSheet As Object
    Dim j as Long
    
    oDoc = ThisComponent
    oSheet = oDoc.Sheets(0) 'get Sheet1
   
    oSheet.getCellByPosition(0,0).String = "Import Size"
   
    oSheet.getCellByPosition(1, 0).String = "Time (ms)"
   
    rowIndex = 1 'row id where the current result will be written
   
    For i = 10000 to 500001 Step 10000
        calculateRunTime(oDoc,oSheet,rowIndex,i)
        rowIndex = rowIndex + 1   
    Next i

End Sub