unit hiStringTable;

interface

uses Kol,Share,Win,Debug,ListEdit;

type
  THIStringTable = class(THIWin)
   private
    Obj:PMatrix;
    arr:PArray;
    SortCol:integer;
    Sel: integer;
    procedure SetColumns(const col:string);
    procedure _OnClick(Obj:PObj);
    procedure _OnColumnClick( Sender: PControl; Idx: Integer );
    procedure _OnBeforeLineChange( Sender: PControl; Idx: Integer );
    procedure _OnLineChange( Sender: PControl; Idx: Integer );
    procedure Add(const Data:string; Index:integer = -1; _Replace:boolean = false);
    function _mRows:integer;
    function _mCols:integer;
    function Get(index:integer):string;
    procedure _Set(x,y:integer; var Val:TData);
    function _Get(x,y:integer):TData;

    procedure _aSet(var Item:TData; var Val:TData);
    function _aGet(Var Item:TData; var Val:TData):boolean;
    function _aCount:integer;
    procedure _aAdd(var Val:TData);

    function _OnCmpText( Sender: PControl; Idx1, Idx2: Integer ): Integer;
    function _OnCmpReal( Sender: PControl; Idx1, Idx2: Integer ): Integer;
    function _OnCmpExt( Sender: PControl; Idx1, Idx2: Integer ): Integer;
    procedure _OnSelState( Sender: PControl; IdxFrom, IdxTo: Integer; OldState, NewState: cardinal );
    procedure _OnMouseDown(Sender: PControl; var Mouse: TMouseEventData); override;
   public
    _prop_StrDelimiter:string;
    _prop_Grid:boolean;
    _prop_RowSelect:boolean;
    _prop_HeaderDragDrop:boolean;
    _prop_FileName:string;
    _prop_SaveWidth:boolean;
    _prop_ClearAll:boolean;
    _prop_Redaction:boolean;
    _prop_Columns:string;
    _prop_ColumnClick:byte;
    _prop_StaticColumn:boolean;
    _prop_Flat:boolean;

    _data_FileName:THI_Event;
    _data_Str:THI_Event;
    _data_ExtCmp:THI_Event;
    _event_onClick:THI_Event;
    _event_onSelect:THI_Event;    
    _event_onColumnClick:THI_Event;
    _event_onBeforeLineChange:THI_Event;
    _event_onLineChange:THI_Event;

    destructor Destroy; override;
    procedure Init; override;
    procedure _work_doAdd(var _Data:TData; Index:word);
    procedure _work_doInsert(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doSelect(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doAddColumn(var _Data:TData; Index:word);
    procedure _work_doSort(var _Data:TData; Index:word);
    procedure _work_doSortDigit(var _Data:TData; Index:word);
    procedure _work_doSortExtCmp(var _Data:TData; Index:word);
    procedure _work_doEnsureVisible(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_Select(var _Data:TData; Index:word);
    procedure _var_Matrix(var _Data:TData; Index:word);
    procedure _var_Strings(var _Data:TData; Index:word);
    procedure _var_Index(var _Data:TData; Index:word);
    procedure _var_StringTable(var _Data:TData; Index:word);
    procedure _var_EndIdx(var _Data:TData; Index:word);    
  end;

implementation

destructor THIStringTable.Destroy;
begin
   if Obj <> nil then
     Dispose(obj);
   if Arr <> nil then
     Dispose(Arr);
   inherited;
end;

procedure THIStringTable._OnClick;
begin
   if (Control.LVCurItem <> -1)and (sel = Control.LVCurItem) then
     _hi_OnEvent(_event_onClick,Control.LVCurItem)
end;

procedure THIStringTable._OnMouseDown;
begin
   sel := Control.LVCurItem;
   inherited;
end;

procedure THIStringTable._OnSelState;
begin
   if newstate = 3 then
   begin
     _hi_OnEvent(_event_onClick,IdxFrom);
     _hi_OnEvent(_event_onSelect,IdxFrom);
   end;  
end;

procedure THIStringTable.Init;
var l:TListViewOptions;
begin
   l := [lvoInfoTip, lvoUnderlineHot ];
   if _prop_Flat then
     include(l,lvoFlatsb);
   if _prop_HeaderDragDrop then
     include(l,lvoHeaderDragDrop);

   if _prop_Redaction then
      Control := NewListEdit(FParent,lvsDetail,l,nil,nil,nil,_OnLineChange,_OnBeforeLineChange)
   else
      Control := NewListView(FParent,lvsDetail,l,nil,nil,nil);

   Control.OnMouseDown := _OnMouseDown;
   Control.OnClick := _OnClick;
   Control.OnColumnClick := _OnColumnClick;
   Control.OnLVStateChange := _OnSelState;
   SetColumns(_prop_Columns);
   inherited;
   l := Control.LVOptions;
   if _prop_Grid then
     include(l,lvoGridLines);
   if _prop_RowSelect then
     include(l,lvoRowSelect);

   Control.LVOptions := l;
end;

procedure THIStringTable._OnColumnClick;
begin
   case _prop_ColumnClick of
    0:  _hi_OnEvent(_event_onColumnClick,Control.LVColText[Idx]);
    1:  _hi_OnEvent(_event_onColumnClick,Idx);
   end;
end;

procedure THIStringTable._OnBeforeLineChange;
begin
   _hi_OnEvent(_event_onBeforeLineChange,Idx);
end;

procedure THIStringTable._OnLineChange;
begin
   _hi_OnEvent(_event_onLineChange,Idx);
end;

procedure THIStringTable.SetColumns;
var lst:PStrList;
    i:word;
    s:string;
begin
   lst := NewStrList;
   lst.text := col;
   if lst.Count > 0 then
    for i := 0 to lst.Count-1 do
     begin
      s := Lst.Items[i] + '=';
      Control.LVColAdd(GetTok(s,'='),taLeft,80);
      if s <> '' then
        Control.LVColWidth[i] := max(5,str2int(s));
     end;
   lst.Free;
end;

procedure THIStringTable._work_doAdd;
begin
    Add( ReadString(_Data,_data_Str,''));
end;

procedure THIStringTable._work_doInsert;
begin
    Add(ToStringEvent(_data_Str),ToInteger(_Data));
end;

procedure THIStringTable.Add;
var s:string;
    i:byte;
begin
    if _prop_StrDelimiter = '' then
     _prop_StrDelimiter := ' ';
    s := Data + _prop_StrDelimiter;

    i := 0;
    if Index = -1 then
     begin
       Control.LVItemAdd('');
       Index := Control.Count-1;
     end
    else if not _replace then Control.LVItemInsert(Index,'');

    while s <> '' do
     begin
      Control.LVItems[Index,i] := gettok(s,_prop_StrDelimiter[1]);
      inc(i);
     end;
end;

procedure THIStringTable._work_doSave;
var i,j,p:integer;
    lst:PStrList;
    function Col(ind:word):string;
    begin
      if _prop_SaveWidth then
        Result := Control.LVColText[ind] + '=' + int2str(Control.LVColWidth[ind])
      else Result := Control.LVColText[i];
    end;
begin
   lst := NewStrList;
   if not _prop_StaticColumn then
    begin
     lst.Add('');
     for i := 0 to Control.LVColCount - 1 do
      if i = 0 then
        lst.Items[0] := Col(i)
      else
        lst.Items[0] := lst.Items[0] + _prop_StrDelimiter + Col(i);
     p := 1;
    end
   else p := 0;

   if (Control.Count > 0)and(Control.LVColCount > 0) then
    for i := 0 to Control.Count - 1 do
     begin
      lst.Add('');
      for j := 0 to Control.LVColCount - 1 do
       if j = 0 then
         lst.Items[i+p] := Control.LVItems[i,j]
       else
         lst.Items[i+p] := lst.Items[i+p] + _prop_StrDelimiter + Control.LVItems[i,j];
     end;
   lst.SaveToFile(ReadString(_Data,_data_FileName,_prop_FileName));
   lst.Free;
end;

procedure THIStringTable._work_doLoad;
var i,p:integer;
    lst:PStrList;
    s:string;
begin
   lst := NewStrList;
   lst.LoadFromFile(ReadString(_Data,_data_FileName,_prop_FileName));

   _work_doClear(_Data,0);
   if not _prop_StaticColumn then
    begin
     while Control.LVColCount > 0 do
      Control.LVColDelete(0);

    if lst.Count > 0 then
     begin
      s := lst.Items[0];
      if _prop_StrDelimiter <> #13#10 then
        Replace(s,_prop_StrDelimiter,#13#10);
      SetColumns(s);
     end;
    p := 1;
    end
   else p := 0;

   for i := p to lst.Count-1 do
    Add(lst.Items[i]);

   lst.Free;
end;

procedure THIStringTable._work_doClear;
begin
   Control.Clear;
   if _prop_ClearAll then
     while Control.LVColCount > 0 do
      Control.LVColDelete(Control.LVColCount-1);
end;

procedure THIStringTable._work_doSelect;
begin
   Control.LVCurItem := ToInteger(_Data);
end;

procedure THIStringTable._work_doDelete;
begin
   Control.LVDelete(ToInteger(_Data));
end;

procedure THIStringTable._work_doAddColumn;
begin
  Control.LVColAdd(ToString(_Data),taLeft,80);
end;

function THIStringTable._OnCmpText;
var S1,S2:string;
begin
  S1 := Sender.LVItems[ Idx1, SortCol ];
  S2 := Sender.LVItems[ Idx2, SortCol ];
  Result := AnsiCompareStrNoCase( S1, S2 );
end;

function THIStringTable._OnCmpReal;
var S1,S2:string; r:real;
begin
  S1 := Sender.LVItems[ Idx1, SortCol ];
  S2 := Sender.LVItems[ Idx2, SortCol ];
  r := str2double(S1)-str2double(S2);
  Result := ord(r>0)-ord(r<0);   
end;

function THIStringTable._OnCmpExt;
var dt1,dt2:TData; r:real;
begin
  dtString(dt1, Sender.LVItems[ Idx1, SortCol ]);
  dtString(dt2, Sender.LVItems[ Idx2, SortCol ]);
  dt1.ldata := @dt2;
  _ReadData(dt1, _data_ExtCmp);
  r := ToReal(dt1);
  Result := ord(r>0)-ord(r<0);   
end;

procedure THIStringTable._work_doSort;
begin
  Control.OnCompareLVItems := _OnCmpText;
  SortCol := ToInteger(_Data);
  Control.LVSort;
end;

procedure THIStringTable._work_doSortDigit;
begin
  Control.OnCompareLVItems := _OnCmpReal;
  SortCol := ToInteger(_Data);
  Control.LVSort;
end;

procedure THIStringTable._work_doSortExtCmp;
begin
  Control.OnCompareLVItems := _OnCmpExt;
  SortCol := ToInteger(_Data);
  Control.LVSort;
end;

procedure THIStringTable._work_doEnsureVisible;
begin
   Control.LVMakeVisible(ToInteger(_Data), False);
end;

procedure THIStringTable._var_Count;
begin
   dtInteger(_Data,control.Count);
end;

procedure THIStringTable._var_EndIdx;
begin
  if Control.Count = 0 then
    dtNull(_Data)
  else
    dtInteger(_Data, Control.Count - 1);
end;

function THIStringTable.Get(index:integer):string;
var i:integer;
begin
    Result := '';

    for i := 0 to Control.LVColCount - 1 do
     begin
       Result := Result + Control.LVItems[Index,i];
       if i < Control.LVColCount - 1 then
         Result := Result + _prop_StrDelimiter;
     end;
end;

procedure THIStringTable._var_Select;
begin
   dtString(_Data,Get(Control.LVCurItem));
end;

function THIStringTable._mRows;
begin
  Result := Control.Count; 
end;

function THIStringTable._mCols;
begin
  Result := Control.LVColCount; 
end;

function THIStringTable._Get;
begin
   if(x>=0)and(y>=0)and(y<Control.Count)and(x<Control.LVColCount) then
     dtString(Result,Control.LVItems[y,x])
   else dtNull(Result);
end;

procedure THIStringTable._Set;
begin
   if(x>=0)and(y>=0)and(y<Control.Count)and(x<Control.LVColCount) then
     Control.LVItems[y,x] := ToString(Val);
end;

procedure THIStringTable._var_Index;
begin
   dtInteger(_Data,control.CurIndex);
end;

procedure THIStringTable._var_StringTable;
begin
   _Data.Data_type := data_int;
   _Data.sdata := 'StringTable';
   _Data.idata := integer(Control);
end;

procedure THIStringTable._var_Matrix;
begin
  if Obj = nil then begin
    new(Obj);
    Obj._Set := _Set;
    Obj._Get := _Get;
    Obj._Rows := _mRows; 
    Obj._Cols := _mCols; 
  end;
  dtMatrix(_Data,Obj);
end;

procedure THIStringTable._aSet;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < Control.Count)then
     Add(ToString(val), ind, true);
end;

procedure THIStringTable._aAdd;
begin
   Add(ToString(val), -1);
end;

function THIStringTable._aGet;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < Control.Count)then
     begin
        Result := true;
        dtString(Val,Get(ind));
     end
   else Result := false;
end;

function THIStringTable._aCount;
begin
   Result := control.Count;
end;

procedure THIStringTable._var_Strings;
begin
  if arr = nil then
    arr := CreateArray(_aset,_aget,_acount,_aadd);
  dtArray(_Data,Arr);
end;


end.

