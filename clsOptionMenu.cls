VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsOptionMenu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit

'����ѡ��˵��࣬�������úͱ�����Ӧ�����Ժ�ֵ�������ɶ�ӦPYTHON��TKinter����

Private m_dicTotal As Dictionary                                                '����ȫ�������ԣ�����Ĭ��ֵ
Private m_Base As clsBaseControl                                                '�����ؼ���
Private m_List() As String
Private m_CanbeOutByMainForm As Boolean

'���PYTHON����,
'sCmdFunc: ����������¼������ص�����;
'rel:�Ƿ�ʹ���������,
'oop:�Ƿ�ʹ�����������
'usettk:�Ƿ�ʹ��TTK������չ(���ʹ��TTK����VB����Ͽ��Ӧ��TTK����Ͽ򣬲�����������ؼ�)
Public Sub toString(ByRef sOut As cStrBuilder, ByRef sCmdFunc As cStrBuilder, rel As Boolean, oop As Boolean, usettk As Boolean)
    
    If Len(m_Base("variable")) = 0 Then
        MsgBox L_F("l_msgMusthasVar", "OptionMenu(ComboBox)����Ҫѡ��variable���ԣ����ڽ�������OptionMenu({0})�Ĵ��롣", m_Base.Name), vbInformation
        Exit Sub
    End If
    
    If oop Then
        toStringOOP sOut, sCmdFunc, rel, usettk
    Else
        toStringStructure sOut, sCmdFunc, rel, usettk
    End If
    
End Sub

'����ṹ������
Private Sub toStringStructure(ByRef sOut As cStrBuilder, ByRef sCmdFunc As cStrBuilder, rel As Boolean, usettk As Boolean)
    
    Dim s() As String, i As Long, sList As String, extra As String, sConfig As String
    
    '�����б�
    For i = 0 To UBound(m_List)
        sList = sList & U(m_List(i)) & ","
    Next
    sList = "(" & sList & ")"
    
    sConfig = getConfigStr()
    
    sOut.Append Space(4) & m_Base.Name & "List = " & sList
    sOut.Append Space(4) & m_Base("variable") & " = StringVar(value=" & m_Base.Name & "List[0])"
    
    extra = m_Base("variable") & ", *" & m_Base.Name & "List"
    
    sOut.Append Space(4) & m_Base.Name & " = OptionMenu(" & m_Base.Parent & IIf(Len(extra), ", ", "") & extra & ")"
    If Len(sConfig) Then
        sOut.Append Space(4) & m_Base.Name & ".configure(" & sConfig & ")"
    End If
    sOut.Append Space(4) & m_Base.Name & ".place(" & m_Base.GetPositionParams(rel) & ")"
    sOut.Append Space(4) & "gComps['" & m_Base.Name & "'] = " & m_Base.Name
    sOut.Append Space(4) & "gComps['" & m_Base("variable") & "'] = " & m_Base("variable")
    
    '�����¼�����������ܣ�����У�
    If Len(m_Base("command")) Then
        sCmdFunc.Append m_Base.CreateFuncDef(m_Base("command"))
    End If
    
    If Len(m_Base("bindcommand")) Then                                          '����Ҫʹ��bind���󶨵������¼�����
        s = Split(m_Base("bindcommand"), ",")
        For i = 0 To UBound(s)
            s(i) = Trim(s(i))
            If s(i) = "<Change>" Then 'ר�Ŵ����Զ��������¼����ÿؼ�����������ģ��
                sOut.Append Space(4) & m_Base("variable") & ".trace('w', " & m_Base.Name & "_Change)"
                sCmdFunc.Append m_Base.CreateFuncDef(m_Base.Name & "_Change", "*args")
            ElseIf Left(s(i), 1) = "<" And Right(s(i), 1) = ">" Then
                sOut.Append Space(4) & m_Base.Name & ".bind('" & s(i) & "', " & m_Base.Name & "_" & Replace(Mid(s(i), 2, Len(s(i)) - 2), "-", "_") & ")"
                sCmdFunc.Append m_Base.CreateFuncDef(m_Base.Name & "_" & Replace(Mid(s(i), 2, Len(s(i)) - 2), "-", "_"), "event")
            End If
        Next
    End If
    
End Sub

'�������������
Private Sub toStringOOP(ByRef sOut As cStrBuilder, ByRef sCmdFunc As cStrBuilder, rel As Boolean, usettk As Boolean)
    
    Dim s() As String, i As Long, sList As String, extra As String, sConfig As String
    
    '�����б�
    For i = 0 To UBound(m_List)
        sList = sList & U(m_List(i)) & ","
    Next
    sList = "(" & sList & ")"
    
    sConfig = getConfigStr()
    
    sOut.Append Space(8) & "self." & m_Base.Name & "List = " & sList
    sOut.Append Space(8) & "self." & m_Base("variable") & " = StringVar(value=self." & m_Base.Name & "List[0])"
    
    extra = "self." & m_Base("variable") & ", *self." & m_Base.Name & "List"
    
    sOut.Append Space(8) & "self." & m_Base.Name & " = OptionMenu(self." & m_Base.Parent & IIf(Len(extra), ", ", "") & extra & ")"
    If Len(sConfig) Then
        sOut.Append Space(8) & "self." & m_Base.Name & ".configure(" & sConfig & ")"
    End If
    sOut.Append Space(8) & "self." & m_Base.Name & ".place(" & m_Base.GetPositionParams(rel) & ")"
    
    '�����¼�����������ܣ�����У�
    If Len(m_Base("command")) Then
        sCmdFunc.Append m_Base.CreateFuncDefOOP(m_Base("command"))
    End If
    
    If Len(m_Base("bindcommand")) Then                                          '����Ҫʹ��bind���󶨵������¼�����
        s = Split(m_Base("bindcommand"), ",")
        For i = 0 To UBound(s)
            s(i) = Trim(s(i))
            If s(i) = "<Change>" Then 'ר�Ŵ����Զ��������¼����ÿؼ�����������ģ��
                sOut.Append Space(8) & "self." & m_Base("variable") & ".trace('w', self." & m_Base.Name & "_Change)"
                sCmdFunc.Append m_Base.CreateFuncDefOOP(m_Base.Name & "_Change", "*args")
            ElseIf Left(s(i), 1) = "<" And Right(s(i), 1) = ">" Then
                sOut.Append Space(8) & "self." & m_Base.Name & ".bind('" & s(i) & "', self." & m_Base.Name & "_" & Replace(Mid(s(i), 2, Len(s(i)) - 2), "-", "_") & ")"
                sCmdFunc.Append m_Base.CreateFuncDefOOP(m_Base.Name & "_" & Replace(Mid(s(i), 2, Len(s(i)) - 2), "-", "_"), "event")
            End If
        Next
    End If
    
End Sub


'���������Ҫ���ϵ������������ʼ��������
Public Sub InitConfig(o As Object, parentWidth As Long, parentHeight As Long, dMethods As Dictionary)
    
    Dim i As Long, oList As Object, sList As String, numList As Long
    Dim s As String, sa() As String, Idx As Long
    
    m_Base.Name = o.Properties("Name")
    
    '��������ѡ��ֵ
    Set oList = o.Properties("List")
    Erase m_List
    numList = 0
    i = IIf(o.Properties("Style") = 2, 1, 0)         ' 2-Dropdown Listʱ��һ��IndexedValueΪ�ؼ��������Դӵڶ��ʼ
    Do While True
        If oList.IndexedValue(i) = "" Then Exit Do
        
        ReDim Preserve m_List(numList) As String
        m_List(numList) = oList.IndexedValue(i)
        i = i + 1
        numList = numList + 1
    Loop
    If numList = 0 Then
        ReDim m_List(0) As String
        m_List(0) = "Add Items in designer or code!"
    End If
    
    m_dicTotal("x") = m_Base.toPixelX(o.Properties("Left"))
    m_dicTotal("y") = m_Base.toPixelY(o.Properties("Top"))
    m_dicTotal("width") = m_Base.toPixelX(o.Properties("Width"))
    m_dicTotal("height") = m_Base.toPixelY(o.Properties("Height"))
    m_dicTotal("relx") = Format(o.Properties("Left") / parentWidth, "0.###")
    m_dicTotal("rely") = Format(o.Properties("Top") / parentHeight, "0.###")
    m_dicTotal("relwidth") = Format(o.Properties("Width") / parentWidth, "0.###")
    m_dicTotal("relheight") = Format(o.Properties("Height") / parentHeight, "0.###")
    m_dicTotal("variable") = o.Properties("Name") & "Var"
    m_dicTotal("relief") = "RAISED"
    m_dicTotal("fg") = TranslateColor(o.Properties("ForeColor"))
    m_dicTotal("bg") = TranslateColor(o.Properties("BackColor"))
    m_dicTotal("bd") = "1"
    m_dicTotal("wraplength") = 150
    m_dicTotal("justify") = "'left'"
    m_dicTotal("state") = IIf(o.Properties("Enabled"), "'normal'", "'disabled'")
    m_dicTotal("anchor") = "'center'"
    m_dicTotal("takefocus") = IIf(o.Properties("TabStop"), 1, 0)
    m_dicTotal("font") = "(" & U(CStr(o.Properties("Font")("Name"))) & "," & Round(o.Properties("Font")("Size")) & _
                        IIf(o.Properties("Font")("Bold"), ",'bold'", "") & IIf(o.Properties("Font")("Italic"), ",'italic'", "") & _
                        IIf(o.Properties("Font")("Underline"), ",'underline'", "") & IIf(o.Properties("Font")("Strikethrough"), ",'overstrike')", ")")
    m_dicTotal("cursor") = m_Base.GetCursorName(o.Properties("MousePointer"))
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
    m_Base("variable") = m_dicTotal("variable")
    If o.Properties("ForeColor") <> vbWindowText Then m_Base("fg") = m_dicTotal("fg")
    If o.Properties("BackColor") <> vbWindowBackground Then m_Base("bg") = m_dicTotal("bg")
    If m_dicTotal("state") <> "'normal'" Then m_Base("state") = m_dicTotal("state")
    If m_dicTotal("takefocus") = 1 Then m_Base("takefocus") = m_dicTotal("takefocus")
    If m_dicTotal("font") <> "(" & U(GetDefaultFontName()) & ",9)" Then m_Base("font") = m_dicTotal("font")
    If m_dicTotal("cursor") <> "" Then m_Base("cursor") = m_dicTotal("cursor")
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
    GetAttrValueList = m_Base.GetAttrValueList(sAttr, sa)
End Function

Public Function Tips(sAttr As String) As String
    Tips = sAttr & vbCrLf
    If sAttr = "wraplength" Then
        Tips = Tips & L("l_TipWrapLen", "���ٸ��ַ����Զ����С����ڶ�����ʾ��")
    Else
        Tips = m_Base.Tips(sAttr)
    End If
End Function

'��ȡ�����ַ���
Private Function getConfigStr() As String
    Dim sOut As New cStrBuilder, saCfg() As String, i As Long
    Const csaCfg = "relief,fg,bg,bd,wraplength,justify,state,anchor,takefocus,font"
    saCfg = Split(csaCfg, ",")
    
    For i = 0 To UBound(saCfg)
        If Len(m_Base(saCfg(i))) Then sOut.Append saCfg(i) & "=" & m_Base(saCfg(i))
    Next
    getConfigStr = sOut.toString(", ")
    
End Function

Private Sub Class_Initialize()
    Set m_dicTotal = New Dictionary
    Set m_Base = New clsBaseControl
    m_Base.ctlType = "OptionMenu"
    m_Base.StyleName = "TMenubutton"
    m_CanbeOutByMainForm = True
End Sub

'���û�ѡ������ø��µ������У�����Ϊʹ��"|"�ָ�ĺܶ������/ֵ��
Public Sub SetConfig(sAttrs As String)
    m_Base.SetConfig sAttrs
End Sub

'�޸Ļ����ӵ������������/ֵ��"|"�ָ�
Public Sub SetSingleConfig(sAttr As String)
    m_Base.SetSingleConfig sAttr
End Sub

'����һ�����ϣ�ÿ����Ŀ��Ԫ��"������|ֵ|�Ƿ�Ĭ��ѡ��"
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
    Description = L("l_DescOptionmenu", "��Ͽ������ҪԤ������Ҫ��ʾ���ַ��б�����Ӧ��Tkinter��Optionmenu�ؼ���")
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


