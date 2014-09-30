unit hiStrList;

interface

uses Kol,Share,Debug;

type
  THIStrList = class(TDebug)
   private
    FList:PStrList;
    Arr:PArray;

    procedure SetText(const Value:string);
    procedure _Set(var Item:TData; var Val:TData);
    function _Get(Var Item:TData; var Val:TData):boolean;
    function _Count:integer;
    procedure _Add(var Val:TData);
   private
    FIndex:integer;
    FString:string;
   public
    _prop_FileName:string;
    _prop_AddType:byte;

    _data_FileName:THI_Event;
    _data_str:THI_Event;
    _data_StrToFind:THI_Event;
    _data_IdxToSelect:THI_Event;
    _data_IdxCur:THI_Event;
    _data_IdxNew:THI_Event;
    _data_Idx1:THI_Event;    
    _data_Idx2:THI_Event;
    _data_Stream:THI_Event;    
    _event_onChange:THI_Event;
    _event_onGetIndex:THI_Event;
    _event_onGetString:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doAdd0(var _Data:TData; Index:word);
    procedure _work_doAdd1(var _Data:TData; Index:word);    
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doReplace(var _Data:TData; Index:word);
    procedure _work_doMove(var _Data:TData; Index:word);
    procedure _work_doSwap(var _Data:TData; Index:word);        
    procedure _work_doText(var _Data:TData; Index:word);
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doLoadFromStream(var _Data:TData; Index:word);
    procedure _work_doSaveToStream(var _Data:TData; Index:word);
    procedure _work_doAppend(var _Data:TData; Index:word);
    procedure _work_doAppendText(var _Data:TData; Index:word);    
    procedure _work_doSort(var _Data:TData; Index:word);
    procedure _work_doInsert(var _Data:TData; Index:word);
    procedure _work_doGetIndex(var _Data:TData; Index:word);
    procedure _work_doGetString(var _Data:TData; Index:word);
    procedure _var_Text(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_EndIdx(var _Data:TData; Index:word);    
    procedure _var_Array(var _Data:TData; Index:word);
    procedure _var_Index(var _Data:TData; Index:word);
    procedure _var_String(var _Data:TData; Index:word);
    property _prop_Strings:string write SetText;
  end;

implementation

constructor THIStrList.Create;
begin
   inherited Create;
   FList := NewStrList;
   FIndex := -1;
end;

destructor THIStrList.Destroy;
begin
   FList.Free;
   if Arr <> nil then dispose(Arr);
   inherited Destroy;
end;

procedure THIStrList.SetText;
begin
//   Flist.Text := Value;
   FList.SetText(Value, false);
end;

procedure THIStrList._work_doAdd0;
begin
   FList.Add(ReadString(_Data,_data_str,''));
   _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THIStrList._work_doAdd1;
begin
   FList.Insert(0,ReadString(_Data,_data_str,''));
   _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THIStrList._work_doClear;
begin
   FList.Clear;
   _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THIStrList._work_doDelete;
var   ind:integer;
begin
   ind := ToIntIndex(_Data);
   if (ind < 0) or (ind > FList.Count - 1) then exit;
   FList.Delete(ind);
   _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THIStrList._work_doInsert;
var   ind:integer;
begin
   ind := ToIntIndex(_Data);
   if (ind < -1) or (ind > FList.Count) then exit
   else if ind = -1 then ind := FList.Count; 
   FList.Insert(ind, ReadString(_Data, _data_str, ''));
   _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THIStrList._work_doReplace;
var   ind:integer;
begin
   ind := ToIntIndex(_Data);
   if (ind < 0) or (ind > FList.Count - 1) then exit;
   FList.Delete(ind);
   FList.Insert(ind, ReadString(_Data, _data_str, ''));   
   _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THIStrList._work_doMove;
var
  ind1, ind2 :integer;
begin
   ind1 := ReadInteger(_Data, _data_IdxCur);
   ind2 := ReadInteger(_Data, _data_IdxNew);
   if (ind1 < 0) or (ind1 > FList.Count - 1) or (ind2 < 0) or (ind2 > FList.Count - 1) then exit;
   FList.Move(ind1, ind2);
   _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THIStrList._work_doSwap;
var
  ind1, ind2 :integer;
begin
   ind1 := ReadInteger(_Data, _data_Idx1);
   ind2 := ReadInteger(_Data, _data_Idx2);
   if (ind1 < 0) or (ind1 > FList.Count - 1) or (ind2 < 0) or (ind2 > FList.Count - 1) then exit;
   FList.Swap(ind1, ind2);
   _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THIStrList._work_doText;
begin
//   FList.Text := ReadString(_Data,_data_str,'');
   FList.SetText(ReadString(_Data,_data_str), false);
   _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THIStrList._work_doLoad;
var   fn:string;
begin
   fn := ReadString(_Data,_data_FileName,_prop_FileName);
   if FileExists(fn) then begin
      FList.LoadFromFile(fn);
      _hi_CreateEvent(_Data, @_event_onChange);
   end;
end;

procedure THIStrList._work_doSave;
var   fn:string;
begin
   fn := ReadString(_Data,_data_FileName,_prop_FileName);
   FList.SaveToFile(fn);
end;

procedure THIStrList._work_doLoadFromStream;
var
  st: PStream;
begin
  st := ReadStream(_Data, _data_Stream);
  if st = nil then exit;
  FList.LoadFromStream(st, false);
  _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THIStrList._work_doSaveToStream;
var
  st: PStream;
begin
  st := ReadStream(_Data, _data_Stream);
  if st = nil then exit;  
  FList.SaveToStream(st);
end;

procedure THIStrList._work_doAppend;
var   fn:string;
begin
   fn := ReadString(_Data,_data_FileName,_prop_FileName);
   FList.AppendToFile(fn);
end;

procedure THIStrList._work_doAppendText;
begin
  FList.SetText(ReadString(_Data,_data_str), true);
  _hi_CreateEvent(_Data, @_event_onChange);   
end;

procedure THIStrList._work_doGetIndex;
begin
   FIndex := FList.IndexOf(ReadString(_Data, _data_StrToFind)); 
   FString := FList.Items[FIndex];
   _hi_CreateEvent(_Data, @_event_onGetIndex, FIndex);
end;

procedure THIStrList._work_doGetString;
begin
   FIndex := ReadInteger(_Data, _data_IdxToSelect);
   FString := FList.Items[FIndex];     
   if (FIndex<0) or (FIndex>=Flist.Count) then FIndex := -1;
   _hi_CreateEvent(_Data, @_event_onGetString, FString);
end;

procedure THIStrList._work_doSort;
begin
   FList.Sort(false);
end;

procedure THIStrList._var_Text;
begin
   dtString(_Data,FList.Text);
end;

procedure THIStrList._var_Count;
begin
  dtInteger(_Data,FList.Count);
end;

procedure THIStrList._var_EndIdx;
begin
  if FList.Count = 0 then
    dtNull(_Data)
  else
    dtInteger(_Data, FList.Count - 1);
end;

procedure THIStrList._var_Index;
begin
  dtInteger(_Data,FIndex);
end;

procedure THIStrList._var_String;
begin
  dtString(_Data,FString);
end;

procedure THIStrList._Set;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if (ind >= 0) and (ind < FList.Count) then
      FList.Items[ind] := ToString(Val);
end;

procedure THIStrList._Add;
begin
   FList.Add(ToString(val));
end;

function THIStrList._Get;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if (ind >= 0) and (ind < FList.Count) then begin
      Result := true;
      dtString(Val,FList.Items[ind]);
   end else
      Result := false;
end;

function THIStrList._Count;
begin
   Result := FList.Count;
end;

procedure THIStrList._var_Array;
begin
   if Arr = nil then Arr := CreateArray(_Set, _Get, _Count, _Add);
   dtArray(_Data,Arr);
end;

end.