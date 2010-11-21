unit hiFTCG_Tools;

interface

uses Kol,Share,Debug,hiFTCG_Tools_EM;

type
  TOnCreate = function(Control:PControl):TFTCG_Tools_EM;
  THIFTCG_Tools = class(TDebug)
   private
     FChild:TFTCG_Tools_EM;
     FOnCreate:TOnCreate;
     procedure SetCreateProc(Value:TOnCreate);
     function CreateInstance:TFTCG_Tools_EM;
   protected
     FControl:PControl;
   public
     Events:array of THI_Event;
     Datas:array of THI_Event;

     ParentClass:TObject;

     constructor Create(Control:PControl); overload;
     constructor Create; overload; //temp
     destructor Destroy; override;
     
     procedure doWork(var Data:TData; Index:word);
     procedure getVar(var Data:TData; Index:word);
     
     property OnCreate:TOnCreate write SetCreateProc;
  end;

implementation

constructor THIFTCG_Tools.Create(Control:PControl);
begin
   Create;
   FControl := Control;
end;

constructor THIFTCG_Tools.Create;
begin
   inherited Create;
end;

destructor THIFTCG_Tools.Destroy;
begin
   FChild.Destroy;
   inherited Destroy;
end;

procedure THIFTCG_Tools.SetCreateProc;
begin
   FOnCreate := Value;
   FChild := CreateInstance;
end;

function THIFTCG_Tools.CreateInstance;
var PrevNeedInit:boolean;
begin
   Result := FOnCreate(FControl);
   Result.Parent := Self;
end;

procedure THIFTCG_Tools.doWork(var Data:TData; Index:word);
begin
   FChild.doWork[index](Data, Index);
end;

procedure THIFTCG_Tools.getVar(var Data:TData; Index:word);
begin
   FChild.getVar[Index](Data, Index);
end;

end.
