unit hiPOP3_Parse;

interface

uses Kol,Share,Debug;

const
   CP_KOI8       =  20866;       // KOI-8 translation
   CP_DOS        =  866;         // DOS   translation
   CP_WIN        =  1251;        // WIN   translation

type
  THIPOP3_Parse = class(TDebug)
   private
    _From:string;
    _To:string;
    _Subject:string;
    _Date:string;

    _Message_Text,_Message_HTML:string;

    _Attach:PStream;

    procedure Decode(_Type,_Encode:string; const Text:string);
    function _DecodeTitle(s:string):string;
   public
    _data_MailText:THI_Event;
    _event_onParse:THI_Event;

    procedure _work_doParse(var _Data:TData; Index:word);
    procedure _var_HTML(var _Data:TData; Index:word);
    procedure _var_Text(var _Data:TData; Index:word);
    procedure _var_Date(var _Data:TData; Index:word);
    procedure _var_Subject(var _Data:TData; Index:word);
    procedure _var_From(var _Data:TData; Index:word);
    procedure _var_To(var _Data:TData; Index:word);
    procedure _var_Attach(var _Data:TData; Index:word);
  end;

implementation

uses hiCharset,hiConvertor;

function quoted_printable(const s:string):string;
var i:word;
begin
  Result := '';
  i := 1;
  while i <= length(s) do begin
    if s[i] = '=' then begin
      if s[i+1] = '=' then inc(i);
      if ((s[i+1] in ['0'..'9']) or
          (s[i+1] in ['A'..'F']) or
          (s[i+1] in ['a'..'f']))and
         ((s[i+2] in ['0'..'9']) or
          (s[i+2] in ['A'..'F']) or
          (s[i+2] in ['a'..'f'])) then begin
        Result := Result + char(Hex2Int(s[i+1] + s[i+2]));
        inc(i,2);
      end else Result := Result + s[i];
    end else Result := Result + s[i];
    inc(i);
  end;
end;

procedure THIPOP3_Parse.Decode;
var s,_Content_Type,_FName,_Char:string;
  procedure _Decode(var Result:string);
  var lst:PStrList; i:integer;
  begin
    if _Encode = 'base64' then begin
      lst := NewStrList;
      lst.text := Text;
      Result := '';
      for i := 0 to lst.Count-1 do
        if lst.Items[i] <> '' then
          Result := Result + Base64_Decode(lst.Items[i]);
      lst.Free;
    end else begin
      Result := Text;
      if _Encode = 'quoted-printable' then
        Result := quoted_printable(Result);
      if StrIComp(PChar(_Char),'koi8-r') = 0 then
//        Result := Koi8ToWin(Result)
          Result := CodePage1ToCodePage2(Result,CP_KOI8,CP_WIN)
      else if StrIComp(PChar(_Char),'ibm866') = 0 then
//        Result := DosToWin(Result);
          Result := CodePage1ToCodePage2(Result,CP_DOS,CP_WIN);
    end;
  end;
  function _Param(const P:string):string;
  begin
    if P[1] <> '"' then Result := p
    else Result := copy(P,2,Length(P)-2);
  end;
begin
  _Content_Type := lowercase(Trim(GetTok(_Type,';')));
  s := Trim(GetTok(_Type,'='));
  if s = 'charset' then
    _Char := _Param(_Type)
  else if s = 'name' then
    _FName := _DecodeTitle(_Param(_Type));

  if _Content_Type = 'text/plain' then
    _Decode(_Message_Text)
  else if _Content_Type = 'text/html' then
    _Decode(_Message_HTML)
  else if (_Content_Type = 'application/x-zip-compressed')or
          (_Content_Type = 'application/octet-stream')or
          (_Content_Type = 'application/zip') then begin
    if _Attach <> nil then _Attach.Size := 0
    else _Attach := NewMemoryStream;
    //_debug(text);
    _Decode(s);
    _Attach.WriteStr(s);
    _Attach.Position := 0;
    _hi_OnEvent(_event_onParse,_fName);
  end;
end;

function THIPOP3_Parse._DecodeTitle;
var name,ch,p:string;
    start,i:integer;
begin
  s := Trim(s);
  i := 1;
  while i < Length(s) do begin
    if (s[i]='=')and(s[i+1]='?') then begin
      start := i;
      inc(i,2);
      ch := '';
      repeat
        ch := ch + s[i];
        inc(i);
      until s[i] = '?';
      p := s[i+1];
      inc(i,3);
      name := '';
      while (i < Length(s))and((s[i] <> '?')or(s[i+1] <> '='))do begin
        Name := name + s[i];
        inc(i);
      end;
      inc(i);
      if p = 'B' then
        name := Base64_Decode(Name)
      else if p = 'Q' then
        name := quoted_printable(Name);

      if StrIComp(PChar(ch),'koi8-r') = 0 then
        name := CodePage1ToCodePage2(name,CP_KOI8,CP_WIN)
//        name := Koi8ToWin(name)
      else if StrIComp(PChar(ch),'ibm866') = 0 then
          name := CodePage1ToCodePage2(name,CP_DOS,CP_WIN);
//        name := DosToWin(name);
      delete(s,start,i - start+1);
      insert(name,s,start);
      i := start + length(name);
    end;
    inc(i);
  end;
  Result := s;
end;

procedure THIPOP3_Parse._work_doParse;
var
    list:PStrList;
    s,Content_Type,Content_Encoding,_t,_e:string;
    i:integer;
begin
  _From := '';
  _To := '';
  _Date := '';
  _Subject := '';
  _Message_Text := '';
  _Message_HTML := '';
  list := NewStrList;
  list.Text := ReadString(_Data,_data_MailText,'');
  i := 0;
  //_________________ HEADER _____________________
  while (i < List.Count) and (List.Items[i] <> '') do begin
    s := List.Items[i];
    if copy( s,1,5) = 'From:' then begin
      delete(s,1,5);
      _From := _DecodeTitle(s);
    end else if copy( s,1,3) = 'To:' then begin
      delete(s,1,3);
      _To := _DecodeTitle(s);
    end else if copy( s,1,8) = 'Subject:' then begin
      delete(s,1,8);
      _Subject := _DecodeTitle(s);
    end else if copy( s,1,5) = 'Date:' then begin
      delete(s,1,5);
      _Date := Trim(s);
    end else if copy( s,1,13) = 'Content-Type:' then begin
      delete(s,1,13);
      Content_Type := s;
      if s[length(s)] = ';' then  begin
        inc(i);
        s := List.Items[i];
        delete(s,1,1);
        Content_Type := Content_Type + s;
      end;
    end else if copy( s,1,26) = 'Content-Transfer-Encoding:' then begin
      delete(s,1,26);
      Content_Encoding := s;
    end;
    inc(i);
  end; // _debug(_From);
 //_________________ BODY _____________________

  s := lowercase(Trim(GetTok(Content_Type,';')));
  if i < List.Count then
  if(s = 'multipart/mixed')or(s = 'multipart/alternative')then begin
    GetTok(Content_Type,'"');
    delete(Content_Type,length(Content_Type),1);
    Content_Type := '--' + Content_Type;
    while (i < List.Count) and (List.Items[i] <> Content_Type) do inc(i);
    while i < List.Count-4 do begin
      inc(i);
      //_____ PART HEAD____________
      _t := '';
      _e := '';
      while List.Items[i] <> '' do begin
        s := lowercase(List.Items[i]);
        if copy( s,1,13) = 'content-type:' then begin
          delete(s,1,13);
          _t := Trim(s);
          if s[length(s)] = ';' then begin
            inc(i);
            s := List.Items[i];
            delete(s,1,1);
            _t := _t + Trim(s);
          end;
        end else if copy( s,1,26) = 'content-transfer-encoding:' then begin
          delete(s,1,26);
          _e := Trim(s);
        end;
        inc(i);
      end;
      s := '';
      inc(i);
      //_____ PART BODY____________
      repeat
        s := s + List.Items[i] + #13#10;
        inc(i);
      until (List.Items[i] = Content_Type)or(List.Items[i] = Content_Type+ '--');
      Decode(_t,_e,s);
      if List.Items[i] = Content_Type + '--' then Break;
    end;
  end else begin
    _Message_Text := '';
    while i < list.Count do begin
      s := list.Items[i];
      if Content_Encoding = 'quoted-printable' then
        s := quoted_printable(s);
      GetTok(Content_Type,'=');
      if StrIComp(PChar(Content_Type),'koi8-r') = 0 then
          s := CodePage1ToCodePage2(s,CP_KOI8,CP_WIN)
//        s := Koi8ToWin(s)
      else if StrIComp(PChar(Content_Type),'ibm866') = 0 then
          s := CodePage1ToCodePage2(s,CP_DOS,CP_WIN);
//        s := DosToWin(s);
      _Message_Text := _Message_Text + s + #13#10;
      inc(i);
    end;
  end;
end;

procedure THIPOP3_Parse._var_HTML;
begin
  dtString(_Data,_Message_HTML);
end;

procedure THIPOP3_Parse._var_Text;
begin
  dtString(_Data,_Message_Text);
end;

procedure THIPOP3_Parse._var_Subject;
begin
  dtString(_Data,_Subject);
end;

procedure THIPOP3_Parse._var_From;
begin
  dtString(_Data,_From);
end;

procedure THIPOP3_Parse._var_To;
begin
  dtString(_Data,_To);
end;

procedure THIPOP3_Parse._var_Date;
begin
  dtString(_Data,_Date);
end;

procedure THIPOP3_Parse._var_Attach;
begin
  dtStream(_Data,_Attach);
end;

end.
