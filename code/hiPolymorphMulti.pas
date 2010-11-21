unit hiPolymorphMulti;

interface

uses Kol,Share,Debug,hiEditPolyMulti,hiPolyBase;

type
  TSDKCreator = function(_parent:pointer; _Control:PControl; _ParentClass:TObject):THiEditPolyMulti;
   
  THIPolymorphMulti = class(TDebug)
   private
    FStrList:PStrListEx;

    function CreateInstance(proc:cardinal):THiEditPolyMulti;
    function TestEvent(F:THiEditPolyMulti;G:PListEH):boolean;
    function GetChilds(index:integer):THIEditPolyMulti;
    function GetChildCount:integer;
    function GetClasses(index:integer):string;
    function GetClassCount:integer;
   protected
    FChilds:PStrListEx;
    FChild:THiEditPolyMulti;
   public
    FControl:PControl;

    _prop_Childrens:string;
    _prop_Selected:string;
    _prop_WorkScheme:byte;

    EvHandle:PListEH;
    Events:array of THI_Event;
    Datas:array of THI_Event;
    
    ParentClass:TObject;
    
    constructor Create(Control:PControl); overload;
    constructor Create; overload; //temp
    destructor Destroy; override;
    procedure Init; virtual;
    procedure Add(var _Data:TData; Index:word); virtual;
    procedure Clear(var _Data:TData; Index:word);
    procedure Count(var _Data:TData; Index:word);

    procedure AddCreator(const name:string; creator:TSDKCreator);

    procedure doWork(var Data:TData; Index:word);
    procedure getVar(var Data:TData; Index:word);

    procedure Select(var Data:TData; Index:word); virtual;
    procedure Delete(var Data:TData; Index:word); virtual;
    procedure NSelect(var Data:TData; Index:word); virtual;
    procedure HSelect(var Data:TData; Index:word); virtual;
    procedure HDelete(var Data:TData; Index:word); virtual;
    procedure Handle(var Data:TData; Index:word);
    procedure Index(var Data:TData; Index:word); virtual;
    procedure Name(var Data:TData; Index:word);
    procedure EventIndex(var Data:TData; Index:word);
    procedure EventHandle(var Data:TData; Index:word);
    
    property Childs[index:integer]:THIEditPolyMulti read GetChilds;
    property ChildCount:integer read GetChildCount;
    
    property Classes[index:integer]:string read GetClasses;
    property ClassCount:integer read GetClassCount;
  end;

implementation

constructor THIPolymorphMulti.Create(Control:PControl);
begin
  Create;
  FControl := Control;
end;

constructor THIPolymorphMulti.Create;
begin
  inherited Create;
  FStrList := NewStrListEx;
  FChilds := NewStrListEx;
end;

destructor THIPolymorphMulti.Destroy;
begin
  FStrList.Free;
  FChilds.Free;
  inherited;
end;

procedure THIPolymorphMulti.Init;
begin
end;

procedure THIPolymorphMulti.AddCreator;
begin
  FStrList.AddObject(name, cardinal(@creator));
end;

procedure THIPolymorphMulti.Add;
var  i:integer;
     dt:TData;
     F:THiEditPolyMulti;
     s: string;
begin
  dt := _Data;
  s := ToString(_Data);
  i := FStrList.IndexOf(s);
  if i <> -1 then
  begin                                
    F := CreateInstance(FStrList.Objects[i]); 
    FChilds.AddObject(s, cardinal(F));
    _hi_onEvent(F.Works[Index], dt);
  end;
end;

procedure THIPolymorphMulti.Clear;
var  i:integer;
begin
  for i := FChilds.Count-1 downto 0 do
  begin
    dtInteger(_Data,i);
    Delete(_Data,Index); //more testng + events before destruction
  end;
end;

procedure THIPolymorphMulti.Count;
begin
  dtInteger(_Data, FChilds.Count);
end;

procedure THIPolymorphMulti.doWork;
var  i: integer;
     dt: TData;
     e:THI_Event;
begin
  case _prop_WorkScheme of
    0: if FChild <> nil then
         begin
           e := FChild.Works[Index]; 
           if not assigned(e.event) then
              e := THiEditPolyMulti(TClassPolyBase(FChild.MainClass).Base).Works[Index];           
           _hi_OnEvent(e, Data);
         end;
    1: for i := 0 to FChilds.Count-1 do
       begin
         dt := Data;
         e := THiEditPolyMulti(FChilds.Objects[i]).Works[Index]; 
         if not assigned(e.event) then
           e := THiEditPolyMulti(TClassPolyBase(THiEditPolyMulti(FChilds.Objects[i]).MainClass).Base).Works[Index];  
         _hi_onEvent(e, dt);
       end;
  end;
end;

procedure THIPolymorphMulti.getVar;
var e:THI_Event;
begin
  if FChild = nil then exit;
  e := FChild.Vars[Index]; 
  if not assigned(e.event) then
     e := THiEditPolyMulti(TClassPolyBase(FChild.MainClass).Base).Vars[Index];
  _ReadData(Data, e);
end;

procedure THIPolymorphMulti.Select;
var  ind:integer;
begin
  ind := ToInteger(Data);
  FChild := nil;
  if (ind < 0) or (ind >= FChilds.Count) then exit;
  FChild := THiEditPolyMulti(FChilds.Objects[ind]);
  _hi_OnEvent(FChild.Works[Index], Data);
end;

procedure THIPolymorphMulti.NSelect;
var  i:integer;
     s:string;
     dt:TData;
begin
  dt := Data;
  s := ToString(dt);
  FChild := nil;
  for i := 0 to FChilds.Count - 1 do
    if s = FChilds.Items[i] then
    begin  
      FChild := THiEditPolyMulti(FChilds.Objects[i]);
      _hi_OnEvent(FChild.Works[Index], dt);
    end;  
end;

function THIPolymorphMulti.TestEvent;
begin
  Result := true;
  while assigned(G) do
  begin
    if F=G.Hnd then
    begin
      _debug('Self destruction is not allowed !!!');
      exit;
    end;
    G := G.Prv;
  end;
  Result := false;
end;

procedure THIPolymorphMulti.Delete;
var  ind:integer;
     F:THiEditPolyMulti;
begin
  ind := ToInteger(Data);
  if (ind < 0) or (ind >= FChilds.Count) then exit;
  F := THiEditPolyMulti(FChilds.Objects[ind]);
  if TestEvent(F, EvHandle) then exit;
  if Index < length(F.Works) then 
    _hi_OnEvent(THiEditPolyMulti(FChilds.Objects[ind]).Works[Index], Data);
  if FChild = F then FChild := nil;
  F.MainClass.Destroy;
  FChilds.Delete(ind);
end;

procedure THIPolymorphMulti.HSelect;
begin
  FChild := THiEditPolyMulti(FChilds.Objects[ToInteger(Data)]);
  if FChilds.IndexOfObj(FChild) = -1 then
    FChild := nil
  else
    _hi_OnEvent(FChild.Works[Index], Data);
end;

procedure THIPolymorphMulti.HDelete;
var  F:THiEditPolyMulti;
begin
  F := THiEditPolyMulti(ToInteger(Data));
  if (FChilds.IndexOfObj(F) = -1) or TestEvent(F, EvHandle) then exit;
  _hi_OnEvent(F.Works[Index], Data);
  if FChild = F then
    FChild := nil;
  F.MainClass.Destroy;
  FChilds.Delete(FChilds.IndexOfObj(F));
end;

procedure THIPolymorphMulti.Handle;
begin
  dtInteger(Data, integer(FChild));
end;

procedure THIPolymorphMulti.Index;
begin
  dtInteger(Data, FChilds.IndexOfObj(FChild));
end;

procedure THIPolymorphMulti.Name;
begin
  dtString(Data, FChilds.Items[FChilds.IndexOfObj(FChild)]);
end;

procedure THIPolymorphMulti.EventIndex;
var  i:integer;
begin
  i := -1;
  if assigned(EvHandle) then
    i := FChilds.IndexOfObj(EvHandle.Hnd);
  dtInteger(Data, i);
end;

procedure THIPolymorphMulti.EventHandle;
var  i:integer;
begin
  i := 0;
  if assigned(EvHandle) then
    i := integer(EvHandle.Hnd);
  dtInteger(Data, i);
end;

function THIPolymorphMulti.CreateInstance;
var  PrevNeedInit:boolean;
begin
  PrevNeedInit := NeedInit;
  NeedInit := false;
  Result := TSDKCreator(proc)(self, FControl, ParentClass);
  Result.Parent := Self;
  if PrevNeedInit then InitDo;
end;

function THIPolymorphMulti.GetChilds(index:integer):THIEditPolyMulti;
begin
   Result := THiEditPolyMulti(FChilds.Objects[index]);
end;

function THIPolymorphMulti.GetChildCount:integer;
begin
   Result := FChilds.Count;
end;

function THIPolymorphMulti.GetClasses(index:integer):string;
begin
   Result := FStrList.Items[index]; 
end;

function THIPolymorphMulti.GetClassCount:integer;
begin
   Result := FStrList.Count;
end;

end.