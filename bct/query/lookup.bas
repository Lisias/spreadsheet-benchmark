REM  *****  BASIC  *****

'for vlookup
Function UsedRange(oSheet As Variant) As Variant
    Dim oCursor As Variant
	oCursor = oSheet.createCursor()
	oCursor.gotoEndOfUsedArea(False)
	oCursor.gotoStartOfUsedArea(True)
	UsedRange = oCursor
End Function

Sub calculateRunTime(rowIndex As Long, rowSize As Long, is_sorted as Long)
	Dim oDoc As Object
	Dim oSheet1 As Object
	Dim oCell As Object
	Dim oCellRange As Object
	Dim oActiveRange As Object
	Dim oSvc as variant
	Dim oArg as variant
	Dim lTick As Long

	Dim totalTime As Long
	Dim Max As Long
	Dim Min As Long

	Max = -1
	Min = 1000000
	totalTime = 0


	oSvc = createUnoService("com.sun.star.sheet.FunctionAccess")
	oDoc = ThisComponent
	oSheet1 = oDoc.Sheets(0)

	oSheet1.getCellByPosition(26,0).String = "Row Size"
	oSheet1.getCellByPosition(27,0).String = "vlookup value"
	oSheet1.getCellByPosition(28,0).String = "Time"

	condition = "1"

	oActiveRange = UsedRange(oDoc.getCurrentController().getActiveSheet())


	For j = 0 To 9

		lTick = GetSystemTicks()
		
                If is_sorted = 0 Then
		   oSvc.callFunction("VLOOKUP",Array(200000,oSheet1.getCellRangeByName("A1:S"+rowSize),3,0))
		End If
		If is_sorted = 1 Then
		   oSvc.callFunction("IFERROR",Array(oSvc.callFunction("VLOOKUP",Array(200000,oSheet1.getCellRangeByName("A1:S"+rowSize),3,0)),"Not Found"))
		End If		 	
		 	 
		oSheet1.getCellByPosition(27,rowIndex).String = TotalCount
		lTick = (GetSystemTicks() - lTick)
		 
		totalTime = totalTime + lTick
		 
		If lTick > Max Then
		   Max = lTick
		End If
		If lTick < Min Then
		   Min = lTick
		End If


	Next j

	totalTime = totalTime - Max - Min

	oSheet1.getCellByPosition(26,rowIndex).String = rowSize
        
        If is_sorted = 0 Then
	   oSheet1.getCellByPosition(27,rowIndex).String = totalTime/ 8
	End If
	If is_sorted = 1 Then
	   oSheet1.getCellByPosition(28,rowIndex).String = totalTime/ 8
	End If

	

End Sub



Sub main
    rowIndex = 1 'row id where the current result will be written
   
    For i = 10000 to 500001 Step 10000
        calculateRunTime(rowIndex,i,0)
        rowIndex = rowIndex + 1   
    Next i

    For i = 10000 to 500001 Step 10000
        calculateRunTime(rowIndex,i,1)
        rowIndex = rowIndex + 1   
    Next i
    
End Sub

