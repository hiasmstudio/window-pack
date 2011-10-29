unit HiSearchInFile;

interface

uses Windows, Kol, Share, Debug;

type
 THiSearchInFile = class(TDebug)
  private
    str: string;
    num: integer;
    FStop: boolean;
  public
    _prop_Text,
    _prop_FileName: string;
    _prop_Sensitive:boolean;
    _data_Text,
    _data_FileName,
    _event_onSearch, _event_onNotSearch: THI_Event;
    _event_onEnd: THI_Event;    

    constructor Create;
    procedure _work_doSearch(var _Data:TData; index:word);
    procedure _work_doStop(var _Data:TData; index:word);    
    procedure _var_String(var _Data:TData; index:word);
    procedure _var_NumStr(var _Data:TData; index:word);
 end;

implementation

constructor THiSearchInFile.Create;
begin
  inherited;
  num := -1;
  str := '';
end;     

procedure THiSearchInFile._work_doSearch;
var
  F: TextFile;
  fn, t: string;
  BufIn : Array[0..65535] of Char;
  k: integer;
begin
  num := -1;
  str := '';
  fn := ReadString(_Data, _data_FileName, _prop_FileName);
  if not FileExists(fn) then exit;
  t := ReadString(_Data, _data_Text, _prop_Text);
  AssignFile(F, fn);
  Reset(F);
  SetTextBuf(F, BufIn);
  FStop := False;
  if t = '' then 
    while not eof(F) and not FStop do
    begin
      Readln(F, str);
      inc(num); // счетчик строк
      _hi_onEvent(_event_onSearch, str);
    end
  else
  begin    
    if not _prop_Sensitive then t := AnsiLowerCase(t);
    while not eof(F) and not FStop do
    begin
      Readln(F, str);
      inc(num); // счетчик строк
      if _prop_Sensitive then
        k := Pos(t, str)
      else
        k := Pos(t, AnsiLowerCase(str));
      if k = 0 then
        _hi_onEvent(_event_onNotSearch, str)
      else
        _hi_onEvent(_event_onSearch, str);
    end;
  end;
  CloseFile(F);
  _hi_onEvent(_event_onEnd);  
end;

procedure THiSearchInFile._work_doStop;
begin
  FStop := true;
end;

procedure THiSearchInFile._var_String;
begin
  dtString(_Data, str);
end;

procedure THiSearchInFile._var_NumStr;
begin
  dtInteger(_Data, num);
end;
end.