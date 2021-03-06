Attribute VB_Name = "Common"
Option Explicit

Public VBE As VBE

Private Declare Function GetDC Lib "user32" (ByVal hWnd As Long) As Long
Private Declare Function GetDeviceCaps Lib "gdi32" (ByVal hdc As Long, ByVal nIndex As Long) As Long
Private Declare Function ReleaseDC Lib "user32" (ByVal hWnd As Long, ByVal hdc As Long) As Long
Private Declare Function GetTextExtentPoint32 Lib "gdi32" Alias "GetTextExtentPoint32A" (ByVal hdc As Long, ByVal lpsz As String, ByVal cbString As Long, lpSize As Size) As Long
Private Declare Function lstrlen Lib "kernel32" Alias "lstrlenA" (ByVal lpString As String) As Long
Private Declare Function OleTranslateColor Lib "olepro32.dll" (ByVal OLE_COLOR As Long, ByVal hPalette As Long, ByRef pccolorref As Long) As Long

Private Const HORZRES = 8
Private Const VERTRES = 10
Private Const LOGPIXELSX = 88
Private Const LOGPIXELSY = 90
Private Const TWIPSPERINCH = 1440
Private Type Size
    cx As Long
    cy As Long
End Type

'ע????API????
'Public Declare Function RegOpenKey Lib "advapi32.dll" Alias "RegOpenKeyA" (ByVal hKey As Long, ByVal lpSubKey As String, phkResult As Long) As Long
Public Declare Function RegOpenKeyEx Lib "advapi32.dll" Alias "RegOpenKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal ulOptions As Long, ByVal samDesired As Long, phkResult As Long) As Long
Public Declare Function RegEnumKeyEx Lib "advapi32.dll" Alias "RegEnumKeyExA" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpName As String, lpcbName As Long, ByVal lpReserved As Long, ByVal lpClass As String, lpcbClass As Long, lpftLastWriteTime As Long) As Long
Public Declare Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As Long
Public Declare Function RegQueryValueEx Lib "advapi32.dll" Alias "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, lpType As Long, ByVal lpData As Any, lpcbData As Long) As Long
Public Const REG_SZ = 1
Public Const HKEY_LOCAL_MACHINE = &H80000002
Public Const KEY_QUERY_VALUE = &H1
Public Const STANDARD_RIGHTS_READ = &H20000
Public Const KEY_ENUMERATE_SUB_KEYS = &H8
Public Const KEY_NOTIFY = &H10
Public Const SYNCHRONIZE = &H100000
Public Const KEY_READ = ((STANDARD_RIGHTS_READ Or KEY_QUERY_VALUE Or KEY_ENUMERATE_SUB_KEYS Or KEY_NOTIFY) And (Not SYNCHRONIZE))
Public Const KEY_WOW64_64KEY = &H100

'??Щ???ڻ?ȡϵͳĬ??????
Private Declare Function GetStockObject Lib "gdi32" (ByVal nIndex As Long) As Long
Private Declare Function GetObject Lib "gdi32" Alias "GetObjectA" (ByVal hObject As Long, ByVal nCount As Long, lpObject As Any) As Long
Private Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long
Private Const DEFAULT_GUI_FONT = 17
Private Const LF_FACESIZE = 32
Private Type LOGFONT
        lfHeight As Long
        lfWidth As Long
        lfEscapement As Long
        lfOrientation As Long
        lfWeight As Long
        lfItalic As Byte
        lfUnderline As Byte
        lfStrikeOut As Byte
        lfCharSet As Byte
        lfOutPrecision As Byte
        lfClipPrecision As Byte
        lfQuality As Byte
        lfPitchAndFamily As Byte
        lfFaceName(1 To LF_FACESIZE) As Byte
End Type

Public Const WTOP = "top" '????tkinter?ж??㴰??????

Public g_DefaultFontName As String '?ݴ?ϵͳĬ??????????????ÿ?β?ѯ
Public g_Comps() As Object '??ǰ?????Ŀؼ??б?????һ??Ϊ????????ʵ??

Public g_bUnicodePrefixU As Boolean '?Ƿ???UNICODE?ַ???ǰ??ǰ׺u
Public g_PythonExe As String '????GUIԤ????????python.exeȫ·??

'PYTHON??UNICODE?ַ???ǰ׺?Ĵ??????????????ַ????д???˫?ֽ??ַ?????????ѡ???????ʵ???ǰ׺
'??????ֻ?Ǽ򵥵????ӵ????ţ???ʹ?մ?Ҳ????һ?Ե?????
Public Function U(s As String) As String
    
    Dim nLen As Long
    nLen = Len(s)
    
    If lstrlen(s) > nLen Then  '????˫?ֽ??ַ?
        If g_bUnicodePrefixU Then
            U = IIf(isQuoted(s), "u" & s, "u'" & s & "'")
        Else
            U = IIf(isQuoted(s), s, "'" & s & "'")
        End If
    ElseIf nLen Then
        U = IIf(isQuoted(s), s, "'" & s & "'")
    Else
        U = "''"
    End If
    
End Function

'?ж??ַ????Ƿ??Ѿ??е????Ż?˫????????????
Public Function isQuoted(s As String) As Boolean
    isQuoted = (Left$(s, 1) = "'" Or Left$(s, 1) = Chr$(34)) And (Right$(s, 1) = "'" Or Right$(s, 1) = Chr$(34))
End Function

'?????ַ????????ţ????Զ?ȥ??
Public Function UnQuote(s As String) As String
    If isQuoted(s) Then
        UnQuote = Mid(s, 2, Len(s) - 2)
    Else
        UnQuote = s
    End If
End Function

'?Զ????ַ???ʹ?õ???????????
Public Function Quote(s As String) As String
    Quote = IIf(isQuoted(s), s, "'" & s & "'")
End Function

'ֱ??ȥ???ַ????ĵ?һ???ַ???????һ???ַ????ٶ?Ϊ???ţ?
Public Function UnQuoteFast(s As String) As String
    UnQuoteFast = Mid(s, 2, Len(s) - 2)
End Function

'ֱ?ӽ??ַ???ʹ?õ???????????
Public Function QuoteFast(s As String) As String
    QuoteFast = "'" & s & "'"
End Function

'Ҫ????????Microsoft Activex data objects 2.8 library
Public Sub Utf8File_Write_VB(ByVal sFileName As String, ByVal vVar As String)
    Dim adostream As New ADODB.Stream
    Dim fn As Long, abContent() As Byte, nSize As Long
    With adostream
        .Type = adTypeText
        .Mode = adModeReadWrite
        .Charset = "utf-8"
        .Open
        .Position = 0
        .WriteText vVar
        .SaveToFile sFileName, adSaveCreateOverWrite
        .Close
    End With
    Set adostream = Nothing
    
    'ȥ??BOM
    On Error GoTo FileError
    
    fn = FreeFile
    Open sFileName For Binary As fn
    nSize = LOF(fn)
    ReDim abContent(1 To nSize - 3) As Byte
    Get fn, 4, abContent
    Close fn
    Open sFileName For Binary As fn
    Put fn, , abContent
    Close fn
    Exit Sub
    
FileError:
    Close fn
End Sub

'Ҫ????????Microsoft Activex data objects 2.8 library
Public Function Utf8File_Read_VB(ByVal sFileName As String) As String
    Dim adostream As New ADODB.Stream
    With adostream
        .Type = adTypeText
        .Mode = adModeReadWrite
        .Charset = "utf-8"
        .Open
        .LoadFromFile sFileName
        Utf8File_Read_VB = .ReadText
        .Close
    End With
    Set adostream = Nothing
End Function

'??ȡ?ļ??Ķ????????ݵ?һ???ֽ??????У????ض?ȡ???ֽ?????0??ʾʧ??
Public Function ReadFileBinaryContent(sFile As String, ByRef abContent() As Byte) As Long
    
    Dim fn As Long, nSize As Long
    
    On Error GoTo FileError
    
    '??ȡ??????????
    fn = FreeFile
    Open sFile For Binary As fn
    nSize = LOF(fn)
    ReDim abContent(nSize - 1) As Byte
    Get fn, , abContent
    Close fn
    ReadFileBinaryContent = nSize
    Exit Function
    
FileError:
    Close fn
    ReadFileBinaryContent = 0
    
End Function

'??ȡ?ļ???????????չ??????????·????
Public Function FileFullName(ByVal sF As String) As String
    Dim ns As Long
    
    ns = InStrRev(sF, "\")
    If ns <= 0 Then
        FileFullName = sF
    Else
        FileFullName = Right$(sF, Len(sF) - ns)
    End If
End Function

'??ȡ?ļ???չ??
Public Function FileExt(sF As String) As String
    Dim sFName As String, ns As Long
    sFName = FileFullName(sF)
    ns = InStrRev(sFName, ".")
    If ns > 0 Then
        FileExt = Right$(sFName, Len(sFName) - ns)
    End If
End Function

'??ȡ·????????????????"\"
Public Function PathName(sF As String) As String
    Dim ns As Long
    
    ns = InStrRev(sF, "\")
    If ns <= 0 Then
        PathName = ""
    Else
        PathName = Left$(sF, ns)
    End If
    
End Function

Function getDPI(bX As Boolean) As Integer                                       '??ȡ??Ļ?ֱ???
    Dim hdc As Long, RetVal As Long
    hdc = GetDC(0)
    If bX = True Then
        getDPI = GetDeviceCaps(hdc, LOGPIXELSX)
    Else
        getDPI = GetDeviceCaps(hdc, LOGPIXELSY)
    End If
    RetVal = ReleaseDC(0, hdc)
End Function
Function Twip2PixelX(x As Long) As Long                                         'ˮƽ????TwipתPixel
    Twip2PixelX = x / TWIPSPERINCH * getDPI(True)
End Function
Function Twip2PixelY(x As Long) As Long                                         '??ֱ????TwipתPixel
    Twip2PixelY = x / TWIPSPERINCH * getDPI(False)
End Function
Function Point2PixelX(x As Long) As Long                                        'ˮƽ????PointתPixel
    Point2PixelX = Twip2PixelX(x * 20)
End Function
Function Point2PixelY(x As Long) As Long                                        '??ֱ????PointתPixel
    Point2PixelY = Twip2PixelY(x * 20)
End Function
Function getScreenX() As Long                                                   '??ȡ??Ļ??
    Dim hdc As Long, RetVal As Long
    hdc = GetDC(0)
    getScreenX = GetDeviceCaps(hdc, HORZRES)
    RetVal = ReleaseDC(0, hdc)
End Function
Function getScreenY() As Long                                                   '??ȡ??Ļ??
    Dim hdc As Long, RetVal As Long
    hdc = GetDC(0)
    getScreenY = GetDeviceCaps(hdc, VERTRES)
    RetVal = ReleaseDC(0, hdc)
End Function

Public Function CharWidth() As Long                '??ȡĬ???????ַ?????(????)
    Dim hdc As Long, RetVal As Long
    Dim typSize     As Size
    Dim lngX     As Long
    Dim lngY     As Long
    
    hdc = GetDC(0)
    RetVal = GetTextExtentPoint32(hdc, "ABli", 4, typSize)
    CharWidth = typSize.cx / 4
    RetVal = ReleaseDC(0, hdc)
End Function

'VB??ɫתPython??RGB??ɫ
'Ҫʹ?õ?ɫ??????ɫ????ת??ΪRGB??ɫ??ʹ??ϵͳ??ɫ?޷?ת??
'Public Function ColorToRGBStr(ByVal dwColor As Long) As String
'    Dim clrHex As String
'    If dwColor > 0 Then
'        clrHex = Replace(Format(Hex$(dwColor), "@@@@@@"), " ", "0")
'        ColorToRGBStr = "'#" & Mid$(clrHex, 5, 2) & Mid$(clrHex, 3, 2) & Mid$(clrHex, 1, 2) & "'"
'    End If
'End Function

'VB??ɫתPython??RGB??ɫ
'????ʹ?õ?ɫ?廹??ϵͳ??ɫ????????ת??ΪRGB??ɫ
Public Function TranslateColor(ByVal dwColor As OLE_COLOR) As String
    Dim nColor As Long, hPalette As Long, clrHex As String
    If OleTranslateColor(dwColor, hPalette, nColor) = 0 Then
        clrHex = Replace(Format(Hex$(nColor), "@@@@@@"), " ", "0")
        TranslateColor = "'#" & Mid$(clrHex, 5, 2) & Mid$(clrHex, 3, 2) & Mid$(clrHex, 1, 2) & "'"
    End If
End Function

' ??ȡϵͳ?????а?װ??Python·??
Public Function GetAllInstalledPython() As String()
    Dim nRe As Long, nHk As Long, nHk2 As Long, i As Long, nLen As Long
    Dim sVer As String, sAllPath As String, sBuff As String, sPythonExe As String
    Dim saVer() As String, nVerNum As Long
    
    nRe = RegOpenKeyEx(HKEY_LOCAL_MACHINE, "SOFTWARE\Python\PythonCore", 0, KEY_READ Or KEY_WOW64_64KEY, nHk)
    If nRe <> 0 Then
        GetAllInstalledPython = Split("")
        Exit Function
    End If
    
    i = 0
    nVerNum = 0
    nLen = 255
    sBuff = String$(255, 0)
    Do While (RegEnumKeyEx(nHk, i, sBuff, nLen, 0, vbNullString, ByVal 0&, ByVal 0&) = 0)
        If nLen > 1 Then
            sBuff = Left$(sBuff, InStr(1, sBuff, Chr(0)) - 1)
            
            ReDim Preserve saVer(nVerNum) As String
            saVer(nVerNum) = sBuff
            nVerNum = nVerNum + 1
        End If
        i = i + 1
        nLen = 255
        sBuff = String$(255, 0)
    Loop
    RegCloseKey nHk
    
    '??ѯ???尲װ·??
    For i = 1 To nVerNum
        nRe = RegOpenKeyEx(HKEY_LOCAL_MACHINE, "SOFTWARE\Python\PythonCore\" & saVer(i - 1) & "\InstallPath", 0, KEY_READ Or KEY_WOW64_64KEY, nHk2)
        If nRe = 0 Then
            nLen = 255
            sBuff = String$(255, 0)
            nRe = RegQueryValueEx(nHk2, "", 0&, REG_SZ, sBuff, nLen)  '??ѯ?Ӽ?Ĭ???ַ???ֵ
            If nRe = 0 And nLen > 1 Then
                sBuff = Left$(sBuff, InStr(1, sBuff, Chr(0)) - 1)
                
                sPythonExe = sBuff & IIf(Right$(sBuff, 1) = "\", "", "\") & "python.exe"
                sPythonExe = sPythonExe & "," & sBuff & IIf(Right$(sBuff, 1) = "\", "", "\") & "pythonw.exe"
                sAllPath = sAllPath & IIf(Len(sAllPath), ",", "") & sPythonExe
            End If
            RegCloseKey nHk2
        End If
    Next
    
    GetAllInstalledPython = Split(sAllPath, ",")
End Function

'??ȡϵͳĬ????????
Public Function GetDefaultFontName() As String
    Dim hFont As Long, lfont As LOGFONT
    
    If Len(g_DefaultFontName) Then
        GetDefaultFontName = g_DefaultFontName
    Else
        hFont = GetStockObject(DEFAULT_GUI_FONT)
        If hFont <> 0 Then
            GetObject hFont, Len(lfont), lfont
            DeleteObject hFont
            GetDefaultFontName = StrConv(lfont.lfFaceName, vbUnicode)
            If InStr(1, GetDefaultFontName, Chr(0)) > 0 Then
                GetDefaultFontName = Left$(GetDefaultFontName, InStr(1, GetDefaultFontName, Chr(0)) - 1)
            End If
            g_DefaultFontName = GetDefaultFontName  '?ݴ棬??һ?ξͲ???API??ѯ??
        End If
    End If
End Function

'??ȡ??ǰ?????????пؼ??б????????ַ?Ϊʹ??|?ָ??????ֺ???????
Public Function GetAllComps() As String()
    Dim nCnt As Long, i As Long, sa() As String
    On Error Resume Next
    nCnt = UBound(g_Comps)
    On Error GoTo 0
    If nCnt <= 0 Then
        GetAllComps = Split("")
        Exit Function
    End If
    
    ReDim sa(nCnt) As String
    For i = 0 To nCnt
        sa(i) = g_Comps(i).Name & "|" & TypeName(g_Comps(i))
    Next
    GetAllComps = sa
End Function

'??????????ϵ?????ؼ????򵥵?ð????????????Ҫ?????ɴ???֮ǰ????
'????ԭ???Ƕ????ؼ??????ɴ??룬???ؼ??????ɴ??룬???????ӿؼ?
Public Sub SortWidgets(ByRef aCompsSorted() As Object, ByVal cnt As Long)
    Dim idx1 As Long, idx2 As Long
    Dim tmp4exchange As Object
    
    For idx1 = 0 To cnt - 2
        For idx2 = idx1 + 1 To cnt - 1
            If aCompsSorted(idx1).Compare(aCompsSorted(idx2)) > 0 Then '???߳???
                Set tmp4exchange = aCompsSorted(idx1)
                Set aCompsSorted(idx1) = aCompsSorted(idx2)
                Set aCompsSorted(idx2) = tmp4exchange
            End If
        Next
    Next
    
End Sub
