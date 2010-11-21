unit hiCommandCenter;

interface

uses Windows,Kol,Share,Debug;

const
  FLG_CHECK = $01;

type
  TCI_Item = record
    obj:pointer;
    onChangeState:procedure(obj:pointer; enabled, checked:boolean) of object;
  end;
  PCI_Item = ^TCI_Item;
  TCommandInfo = record
    name:string;
    info:string;
    flags:byte;
    icon:integer;
    items:PList;
    enabled:boolean;
    checked:boolean;
  end;
  PCommandInfo = ^TCommandInfo;
  
  TCI_Monitor = class(TDebug)
    onDestroy:procedure (obj:TCI_Monitor) of object;
    
    procedure onRefresh; virtual; abstract;
  end;

  THICommandCenter = class(TDebug)
   private
    CList: PStrListEx;
    CIMList: PList;
    
    procedure SetCommands(value: PStrListEx);
    procedure addCmdInfo(const name, info:string; icon:integer; flags:byte);
    function GetCommandInfo(index:integer):PCommandInfo;
    
    procedure onCIM_Destroy(obj:TCI_Monitor);
   public
    IList: PImageList;

    _prop_Name:string;

    _event_onAction:THI_Event;
    _event_onRefresh:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doRefresh(var _Data:TData; Index:word);
    function getInterfaceCommandCenter:THICommandCenter;
    
    procedure AddMonitor(obj:TCI_Monitor);
    function findCmd(const name:string):PCommandInfo;
    
    procedure event(cmd:PCommandInfo);
    procedure state(const name:string; enabled,checked:boolean);
    
    property _prop_Commands:PStrListEx write SetCommands;
    property Items[index:integer]:PCommandInfo read GetCommandInfo;
  end;
  ICommandCenter = THICommandCenter;

implementation

constructor THICommandCenter.Create;
begin
  inherited;
  IList := NewImageList(nil);
  //IList.BkColor := FBkColor;
  IList.Colors := ilcColor24;
  IList.ImgWidth := 16;
  IList.ImgHeight := 16;
  IList.DrawingStyle := [dsTransparent];
  IList.bkColor := clBtnFace;
  IList.BlendColor := clBtnFace;
  
  CList := NewStrListEx;
  CIMList := NewList;
end;

destructor THICommandCenter.Destroy;
begin
  IList.free;
  CList.free;
  CIMList.free;
  inherited;
end;

function THICommandCenter.getInterfaceCommandCenter:ICommandCenter;
begin
   Result := self;
end;

procedure THICommandCenter.AddMonitor;
begin
   CIMList.Add(obj);
   obj.onDestroy := onCIM_Destroy; 
end;

function THICommandCenter.findCmd;
var i:integer;
begin
    if CList.find(name, i) then
      Result := Items[i]
    else
      Result := nil
end;

procedure THICommandCenter.event;
var j:integer;
begin
   _hi_onEvent(_event_onAction, cmd.name);

   if cmd.flags and FLG_CHECK > 0 then
     with cmd^ do
       begin
         checked := not checked;
         for j := 0 to items.Count-1 do
          PCI_Item(items.Items[j]).onChangeState(PCI_Item(items.Items[j]).obj, true, checked);
       end;
end;

procedure THICommandCenter.state;
var cmd:PCommandInfo;
begin
  cmd := findCmd(name);
  if cmd <> nil then
    begin
      cmd.enabled := enabled;
      cmd.checked := checked; 
    end; 
end;

procedure THICommandCenter.SetCommands;
var
  i,ico: integer;
  name,info:string;
  def:HICON;
  f:byte;
begin
  def := LoadIcon(HInstance, 'ASMA');
  for i := 0 to Value.Count - 1 do
    begin
      info := Value.items[i];
      name := GetTok(info, '=');
      if name = '' then name := info;
      if name[1] = '^' then
        begin
           delete(name, 1, 1);
           f := FLG_CHECK;
        end
      else F := 0;
      
      if def = Value.Objects[i] then   // вот такой оригинальный костыль...
        ico := -1
      else ico := IList.AddIcon(Value.Objects[i]); 
      addCmdInfo(name, info, ico, f);
    end;   
end;

procedure THICommandCenter.addCmdInfo;
var cmd:PCommandInfo;
begin
  new(cmd);
  fillchar(cmd^, sizeof(TCommandInfo), 0);
  cmd.name := name;
  cmd.info := info;
  cmd.flags := flags;
  cmd.icon := icon;
  cmd.items := NewList;
  CList.AddObject(LowerCase(name), cardinal(cmd));
  CList.sort(false);
end;

function THICommandCenter.GetCommandInfo;
begin
   Result := PCommandInfo(CList.OBjects[index]);
end;

procedure THICommandCenter.onCIM_Destroy;
begin
  CIMList.Delete(CIMList.IndexOf(obj));
end;

procedure THICommandCenter._work_doRefresh;
var i,j:integer;
begin
   // reset
   for i := 0 to CList.Count-1 do
     begin
       Items[i].Enabled := false;
       Items[i].Checked := false;
     end;
   
   // refresh
   for i := 0 to CIMList.Count-1 do
     TCI_Monitor(CIMList.Items[i]).onRefresh;
   _hi_onevent(_event_onRefresh);
   
   // apply
   for i := 0 to CList.Count-1 do
     with Items[i]^ do
       for j := 0 to items.Count-1 do
          PCI_Item(items.Items[j]).onChangeState(PCI_Item(items.Items[j]).obj, enabled, checked);
end;

end.
