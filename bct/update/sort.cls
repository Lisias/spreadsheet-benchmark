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

Sub calculateRunTime(ByVal rowIndex, ByVal rowCount)
    
'Initialize Timer Variables
    Dim StartTime As Double
    Dim SecondsElapsed As Double
    Dim Name As String
    
    Dim sheetNew As Worksheet
    
 'Remember time when macro starts
    Max = -1
    Min = 1000000
    totalTime = 0
    'RELATIVE_PATH ---> assign directory path here
    'FILE_PREFIX ---> assuming all the files in the directory have a common prefix followed by its number of rows
    
    Name = FILE_PREFIX & CStr(rowSize) & ".xlsx"
    FILE_PATH = Dir(RELATIVE_PATH & Name)
    sheetName = "Sheet1"
    
    Workbooks.Open (FILE_PATH)
    
    For j = 1 To 10
    
        Sheets("Sheet1").Delete
        Set sheetNew = Sheets.Add
        sheetNew.Name = "Sheet1"
        Workbooks(FILE_PATH).Worksheets(sheetName).Range("A1:O" & CStr(rowSize + 1)).Copy
        Sheets("Sheet1").Activate
        Range("A1").Select
        ActiveSheet.Paste
        Application.CutCopyMode = False
        
        Cells(1, 4).Value = "Type"
        Cells(1, 13).Value = "Count"
        Cells(1, 18).Value = "Count2"
        StartTime = GetTickCount
        
        Range("A1:O" & CStr(rowSize + 1)).Sort Key1:=Range("A1"), Order1:=xlAscending
        
        SecondsElapsed = Round(GetTickCount - StartTime, 2)
        
        timeTaken = SecondsElapsed

        Sheets("import").Cells(rowIndex, 2 + j).Value = timeTaken
        totalTime = totalTime + timeTaken
          
        If timeTaken > Max Then
          Max = timeTaken
        End If
        If timeTaken < Min Then
          Min = timeTaken
        End If
        Range("A1:O" & CStr(rowSize + 1)).Sort Key1:=Range("A1"), Order1:=xlDescending
          
    Next j
    
    Workbooks(Filename).Close
    
    
    totalTime = totalTime - Max - Min
    
    Sheets("import").Activate
   
    Sheets("import").Cells(rowIndex, 1).Value = rowSize
    
    Sheets("import").Cells(rowIndex, 2).Value = totalTime / 8

    
End Sub

Sub main()
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    Sheets("import").Cells(1, 1).Value = "Rows Imported"
    Sheets("import").Cells(1, 2).Value = "Time (ms)"
    
    rowIndex = 2
    For i = 10000 to 500001 Step 10000
        calculateRunTime rowIndex, i
        rowIndex = rowIndex + 1 
    Next i
    
    Application.ScreenUpdating = True
End Sub
