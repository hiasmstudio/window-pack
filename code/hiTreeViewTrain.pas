unit hiTreeViewTrain;

interface

uses windows,Kol,Share,Debug,Win,hiIconsManager,if_arg;

const
  ADD_ERR_SUCCESS   = 0;
  ADD_ERR_PARENT_NF = 1;
  
  CHANGE_ERR_SUCCESS = 0;
  CHANGE_ERR_ID_NF   = 1;
  
  DEL_ERR_SUCCESS    = 0;
  DEL_ERR_ID_NF      = 1;
  
  FIRST_ERR_SUCCESS   = 0;
  FIRST_ERR_PARENT_NF = 1;
  FIRST_ERR_CHILD_NF  = 2;
  
  IPATH_ERR_SUCCESS   = 0;
  IPATH_ERR_PARENT_NF = 1;

type
  PCardinal = ^cardinal;
  TITreeViewTrain = record
     Control:PControl;
     AddNode:function (const Data:TData):integer of object;
     AddNodeAt:function (parent:cardinal; const Data:TData; last:PCardinal):integer of object;
     ChangeNode:function (const Data:TData):integer of object;
     DeleteNode:function (const Data:TData):integer of object;
     FirstNode:function (var Data:TData; var ID:TData):integer of object;
     ItemPath:function (var Data:TData; var ID:TData; d:Char):integer of object;
     findNode:function (var ID:TData):cardinal of object;
  end;
  PITreeViewTrain = ^TITreeViewTrain;
  THITreeViewTrain = class(THIWin)
   private
     train:TITreeViewTrain;
     FClear:boolean;
     FDrag:boolean;
     FLastSelect:cardinal;
     FHash:PStrListEx;
    
     procedure _OnClick(Obj:PObj);
     procedure _OnBeginDrag( Sender: PControl; Item: THandle );
     procedure _onDelete( Sender: PControl; Item: THandle );
     function _OnExpanding(Sender: PControl; Item: THandle; Expand: Boolean): Boolean;
          
     function _onDrag( Sender: PControl; ScrX, ScrY: Integer; var CursorShape: Integer;
            var Stop: Boolean ): Boolean;
     
     function AddNode(const Data:TData):integer;   
     function ChangeNode(const Data:TData):integer;
     function DeleteNode(const Data:TData):integer;
     function findNode(var ID:TData):cardinal; 
     function FirstNode(var Data:TData; var ID:TData):integer;
     function ItemPath(var Data:TData; var ID:TData; d:Char):integer;
     
     function AddNodeAt(pid:cardinal; const Data:TData; last:PCardinal):integer;
     
     procedure setIM(value:IIconsManager);
     procedure changeState(state:cardinal);
   protected
     procedure _onMouseMove(Sender: PControl; var Mouse: TMouseEventData); override;
     procedure _onMouseUp(Sender: PControl; var Mouse: TMouseEventData); override;
   public
    _prop_Lines:boolean;
    _prop_LinesRoot:boolean;
    _prop_Tooltips:boolean;
    _prop_DragDrop:boolean;
    tmp:IIconsManager;
//    _prop_IconsManager:IIconsManager;
    _prop_Name:string;
    
    _prop_CaptionIndex:integer;
    _prop_ParentIDIndex:integer;
    _prop_IDIndex:integer;
    _prop_IconIndex:integer;
    
    _prop_Numeric:integer;
    _prop_String:string;
    
    _prop_UseHashMap:boolean;
    
    _data_DropAccept:THI_Event;
        
    _event_onClick:THI_Event;
    _event_onDelete:THI_Event;
    _event_onExpand:THI_Event;
    _event_onCollapse:THI_Event;    
    _event_onDrop:THI_Event;
    
    property _prop_IconsManager:IIconsManager read tmp write setIM;
    
    procedure Init; override;
    destructor Destroy; override;
    procedure _work_doClear(var _Data:TData; index:word);
    procedure _work_doExpand(var _Data:TData; index:word);
    procedure _work_doExpandNode(var _Data:TData; index:word);
    procedure _work_doExpandToggle(var _Data:TData; index:word);    
    procedure _work_doCollapseNode(var _Data:TData; index:word);         
    procedure _work_doCollapse(var _Data:TData; index:word);
    procedure _work_doSort(var _Data:TData; index:word);    
    procedure _var_Select(var _Data:TData; index:word);
    procedure _var_NextID(var _Data:TData; index:word);
    function getinterfaceTreeView:PITreeViewTrain; 
  end;

implementation

destructor THITreeViewTrain.Destroy;
begin
   FHash.Free;
   inherited;
end;

function THITreeViewTrain.getinterfaceTreeView:PITreeViewTrain; 
begin
  train.Control := Control;
  train.AddNode := AddNode;
  train.AddNodeAt := AddNodeAt;
  train.ChangeNode := ChangeNode;
  train.DeleteNode := DeleteNode;
  train.FirstNode := FirstNode;
  train.ItemPath := ItemPath;
  train.findNode := findNode;
  Result := @train; 
end;

function getItem(var d:TData; index:integer):boolean;
var dt:PData;
begin         
  Result := true;
  if index = 0 then Exit;
     
  dt := d.ldata;
  while dt <> nil do
   begin
     dec(index);
     if index = 0 then
       begin
         d := dt^;
         exit;
       end; 
     dt := dt.ldata;     
   end;
  Result := false; 
end;

function THITreeViewTrain.findNode(var ID:TData):cardinal;
var d:TData;
    p:cardinal;
    i:integer;
begin
   Result := 0;

   if _prop_UseHashMap and FHash.find(ToString(ID), i) then
    begin
     Result := integer(FHash.objects[i]);
     exit
    end;

   p := Control.TVRoot;
   while p > 0 do
    begin
      d := PData(Control.TVItemData[p])^;
      if getItem(d, _prop_IDIndex) and (_IsType(d) = _IsType(ID)) and Compare(d,ID,0) then
        begin
          Result := p;
          break;          
        end; 

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
    end;
end;

function THITreeViewTrain.FirstNode;
var pid,node:cardinal;
begin
  Result := FIRST_ERR_SUCCESS;
  
  pid := findNode(ID);
  if pid = 0 then
   begin
      Result := FIRST_ERR_PARENT_NF;
      exit;
   end;
  node := Control.TVItemChild[pid];
  if node = 0 then
    Result := FIRST_ERR_CHILD_NF
  else Data := PData(Control.TVItemData[node])^;
end;

function THITreeViewTrain.ItemPath;
var pid:cardinal;
begin
  Result := IPATH_ERR_SUCCESS;

  pid := findNode(ID);
  if pid = 0 then
   begin
      Result := IPATH_ERR_PARENT_NF;
      exit;
   end
   else dtString(Data, Control.TVItemPath(pid, d));
end;

function THITreeViewTrain.AddNodeAt;
var
    dt:TData;
    fd:PData;
    node:cardinal;
    cap:string;
begin
  dt := Data;
  new(fd);
  FillChar(fd^, sizeof(TData), 0);
  CopyData(fd,@dt);
  
  if getItem(dt, _prop_CaptionIndex) then
    cap := ToString(dt)
  else cap := 'node';  
  
  node := Control.TVInsert(pid, 0, cap); 
  Control.TVItemData[node] := fd;
  dt := Data;
  if (Control.ImageListNormal <> nil)and getItem(dt, _prop_IconIndex) then
   begin
     Control.TVItemImage[node] := ToInteger(Dt); 
     Control.TVItemSelImg[node] := Control.TVItemImage[node];
   end;
  Result := ADD_ERR_SUCCESS;
  if _prop_UseHashMap then
   begin
      dt := Data;
      getItem(dt, _prop_IDIndex);  
      FHash.AddObject(ToString(dt), node);
   end;
  if last <> nil then
    last^ := node; 
end;

function THITreeViewTrain.AddNode(const Data:TData):integer;
var dt:TData;
    pid:integer;
begin
  dt := Data;
  if getItem(dt, _prop_ParentIDIndex) then
   begin
     if(_IsStr(dt) and (ToString(dt) = _prop_String))or(_isInteger(dt) and (ToInteger(dt) = _prop_Numeric)) then
        pid := 0
     else 
      begin
        pid := findNode(dt);
        if pid = 0 then
         begin
           Result := ADD_ERR_PARENT_NF;
           exit;
         end;
      end;
   end
  else pid := 0; 

  Result := AddNodeAt(pid, Data, nil);
end;

function THITreeViewTrain.ChangeNode(const Data:TData):integer;
var id,i:integer;
    dt:TData;
    fd:PData;
begin     
   dt := Data; 
   if not getItem(dt, _prop_IDIndex) then 
    begin
      Result := CHANGE_ERR_ID_NF;
      exit;
    end;
   id := findNode(dt);
   if id = 0 then 
    begin
      Result := CHANGE_ERR_ID_NF;
      exit;
    end;
   fd := Control.TVItemData[id];
   dt := Data;
   i := 0;
   while fd <> nil do
    begin
//      _debug(dt.data_type);
      if _IsInteger(dt) then
       begin
         if dt.idata <> _prop_Numeric then
           fd.idata := dt.idata;
       end
      else if _IsStr(dt) then
       begin
         if dt.sdata <> _prop_String then
           fd.sdata := dt.sdata;
       end
      else
       begin
          fd.sdata := dt.sdata;
          fd.idata := dt.idata;
          fd.rdata := dt.rdata;
       end; 
      if i = _prop_CaptionIndex then
        Control.TVItemText[id] := ToString(fd^)
      else if(i = _prop_Iconindex)and(Control.ImageListNormal <> nil) then 
        begin
          Control.TVItemImage[id] := ToInteger(fd^); 
          Control.TVItemSelImg[id] := Control.TVItemImage[id];
        end;
      inc(i);
      fd := fd.ldata;
      if dt.ldata <> nil then 
        dt := dt.ldata^;
    end;     
   Result := CHANGE_ERR_SUCCESS;
end;    

function THITreeViewTrain.DeleteNode(const Data:TData):integer;
var id:integer;
    dt:TData;
begin     
   dt := Data; 
   if not getItem(dt, _prop_IDIndex) then 
    begin
      Result := DEL_ERR_ID_NF;
      exit;
    end;
   id := findNode(dt);
   if id = 0 then 
    begin
      Result := DEL_ERR_ID_NF;
      exit;
    end;
   Control.TVDelete(id);
   Result := DEL_ERR_SUCCESS;
end;

procedure THITreeViewTrain.Init;
var 
    Fl:TTreeViewOptions;
    icons:PImageList;
begin
   if _prop_DragDrop then
     fl := [tvoDragDrop]
   else fl := [];
   
   if not _prop_Lines then
     include(fl, tvoNoLines);
   
   if not _prop_Tooltips then
     include(fl, tvoNoTooltips);
   if _prop_LinesRoot then
     include(fl, tvoLinesRoot);

   if _prop_IconsManager = nil then
     icons := nil
   else icons := _prop_IconsManager.iconList;
   Control := NewTreeView(FParent,fl,icons,nil);
   Control.OnSelChange := _OnClick;
   Control.OnTVDelete := _onDelete;
   Control.OnTVExpanding := _OnExpanding;
   Control.OnTVBeginDrag := _OnBeginDrag;
   FHash := NewStrListEx;
   inherited;
end;

procedure THITreeViewTrain.setIM(value:IIconsManager);
begin
  if value <> nil then
    Control.ImageListNormal := value.iconList;
end;

procedure THITreeViewTrain._work_doClear(var _Data:TData; index:word);
begin
   FClear := true;
   Control.Clear;
   FClear := false;
end;

procedure THITreeViewTrain.changeState;
var p:cardinal;
begin
   p := Control.TVRoot;
   while p > 0 do
    begin
      if Control.TVItemChild[p] > 0 then
       begin
         Control.TVExpand(p, State);
         p := Control.TVItemChild[p];
       end
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
    end; 
end;

procedure THITreeViewTrain._work_doExpand(var _Data:TData; index:word);
begin
   changeState(TVE_EXPAND);
end;

procedure THITreeViewTrain._work_doCollapse(var _Data:TData; index:word);
begin
   changeState(TVE_COLLAPSE);
end;

procedure THITreeViewTrain._work_doExpandNode(var _Data:TData; index:word);
var pid:cardinal;
begin
   pid := findNode(_Data);
   if pid = 0 then
     exit
   else
     Control.TVExpand(pid, TVE_EXPAND);
end;

procedure THITreeViewTrain._work_doExpandToggle(var _Data:TData; index:word);
var pid:cardinal;
begin
   pid := findNode(_Data);
   if pid = 0 then
     exit
   else
     Control.TVExpand(pid, TVE_TOGGLE);
end;

procedure THITreeViewTrain._work_doCollapseNode(var _Data:TData; index:word);
var pid:cardinal;
begin
   pid := findNode(_Data);
   if pid = 0 then
     exit
   else
     Control.TVExpand(pid, TVE_COLLAPSE);
end;

procedure THITreeViewTrain._work_doSort(var _Data:TData; index:word);
begin
   Control.TVSort(0);
end;

procedure THITreeViewTrain._var_Select(var _Data:TData; index:word);
var n:cardinal;
begin
   n := Control.TVSelected;
   if n = 0 then
     dtNull(_Data)
   else _Data := PData(Control.TVItemData[n])^; 
end;

procedure THITreeViewTrain._var_NextID(var _Data:TData; index:word);
var i,FNextID,c:integer;
      procedure findID(prn:cardinal);
      var dt:PData;
      begin
         if prn > 0 then 
           begin
             dt := PData(Control.TVItemData[prn]);
             getItem(dt^, _prop_IDIndex);
             c := ToInteger(dt^);
             if c >= FNextID then 
                FNextID := c + 1;            
             if Control.TVItemChild[prn] > 0 then 
                findID(Control.TVItemChild[prn]);
             findID(Control.TVItemNext[prn]);
           end;
      end;
begin
   FNextID := 1;
   if _prop_UseHashMap then
     for i := 0 to FHash.count-1 do
       begin
         c := str2int(FHash.items[i]);
         if c >= FNextID then 
           FNextID := c + 1;
       end
   else findID(Control.TVRoot); 
     
   dtInteger(_data, FNextID); 
end;

function THITreeViewTrain._onDrag( Sender: PControl; ScrX, ScrY: Integer; var CursorShape: Integer;
            var Stop: Boolean ): Boolean;
begin

end;

procedure THITreeViewTrain._onDelete( Sender: PControl; Item: THandle );
var dt:TData;
    i:integer;
begin
  if Control.TVItemData[Item] = nil then exit;
  
  if not FClear then
   begin
     dt := PData(Control.TVItemData[Item])^; 
     _hi_onEvent(_event_onDelete, dt);
   end;
  FreeData(PData(Control.TVItemData[Item]));
  
  if _prop_UseHashMap then
     FHash.Delete(FHash.IndexOfObj(pointer(Item)));
end;

function THITreeViewTrain._OnExpanding;
var dt:TData;
begin
   Result := true;
   dt := PData(Control.TVItemData[Item])^; 
   if Expand then
     _hi_onEvent(_event_onExpand, dt)
   else  
     _hi_onEvent(_event_onCollapse, dt)
end;

procedure THITreeViewTrain._OnClick(Obj:PObj);
var d:PData;
begin
  d := Control.TVItemData[Control.TVSelected];
  _hi_onEvent_(_event_onClick, d^);
end;

//---------------------------- DRAG DROP ---------------------------------------

procedure THITreeViewTrain._OnBeginDrag( Sender: PControl; Item: THandle );
begin
  FDrag := true;
  Control.CursorLoad(0, MakeIntResource(crHandPoint));
  Control.TVSelected := Item;
  FLastSelect := 0; 
end;

procedure THITreeViewTrain._onMouseMove;
var c,where:cardinal;
    dt:TData;
begin
  inherited;
  c := Control.TVItemAtPos(Mouse.X, Mouse.Y, where);
  if not FDrag or(FLastSelect = c) or (c = 0) then exit;
  Control.TVItemDropHighlighted[FLastSelect] := false;
  dt := PData(Control.TVItemData[c])^;
  _ReadData(dt, _data_DropAccept);
  if ToInteger(dt) <> 0 then
   begin
     Control.TVItemDropHighlighted[c] := true;
     Control.CursorLoad(0, MakeIntResource(crHandPoint));
     FLastSelect := c;
   end
  else 
   begin
     Control.CursorLoad(0, MakeIntResource(crNo));
     FLastSelect := 0;
   end;
end;

procedure THITreeViewTrain._onMouseUp;
var c,where,sel,lastNode:cardinal;
    d,fd:PData;
    pd,fs:TData;
    i:integer;
    function moveNode(fromNode, toNode:cardinal):cardinal;
    begin
       Result := Control.TVInsert(toNode, 0, Control.TVItemText[fromNode]); 
       Control.TVItemData[Result] := Control.TVItemData[fromNode];
       Control.TVItemData[fromNode] := 0;
       Control.TVItemImage[Result] := Control.TVItemImage[fromNode]; 
       Control.TVItemSelImg[Result] := Control.TVItemImage[fromNode];
        if _prop_UseHashMap then
          begin
            i := FHash.IndexOfObj(pointer(fromNode));
            FHash.Objects[i] := Result;
          end;
    end; 
    procedure moveNodes(fromNode, toNode:cardinal);
    var n:cardinal;
        p:cardinal;
    begin
       p := Control.TVItemChild[fromNode];
       while p > 0 do
         begin
           n := moveNode(p, toNode);
           moveNodes(p, n); 
           p := Control.TVItemNext[p];
         end;
    end;
    function isNodeCross(fromNode, toNode:cardinal):boolean;
    var p:cardinal;
    begin
       Result := True;
       if fromNode = toNode then exit;
       
       p := Control.TVItemChild[fromNode];
       while p > 0 do
         begin
           if isNodeCross(p, toNode) then exit;           
           p := Control.TVItemNext[p];                                         
         end;
         
       Result := false;  
    end;
begin
  inherited;
  if not FDrag  then exit;

  c := FLastSelect;
  if(c <> 0)and not isNodeCross(Control.TVSelected, c) then
   begin
     sel := Control.TVSelected; 
     d := Control.TVItemData[sel];
     pd := PData(Control.TVItemData[c])^;
     getItem(pd, _prop_IDIndex);

     fs := d^;
     fd := d;   
     i := 0;
     while fd <> nil do
       begin          
          if i = _prop_ParentIDIndex then
            begin
              fd.data_type := pd.data_type;
              fd.idata := pd.idata;
              fd.sdata := pd.sdata;
              fd.rdata := pd.rdata;
              break;
            end;
          inc(i);
          fd := fd.ldata;
       end; 
     //AddNodeAt(c, d^, @lastNode);
     lastNode := moveNode(sel, c);  
     moveNodes(sel, lastNode);
     FClear := true;
     Control.TVDelete(sel);
     FClear := false;
     pd := PData(Control.TVItemData[lastNode])^;
     _hi_onEvent_(_event_onDrop, pd);
   end;  
  Control.TVItemDropHighlighted[FLastSelect] := false;
  FLastSelect := 0;
  FDrag := false;
  Control.CursorLoad(0, MakeIntResource(crDefault));
end;

end.