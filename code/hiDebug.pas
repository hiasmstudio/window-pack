unit hiDebug;

interface

{$I share.inc}
{$ifndef F_P}
{$R db.res}
{$endif}

uses Windows,Kol,Share,Debug;

type
  THIDebug = class(TDebug)
   private
    eind:integer;
    dind:integer;
    uind:integer;
    Counter:cardinal;
    CounterVD:cardinal;
    CounterUp:cardinal;
    logWE,logVD,logUp:PStrList;

    procedure SetEnabled(const Value:boolean);
    procedure Blink(var dt:TData; Ind:smallint; var Cnt:cardinal; list:PStrList);
    function Execute(Sender:PThread): Integer;
   public
    _prop_EventDelay:integer;
    _prop_Synchronize:boolean;
    _prop_WEName:string;
    _prop_VDName:string;
    _prop_UpName:string;
    _prop_LogCount:integer;
    _prop_logFormat:string;
    _data_Data:THI_Event;
    _event_onEvent:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doEvent(var _Data:TData; Index:word);
    procedure _var_Var(var _Data:TData; Index:word);
    property _prop_Enabled:boolean write SetEnabled;
  end;

implementation

type
 PInt = ^integer;
 TDForm = object
   private
    Form:PControl;
    Bar:PControl;
    Bmp:PBitmap;
    LogForm:PControl;
    Log:PControl;
    IList:PList;

    procedure _OnClose(Sender: PObj; var Accept: Boolean );
    procedure _OnSave(Sender: PObj);
    procedure _OnClick(Obj:PObj);
    
    procedure _OnDestroy(Sender:PObj);
   public
    List:PControl;

    procedure Init;
    function Add(const Name:string; index:PInt):integer;
    procedure SetItem(ind:integer; Value:string);
    procedure SetType(ind:integer; const Data:TData);
    procedure SetCounter(ind:integer; Value:integer);
    procedure Select(ind:integer; State:boolean );
    procedure Delete(ind:PInt);
 end;

var DForm:TDForm;

procedure TDForm.Init;
var hk:HKEY;w,lw:integer;
    ico:PIcon;
    b:PBitmap;
    r:TRect;
begin
   if Form <> nil then exit;
   Form := NewForm(Applet,'Debug');
   Form.GetWindowHandle;
   Form.StayOnTop := true;
   Form.onClose := _onClose;

   Bmp := NewBitmap(16*3, 16);   
   ico := NewIcon;
   b := NewBitmap(0,0);
   r.top := 0;
   r.bottom := 16;
   for w := 0 to 2 do
    begin
     r.left := w*16;
     r.right := r.left + 16;
     ico.handle := LoadIcon(hInstance, PChar('DB' + int2str(w+1)));
     b.handle := ico.Convert2Bitmap(clBtnFace); 
     bmp.CopyRect(r, b, b.BoundsRect);
    end;
   ico.free;
   b.free;
   
   Bar := NewToolbar(Form,caTop,[tboFlat],bmp.handle,['','',''],[0,1]);
   Bar.TBSetTooltips(Bar.TBIndex2Item(0),['Popup window','Show log','Copy to clipboard']);
   with Bar{$ifndef F_P}^{$endif} do
    begin
      Align := caTop;
      Height := 24;
      OnClick := _OnClick;
    end;

   hk := RegKeyOpenCreate(HKEY_CURRENT_USER,'Software\HiAsm\Debug');
   with Form{$ifndef F_P}^{$endif} do 
    begin
     Applet.OnClose := _onClose;
     w := RegKeyGetDw(hk,'Left');
     if w=0 then begin
       if Applet.ChildCount=0 then w := 20
       else w := Applet.Children[0].Left;
     end;
     Left := w;
     w := RegKeyGetDw(hk,'Top');
     if w=0 then begin
       if Applet.ChildCount=0 then w := 105
       else w := Applet.Children[0].Height+Applet.Children[0].Top;
     end;
     Top := w;
     w := RegKeyGetDw(hk,'Width');
     if w=0 then begin
       if Applet.ChildCount=0 then w := 400
       else w := Applet.Children[0].Width;
     end;
     Width := w;
     w := RegKeyGetDw(hk,'Height');
     if w=0 then w := 80;
     Height := w;
     Style := WS_CAPTION or WS_THICKFRAME or WS_SYSMENU;
     ExStyle := WS_EX_TOOLWINDOW;
     Border := 0;
     Show;
     Invalidate;
    end;
   List := NewListView(Form,lvsDetail,[lvoRowSelect],nil,nil,nil);
   List.OnDestroy     := _OnDestroy;
   List.Align := caClient;
   lw := List.ClientWidth;
   w := RegKeyGetDw(hk,'wName');
   if w=0 then w := min(80,lw div 4); dec(lw,w);
   List.LVColAdd('Name', taLeft,w);
   w := RegKeyGetDw(hk,'wValue');
   if w=0 then w := lw div 3; dec(lw,w);
   List.LVColAdd('Value',taLeft,w);
   w := RegKeyGetDw(hk,'wType');
   if w=0 then w := lw div 2; dec(lw,w);
   List.LVColAdd('Type', taLeft,w);
   w := RegKeyGetDw(hk,'wCount');
   if w=0 then w := lw;
   List.LVColAdd('Count',taLeft,w);
   kol.RegKeyClose(hk);
   
   IList := NewList;
end;

procedure TDForm._OnDestroy;
begin
  List := nil; 
end;

procedure TDForm._OnClick;
var i:integer; 
    lst:PStrList;
begin
  if not Bar.RightClick then
    case Bar.CurIndex of
      0: Form.StayOnTop := not Form.StayOnTop;
      1: 
        if(List.LVCurItem <> -1)and(List.LVItemData[List.LVCurItem] > 0)then
         begin
          lst := PStrList(List.LVItemData[List.LVCurItem]);    
          logForm := NewForm(Applet, 'Log');
          logForm.SetSize(Form.Width, Form.Height);
          log := NewListBox(logForm, [loNoIntegralHeight,loNoExtendSel]);
          log.Font.Assign(logForm.Font);
          log.Align := caClient;
          for i := 0 to lst.Count-1 do
            log.Add(lst.Items[i]); 
          logForm.Show;
         end;
      2:
       if(List.LVCurItem <> -1)then
         Text2Clipboard(List.LVItems[List.LVCurItem,1]);       
    end;
end;

procedure TDForm._OnSave;
var hk:HKEY;
begin
   hk := RegKeyOpenWrite(HKEY_CURRENT_USER,'Software\HiAsm\Debug');
   RegKeySetDw(hk,'Left',  Form.Left);
   RegKeySetDw(hk,'Top',   Form.Top);
   RegKeySetDw(hk,'Width', Form.Width);
   RegKeySetDw(hk,'Height',Form.Height);
   RegKeySetDw(hk,'wName', List.LVColWidth[0]);
   RegKeySetDw(hk,'wValue',List.LVColWidth[1]);
   RegKeySetDw(hk,'wType', List.LVColWidth[2]);
   RegKeySetDw(hk,'wCount',List.LVColWidth[3]);
   RegKeyClose(hk);
end;

procedure TDForm._OnClose;
begin
   Accept := false;
   _OnSave(Sender);
   Form.Hide;
end;

function TDForm.Add;
begin
   Result := List.LVItemAdd(Name);
   IList.Add(index);
end;

procedure TDForm.SetItem;
begin
  List.LVItems[ind,1] := Value;
end;

procedure TDForm.SetType;
var t:byte;
begin
  t := _isType(Data);
  if (t>0)and(Data.ldata<>nil) then
    List.LVItems[ind,2] := 'MultiThread'
  else if t <= high(DataNames) then
    List.LVItems[ind,2] := DataNames[t]
  else
    List.LVItems[ind,2] := 'Unknown: '+int2str(t);
end;

procedure TDForm.SetCounter;
begin
  List.LVItems[ind,3] := Int2Str(Value);
end;

procedure TDForm.Select;
begin
  if State then
    List.LVItemState[ind] := [lvisHighlight]
  else List.LVItemState[ind] := [];
end;

procedure TDForm.Delete;
var i,il:integer;
begin
   if List = nil then exit;
   il := IList.indexof(ind);
   List.LVDelete(ind^);
   for i := il+1 to IList.Count-1 do
     dec(integer(IList.Items[i]^));
   IList.Delete(il);    
end;

constructor THIDebug.Create;
begin
  inherited Create;
end;

destructor THIDebug.Destroy;
begin
  if eind <> -1 then
    DForm.Delete(@eind);
  if dind <> -1 then
    DForm.Delete(@dind);
  if uind <> -1 then
    DForm.Delete(@uind);
  inherited;
end; 

function THIDebug.Execute(Sender:PThread): Integer;
begin
   sleep(_prop_EventDelay);
   DForm.Select(Sender.Tag,false);
   Result := 0;
end;

procedure THIDebug.SetEnabled;
begin
  eind := -1;
  dind := -1;
  uind := -1;
  if not Value then exit; 
  DForm.Init;
  
  if _prop_WEName <> '' then 
   begin
     eind := DForm.Add(_prop_WEName, @eind);
     if _prop_LogCount > 0 then
       logWE := NewStrList;
     DForm.List.LVItemData[eind] := cardinal(logWE);
   end;
  if _prop_VDName <> '' then
   begin 
     dind := DForm.Add(_prop_VDName, @dind);
     if _prop_LogCount > 0 then
       logVD := NewStrList;
     DForm.List.LVItemData[dind] := cardinal(logVD);  
   end;
  if _prop_UpName <> '' then
   begin 
     uind := DForm.Add(_prop_UpName, @uind);
     if _prop_LogCount > 0 then
       logUp := NewStrList;
     DForm.List.LVItemData[uind] := cardinal(logUp);  
   end;
end;

procedure THIDebug.Blink;
var s,r:string;
  function GetStr(var _Data:TData):string;
  var dt:PData; s:string; t:byte;
  begin
    if _isNull(_Data)or(_Data.ldata=nil)then begin
      Result := GetString(_Data);
      exit;
    end;
    Result := '';
    dt := @_Data;
    repeat
      s :=GetString(dt^);
      t := _isType(dt^);
      if s<>'' then Result := Result + '[ ' + s + ' ]'
      else if t>high(DataNames) then
        Result := Result + '[ Unknown: '+int2str(t)+ ' ]'
      else Result := Result + '[ ' + DataNames[t] + ' ]';
      if _isNull(dt^) then dt := nil
      else dt := dt.ldata;
    until dt = nil;
  end;
begin
  if ind<0 then exit;
  if _prop_EventDelay=0 then exit;
  inc(Cnt);
  s := GetStr(dt); 
  DForm.SetItem(ind,s);
  DForm.SetType(ind,dt);
  DForm.SetCounter(ind,Cnt);
//  DForm.Select(ind,true);
  if list <> nil then
   begin
    r := _prop_LogFormat;
    replace(r, '%time', Time2StrFmt('HH:mm:ss', Now));
    replace(r, '%type', int2str(dt.data_type));
    replace(r, '%data', s);   
    list.add(r);
    if list.count > _prop_LogCount then
     list.delete(0);
   end;
  if _prop_Synchronize then 
   begin
    Applet.ProcessMessages;
    Sleep(_prop_EventDelay);
//    DForm.Select(ind,false);
   end
(*  else 
   with {$ifdef F_P}NewThreadForFPC
                {$else}NewThread^{$endif}do 
    begin
     Tag := ind;
     OnExecute := Self.Execute;
     AutoFree := true;
     Resume;
   end;
*)
end;

procedure THIDebug._work_doEvent;
begin
   if eind = -1 then 
    begin
      _hi_CreateEvent_(_Data,@_event_onEvent);
      exit;
    end;
   Blink(_Data, eind, Counter, logWE);
   _Init := true;
   _hi_CreateEvent_(_Data,@_event_onEvent);
end;

procedure THIDebug._var_Var;
begin
   if(uind = -1)and(dind = -1)then 
    begin
      _ReadData(_Data,_data_Data);
      exit;
    end;
   Blink(_Data, uind, CounterUp, logUP);
   _ReadData(_Data,_data_Data);
   Blink(_Data, dind, CounterVD, logVD);
end;

end.