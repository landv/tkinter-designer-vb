VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsCombobox"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'��Ͽ��࣬�������úͱ�����Ӧ�����Ժ�ֵ�������ɶ�ӦPYTHON��TKinter����

Private m_dicTotal As Dictionary                                                '����ȫ�������ԣ�����Ĭ��ֵ
Private m_Base As clsBaseControl                                                '�����ؼ���
Private m_List As String
Private m_CanbeOutByMainForm As Boolean

'���PYTHON����,
'sCmdFunc: ����������¼������ص�����;
'rel:�Ƿ�ʹ���������,
'oop:�Ƿ�ʹ�����������
'usettk:�Ƿ�ʹ��TTK������չ
Public Sub toString(ByRef sOut As cStrBuilder, ByRef sCmdFunc As cStrBuilder, rel As Boolean, oop As Boolean, usettk As Boolean)
    
    '�ȴ��������б�
    If Len(m_Base("values")) Then
        If oop Then
            sOut.Append Space(8) & "self." & m_Base.Name & "List = " & m_List
        Else
            sOut.Append Space(4) & m_Base.Name & "List = " & m_List
        End If
        If Len(m_Base("textvariable")) Then m_Base("text") = GetFirstItemText()
    End If
    
    m_Base.toString sOut, sCmdFunc, rel, oop, usettk
    
    'Ĭ����������Ͽ���ʾ��һ��
    If Len(m_Base("values")) Then
        If Len(m_Base("textvariable")) Then
            m_Base.Remove ("text")
        Else
            If oop Then
                sOut.Append Space(8) & "self." & m_Base.Name & ".set(self." & m_Base.Name & "List[0])"
            Else
                sOut.Append Space(4) & m_Base.Name & ".set(" & m_Base.Name & "List[0])"
            End If
        End If
    End If
    
End Sub

'���������Ҫ���ϵ������������ʼ��������
Public Sub InitConfig(o As Object, parentWidth As Long, parentHeight As Long, dMethods As Dictionary)
    
    Dim i As Long, oList As Object, sList As String
    Dim s As String, sa() As String, Idx As Long

    m_Base.Name = o.Properties("Name")
    
    '��������ѡ��ֵ
    Set oList = o.Properties("List")
    sList = "["
    i = IIf(o.Properties("Style") = 2, 1, 0)                                    ' 2-Dropdown Listʱ��һ��IndexedValueΪ�ؼ��������Դӵڶ��ʼ
    Do While True
        If oList.IndexedValue(i) = "" Then Exit Do
        sList = sList & U(oList.IndexedValue(i)) & ","
        i = i + 1
    Loop
    m_List = sList & IIf(sList = "[", "'Add items in design or code!',]", "]")
    
    m_dicTotal("x") = m_Base.toPixelX(o.Properties("Left"))
    m_dicTotal("y") = m_Base.toPixelY(o.Properties("Top"))
    m_dicTotal("width") = m_Base.toPixelX(o.Properties("Width"))
    m_dicTotal("height") = m_Base.toPixelY(o.Properties("Height"))
    m_dicTotal("relx") = Format(o.Properties("Left") / parentWidth, "0.###")
    m_dicTotal("rely") = Format(o.Properties("Top") / parentHeight, "0.###")
    m_dicTotal("relwidth") = Format(o.Properties("Width") / parentWidth, "0.###")
    m_dicTotal("relheight") = Format(o.Properties("Height") / parentHeight, "0.###")
    m_dicTotal("displayrows") = ""
    m_dicTotal("textvariable") = m_Base.Name & "Var"
    m_dicTotal("fg") = TranslateColor(o.Properties("ForeColor"))
    m_dicTotal("bg") = TranslateColor(o.Properties("BackColor"))
    m_dicTotal("bd") = "1"
    m_dicTotal("relief") = "SUNKEN"
    m_dicTotal("justify") = "'left'"
    m_dicTotal("state") = IIf(o.Properties("Enabled"), IIf(o.Properties("Locked") Or o.Properties("Style") = 2, "'readonly'", "'normal'"), "'disabled'")
    m_dicTotal("values") = m_Base.Name & "List"
    m_dicTotal("font") = "(" & U(CStr(o.Properties("Font")("Name"))) & "," & Round(o.Properties("Font")("Size")) & _
                        IIf(o.Properties("Font")("Bold"), ",'bold'", "") & IIf(o.Properties("Font")("Italic"), ",'italic'", "") & _
                        IIf(o.Properties("Font")("Underline"), ",'underline'", "") & IIf(o.Properties("Font")("Strikethrough"), ",'overstrike')", ")")
    m_dicTotal("takefocus") = IIf(o.Properties("TabStop"), 1, 0)
    m_dicTotal("cursor") = m_Base.GetCursorName(o.Properties("MousePointer"))
    m_dicTotal("exportselection") = ""
    m_dicTotal("postcommand") = ""
    m_dicTotal("bindcommand") = m_Base.GetBindCommandStr(dMethods)
    
    '��Щ��Ĭ��ѡ���
    m_Base("x") = m_dicTotal("x")
    m_Base("y") = m_dicTotal("y")
    m_Base("width") = m_dicTotal("width")
    m_Base("height") = m_dicTotal("height")
    m_Base("relx") = m_dicTotal("relx")
    m_Base("rely") = m_dicTotal("rely")
    m_Base("relwidth") = m_dicTotal("relwidth")
    m_Base("relheight") = m_dicTotal("relheight")
    m_Base("values") = m_dicTotal("values")
    m_Base("textvariable") = m_dicTotal("textvariable")
    If o.Properties("ForeColor") <> vbWindowText Then m_Base("fg") = m_dicTotal("fg")
    If o.Properties("BackColor") <> vbWindowBackground Then m_Base("bg") = m_dicTotal("bg")
    If m_dicTotal("state") <> "'normal'" Then m_Base("state") = m_dicTotal("state")
    If m_dicTotal("font") <> "(" & U(GetDefaultFontName()) & ",9)" Then m_Base("font") = m_dicTotal("font")
    If m_dicTotal("takefocus") = 0 Then m_Base("takefocus") = m_dicTotal("takefocus")
    If m_dicTotal("cursor") <> "" Then m_Base("cursor") = m_dicTotal("cursor")
    If m_Base.IsExistCommand(dMethods, "Change") Then m_Base("textvariable") = m_dicTotal("textvariable")
    If m_dicTotal("bindcommand") <> "" Then m_Base("bindcommand") = m_dicTotal("bindcommand")
    
    'ʹ�ÿؼ���tag���Ա���һЩ����Ĭ��Ҫ��������ԣ�
    '��ʼ�ַ�Ϊ��p@�������������ÿ������ʹ��@����������ֵ��ѡ�������ֵ����ʹ��k=v��ʽ
    s = Trim(o.Properties("Tag"))
    If Len(s) Then
        sa = Split(s, "@")
        If sa(0) = "p" Or sa(0) = "P" Then
            For i = 1 To UBound(sa)
                s = sa(i)
                Idx = InStr(2, s, "=")
                If Idx > 0 Then '��ֵ
                    m_dicTotal(Left$(s, Idx - 1)) = Mid$(s, Idx + 1)
                    m_Base(Left$(s, Idx - 1)) = m_dicTotal(Left$(s, Idx - 1))
                ElseIf Len(s) > 0 And Len(m_dicTotal(s)) > 0 Then '�������ԣ����ж������Ƿ�Ϸ�
                    m_Base(s) = m_dicTotal(s)
                End If
            Next
        End If
    End If
End Sub

'��������ֵ�Ŀ���ֵ�б�
'����ֵ��0-û�п�ѡֵ��1-��һ���ϸ����ƵĿ�ѡֵ�б���2-���ṩ�Ŀ�ѡֵ�б��⣬�������ֶ���������ֵ
'�����sa()��ѡֵ�б�����
Public Function GetAttrValueList(sAttr As String, ByRef sa() As String) As Long
    
    GetAttrValueList = 1
    Select Case sAttr
        Case "state"
            sa = Split("'normal','readonly','disabled'", ",")
        Case "exportselection"
            sa = Split("False,True", ",")
        Case "bindcommand"
            GetAttrValueList = 2
            sa = Split("<<ComboboxSelected>>", ",")
        Case Else
            GetAttrValueList = m_Base.GetAttrValueList(sAttr, sa)
    End Select
End Function

Public Function Tips(sAttr As String) As String
    
    Tips = sAttr & vbCrLf
    Select Case sAttr:
    Case "displayrows":
        Tips = Tips & L("l_TipDisplayRows", "ָ��Ҫ��ʾ������")
    Case "state":
        Tips = Tips & L("l_TipStateHasRO", "�ؼ�״̬����ʹ����������������ѡֵ�У�'normal', 'readonly', 'disabled'")
    Case "values":
        Tips = Tips & L("l_TipValues", "�ؼ��������ı��б���������ֵ����Ϊ��������Ϊһ���б����������Ҫ����ʱ���Ӻ�ɾ�������ı��б�����Ҫ����ʹ����Ͽ��configure��������values���ԡ�")
    Case "postcommand":
        Tips = Tips & L("l_TipPostCmd", "ÿ�������б���ǰ���ô˻ص�������")
    Case "exportselection":
        Tips = Tips & L("l_TipExportSelection", "Ĭ��ΪFalse��ΪTrueʱ������Window Manager selection��")
    Case Else:
        Tips = m_Base.Tips(sAttr)
    End Select
    
End Function

'��ȡ�����б���һ����ı�
Private Function GetFirstItemText() As String
    If Len(m_List) Then
        GetFirstItemText = Mid(m_List, 3, InStr(1, m_List, ",") - 4)
    Else
        GetFirstItemText = ""
    End If
End Function

Private Sub Class_Initialize()
    Set m_dicTotal = New Dictionary
    Set m_Base = New clsBaseControl
    m_Base.ctlType = "Combobox"
    m_Base.StyleName = "TCombobox"
    m_CanbeOutByMainForm = True
End Sub

'����һ�����ϣ�ÿ����Ŀ��Ԫ��"������|ֵ|�Ƿ�Ĭ��ѡ��"
'�����������������������Բ����б���
Public Function Allitems() As Collection
    Dim re As Collection, k As Variant, ks As Collection
    
    Set re = New Collection
    
    '��׼����
    Set ks = m_dicTotal.Keys
    For Each k In ks
        If Len(m_Base(k)) Then
            re.Add k & "|" & m_Base(k) & "|1"
        Else
            re.Add k & "|" & m_dicTotal(k) & "|0"
        End If
    Next
    
    '�û����ӵ��Զ������������еĻ���
    Set ks = m_Base.Keys
    For Each k In ks
        If Not m_dicTotal.Exists(k) Then
            re.Add k & "|" & m_Base(k) & "|1"
        End If
    Next
    
    Set Allitems = re
    
End Function

'���û�ѡ������ø��µ������У�����Ϊʹ��"|"�ָ�ĺܶ������/ֵ��
Public Sub SetConfig(sAttrs As String)
    m_Base.SetConfig sAttrs
End Sub

'�޸Ļ����ӵ������������/ֵ��"|"�ָ�
Public Sub SetSingleConfig(sAttr As String)
    m_Base.SetSingleConfig sAttr
End Sub

Private Sub Class_Terminate()
    Set m_dicTotal = Nothing
    Set m_Base = Nothing
End Sub

Public Property Let Parent(s As String)
    m_Base.Parent = s
End Property

Public Property Get Parent() As String
    Parent = m_Base.Parent
End Property

Public Property Get Name() As String
    Name = m_Base.Name
End Property

'���ڸı���Ĭ�϶�Ӧ��widget���ͣ��޸�widget���ͺ�ע�������б��ĺϷ���
Public Function SetWidgetType(sType As String, sStyleName As String)
    m_Base.ctlType = sType
    m_Base.StyleName = sStyleName
End Function

'ȷ�������������ܷ������toString()���������룬Ĭ��ΪTrue������ΪFalse˵�����������������ô���
Public Property Get EnableOutByMainForm() As Boolean
    EnableOutByMainForm = m_CanbeOutByMainForm
End Property
Public Property Let EnableOutByMainForm(bEnable As Boolean)
    m_CanbeOutByMainForm = bEnable
End Property

'�������л�����
Public Function Serializer(vSer As clsSerialization)
    vSer.Serializer m_Base
End Function

Public Function Deserializer(vSer As clsSerialization)
    vSer.Deserializer m_Base
End Function

Public Property Get Description() As String
    Description = L("l_DescCombobox", "�ı���Ͽ���󣬶�Ӧ��tkinter.ttk��Combobox�ؼ���")
End Property

Public Property Let ScaleMode(nV As Long)
    m_Base.ScaleMode = nV
End Property

'����ģ��Ƚ�����ĺ�����ʵ�������ж����������������ϵ
'�ñ��������һ������Ƚϣ��߼����Ϊ'������-��һ������'
'����ֵ���壺
'<0����ʾ��������Ҫ����һ������ǰ�������
'=0����ʾ���߽�û��������ϵ������ǰ��˳����Ӱ��
'>0����һ������Ҫ��������롣
'������߼�����������صĳ���
Public Function Compare(ByRef Obj As Object) As Long
    
    If Parent = Obj.Name Then '���ؼ����������
        Compare = 1
    ElseIf Obj.Parent = Name Then
        Compare = -1
    ElseIf Parent = WTOP And Obj.Parent <> WTOP Then '����ؼ������
        Compare = -1
    ElseIf Parent <> WTOP And Obj.Parent = WTOP Then
        Compare = 1
    Else
        Compare = 0
    End If
End Function


