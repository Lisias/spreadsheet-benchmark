VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Sheet1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True

Sub calculateRunTime(ByVal rowIndex, ByVal rowSize)
    
'Initialize Timer Variables
    Dim StartTime As Double
    Dim SecondsElapsed As Double
    Dim Name As String
    
    
 'Remember time when macro starts
    Max = -1
    Min = 1000000
    totalTime = 0

    'RELATIVE_PATH ---> assign directory path here
    'FILE_PREFIX ---> assuming all the files in the directory have a common prefix followed by its number of rows
    
    Name = FILE_PREFIX & CStr(rowSize) & ".xlsx"
    FILE_PATH = Dir(RELATIVE_PATH & Name)
    
    For j = 1 To 10 '10 trials
        StartTime = Timer
        Workbooks.Open (FILE_PATH)
        SecondsElapsed = Round(Timer - StartTime, 2)
     
        Workbooks(Filename).Close
             
        timeTaken = SecondsElapsed
        totalTime = totalTime + timeTaken
         
        If timeTaken > Max Then
           Max = timeTaken
        End If
        
        If timeTaken < Min Then
           Min = timeTaken
        End If     
    Next j
    
    totalTime = totalTime - Max - Min 'remove outliers
    
    'write results back to .xlsm file

    Sheets("import").Cells(rowIndex, 1).Value = rowSize 
    
    Sheets("import").Cells(rowIndex, 2).Value = totalTime / 8

    
End Sub

Sub main() 

    Dim i As Long
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False

    'add headers to the current /xlsm file where results will be written
    Sheets("import").Cells(1, 1).Value = "Rows Imported"
    Sheets("import").Cells(1, 2).Value = "Time (s)"

    rowIndex = 2
    For i = 10000 to 500001 Step 10000
        calculateRunTime rowIndex, i
        rowIndex = rowIndex + 1
         
    Next i

    Application.ScreenUpdating = True

End Sub
