unit WinList;

interface

uses Kol,Share,Win,Windows,Debug,Messages;

const
  RDW_NO  = 0;
  RDW_YES = 1;

type
 THIWinList = class(THIWin)
   private
    Arr:PArray;
   protected
    FList:PStrList;

    procedure SaveToList; virtual;
    procedure SetStrings(const Value:string); virtual; abstract;
    procedure SetStringsBefore(len:cardinal); virtual;
    procedure SetStringsAfter; virtual;
    function  Add(const Text:string):integer; virtual;
    procedure Select(idx:integer); virtual;
    procedure _OnClick(Obj:PObj);

    procedure _Set(var Item:TData; var Val:TData); virtual;
    function  _Get(Var Item:TData; var Val:TData):boolean;
    function  _Count:integer;
    procedure _Add(var Val:TData);
   public
    _prop_FileName:string;
    _prop_AddType:byte;
    _prop_SelectAdd:boolean;
    _prop_DataType:byte;

    _data_FileName:THI_Event;
    _data_str:THI_Event;
    _data_Value:THI_Event;
    _event_onChange:THI_Event;
    _event_onClick:THI_Event;
    _event_onSelect:THI_Event;

    destructor Destroy; override;
    procedure _work_doAdd(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word); virtual;
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doText(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doAppend(var _Data:TData; Index:word);
    procedure _work_doAddDir(var _Data:TData; Index:word);
    procedure _work_doReplace(var _Data:TData; Index:word);
    procedure _work_doSort(var _Data:TData; Index:word);

    procedure _work_doSetSelect(var _Data:TData; Index:word);
    procedure _work_doSetSelStart(var _Data:TData; Index:word);
    procedure _work_doSetSelLength(var _Data:TData; Index:word);
    procedure _work_doSelect(var _Data:TData; Index:word);
    procedure _work_doSelectString(var _Data:TData; Index:word);

    procedure _var_Text(var _Data:TData; Index:word); virtual;
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_EndIdx(var _Data:TData; Index:word);
    procedure _var_Array(var _Data:TData; Index:word);
    procedure _var_String(var _Data:TData; Index:word);
    procedure _var_SelText(var _Data:TData; Index:word);
 end;

implementation

destructor THIWinList.Destroy;
begin
   if Arr <> nil then dispose(Arr);
   inherited;
end;

procedure THIWinList._OnClick;
var i:integer; dt,di:TData;
begin
  i := Control.CurIndex;
  if _prop_DataType = 1 then
    dtString(dt,Control.Items[i])
  else  dtInteger(dt,i);
  i := Control.ItemData[i];
  if i<>-1 then begin
    dtInteger(di,i);
    dt.ldata := @di;
  end;
  _hi_OnEvent_(_event_onClick,dt);
end;

procedure THIWinList.SaveToList;
var  i:integer;
begin
   for i := 0 to Control.Count - 1 do
     FList.Add(Control.Items[i]);
end;

procedure THIWinList.Select;
begin
   if(idx<0)or(idx>=Control.Count)then
     idx := -1;
   Control.CurIndex := idx;
end;

procedure THIWinList._work_doSelect;
var
  i: integer;
  dt,di: TData;
begin
  Select(ToInteger(_Data));
  i := Control.CurIndex;
  if _prop_DataType = 1 then
    if i <> -1 then
      dtString(dt, Control.Items[i])
    else
      dtString(dt, '')
  else
    dtInteger(dt, i);
  i := Control.ItemData[i];
  if i <> -1 then
  begin
    dtInteger(di, i);
    dt.ldata := @di;
  end;
  _hi_OnEvent_(_event_onSelect,dt);
end;

procedure THIWinList._work_doSelectString;
var S,L:string;
begin
  S := ToString(_Data);
  if S='' then exit;
  L := GetTok(S,'*');
  Select(Control.SearchFor(L,-1,S<>L));
end;

procedure THIWinList._work_doAdd;
var s:string;
    idx:integer;
    dt:TData;
begin
   s := ReadString(_Data,_data_str);
   if _prop_AddType = 0 then
     idx := Add(s)
   else begin
     idx := Control.Insert(0,s);
     if idx = -1 then Control.Text := s + #13#10 + Control.Text;
   end;
   if _prop_SelectAdd then Control.CurIndex := idx;
   dt := ReadData(_Data,_data_value);
//   if _isInteger(dt) then Control.ItemData[idx] := ToInteger(dt);
   Control.ItemData[idx] := ToInteger(dt);
   _hi_CreateEvent(_Data,@_event_onChange);
end;

function THIWinList.Add;
begin
   Result := Control.Add(Text);
end;

procedure THIWinList._work_doClear;
begin
   Control.Clear;
   _hi_CreateEvent(_Data,@_event_onChange);
end;

procedure THIWinList._work_doDelete;
var ind,SelStart,SelEnd,FHandle:integer;
begin
  ind := ToInteger(_Data);
  if ind < 0 then exit;
  Control.Delete(ind);
  FHandle := Control.Handle;
  SelStart := SendMessage(FHandle, EM_LINEINDEX, ind, 0);
  if SelStart >= 0 then
    begin
      SelEnd := SendMessage(FHandle, EM_LINEINDEX, ind + 1, 0);
      if SelEnd < 0 then SelEnd := SelStart +
             SendMessage(FHandle, EM_LINELENGTH, SelStart, 0);
      SendMessage(FHandle, EM_SETSEL, SelStart, SelEnd);
      SendMessage(FHandle, EM_REPLACESEL, 0, cardinal(PChar('')));
    end;
  
  _hi_CreateEvent(_Data,@_event_onChange);
end;

procedure THIWinList._work_doText;
begin
   SetStrings(ToString(_Data));
   _hi_CreateEvent(_Data,@_event_onChange);
end;

procedure THIWinList._work_doSave;
var
   fn:string;
begin
   fn := ReadString(_Data,_data_FileName,_prop_FileName);
   FList := NewStrList;
   SaveToList;
   FList.SaveToFile(fn);
   FList.Free;
end;

procedure THIWinList._work_doAppend;
var
   fn:string;
begin
   fn := ReadString(_Data,_data_FileName,_prop_FileName);
   FList := NewStrList;
   FList.LoadFromFile(fn);
   SaveToList;
   FList.SaveToFile(fn);
   FList.Free;
end;

procedure THIWinList._work_doAddDir;
var Lst:PDirList;
begin
   Lst := NewDirList(ToString(_Data),'*.*',FILE_ATTRIBUTE_NORMAL);
   SetStrings(Lst.FileList(#13#10,false,false));//!!!
   Lst.free;
end;

procedure THIWinList._work_doReplace;
var ind:integer;
begin
   ind := ReadInteger(_Data,NULL);
   if(ind >= 0)and(ind < Control.Count)then
     Control.Items[ind] := ReadString(_Data,_data_str);
end;

procedure THIWinList._work_doSort;
begin
   if Control.Count <= 0 then exit;
   FList := NewStrList;
   SaveToList;
   FList.Sort(true);
   SetStrings(FList.Text);
   FList.Free;
end;

procedure THIWinList._work_doSetSelect;
begin
   Control.Selection := ToString(_Data);
end;

procedure THIWinList._work_doSetSelStart;
begin
   Control.SelStart := ToInteger(_Data);
end;

procedure THIWinList._work_doSetSelLength;
begin
   Control.SelLength := ToInteger(_Data);
end;

procedure THIWinList._var_Text;
var s:string;
begin
   FList := NewStrList;
   SaveToList;
   s := FList.Text; 
   if(FList.count > 0)and(FList.Items[FList.Count-1] <> '')then
     delete(s, length(s)-1, 2); 
   dtString(_Data,s);
   FList.Free;
end;

procedure THIWinList._var_Count;
begin
   dtInteger(_Data,Control.Count);
end;

procedure THIWinList._var_EndIdx;
begin
  if Control.Count = 0 then
    dtNull(_Data)
  else
    dtInteger(_Data, Control.Count - 1);
end;

procedure THIWinList._Set;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < Control.Count)then
     Control.Items[ind] := ToString(Val);
end;

procedure THIWinList._Add;
begin
   Add(ToString(val));
end;

function THIWinList._Get;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   Result := (ind >= 0)and(ind < Control.Count);
   if Result then dtString(Val,Control.Items[ind]);
end;

function THIWinList._Count;
begin
   Result := Control.Count;
end;

procedure THIWinList._var_Array;
begin
   if Arr = nil then
     Arr := CreateArray(_Set,_Get,_Count,_Add);
   dtArray(_Data,Arr);
end;

procedure THIWinList._var_String;
begin
   if (Control.curindex >= 0) then
     dtString(_data,Control.Items[Control.curindex])
   else dtNull(_data);
end;

procedure THIWinList._var_SelText;
begin
   dtString(_Data,Control.Selection);
end;

procedure THIWinList.SetStringsBefore;
begin
  if Control.Visible = true then
    Control.Perform(WM_SETREDRAW, RDW_NO, 0);
  Control.Clear;
end;

procedure THIWinList.SetStringsAfter;
begin
  if Control.Visible = false then exit;
  Control.Perform(WM_SETREDRAW, RDW_YES, 0);
  InvalidateRect(Control.Handle, nil, false);
end;

end.