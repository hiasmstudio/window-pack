unit hiTreeView;

interface

uses Windows,Kol,Share,Win;

const
  TV_FIRST                = $1100;      { TreeView messages }
  TVM_SETBKCOLOR          = TV_FIRST + 29;
  TVM_SETTEXTCOLOR        = TV_FIRST + 30;
  TVM_SETINSERTMARKCOLOR  = TV_FIRST + 37;
  TVM_SETLINECOLOR        = TV_FIRST + 40;

type
  THITreeView = class(THIWin)
   private
    _Arr:PArray;
    IList:PImageList;

    //procedure _OnKey( Sender: PControl; var Key: Longint; Shift: DWORD );
    procedure _OnClick(Obj:PObj);

    procedure LoadFromText(Lst:PStrList);
    function IndexToHandle(Index:integer):THandle;
    function HandleToIndex(Handle:THandle):integer;

    procedure _Set(var Item:TData; var Val:TData);
    function _Get(Var Item:TData; var Val:TData):boolean;
    function _Count:integer;
    procedure _Add(var Val:TData);

    procedure SetIcons(const value:PStrListEx);
   public
    _prop_Strings:string;
    _prop_Lines:boolean;
    _prop_LinesRoot:boolean;
    _prop_LinesColor:TColor;    
    _prop_Tooltips:boolean;
    _prop_FileName:string;

    _data_FileName:THI_Event;
    _data_str:THI_Event;
    _event_onClick:THI_Event;
    _event_onChange:THI_Event;

    {icons}
    _data_IconID:THI_Event;
    property _prop_Icons:PStrListEx write SetIcons;

    procedure Init; override;
    destructor Destroy; override;
        procedure _work_doColor(var Data:TData; Index:word);
    procedure _work_doFont(var Data:TData; Index:word);
    procedure _work_doLinesColor(var Data:TData; Index:word);
    procedure _work_doAdd(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doLoadFromText(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doSelect(var _Data:TData; Index:word);
    procedure _work_doRename(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_Array(var _Data:TData; Index:word);
    procedure _var_Index(var _Data:TData; Index:word);
  end;

function MakeArrayIcon(Names:PChar; Values:array of integer):PStrListEx;

implementation
              
procedure THITreeView._work_doColor;
begin
  inherited;
  Control.Perform(TVM_SETBKCOLOR, 0, Color2RGB(Control.Color));
end;

procedure THITreeView._work_doFont;
begin
  inherited;
  Control.Perform(TVM_SETTEXTCOLOR, 0, Control.Font.Color);  
end;

procedure THITreeView._work_doLinesColor;
begin
  _prop_LinesColor := ToInteger(Data);
  if _prop_LinesColor = clDefault then
    Control.Perform(TVM_SETLINECOLOR, 0, CLR_DEFAULT)
  else
    Control.Perform(TVM_SETLINECOLOR, 0, Color2RGB(_prop_LinesColor)); 
end;

procedure THITreeView.Init;
var Lst:PStrList;
    Fl:TTreeViewOptions;
begin
   if _prop_Lines then
    fl := []
   else fl := [tvoNoLines];
   if not _prop_Tooltips then
    fl := [tvoNoTooltips];
   if _prop_LinesRoot then
    fl := [tvoLinesRoot];

   Control := NewTreeView(FParent,fl,IList,nil);
   Control.OnSelChange := _OnClick;
   //Control.OnChange := _OnClick;
   //Control.OnKeyDown := _OnKey;

   Lst := NewStrList;
   Lst.Text := _prop_Strings;
   LoadFromText(Lst);

   //Control.ImageListNormal.BkColor := clWindow;

   inherited;
   Control.Perform(TVM_SETBKCOLOR, 0, Color2RGB(Control.Color));
   Control.Perform(TVM_SETTEXTCOLOR, 0, Control.Font.Color);
   if _prop_LinesColor = clDefault then
     Control.Perform(TVM_SETLINECOLOR, 0, CLR_DEFAULT)
   else
     Control.Perform(TVM_SETLINECOLOR, 0, Color2RGB(_prop_LinesColor));   
end;

destructor THITreeView.Destroy;
begin
   if _Arr <> nil then dispose(_Arr);
   if Assigned(IList) then IList.free;
   inherited;
end;

procedure THITreeView.LoadFromText;
var
    i:smallint;
    Last,Prn:cardinal;
    s:string;
begin
   Control.Clear;
   Last := 0;
   Prn := 0;
   for i := 0 to Lst.Count-1 do
    begin
      s := Lst.Items[i];
      if s = '(' then
        Prn := Last
      else if s = ')' then
       begin
         last := Prn;
         Prn := Control.TVItemParent[Prn];
       end
      else begin
        Last := Control.TVInsert(Prn,Control.Count-1,s);
        Control.TVItemImage[Last] := Control.Count-1;
        Control.TVItemSelImg[Last] := Control.TVItemImage[Last];
      end;
    end;
   Lst.Free;
   _hi_OnEvent(_event_onChange);
end;

procedure THITreeView._OnClick;
begin
   //if _prop_DataType = 1 then
     _hi_OnEvent(_event_onClick,Control.TVItemText[Control.TVSelected])
   //else  _hi_OnEvent(_event_onClick,Control.CurIndex);
end;

function THITreeView.IndexToHandle;
var i:smallint;
    p:THandle;
begin
   p := 0;
   i := 0;
   while i <= Index do
    begin
      if Control.TVItemChild[p] > 0 then
       p := Control.TVItemChild[p]
      else if Control.TVItemNext[p] > 0 then
       p := Control.TVItemNext[p]
      else
       begin
        repeat
         p := Control.TVItemParent[p];
        until (p = 0)or(Control.TVItemNext[p] > 0);
        if p > 0 then
          p := Control.TVItemNext[p];
       end;
      inc(i);
    end;
   Result := p
end;

function THITreeView.HandleToIndex;
var ind:integer;
  function HTI(prn:THandle):boolean;
//  var i:smallint;
  begin
    repeat
     if prn = Handle then
      Result := true
     else if prn = 0 then
      Result := false
     else if Control.TVItemChild[prn] > 0 then
      Result := HTI( Control.TVItemChild[prn] )
     else Result := false;

     inc(ind);
     prn := Control.TVItemNext[prn];
    until Result or( prn = 0 );
  end;
begin
  ind := 0;

  if HTI(Control.TVRoot) then
    Result := Ind-1
  else Result := -1;
end;

procedure THITreeView._work_doAdd;
var item:THandle; id:integer;
begin
  item := Control.TVInsert(Control.TVSelected,0,ReadString(_Data,_data_str,''));
  id := ReadInteger(_Data,_data_IconID,0);
  Control.TVItemImage[item] := id;
  Control.TVItemSelImg[item] := id;
  _hi_OnEvent(_event_onChange);
end;

procedure THITreeView._work_doClear;
begin
  Control.Clear;
  _hi_OnEvent(_event_onChange);
end;

procedure THITreeView._work_doDelete;
begin
  Control.TVDelete(IndexToHandle(ToInteger(_Data)));
  _hi_OnEvent(_event_onChange);
end;

procedure THITreeView._work_doLoad;
var Lst:PStrList;
begin
   Lst := NewStrList;
   Lst.LoadFromFile(ReadFileName(ReadString(_Data,_data_FileName,_prop_FileName)));
   LoadFromText(Lst);
end;

procedure THITreeView._work_doLoadFromText;
var Lst:PStrList;
begin
   Lst := NewStrList;
   Lst.Text := ReadString(_Data,_data_FileName,_prop_FileName);
   LoadFromText(Lst);
end;

procedure THITreeView._work_doSave;
var
  Lst:PStrList;
  procedure Save(prn:THandle);
//  var i:smallint;
  begin
     if prn > 0 then
      begin
       Lst.Add( Control.TVItemText[prn] );
       if Control.TVItemChild[prn] > 0 then
        begin
         Lst.Add('(');
         Save(Control.TVItemChild[prn]);
         Lst.Add(')');
        end;
       Save( Control.TVItemNext[prn] );
      end;
  end;
begin
   Lst := NewStrList;
   Save(Control.TVRoot);
   Lst.SaveToFile(ReadFileName(ReadString(_Data,_data_FileName,_prop_FileName)));
   Lst.Free;
end;

procedure THITreeView._work_doSelect;
begin
  Control.TVSelected := IndexToHandle( ToInteger(_Data) );
end;

procedure THITreeView._work_doRename;
begin
  Control.TVItemText[ Control.TVSelected ] := ToString(_Data);
end;

procedure THITreeView._var_Count;
begin
   dtInteger(_Data,Control.Count);
end;

procedure THITreeView._Set(var Item:TData; var Val:TData);
var ind:integer;
begin
  ind := ToInteger(Item);
  if(ind >= 0 )and(ind < Control.Count )then
   Control.TVItemText[ IndexToHandle(ind) ] := ToString(Val);
end;

function THITreeView._Get(Var Item:TData; var Val:TData):boolean;
var ind:integer;
begin
  ind := ToInteger(Item);
  if(ind >= 0 )and(ind < Control.Count )then
   begin
    dtString(Val,Control.TVItemText[ IndexToHandle(ind) ]);
    Result := true;
   end
  else Result := false;
end;

function THITreeView._Count:integer;
begin
   Result := Control.Count;
end;

procedure THITreeView._Add(var Val:TData);
begin
    _work_doAdd(Val,0);
end;

procedure THITreeView._var_Array;
begin
   if _arr = nil then
     _Arr := CreateArray(_Set,_Get,_Count,_Add);
   dtArray(_Data,_Arr);
end;

procedure THITreeView._var_Index;
begin
   dtInteger(_Data,HandleToIndex(Control.TVSelected));
end;

procedure THITreeView.SetIcons;
var i:integer;
begin
   IList := NewImageList(Control);
   IList.BkColor := clWindow;
   IList.ImgWidth := 16;
   IList.ImgHeight := 16;
   for i := 0 to value.Count-1 do
     IList.AddIcon(Value.Objects[i]);
end;

function MakeArrayIcon;
begin
   Result := MakeArrayInteger(Names,Values);
end;

end.