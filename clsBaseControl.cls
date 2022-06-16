VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsBaseControl"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit

'ʵ�����пؼ���Ĺ��ô��룬��ΪVB��֧�������ļ̳У����������ؼ��ཫ��Ƕ����࣬�����Ǽ̳�

Private m_dic As Dictionary                                                     '��ǰҪ���ɴ��������/ֵ��
Private m_Type As String                                                        'ֱ�Ӷ�Ӧ��PYTHON�Ŀؼ�����
Private m_Name As String                                                        '�ؼ���
Private m_Parent As String
Private m_Value As String                                                       ' �ؼ�ֵ�������Ļ���
Private m_StyleName As String                                                   '��ʽ����
Private m_ScaleMode As Long

'���PYTHON����,
'sCmdFunc: ����������¼������ص�����;
'rel:�Ƿ�ʹ���������,
'oop:�Ƿ�ʹ�����������
'usettk:�Ƿ�ʹ��TTK������չ
Public Sub toString(ByRef sOut As cStrBuilder, ByRef sCmdFunc As cStrBuilder, rel As Boolean, oop As Boolean, usettk As Boolean)
    
    If oop Then
        toStringOOP sOut, sCmdFunc, rel, IIf(Len(m_StyleName), usettk, False)
    Else
        toStringStructure sOut, sCmdFunc, rel, IIf(Len(m_StyleName), usettk, False)
    End If
    
End Sub

'����ṹ������
Public Sub toStringStructure(ByRef sOut As cStrBuilder, ByRef sCmdFunc As cStrBuilder, rel As Boolean, usettk As Boolean, Optional sOtherParams As String = "")
    
    Dim s() As String, i As Long, extra As String, sStyle As String
    Dim sTmp As String, dTmp As Double, sCmdName As String, sUnderlineCmd As String
    
    '�����Ҫ�����󶨣����ȴ�����Ӧ�ı���
    If Len(Dic("textvariable")) Then
        sOut.Append Space(4) & Dic("textvariable") & " = StringVar(value=" & U(Dic("text")) & ")"
    End If
    If Len(Dic("variable")) Then
        If m_Type = "Radiobutton" Then  'һ�鵥ѡ��ť��variable����ͬһ������Ҫ�ظ�����
            If Not sOut.ExistString(Space(4) & Dic("variable") & " = StringVar()") Then
                sOut.Append Space(4) & Dic("variable") & " = StringVar()"
            End If
        ElseIf m_Type = "Checkbutton" Then '��ѡ��ť��variableʹ��IntVar�ȽϺ�
            sOut.Append Space(4) & Dic("variable") & " = IntVar(value=" & m_Value & ")"
        Else
            sOut.Append Space(4) & Dic("variable") & " = StringVar(value=" & U(m_Value) & ")"
        End If
    End If
    If Len(Dic("listvariable")) Then
        sOut.Append Space(4) & Dic("listvariable") & " = StringVar(value=" & U(m_Value) & ")"
    End If
    If Not usettk And Len(Dic("font")) Then
        If Left$(Dic("font"), 1) = "(" Then
            sOut.Append Space(4) & m_Name & "Font = Font(font=" & Dic("font") & ")"
        Else '����û����˼����ţ��������
            sOut.Append Space(4) & m_Name & "Font = Font(font=(" & Dic("font") & "))"
        End If
    End If
    
    If Len(Dic("columns")) Then
        sOut.Append Space(4) & Dic("columns") & " = []  " & L("l_cmtTodoCols", "#TODO���������ӱ����б�����һ�й̶�Ϊ������ʾ")
    End If
    If Len(Dic("displaycolumns")) And InStr(1, Dic("displaycolumns"), "#all") <= 0 Then
        sOut.Append Space(4) & Dic("displaycolumns") & "[]    " & L("l_cmtTodoDisCols", "#TODO������������ʾ�����б�����һ�й̶�Ϊ������ʾ")
    End If
    
    '��Ͽ�displayrowsת��Ϊheight����
    If Len(Dic("displayrows")) Then
        sOtherParams = sOtherParams & IIf(Len(sOtherParams), ", ", "") & "height=" & Dic("displayrows")
    End If
    
    If usettk Then                                                              '����STYLE����
        sStyle = GetStyleParams(False, usettk)
        If Len(sStyle) Then
            sOut.Append Space(4) & "style.configure('T" & m_Name & "." & m_StyleName & "', " & sStyle & ")"
            If m_Type = "LabelFrame" Then ' LabelFrame�������ǰ��ɫҪ���õ�Label
                sOut.Append Space(4) & "style.configure('T" & m_Name & "." & m_StyleName & ".Label" & "', " & sStyle & ")"
            End If
            sOtherParams = sOtherParams & IIf(Len(sOtherParams), ", ", "") & "style='T" & m_Name & "." & m_StyleName & "'"
        End If
    End If
    
    extra = GetExtraParams(False, usettk)
    extra = extra & IIf(Len(extra) > 0 And Len(sOtherParams) > 0, ", ", "") & sOtherParams
    sOut.Append Space(4) & m_Name & " = " & m_Type & "(" & m_Parent & IIf(Len(extra), ", ", "") & extra & ")"
    sOut.Append Space(4) & m_Name & ".place(" & GetPositionParams(rel) & ")"
    sOut.Append Space(4) & "gComps['" & m_Name & "'] = " & m_Name
    
    '�����Ҫ�����󶨣�Ϊ�˷�����main()������ʹ�ã�ͬʱ���������÷���ȫ�ֿؼ��ֵ�
    If Len(Dic("textvariable")) Then
        sOut.Append Space(4) & "gComps['" & Dic("textvariable") & "'] = " & Dic("textvariable")
    End If
    If Len(Dic("variable")) Then
        sOut.Append Space(4) & "gComps['" & Dic("variable") & "'] = " & Dic("variable")
    End If
    If Len(Dic("listvariable")) Then
        sOut.Append Space(4) & "gComps['" & Dic("listvariable") & "'] = " & Dic("listvariable")
    End If
    
    '�����¼�����������ܣ�����У����¼������е��˵���ǵ���ϵͳ�ĺ���������Ҫ���ɺ�����
    If Len(Dic("command")) > 0 And InStr(1, Dic("command"), ".") <= 0 And InStr(1, Dic("command"), "lambda ") <= 0 Then
        sCmdFunc.Append CreateFuncDef(Dic("command"), "event=None")
    End If
    If Len(Dic("postcommand")) Then
        sCmdFunc.Append CreateFuncDef(Dic("postcommand"), "event=None")
    End If
    
    '�����»��߿�ݷ�ʽ
    If Len(Dic("underline")) > 0 And Dic("underline") <> "-1" And IsNumeric(Dic("underline")) Then
        If m_Type = "Button" Or m_Type = "Checkbutton" Or m_Type = "Radiobutton" Then
            sUnderlineCmd = "lambda e: " & m_Name & ".focus_set() or " & m_Name & ".invoke()"
        ElseIf Len(Dic("command")) > 0 Then
            sUnderlineCmd = Dic("command")
        Else
            sUnderlineCmd = "lambda e: " & m_Name & ".focus_set()"
        End If
        
        If Len(sUnderlineCmd) Then
            sTmp = Dic("text")
            If Len(sTmp) = 0 Then sTmp = Dic("label")
            If Len(sTmp) And CLng(Dic("underline")) < Len(sTmp) Then
                sOut.Append Space(4) & WTOP & ".bind_all('<Alt-" & Mid(sTmp, CLng(Dic("underline")) + 1, 1) & ">', " & sUnderlineCmd & ")"
                If Mid(sTmp, CLng(Dic("underline")) + 1, 1) >= "a" And Mid(sTmp, CLng(Dic("underline")) + 1, 1) <= "z" Then
                    sOut.Append Space(4) & WTOP & ".bind_all('<Alt-" & UCase(Mid(sTmp, CLng(Dic("underline")) + 1, 1)) & ">', " & sUnderlineCmd & ")"
                ElseIf Mid(sTmp, CLng(Dic("underline")) + 1, 1) >= "A" And Mid(sTmp, CLng(Dic("underline")) + 1, 1) <= "Z" Then
                    sOut.Append Space(4) & WTOP & ".bind_all('<Alt-" & LCase(Mid(sTmp, CLng(Dic("underline")) + 1, 1)) & ">', " & sUnderlineCmd & ")"
                End If
            End If
        End If
    End If
    
    If Len(Dic("bindcommand")) Then                                             '����Ҫʹ��bind���󶨵������¼�����
        sTmp = Dic("bindcommand")
        sTmp = Replace(sTmp, "'", "")                                           '�Զ�ȥ�����źͿո�����еĻ�
        sTmp = Replace(sTmp, Chr(34), "")
        sTmp = Replace(sTmp, " ", "")
        
        s = Split(sTmp, ",")
        For i = 0 To UBound(s)
            s(i) = Trim(s(i))
            If s(i) = "<Change>" Then 'ר�Ŵ����Զ��������¼����ÿؼ�����������ģ��
                If (m_Type = "Combobox" Or m_Type = "Entry" Or m_Type = "Label") And (Len(Dic("textvariable")) > 0) Then
                    sCmdName = m_Name & "_Change"
                    sOut.Append Space(4) & Dic("textvariable") & ".trace('w', " & sCmdName & ")"
                    sCmdFunc.Append CreateFuncDef(sCmdName, "*args")
                End If
            ElseIf Left(s(i), 1) = "<" And Right(s(i), 1) = ">" Then
                
                sCmdName = m_Name & "_" & Replace(Replace(Replace(s(i), "<", ""), ">", ""), "-", "_")
                
                sOut.Append Space(4) & m_Name & ".bind('" & s(i) & "', " & sCmdName & ")"
                
                sCmdFunc.Append CreateFuncDef(sCmdName, "event")
                
                'Python�Ǵ�Сд���еģ���Ӧ��ݼ�Ҳһ����������õĿ�ݼ�������ĸ�����򽫶�Ӧ�Ĵ�д/СдҲһ���
                If Right(s(i), 3) >= "-a>" And Right(s(i), 3) <= "-z>" Then
                    
                    s(i) = Left(s(i), Len(s(i)) - 2) & UCase(Mid(s(i), Len(s(i)) - 1, 1)) & ">" '��Ӧ��ĸ���д
                    sOut.Append Space(4) & m_Name & ".bind('" & s(i) & "', " & sCmdName & ")"
                    
                ElseIf Right(s(i), 3) >= "-A>" And Right(s(i), 3) <= "-Z>" Then
                    
                    s(i) = Left(s(i), Len(s(i)) - 2) & LCase(Mid(s(i), Len(s(i)) - 1, 1)) & ">" '��Ӧ��ĸ��Сд
                    sOut.Append Space(4) & m_Name & ".bind('" & s(i) & "', " & sCmdName & ")"
                    
                End If
            End If
        Next
    End If
    
End Sub

'�������������
Public Sub toStringOOP(ByRef sOut As cStrBuilder, ByRef sCmdFunc As cStrBuilder, rel As Boolean, usettk As Boolean, Optional sOtherParams As String = "")
    
    Dim s() As String, i As Long, extra As String
    Dim sTmp As String, sStyle As String, sCmdName As String, sUnderlineCmd As String
    
    '�����Ҫ�����󶨣����ȴ�����Ӧ�ı���
    If Len(Dic("textvariable")) Then
        sOut.Append Space(8) & "self." & Dic("textvariable") & " = StringVar(value=" & U(Dic("text")) & ")"
    End If
    If Len(Dic("variable")) Then
        If m_Type = "Radiobutton" Then  'һ�鵥ѡ��ť��variable����ͬһ������Ҫ�ظ�����
            If Not sOut.ExistString(Space(8) & "self." & Dic("variable") & " = StringVar()") Then
                sOut.Append Space(8) & "self." & Dic("variable") & " = StringVar()"
            End If
        ElseIf m_Type = "Checkbutton" Then '��ѡ��ť��variableʹ��IntVar�ȽϺ�
            sOut.Append Space(8) & "self." & Dic("variable") & " = IntVar(value=" & m_Value & ")"
        Else
            sOut.Append Space(8) & "self." & Dic("variable") & " = StringVar(value=" & U(m_Value) & ")"
        End If
    End If
    If Len(Dic("listvariable")) Then
        sOut.Append Space(8) & "self." & Dic("listvariable") & " = StringVar(value=" & U(m_Value) & ")"
    End If
    If Not usettk And Len(Dic("font")) Then
        If Left$(Dic("font"), 1) = "(" Then
            sOut.Append Space(8) & "self." & m_Name & "Font = Font(font=" & Dic("font") & ")"
        Else
            sOut.Append Space(8) & "self." & m_Name & "Font = Font(font=(" & Dic("font") & "))"
        End If
    End If
    
    If Len(Dic("columns")) Then
        sOut.Append Space(8) & "self." & Dic("columns") & " = []    " & L("l_cmtTodoCols", "#TODO���������ӱ����б�����һ�й̶�Ϊ������ʾ")
    End If
    If Len(Dic("displaycolumns")) And InStr(1, Dic("displaycolumns"), "#all") <= 0 Then
        sOut.Append Space(8) & "self." & Dic("displaycolumns") & " = []    " & L("l_cmtTodoDisCols", "#TODO������������ʾ�����б�����һ�й̶�Ϊ������ʾ")
    End If
    
    '��Ͽ�displayrowsת��Ϊheight����
    If Len(Dic("displayrows")) Then
        sOtherParams = sOtherParams & IIf(Len(sOtherParams), ", ", "") & "height=" & Dic("displayrows")
    End If
    
    If usettk Then                                                              '����STYLE����
        sStyle = GetStyleParams(True, usettk)
        If Len(sStyle) Then
            sOut.Append Space(8) & "self.style.configure('T" & m_Name & "." & m_StyleName & "', " & sStyle & ")"
            If m_Type = "LabelFrame" Then ' LabelFrame�������ǰ��ɫҪ���õ�Label
                sOut.Append Space(8) & "self.style.configure('T" & m_Name & "." & m_StyleName & ".Label" & "', " & sStyle & ")"
            End If
            sOtherParams = sOtherParams & IIf(Len(sOtherParams), ", ", "") & "style='T" & m_Name & "." & m_StyleName & "'"
        End If
    End If
    
    extra = GetExtraParams(True, usettk)
    extra = extra & IIf(Len(extra) > 0 And Len(sOtherParams) > 0, ", ", "") & sOtherParams
    sOut.Append Space(8) & "self." & m_Name & " = " & m_Type & "(self." & m_Parent & IIf(Len(extra), ", ", "") & extra & ")"
    sOut.Append Space(8) & "self." & m_Name & ".place(" & GetPositionParams(rel) & ")"
    
    '�����¼�����������ܣ�����У����¼������е��˵���ǵ���ϵͳ�ĺ���������Ҫ���ɺ�����
    If Len(Dic("command")) > 0 And InStr(1, Dic("command"), ".") <= 0 And InStr(1, Dic("command"), "lambda ") <= 0 Then
        sCmdFunc.Append CreateFuncDefOOP(Dic("command"), "event=None")
    End If
    If Len(Dic("postcommand")) Then
        sCmdFunc.Append CreateFuncDefOOP(Dic("postcommand"), "event=None")
    End If
    
    '�����»��߿�ݷ�ʽ
    If Len(Dic("underline")) > 0 And Dic("underline") <> "-1" And IsNumeric(Dic("underline")) Then
        If m_Type = "Button" Or m_Type = "Checkbutton" Or m_Type = "Radiobutton" Then
            sUnderlineCmd = "lambda e: self." & m_Name & ".focus_set() or self." & m_Name & ".invoke()"
        ElseIf Len(Dic("command")) > 0 Then
            sUnderlineCmd = "self." & Dic("command")
        Else
            sUnderlineCmd = "lambda e: self." & m_Name & ".focus_set()"
        End If
        
        If Len(sUnderlineCmd) Then
            sTmp = Dic("text")
            If Len(sTmp) = 0 Then sTmp = Dic("label")
            If Len(sTmp) And CLng(Dic("underline")) < Len(sTmp) Then
                sOut.Append Space(8) & "self." & WTOP & ".bind_all('<Alt-" & Mid(sTmp, CLng(Dic("underline")) + 1, 1) & ">', " & sUnderlineCmd & ")"
                If Mid(sTmp, CLng(Dic("underline")) + 1, 1) >= "a" And Mid(sTmp, CLng(Dic("underline")) + 1, 1) <= "z" Then
                    sOut.Append Space(8) & "self." & WTOP & ".bind_all('<Alt-" & UCase(Mid(sTmp, CLng(Dic("underline")) + 1, 1)) & ">', " & sUnderlineCmd & ")"
                ElseIf Mid(sTmp, CLng(Dic("underline")) + 1, 1) >= "A" And Mid(sTmp, CLng(Dic("underline")) + 1, 1) <= "Z" Then
                    sOut.Append Space(8) & "self." & WTOP & ".bind_all('<Alt-" & LCase(Mid(sTmp, CLng(Dic("underline")) + 1, 1)) & ">', " & sUnderlineCmd & ")"
                End If
            End If
        End If
    End If
    
    If Len(Dic("bindcommand")) Then                                             '����Ҫʹ��bind���󶨵������¼�����
        sTmp = Dic("bindcommand")
        sTmp = Replace(sTmp, "'", "")                                           '�Զ�ȥ�����źͿո�����еĻ�
        sTmp = Replace(sTmp, Chr(34), "")
        sTmp = Replace(sTmp, " ", "")
        
        s = Split(sTmp, ",")
        For i = 0 To UBound(s)
            s(i) = Trim(s(i))
            If s(i) = "<Change>" Then 'ר�Ŵ����Զ��������¼����ÿؼ�����������ģ��
                If (m_Type = "Combobox" Or m_Type = "Entry" Or m_Type = "Label") And (Len(Dic("textvariable")) > 0) Then
                    sCmdName = m_Name & "_Change"
                    sOut.Append Space(8) & "self." & Dic("textvariable") & ".trace('w', self." & sCmdName & ")"
                    sCmdFunc.Append CreateFuncDefOOP(sCmdName, "*args")
                End If
            ElseIf Left(s(i), 1) = "<" And Right(s(i), 1) = ">" Then
                
                sCmdName = m_Name & "_" & Replace(Replace(Replace(s(i), "<", ""), ">", ""), "-", "_")
                
                sOut.Append Space(8) & "self." & m_Name & ".bind('" & s(i) & "', self." & sCmdName & ")"
                sCmdFunc.Append CreateFuncDefOOP(sCmdName, "event")
                
                'Python�Ǵ�Сд���еģ���Ӧ��ݼ�Ҳһ����������õĿ�ݼ�������ĸ�����򽫶�Ӧ�Ĵ�д/СдҲһ���
                If Right(s(i), 3) >= "-a>" And Right(s(i), 3) <= "-z>" Then
                    
                    s(i) = Left(s(i), Len(s(i)) - 2) & UCase(Mid(s(i), Len(s(i)) - 1, 1)) & ">" '���д
                    sOut.Append Space(8) & "self." & m_Name & ".bind('" & s(i) & "', self." & sCmdName & ")"
                    
                ElseIf Right(s(i), 3) >= "-A>" And Right(s(i), 3) <= "-Z>" Then
                    
                    s(i) = Left(s(i), Len(s(i)) - 2) & LCase(Mid(s(i), Len(s(i)) - 1, 1)) & ">" '��Сд
                    sOut.Append Space(8) & "self." & m_Name & ".bind('" & s(i) & "', self." & sCmdName & ")"
                    
                End If
            End If
        Next
    End If
    
End Sub

'����rel(�Ƿ�����������)�����ɶ�Ӧ�Ŀؼ�λ����Ϣ
Public Function GetPositionParams(rel As Boolean) As String
    If rel Then
        GetPositionParams = "relx=" & Commas2Points(Dic("relx")) & ", rely=" & Commas2Points(Dic("rely")) & _
            ", relwidth=" & Commas2Points(Dic("relwidth"))
        If m_Type <> "Combobox" Then 'Combobox����Ҫ����height����
            GetPositionParams = GetPositionParams & ", relheight=" & Commas2Points(Dic("relheight"))
        End If
    Else
        GetPositionParams = "x=" & Commas2Points(Dic("x")) & ", y=" & Commas2Points(Dic("y")) & _
            ", width=" & Commas2Points(Dic("width"))
        If m_Type <> "Combobox" Then 'Combobox����Ҫ����height����
            GetPositionParams = GetPositionParams & ", height=" & Commas2Points(Dic("height"))
        End If
    End If
End Function

'���˱�ѡ�����⣬������������û�ѡ������������б�
Public Function GetExtraParams(oop As Boolean, usettk As Boolean) As String
    
    Dim cfg As Variant, k As Variant, ks As Variant, sValue As String, s As New cStrBuilder
    
    Set ks = m_dic.Keys
    
    For Each k In ks
        If isExtra(k, usettk) And Len(Dic(k)) Then
            '��Ҫʹ�����������������ԣ�����û����ˣ����������Զ�����
            If k = "text" Or k = "label" Then
                If m_Type = "Entry" And Len(Dic("textvariable")) > 0 And usettk Then 'ttkģʽ��Entryʹ��textvariable��ʾ�ַ���������ʹ��text����
                    '����text����
                    sValue = ""
                Else
                    sValue = U(Dic(k))
                End If
            ElseIf InStr(1, ",fg,bg,anchor,justify,show,state,activestyle,labelanchor,mode,cursor,highlightbackground,highlightcolor,selectbackground,selectforeground,", _
                        "," & k & ",") Then
                sValue = Quote(Dic(k))
            Else
                sValue = Dic(k)
            End If
            
            If Len(sValue) Then
                s.Append k & "=" & sValue
            End If
        End If
    Next
    
    If Len(Dic("columns")) Then s.Append "columns=" & IIf(oop, "self.", "") & Dic("columns")
    If Len(Dic("displaycolumns")) Then
        If InStr(1, Dic("displaycolumns"), "#all") <= 0 Then
            s.Append "displaycolumns=" & IIf(oop, "self.", "") & Dic("displaycolumns")
        Else
            s.Append "displaycolumns='#all'"
        End If
    End If
    
    If Len(Dic("textvariable")) Then s.Append "textvariable=" & IIf(oop, "self.", "") & Dic("textvariable")
    If Len(Dic("variable")) Then s.Append "variable=" & IIf(oop, "self.", "") & Dic("variable")
    If Len(Dic("listvariable")) Then s.Append "listvariable=" & IIf(oop, "self.", "") & Dic("listvariable")
    If Len(Dic("values")) Then s.Append "values=" & IIf(oop, "self.", "") & Dic("values")
    
    If Len(Dic("command")) Then
        If InStr(1, Dic("command"), "lambda ") > 0 Then '�������������ü�self.
            s.Append "command=" & Dic("command")
        Else
            s.Append "command=" & IIf(oop, "self.", "") & Dic("command")
        End If
    End If
    
    If Len(Dic("postcommand")) Then s.Append "postcommand=" & IIf(oop, "self.", "") & Dic("postcommand")
    If Len(Dic("xscrollcommand")) Then s.Append "xscrollcommand=" & IIf(oop, "self.", "") & Dic("xscrollcommand")
    If Len(Dic("yscrollcommand")) Then s.Append "yscrollcommand=" & IIf(oop, "self.", "") & Dic("yscrollcommand")
    If Len(Dic("font")) Then
        If usettk Then 'TTKģʽ�Ĵ�����ؼ���fontһ�㶼Ҫд����ʽ���棬��Entry/Combobox��fontҪд�ڴ��������вŹ���
            If m_Type = "Entry" Or m_Type = "Combobox" Then
                s.Append "font=" & IIf(Left$(Dic("font"), 1) = "(", Dic("font"), "(" & Dic("font") & ")") '�Զ�������
            End If
        Else
            s.Append "font=" & IIf(oop, "self.", "") & m_Name & "Font"
        End If
    End If
    
    GetExtraParams = s.toString(", ")
    
End Function

'�ж�һ�������Ƿ��Ƕ�������������TTK���жϸ��������
Private Function isExtra(ByVal sK As String, usettk As Boolean) As Boolean
    Const EXTRA_STRING As String = ",x,y,relx,rely,width,height,relwidth,relheight,command,bindcommand,xscrollcommand," & _
        "yscrollcommand,postcommand,font,textvariable,variable,listvariable,values,displayrows,columns,displaycolumns,"
    Const EXTRA_STRING_TTK As String = EXTRA_STRING & ",fg,bg,bd,relief,activerelief,overrelief,anchor,jump,indicatoron,resolution,digits," & _
        "sliderlength,sliderrelief,showvalue,tickinterval,"
    
    If usettk Then
        isExtra = (InStr(1, EXTRA_STRING_TTK, "," & sK & ",") <= 0)
    Else
        isExtra = (InStr(1, EXTRA_STRING, "," & sK & ",") <= 0)
    End If
End Function

'���ʹ����TTK��չ��ʹ�����������ȡTTK��ز����������Ϸ����ַ������б�
Private Function GetStyleParams(oop As Boolean, usettk As Boolean) As String
    Dim s As New cStrBuilder
    
    If Len(Dic("relief")) Then s.Append "relief=" & Dic("relief")
    If Len(Dic("activerelief")) Then s.Append "activerelief=" & Dic("activerelief")
    If Len(Dic("overrelief")) Then s.Append "overrelief=" & Dic("overrelief")
    If Len(Dic("anchor")) Then s.Append "anchor=" & Quote(Dic("anchor"))
    If Len(Dic("fg")) Then s.Append "foreground=" & Quote(Dic("fg"))
    If Len(Dic("bg")) Then s.Append "background=" & Quote(Dic("bg"))
    If Len(Dic("bd")) Then s.Append "borderwidth=" & Dic("bd")
    If Len(Dic("jump")) Then s.Append "jump=" & Dic("jump")
    If Len(Dic("indicatoron")) Then s.Append "indicatoron=" & Dic("indicatoron")
    If Len(Dic("font")) Then
        'ttk.Entry��fontҪд�ڹ��������вŹ���,ttk.LabelFrame��fontҪ���õ�.Label���ԲŹ���
        If m_Type <> "Entry" And m_Type <> "Combobox" Then
            If Left$(Dic("font"), 1) = "(" Then
                s.Append "font=" & Dic("font")
            Else  '����û����˼����ţ��������
                s.Append "font=(" & Dic("font") & ")"
            End If
        End If
    End If
    If Len(Dic("showvalue")) Then s.Append "showvalue=" & Dic("showvalue")
    If Len(Dic("tickinterval")) Then s.Append "tickinterval=" & Dic("tickinterval")
    If Len(Dic("sliderrelief")) Then s.Append "sliderrelief=" & Dic("sliderrelief")
    If Len(Dic("sliderlength")) Then s.Append "sliderlength=" & Dic("sliderlength")
    If Len(Dic("digits")) Then s.Append "digits=" & Dic("digits")
    
    GetStyleParams = s.toString(", ")
    
End Function

'���ݴ���ģ���еĺ����������Զ���дbindcommand��
'dMethods���ؼ���Ϊ����ʹ�ö��ŷָ��Ŀؼ��¼������������ַ���
Public Function GetBindCommandStr(dMethods As Dictionary) As String
    Dim s As String, sOut As cStrBuilder
    If Not dMethods.Exists(m_Name) Then Exit Function
    
    Set sOut = New cStrBuilder
    s = dMethods.Item(m_Name)
    
    '�⼸���ؼ���Click�¼���command�������ñȽϺã�����Ҫbind
    If m_Type = "Button" Or m_Type = "Checkbutton" Or m_Type = "Radiobutton" Then
        If InStr(1, s, "," & m_Name & "_MouseDown,") > 0 Then sOut.Append "<Button-1>"
    Else
        If InStr(1, s, "," & m_Name & "_Click,") > 0 Or InStr(1, s, "," & m_Name & "_MouseDown,") > 0 Then sOut.Append "<Button-1>"
    End If
    
    If InStr(1, s, "," & m_Name & "_DblClick,") > 0 Then sOut.Append "<Double-Button-1>"
    If InStr(1, s, "," & m_Name & "_Resize,") > 0 Then sOut.Append "<Configure>"
    If InStr(1, s, "," & m_Name & "_GotFocus,") > 0 Then sOut.Append "<FocusIn>"
    If InStr(1, s, "," & m_Name & "_LostFocus,") > 0 Then sOut.Append "<FocusOut>"
    If InStr(1, s, "," & m_Name & "_KeyPress,") > 0 Or InStr(1, s, "," & m_Name & "_KeyDown,") > 0 Then sOut.Append "<KeyPress>"
    If InStr(1, s, "," & m_Name & "_KeyUp,") > 0 Then sOut.Append "<KeyRelease>"
    If InStr(1, s, "," & m_Name & "_MouseUp,") > 0 Then sOut.Append "<ButtonRelease-1>"
    If InStr(1, s, "," & m_Name & "_Enter,") > 0 Or InStr(1, s, "," & m_Name & "_MouseMove,") > 0 Then sOut.Append "<Motion>"
    If InStr(1, s, "," & m_Name & "_Leave,") > 0 Then sOut.Append "<Leave>"
    
    If InStr(1, s, "," & m_Name & "_Change,") > 0 Then sOut.Append "<Change>"  '����¼����ڲ����������Ǳ�׼tk�¼�
    
    If m_Type = "Treeview" Then
        If InStr(1, s, "," & m_Name & "_NodeClick,") > 0 Then sOut.Append "<<TreeviewSelect>>"
        If InStr(1, s, "," & m_Name & "_Collapse,") > 0 Then sOut.Append "<<TreeviewClose>>"
        If InStr(1, s, "," & m_Name & "_Expand,") > 0 Then sOut.Append "<<TreeviewOpen>>"
    ElseIf m_Type = "Notebook" Then
        If InStr(1, s, "," & m_Name & "_BeforeClick,") > 0 Then sOut.Append "<<NotebookTabChanged>>"
    End If
    
    GetBindCommandStr = sOut.toString(",")
End Function

Public Function IsExistCommand(dMethods As Dictionary, sCmd As String) As Boolean
    If dMethods.Exists(m_Name) Then IsExistCommand = (InStr(1, dMethods.Item(m_Name), "," & m_Name & "_" & sCmd & ",") > 0)
End Function

'����/��ȡ�ֵ��ֵ
Public Property Get Dic(ByVal sKey As String) As String
Attribute Dic.VB_UserMemId = 0
    If m_dic.Exists(sKey) Then Dic = m_dic(sKey)
End Property

Public Property Let Dic(ByVal sKey As String, ByVal sValue As String)
    m_dic(sKey) = sValue
End Property

Public Sub Remove(ByVal sKey As String)
    m_dic.Remove (sKey)
End Sub

'���û�ѡ������ø��µ������У�����Ϊʹ��"|"�ָ�ĺܶ������/ֵ��
Public Sub SetConfig(sAttrs As String)
    Dim sa() As String, i As Long
    
    sa = Split(sAttrs, "|")
    Debug.Assert (UBound(sa) Mod 1 = 0)
    
    m_dic.RemoveAll
    
    For i = 0 To UBound(sa) - 1 Step 2
        m_dic(sa(i)) = sa(i + 1)
    Next
    
End Sub


'�޸Ļ����ӵ������������/ֵ��"|"�ָ�
Public Sub SetSingleConfig(sAttr As String)
    Dim sa() As String
    sa = Split(sAttr, "|")
    Debug.Assert (UBound(sa) = 1)
    m_dic(sa(0)) = sa(1)
End Sub

'��������ֵ�Ŀ���ֵ�б�
'����ֵ��0-û�п�ѡֵ��1-��һ���ϸ����ƵĿ�ѡֵ�б���2-���ṩ�Ŀ�ѡֵ�б��⣬�������ֶ���������ֵ
'�����sa()��ѡֵ�б�����
Public Function GetAttrValueList(sAttr As String, ByRef sa() As String) As Long
    GetAttrValueList = 1
    Select Case sAttr
        Case "anchor"
            sa = Split("'w','n','s','e','nw','ne','sw','se','center'", ",")
        Case "relief", "overrelief"
            sa = Split("FLAT,GROOVE,RAISED,RIDGE,SOLID,SUNKEN", ",")
        Case "takefocus"
            sa = Split("1,0", ",")
        Case "state"
            sa = Split("'normal','disabled'", ",")
        Case "justify"
            sa = Split("'left','right','center'", ",")
        Case "orient"
            sa = Split("'horizontal','vertical'", ",")
        Case "cursor"
            sa = Split("'arrow','bottom_left_corner','bottom_right_corner','center_ptr','circle','clock','cross'," & _
                "'crosshair','dot','double_arrow','exchange','fleur','hand1','hand2','icon','left_ptr','plus'," & _
                "'question_arrow','sb_h_double_arrow','sb_v_double_arrow','sizing','tcross','watch','xterm','X_cursor'", ",")
            GetAttrValueList = 2
        Case Else
            GetAttrValueList = 0
    End Select
            
End Function

'�����������߰���
Public Function Tips(sAttr As String) As String
    
    Tips = sAttr & vbCrLf
    Select Case sAttr:
    Case "text", "label":
        Tips = Tips & L("l_TipText", "�ؼ�����ʾ�ı���")
    Case "x", "y":
        Tips = Tips & L("l_TipXY", "�ؼ��ķ���λ�á�")
    Case "width":
        Tips = Tips & L("l_TipWidth", "�ؼ��Ŀ��ȡ�")
    Case "height":
        Tips = Tips & L("l_TipHeight", "�ؼ��ĸ߶ȡ�")
    Case "relx", "rely":
        Tips = Tips & L("l_TipRelXY", "�ؼ�����ڸ����ڵ�λ�ã�ֵ��ΧΪ0-1��")
    Case "relwidth":
        Tips = Tips & L("l_TipRelWidth", "�ؼ�����ڸ����ڵĿ��ȣ�ֵ��ΧΪ0-1��")
    Case "relheight":
        Tips = Tips & L("l_TipRelHeight", "�ؼ�����ڸ����ڵĸ߶ȣ�ֵ��ΧΪ0-1��")
    Case "fg":
        Tips = Tips & L("l_TipFg", "ǰ��ɫ����ʽΪ#RGB��red�ȵ��ʣ�����'#FFEA00'��")
    Case "bg":
        Tips = Tips & L("l_TipBg", "����ɫ����ʽΪ#RGB��red�ȵ��ʣ�����'#FFEA00'��")
    Case "bd":
        Tips = Tips & L("l_TipBd", "�߿���ȣ���λΪ���ء�")
    Case "anchor":
        Tips = Tips & L("l_TipAnchor", "�ؼ������ֵĶ��뷽ʽ������ֵΪ��\n'w'|'n'|'s'|'e'|'nw'|'ne'|'sw'|'se'|'center'.")
    Case "relief":
        Tips = Tips & L("l_TipRelief", "���Ч������ѡֵ�У�FLAT, GROOVE, RAISED, RIDGE, SOLID, SUNKEN��")
    Case "overrelief":
        Tips = Tips & L("l_TipOverRelief", "�����ͣ�ڿؼ��ϵ����Ч������ѡֵ�У�FLAT, GROOVE, RAISED, RIDGE, SOLID, SUNKEN��")
    Case "takefocus":
        Tips = Tips & L("l_TipTakeFocus", "�Ƿ�����TABѡ��ؼ�������Ϊ1Ϊ����������Ϊ0��TAB�����˿ؼ���")
    Case "state":
        Tips = Tips & L("l_TipState", "�ؼ�״̬����ѡֵ�У�'normal', 'disabled'")
    Case "underline":
        Tips = Tips & L("l_TipUnderline", "���ĸ���ĸ�������»��ߣ���Ϊ��ݷ�ʽ�ı�ʾ����һ����ĸ����Ϊ0��")
    Case "justify":
        Tips = Tips & L("l_TipJustify", "���ƶ����ַ��Ķ��뷽ʽ������ֵΪ��" & vbCrLf & "left, right, center��")
    Case "padding":
        Tips = Tips & L("l_TipPadding", "�ؼ��ڲ������࣬һ�㲻��Ҫ���á������Ҫ���ã����ṩ'�� �� �� ��'�ĸ�ֵ��������ֵ'�� �� ��'(��=��)������ֵ'�� ��'(��=��,��=��)��һ��ֵ'��'(��=��=��=��)��")
    Case "orient":
        Tips = Tips & L("l_TipOrient", "�ؼ��������ͣ�ȫ��д�������ţ�Сд����Ҫ��������������ѡֵ�У�'horizontal', 'vertical'��")
    Case "cursor":
        Tips = Tips & L("l_TipCursor", "���ָ�롣����ʹ��tk���õ�ָ�룬�����ļ���ǰ����һ��@����ʹ���ⲿָ�룬��'@custom.cur'��")
    Case "variable":
        Tips = Tips & L("l_TipVariable", "�ؼ�ֵ��һ�������󶨣�ͨ���������Ի�ȡ�����ÿؼ���ֵ��\n�����Ҫ������ԣ������������Ϊ��������")
    Case "textvariable":
        Tips = Tips & L("l_TipTextVariable", "����ʾ�ı���һ�������󶨣������仯ʱ�ؼ�����ʾ�ı����ı䣬������Ȼ��\n�����Ҫ������ԣ������������Ϊ��������")
    Case "command":
        Tips = Tips & L("l_TipCommand", "�����¼�������������������������Ҳ��������Ϊtop.destroy��tk������ʹ��lambda������")
    Case "bindcommand":
        Tips = Tips & L("l_TipBindCommand", "ʹ��bind()�󶨵��¼������б����󶨶����ʹ�ö��ŷָ�(���磺<Control-C>,<F8>,<Alt-A>)��\n˫���ı���鿴���顣")
    Case "font":
        Tips = Tips & L("l_TipFont", "�����������ԡ���һ��Ԫ�顣\nԪ��ǰ����Ԫ��Ϊ��������,�����С,֮��ļ���Ԫ�ؿ�ѡ��'bold', 'italic', 'underline', 'overstrike'")
    Case "xscrollcommand":
        Tips = Tips & L("l_TipXScrlCmd", "ˮƽ�����¼������������Ҫˮƽ�������������ֵΪˮƽ��������set������")
    Case "yscrollcommand":
        Tips = Tips & L("l_TipYScrlCmd", "���¹����¼������������Ҫ���¹������������ֵΪ��ֱ��������set������")
    Case "xscrollincrement":
        Tips = Tips & L("l_TipXScrlIncre", "ˮƽÿ�ι���������Ĭ��Ϊ0�����������������������Ϊһ���������������")
    Case "yscrollincrement":
        Tips = Tips & L("l_TipYScrlIncre", "����ÿ�ι���������Ĭ��Ϊ0�����������������������Ϊһ���������������")
    Case "scrollregion"
        Tips = Tips & L("l_TipScrlregion", "�ؼ�������Χ����������Ϊ�ؼ�ʵ�����ж�󣩣���ʽ��(w,n,e,s)��\n���Ҫ����Canvas���Թ�������������ô����ԡ�")
    Case "confine"
        Tips = Tips & L("l_TipConfine", "�Ƿ�������scrollregion�ڹ�����Ĭ��Ϊtrue��")
    Case "highlightbackground"
        Tips = Tips & L("l_TipHlbg", "�ؼ�ʧȥ����ʱ�߿����ɫ��")
    Case "highlightcolor"
        Tips = Tips & L("l_TipHlColor", "�ؼ�ѡ��״̬ʱ�߿����ɫ��")
    Case "highlightthickness"
        Tips = Tips & L("l_TipHlThickness", "����״̬�߿���ȣ�Ĭ��Ϊ1��")
    Case "selectbackground"
        Tips = Tips & L("l_TipSltbg", "�ؼ���ѡ����ı���ɫ��")
    Case "selectborderwidth"
        Tips = Tips & L("l_TipSltbd", "�ؼ���ѡ����ı߿���ȡ�")
    Case "selectforeground"
        Tips = Tips & L("l_TipSltfg", "�ؼ���ѡ�����ǰ��ɫ��")
    Case Else:
        Tips = Tips & L("l_TipUnknown", "δ֪���ԡ�")
    End Select
    
End Function

Public Property Let ctlType(s As String)
    m_Type = s
End Property

'���ÿؼ��ĸ����ڣ�Ĭ����top
Public Property Let Parent(s As String)
    m_Parent = s
End Property

'���ؿؼ��ĸ����ڣ�Ĭ����top
Public Property Get Parent() As String
    Parent = m_Parent
End Property

'��ʵ���������Ŀؼ��������
Public Property Get Name() As String
    Name = m_Name
End Property
Public Property Let Name(s As String)
    m_Name = s
End Property

Public Property Let Value(s As String)
    m_Value = s
End Property

Public Property Let StyleName(s As String)
    m_StyleName = s
End Property

Public Property Let ScaleMode(nV As Long)
    m_ScaleMode = nV
End Property
Public Property Get ScaleMode() As Long
    ScaleMode = m_ScaleMode
End Property

'�������л�����
Public Function Serializer(vSer As clsSerialization)
    vSer.Serializer m_dic
End Function

Public Function Deserializer(vSer As clsSerialization)
    vSer.Deserializer m_dic
End Function

Public Function Keys() As Collection
    Set Keys = New Collection
    Dim k As Variant
    For Each k In m_dic.Keys
        Keys.Add k
    Next
End Function

Private Sub Class_Initialize()
    m_Type = ""
    m_Name = ""
    m_Value = ""
    m_StyleName = ""
    m_Parent = WTOP
    m_ScaleMode = vbTwips
    Set m_dic = New Dictionary
End Sub

'����һ�������չǼ�; FuncName: ��������Params: ������sbody: ������
Public Function CreateFuncDef(FuncName As String, Optional sparams As String = "", Optional sbody As String = "") As String
    If Len(FuncName) = 0 Then Exit Function
    CreateFuncDef = "def " & FuncName & "(" & sparams & "):" & vbCrLf
    If Len(sbody) Then
        CreateFuncDef = CreateFuncDef & sbody & vbCrLf
    Else
    #If DebugVer Then
        CreateFuncDef = CreateFuncDef & Space(4) & "print('" & FuncName & "')" & vbCrLf
    #Else
        CreateFuncDef = CreateFuncDef & Space(4) & "#TODO, Please finish the function here!" & vbCrLf
        CreateFuncDef = CreateFuncDef & Space(4) & "pass" & vbCrLf
    #End If
    End If
End Function

'����һ�������չǼܣ����������룩; FuncName: ��������Params: ������sbody: ������
Public Function CreateFuncDefOOP(FuncName As String, Optional sparams As String = "", Optional sbody As String = "") As String
    If Len(FuncName) = 0 Then Exit Function
    CreateFuncDefOOP = "    def " & FuncName & "(self" & IIf(Len(sparams), ", ", "") & sparams & "):" & vbCrLf
    If Len(sbody) Then
        CreateFuncDefOOP = CreateFuncDefOOP & sbody & vbCrLf
    Else
    #If DebugVer Then
        CreateFuncDefOOP = CreateFuncDefOOP & Space(8) & "print('" & FuncName & "')" & vbCrLf
    #Else
        CreateFuncDefOOP = CreateFuncDefOOP & Space(8) & "#TODO, Please finish the function here!" & vbCrLf
        CreateFuncDefOOP = CreateFuncDefOOP & Space(8) & "pass" & vbCrLf
    #End If
    End If
End Function


'�����ֵ�λת��Ϊ����
Public Function toPixelX(nX As Long) As Long
    If m_ScaleMode = vbTwips Then
        toPixelX = Twip2PixelX(nX)
    ElseIf m_ScaleMode = vbPoints Then
        toPixelX = Point2PixelX(nX)
    Else
        toPixelX = nX
    End If
End Function

Public Function toPixelY(nY As Long) As Long
    If m_ScaleMode = vbTwips Then
        toPixelY = Twip2PixelY(nY)
    ElseIf m_ScaleMode = vbPoints Then
        toPixelY = Point2PixelY(nY)
    Else
        toPixelY = nY
    End If
End Function

'��VB�����ָ��ֵ����Ϊtkinter�����ָ����
Public Function GetCursorName(nCursor As Long) As String
    Select Case nCursor
        Case vbArrow: GetCursorName = "'arrow'"
        Case vbCrosshair: GetCursorName = "'cross'"
        Case vbIbeam: GetCursorName = "'xterm'"
        Case vbSizePointer: GetCursorName = "'fleur'"
        Case vbSizeNESW: GetCursorName = "'bottom_left_corner'"
        Case vbSizeNS: GetCursorName = "'sb_v_double_arrow'"
        Case vbSizeNWSE: GetCursorName = "'bottom_right_corner'"
        Case vbSizeWE: GetCursorName = "'sb_h_double_arrow'"
        Case vbUpArrow: GetCursorName = "'center_ptr'"
        Case vbHourglass: GetCursorName = "'clock'"
        Case vbNoDrop: GetCursorName = "'X_cursor'"
        Case vbArrowHourglass: GetCursorName = "'watch'"
        Case vbArrowQuestion: GetCursorName = "'question_arrow'"
        Case vbSizeAll: GetCursorName = "'sizing'"
        Case Else: GetCursorName = ""
    End Select
End Function

'For latin, decimal 123,45 changed to 123.45
Function Commas2Points(ByVal InS As String) As String
    Commas2Points = Replace(InS, ",", ".")
End Function