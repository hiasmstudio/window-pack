unit hiMultiElementEx;

interface

uses Kol,Share,hiEditMultiEx,Debug;

type
 TOnCreate = function(_parent:pointer; Control:PControl; ParentClass:TObject):THIEditMultiEx;
 THIMultiElementEx = class(TDebug)
   private
     FChild:THIEditMultiEx;
     FOnCreate:TOnCreate;
     procedure SetCreateProc(Value:TOnCreate);
     function CreateInstance:THIEditMultiEx;
     function TestEvent(F:THIEditMultiEx;G:PListEH):boolean;
   protected
     FList:PList;
     FControl:PControl;
     function AddInstance:THIEditMultiEx;
     procedure RemoveInstance(pInstance:THIEditMultiEx);
   public
     _prop_Mode:byte;
     EvHandle:PListEH;
     Events:array of THI_Event;
     Datas:array of THI_Event;
     
     ParentClass:TObject;

     constructor Create(Control:PControl); overload;
     constructor Create; overload; //temp
     destructor Destroy; override;
     procedure Init;
     procedure doWork(var Data:TData; Index:word);
     procedure getVar(var Data:TData; Index:word);
     procedure Add(var Data:TData; Index:word);
     procedure Select(var Data:TData; Index:word);
     procedure Delete(var Data:TData; Index:word);
     procedure Clear(var Data:TData; Index:word);
     procedure Count(var Data:TData; Index:word);
     procedure HSelect(var Data:TData; Index:word);
     procedure HDelete(var Data:TData; Index:word);
     procedure Handle(var Data:TData; Index:word);
     procedure Index(var Data:TData; Index:word);
     procedure EventIndex(var Data:TData; Index:word);
     procedure EventHandle(var Data:TData; Index:word);

     property OnCreate:TOnCreate write SetCreateProc;
 end;

implementation

function THIMultiElementEx.AddInstance:THIEditMultiEx;
begin
   FChild := CreateInstance;
   FList.Add(FChild); Result := FChild;
end;

procedure THIMultiElementEx.RemoveInstance(pInstance:THIEditMultiEx);
begin
   if FChild = pInstance then FChild := nil;
   pInstance.MainClass.Destroy;
   FList.Remove(pInstance);
end;

constructor THIMultiElementEx.Create(Control:PControl);
begin
   Create;
   FControl := Control;
end;

constructor THIMultiElementEx.Create;
begin
   inherited Create;
   FList := NewList;
end;

destructor THIMultiElementEx.Destroy;
begin
  Clear(_data_Empty,$FFFF); //no delete-events
  FList.Free;
  inherited;
end;

procedure THIMultiElementEx.Init;
begin
end;

procedure THIMultiElementEx.Add;
begin
   FChild := CreateInstance;
   FList.Add(FChild);
   _hi_OnEvent(FChild.Works[Index],Data);
end;

procedure THIMultiElementEx.Select;
var Ind:integer;
begin
   ind := ToInteger(Data);
   FChild := nil;
   if(ind < 0)or(ind >= FList.Count)then exit;
   FChild := FList.Items[ind];
   _hi_OnEvent(FChild.Works[Index],Data);
end;

function THIMultiElementEx.TestEvent;
begin
  Result := true;
   while assigned(G) do begin
     if F=G.Hnd then begin
       _debug('Self destruction is not allowed !!!');
       exit;
      end;
     G := G.Prv;
    end;
  Result := false;
end;

procedure THIMultiElementEx.Delete;
var Ind:integer;
    F:THIEditMultiEx;
begin
   ind := ToInteger(Data);
   if(ind < 0)or(ind >= FList.Count)then exit;
   F := FList.Items[ind];
   if TestEvent(F,EvHandle) then exit;
   if Index < length(F.Works) then 
     _hi_OnEvent(F.Works[Index],Data);
   if FChild = F then FChild := nil;
   F.MainClass.Destroy;
   FList.delete(ind);
end;

procedure THIMultiElementEx.Clear;
var i:integer; 
begin 
   for i := FList.count-1 downto 0 do begin
     dtInteger(Data,i);
     Delete(Data,Index); //more testng + events before destruction
   end
end;

procedure THIMultiElementEx.Handle(var Data:TData; Index:word);
begin
   dtInteger(Data,integer(FChild));
end;

procedure THIMultiElementEx.EventHandle(var Data:TData; Index:word);
var i:integer;
begin
   i := 0;
   if assigned(EvHandle) then i := integer(EvHandle.Hnd);
   dtInteger(Data,i);
end;

procedure THIMultiElementEx.HSelect(var Data:TData; Index:word);
begin
   FChild := THIEditMultiEx(ToInteger(Data));
   if FList.IndexOf(FChild) = -1 then FChild := nil
   else _hi_OnEvent(FChild.Works[Index],Data);
end;

procedure THIMultiElementEx.HDelete(var Data:TData; Index:word);
var F:THIEditMultiEx;
begin
   F := THIEditMultiEx(ToInteger(Data));
   if (FList.IndexOf(f)=-1)or TestEvent(F,EvHandle) then exit;
   _hi_OnEvent(F.Works[Index],Data);
   if FChild = F then FChild := nil;
   F.MainClass.Destroy;
   FList.Remove(F);
end;

procedure THIMultiElementEx.Index(var Data:TData; Index:word);
begin
  dtInteger(Data,FList.IndexOf(FChild));
end;

procedure THIMultiElementEx.EventIndex(var Data:TData; Index:word);
var i:integer;
begin
  i := -1;
  if assigned(EvHandle) then i := FList.IndexOf(EvHandle.Hnd);
  dtInteger(Data,i);
end;

procedure THIMultiElementEx.doWork;
var F:THIEditMultiEx;
begin
    if FChild = nil then
     begin
      F := CreateInstance;
      _hi_OnEvent(F.Works[Index],Data);
      F.MainClass.Destroy;
     end
    else _hi_OnEvent(FChild.Works[Index],Data);
end;

procedure THIMultiElementEx.Count;
begin
   dtInteger(Data,FList.Count);
end;

procedure THIMultiElementEx.getVar;
var F:THIEditMultiEx;
begin
    if FChild = nil then
     begin
      F := CreateInstance;
      _ReadData(Data,F.Vars[Index]);
      F.MainClass.Destroy;
     end
    else  _ReadData(Data,FChild.Vars[Index]);
end;

procedure THIMultiElementEx.SetCreateProc;
begin
   FOnCreate := Value;
   if _prop_Mode<>0 then exit;
   FChild := CreateInstance;
   FList.Add(FChild);
end;

function THIMultiElementEx.CreateInstance;
var PrevNeedInit:boolean;
begin
   PrevNeedInit := NeedInit;
   NeedInit := false;
   Result := FOnCreate(self, FControl, ParentClass);
//   Result.Parent := Self;
   if PrevNeedInit then InitDo;
end;

end.
