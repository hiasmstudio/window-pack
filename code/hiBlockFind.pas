unit hiBlockFind;

interface

uses Kol,Share,Debug;

type
  THIBlockFind = class(TDebug)
   private
    Stop:boolean;
   public
    _prop_IncludeBlock:boolean;
    _prop_Delete:boolean;
    _prop_ReplaceStr:string;
    _prop_UserReplace:boolean;
    _prop_StartBlock:string;
    _prop_EndBlock:string;

    _data_Replace:THI_Event;
    _data_Text:THI_Event;
    _event_onEndSearch:THI_Event;
    _event_onNotFind:THI_Event;    
    _event_onSearch:THI_Event;

    procedure _work_doSearch(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _work_doStartBlock(var _Data:TData; Index:word);
    procedure _work_doEndBlock(var _Data:TData; Index:word);            
    procedure _work_doReplaceStr(var _Data:TData; Index:word);
  end;

implementation

procedure THIBlockFind._work_doStop;
begin
  Stop := true;
end;

procedure THIBlockFind._work_doReplaceStr;
begin
   _prop_ReplaceStr := ToString(_Data);
end;

procedure THIBlockFind._work_doStartBlock;
begin
   _prop_StartBlock := ToString(_Data);
end;

procedure THIBlockFind._work_doEndBlock;
begin
   _prop_EndBlock := ToString(_Data);
end;

procedure THIBlockFind._work_doSearch;
var
  i,j:integer;
  Text:string;
begin
  Text := ReadString(_Data,_data_Text);
  i := pos(_prop_StartBlock,Text);
  Stop := false;
  j := 0;
  while i > 0 do begin
    j := PosEx(_prop_EndBlock,Text,i+Length(_prop_StartBlock));
    if j = 0 then break;
    if _prop_IncludeBlock then
      _hi_OnEvent(_event_onSearch,copy(Text,i,j-i+Length(_prop_EndBlock)))
    else
      _hi_OnEvent(_event_onSearch,copy(Text,i+Length(_prop_StartBlock),j-i-Length(_prop_StartBlock)));
    if Stop then break;
    if not _prop_Delete then
      inc(j,Length(_prop_EndBlock))
    else if (not _prop_UserReplace)or(ToIntegerEvent(_data_Replace)<>0)then begin
      if Stop then break;
      if _prop_IncludeBlock then
        Delete(Text,i,j-i+length(_prop_EndBlock))
      else begin
        inc(i,length(_prop_StartBlock));
        Delete(Text,i,j-i);
      end;
      if _prop_ReplaceStr <> '' then
        Insert(_prop_ReplaceStr,Text,i);
      j := i + Length(_prop_ReplaceStr);
    end;
    if Stop then break;
    i := PosEx(_prop_StartBlock,Text,j);
  end;

  if j = 0 then
    _hi_onEvent(_event_onNotFind);  
  _hi_CreateEvent(_Data,@_event_onEndSearch,Text);
end;

end.