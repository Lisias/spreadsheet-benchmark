REM  *****  BASIC  *****

Sub calculateRunTime(oDoc as Object, oSheet as Object, rowIndex As Long, rowSize As Long)
    Dim openedDoc As Object 
    Dim totalTime As Long
    Dim Max As Long
    Dim Min As Long
   
    Dim Prop(0) as New com.sun.star.beans.PropertyValue

    Max = -1
    Min = 1000000
    totalTime = 0

    'RELATIVE_PATH ---> assign directory path here
    'FILE_PREFIX ---> assuming all the files in the directory have a common prefix followed by its number of rows
    FILE_PATH = RELATIVE_PATH & "/" & FILE_PREFIX & "/" & (rowSize) & ".ods"
    url = ConvertToURL(FILE_PATH)

    For j = 0 To 9 '10 trials
	lTick = GetSystemTicks()

	openedDoc = stardesktop.LoadComponentFromURL(url, "_blank",0, Prop()) 'open it

	lTick = (GetSystemTicks() - lTick)

	openedDoc.dispose 'close it

	oSheet.getCellByPosition(2+j,rowIndex).String = lTick

	totalTime = totalTime + lTick
	 
	If lTick > Max Then
	   Max = lTick
	End If
	
	If lTick < Min Then
	   Min = lTick
	End If
    Next j

    totalTime = totalTime - Max - Min 'remove outliers
    
    'write results back to oDoc
    oSheet.getCellByPosition(0,rowIndex).String = rowSize 
    oSheet.getCellByPosition(1, rowIndex).String = totalTime/8


End Sub



Sub main
   
    Dim oDoc As Object
    Dim oSheet As Object
    Dim j as Long

    oDoc = ThisComponent ' the file where the results are written

    oSheet = oDoc.Sheets(0) 'get Sheet1
   
    oSheet.getCellByPosition(0,0).String = "Import Size"
   
    oSheet.getCellByPosition(1, 0).String = "Time (ms)"

    rowIndex = 1 'row id where the current result will be written
   
    For i = 10000 to 500001 Step 10000
        calculateRunTime(oDoc,oSheet,rowIndex,i)
        rowIndex = rowIndex + 1   
    Next i

End Sub