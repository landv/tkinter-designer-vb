VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Setup for Tkinter Designer"
   ClientHeight    =   3405
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   7770
   Icon            =   "Main.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   3405
   ScaleWidth      =   7770
   StartUpPosition =   3  '窗口缺省
   Begin VB.CommandButton CmdUninstall 
      Caption         =   "卸载(&U)"
      Enabled         =   0   'False
      Height          =   615
      Left            =   2760
      TabIndex        =   3
      Top             =   2745
      Width           =   1935
   End
   Begin VB.CommandButton CmdQuit 
      Caption         =   "退出(&Q)"
      Height          =   615
      Left            =   5280
      TabIndex        =   2
      Top             =   2745
      Width           =   1935
   End
   Begin VB.CommandButton CmdSetup 
      Caption         =   "安装(&S)"
      Height          =   615
      Left            =   240
      TabIndex        =   1
      Top             =   2745
      Width           =   1935
   End
   Begin VB.Label Label1 
      Caption         =   "Label1"
      BeginProperty Font 
         Name            =   "宋体"
         Size            =   12
         Charset         =   134
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   2520
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   7575
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Declare Sub InitCommonControls Lib "comctl32.dll" ()
Private Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lpFileName As String) As Long
Private Declare Function GetPrivateProfileString Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long
Private Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Private Declare Function GetSystemDefaultLCID Lib "kernel32" () As Long

Private m_English As Boolean

Private Sub AddToINI()
    WritePrivateProfileString "Add-Ins32", "TkinterDesigner.Connect", "3", "VBADDIN.INI"
End Sub
Private Sub DelFromINI()
    WritePrivateProfileString "Add-Ins32", "TkinterDesigner.Connect", vbNullString, "VBADDIN.INI"
End Sub

Private Sub DelRegister()
    On Error Resume Next
    DeleteSetting "Tkinter Designer"
End Sub

Private Sub CmdQuit_Click()
    End
End Sub

Private Sub CmdSetup_Click()
    
    Dim sf As String
    
    sf = App.Path & IIf(Right(App.Path, 1) = "\", "", "\") & "TkinterDesigner.dll"
    
    If Dir(sf) = "" Then
        If m_English Then
            MsgBox "Please run the setup program in directory of TkinterDesigner.dll", vbInformation
        Else
            MsgBox "请在TkinterDesigner.dll的同一目录下执行此软件。", vbInformation
        End If
        Exit Sub
    End If
    
    '判断VB6是否在运行，如果运行的话，建议先退出
    If FindWindow("wndclass_desked_gsk", vbNullString) <> 0 Then
        If m_English Then
            MsgBox "A process VB6.EXE detected, please quit VB6.EXE firstly.", vbInformation
        Else
            MsgBox "当前检测到VB6正在运行，建议先退出VB6，然后再执行此安装程序。", vbInformation
        End If
        Exit Sub
    End If
    
    AddToINI
    
    Shell "regsvr32 /s " & Chr(34) & sf & Chr(34)
    
    MsgBox IIf(m_English, "Setup successed!", "注册完成！"), vbInformation
    
End Sub

Private Sub CmdUninstall_Click()
    
    Dim sf As String
    
    sf = App.Path & IIf(Right(App.Path, 1) = "\", "", "\") & "TkinterDesigner.dll"
    
    If Dir(sf) = "" Then
        If m_English Then
            MsgBox "Please run the setup program in directory of TkinterDesigner.dll", vbInformation
        Else
            MsgBox "请在TkinterDesigner.dll的同一目录下执行此软件。", vbInformation
        End If
        Exit Sub
    End If
    
    '判断VB6是否在运行，如果运行的话，建议先退出
    If FindWindow("wndclass_desked_gsk", vbNullString) <> 0 Then
        If m_English Then
            MsgBox "A process VB6.EXE detected, please quit VB6.EXE firstly.", vbInformation
        Else
            MsgBox "当前检测到VB6正在运行，建议先退出VB6，然后再执行卸载程序。", vbInformation
        End If
        Exit Sub
    End If
    
    Shell "regsvr32 /u " & Chr(34) & sf & Chr(34)
    
    DelFromINI
    
    DelRegister
    
End Sub

Private Sub Form_Initialize()
    InitCommonControls
End Sub

Private Sub Form_Load()
    Dim svb6 As String, s As String, n As Long
    
    n = GetSystemDefaultLCID()
    Select Case n
        Case &H804, &H1004, &H404, &HC04
            Label1.Caption = "这个程序用于注册Tkinter Designer插件，你也可以手工完成：" & vbCrLf & vbCrLf & _
                "1. 运行：regsvr32 /s 你的目录\TkinterDesigner.dll" & vbCrLf & _
                "2. 在C:\WINDOWS\VBADDIN.INI的段[Add-Ins32]增加一行：" & vbCrLf & _
                "      TkinterDesigner.Connect=3"
            m_English = False
        Case Else
            CmdSetup.Caption = "Install(&S)"
            CmdUninstall.Caption = "Uninstall(&U)"
            CmdQuit.Caption = "Quit(&Q)"
            
            Label1.Caption = "The programe will finish the setup procedure for addin of VB 'TkinterDesigner', you can do it manually too." & vbCrLf & vbCrLf & _
                "1. Run Command : regsvr32 /s path\TkinterDesigner.dll" & vbCrLf & _
                "2. Add a line in section Add-Ins32 of c:\windows\vbaddin.ini:" & vbCrLf & _
                "      TkinterDesigner.Connect=3"
            m_English = True
    End Select
    
    '确认是否已经安装
    CmdUninstall.Enabled = IsRegistered("TkinterDesigner.Connect")
    
End Sub

'判断对应组件是否已经注册
Private Function IsRegistered(ByVal KJname As String) As Boolean
    On Error Resume Next
    Dim oCheckup As Object
    Set oCheckup = CreateObject(KJname)
    IsRegistered = (Err.Number = 0)
    Set oCheckup = Nothing
    On Error GoTo 0
End Function

