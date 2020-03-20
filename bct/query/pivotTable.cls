VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisWorkbook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Private mlngStart As Long
Private Declare Function GetTickCount Lib "kernel32" () As Long

Public Sub StartTimer()
    mlngStart = GetTickCount
End Sub

Public Function EndTimer() As Long
    EndTimer = (GetTickCount - mlngStart)
End Function

Sub calculateRunTime(ByVal rowIndex, ByVal rowSize)
    
'Initialize Timer Variables
    Dim StartTime As Double
    Dim SecondsElapsed As Double
    Dim Name As String
    
    Dim sht As Worksheet
    Dim pvtCache As PivotCache
    Dim pvt As PivotTable
    Dim StartPvt As String
    Dim SrcData As String
    
    Dim dm As String
    Dim measure As String
    Dim aggregate_name As String
    
    Max = -1
    Min = 1000000
    totalTime = 0
    
    'RELATIVE_PATH ---> assign directory path here
    'FILE_PREFIX ---> assuming all the files in the directory have a common prefix followed by its number of rows
    
    Name = FILE_PREFIX & CStr(rowSize) & ".xlsx"
    FILE_PATH = Dir(RELATIVE_PATH & Name)
    sheetName = "Sheet1"
    
    Workbooks.Open (FILE_PATH)
        
    Workbooks(FILE_PATH).Worksheets(sheetName).Range("A1:O" & CStr(rowSize + 1)).Copy
    
    'Activate the destination worksheet
    Sheets("Sheet1").Activate
    'Select the target range
    Range("A1").Select
    'Paste in the target destination
    ActiveSheet.Paste
    
    Application.CutCopyMode = False
    Workbooks(FILE_PATH).Close
    
    
    For j = 1 To 10
        
        StartTime = GetTickCount
        'Determine the data range you want to pivot
          SrcData = ActiveSheet.Name & "!" & Range("A1:O" & CStr(rowSize + 1)).Address(ReferenceStyle:=xlR1C1)
        
        'Create a new worksheet
          Set sht = Sheets.Add
          'Where do you want Pivot Table to start?
          StartPvt = sht.Name & "!" & sht.Range("A1").Address(ReferenceStyle:=xlR1C1)
        
        'Create Pivot Cache from Source Data
          Set pvtCache = ActiveWorkbook.PivotCaches.Create( _
            SourceType:=xlDatabase, _
            SourceData:=SrcData)
        
        'Create Pivot table from Pivot Cache
          Set pvt = pvtCache.CreatePivotTable( _
            TableDestination:=StartPvt, _
            TableName:="PivotTable1")

        'dm -> header name of the dimension column
	dm = "city" 'provide the column header name
        'Add item to the Row Labels
            pvt.PivotFields(dm).Orientation = xlRowField 
            
            measure = "price" 'provide the column header name
            aggregate_name = "Sum of price"
            
            pvt.AddDataField pvt.PivotFields("price"), aggregate_name, xlSum
 
        SecondsElapsed = Round(GetTickCount - StartTime, 2)
        
        timeTaken = SecondsElapsed
        totalTime = totalTime + timeTaken
          
        If timeTaken > Max Then
          Max = timeTaken
        End If
        If timeTaken < Min Then
          Min = timeTaken
        End If
        
        sht.Delete
          
          
    Next j
    
    
    totalTime = totalTime - Max - Min
    
    Sheets("import").Activate
   
    Sheets("import").Cells(rowIndex, 1).Value = rowSize
    
    Sheets("import").Cells(rowIndex, 2).Value = totalTime / 8

    
End Sub

Sub main()
    Dim i As Long
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    Sheets("import").Cells(1, 1).Value = "Rows Imported"
    Sheets("import").Cells(1, 2).Value = "Time (s)"
    
    rowIndex = 2
    For i = 10000 to 500001 Step 10000
        calculateRunTime rowIndex, i
        rowIndex = rowIndex + 1 
    Next i
    
    Application.ScreenUpdating = True
End Sub
