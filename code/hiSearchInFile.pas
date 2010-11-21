unit HiSearchInFile;

interface

uses Windows, Kol, Share, Debug;

type
 THiSearchInFile = class(TDebug)
  private
    str: string;
    FStop: boolean;
  public
    _prop_Text,
    _prop_FileName: string;
    _data_Text,
    _data_FileName,
    _event_onSearch: THI_Event;
    _event_onEnd: THI_Event;    

    procedure _work_doSearch(var _Data:TData; index:word);
    procedure _work_doStop(var _Data:TData; index:word);    
    procedure _var_String(var _Data:TData; index:word);
 end;

implementation

procedure THiSearchInFile._work_doSearch;
var
  F: TextFile;
  fn, t: string;
  BufIn : Array[0..65535] of Char;
begin
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
      _hi_onEvent(_event_onSearch, str);
    end
  else    
    while not eof(F) and not FStop do
    begin
      Readln(F, str);
      case Pos(t, str) of
        0: Continue
      else
        _hi_onEvent(_event_onSearch, str);
      end;
  end;
  CloseFile(F);
  _hi_onEvent(_event_onEnd, '');  
end;

procedure THiSearchInFile._work_doStop;
begin
  FStop := true;
end;

procedure THiSearchInFile._var_String;
begin
  dtString(_Data, str);
end;

end.