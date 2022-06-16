VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Connect"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Description = "TkinterDesigner"
Option Explicit

Private mcbMenuItem         As Office.CommandBarControl
Private mcbToolBoxItem      As Office.CommandBarControl
Private mfrmAddIn           As New FrmMain
Public WithEvents MenuHandler As CommandBarEvents
Attribute MenuHandler.VB_VarHelpID = -1
Public WithEvents ToolBoxHandler As CommandBarEvents
Attribute ToolBoxHandler.VB_VarHelpID = -1

'ADDIN����Ҫʵ�ֵĽӿڣ�ʹ������ӿڶ�����ֱ��ʹ��VB6�ṩ��Designer��Ϊ��֧��VB6��ɫ�����
Implements IDTExtensibility

Private Sub Class_Terminate()
    Set IDTExtensibility = Nothing
End Sub

Private Sub IDTExtensibility_OnAddInsUpdate(custom() As Variant)
    'Ԥ��������ɾ����������Ϊ����ӿڱ���Ҫʵ��
    Dim i As Long
    i = 1
End Sub
Private Sub IDTExtensibility_OnStartupComplete(custom() As Variant)
    'Ԥ��������ɾ����������Ϊ����ӿڱ���Ҫʵ��
    Dim i As Long
    i = 1
End Sub

Private Sub IDTExtensibility_OnConnection(ByVal VBInst As Object, ByVal ConnectMode As VBIDE.vbext_ConnectMode, ByVal AddInInst As VBIDE.AddIn, custom() As Variant)
    Set Common.VBE = VBInst
    
    If ConnectMode = vbext_cm_Startup Or ConnectMode = vbext_cm_AfterStartup Then
        AddToMenu (App.Title & "(&T)")
        AddToToolBox (App.Title)
    ElseIf ConnectMode = vbext_cm_External Then
        Show
    End If

End Sub

Private Sub IDTExtensibility_OnDisconnection(ByVal RemoveMode As VBIDE.vbext_DisconnectMode, custom() As Variant)
    'If RemoveMode = vbext_dm_UserClosed Then
    'End If
    
    On Error Resume Next
    
    'ɾ����������Ŀ
    If Not (mcbMenuItem Is Nothing) Then mcbMenuItem.Delete
    If Not (mcbToolBoxItem Is Nothing) Then mcbToolBoxItem.Delete
    Set mcbMenuItem = Nothing
    Set mcbToolBoxItem = Nothing
    
    If Not (mfrmAddIn Is Nothing) Then Unload mfrmAddIn
    Set mfrmAddIn = Nothing
End Sub

Public Sub Hide()
    If Not (mfrmAddIn Is Nothing) Then
        Unload mfrmAddIn
        Set mfrmAddIn = Nothing
    End If
End Sub

Public Sub Show()
    If mfrmAddIn Is Nothing Then Set mfrmAddIn = New FrmMain
    Set mfrmAddIn.mConnect = Me
    mfrmAddIn.Show
End Sub

'����ӳ���˵�������һ���˵���
Private Sub AddToMenu(sCaption As String)
    Dim cbMenuCommandBar As Office.CommandBarControl
    Dim cbMenu
    
    On Error Resume Next
    
    '�쿴�ܷ��ҵ���ӳ���˵�
    Set cbMenu = VBE.CommandBars("Add-Ins")
    If cbMenu Is Nothing Then Exit Sub
    
    '��������������
    Set cbMenuCommandBar = cbMenu.Controls.Add(msoControlButton)
    If cbMenuCommandBar Is Nothing Then Exit Sub
    
    cbMenuCommandBar.BeginGroup = True
    
    '���ñ���
    cbMenuCommandBar.Caption = sCaption
    
    Set mcbMenuItem = cbMenuCommandBar
    Set MenuHandler = VBE.Events.CommandBarEvents(mcbMenuItem)
        
End Sub

'�ڹ���������һ��ͼ��
Private Sub AddToToolBox(sCaption As String)
    Dim cbToolboxCommandBar As Office.CommandBarControl
    Dim cbStandard As CommandBar
    
    '�쿴�ܷ��ҵ���׼������
    On Error Resume Next
    Set cbStandard = VBE.CommandBars("��׼")
    If Err.Number <> 0 Then Set cbStandard = VBE.CommandBars("Standard")
    
    If cbStandard Is Nothing Then Exit Sub
    
    Err.Clear
    On Error GoTo AddToAddInToolboxErr
    
    '��������������
    Set cbToolboxCommandBar = cbStandard.Controls.Add(msoControlButton, , , cbStandard.Controls.Count)
    cbToolboxCommandBar.BeginGroup = True
    cbToolboxCommandBar.Caption = sCaption
    Set mcbToolBoxItem = cbToolboxCommandBar
    Clipboard.SetData LoadResPicture(101, vbResBitmap)
    cbToolboxCommandBar.PasteFace
    
    Set ToolBoxHandler = VBE.Events.CommandBarEvents(mcbToolBoxItem)
        
AddToAddInToolboxErr:
    
End Sub

Private Sub MenuHandler_Click(ByVal CommandBarControl As Object, handled As Boolean, CancelDefault As Boolean)
    Show
End Sub

Private Sub ToolBoxHandler_Click(ByVal CommandBarControl As Object, handled As Boolean, CancelDefault As Boolean)
    Show
End Sub