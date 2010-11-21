unit hiFTCG_Tools_EM;

interface

uses windows,kol,Debug,Share;

type
  TEventProc = procedure(var Data:TData; index:word) of object;
  TFTCG_Tools_EM = class(TDebug)
    protected
      FParent:pointer;
    public      
      doWork:array of TEventProc;
      getVar:array of TEventProc;
      
      constructor Create(_Control:PControl);
      destructor Destroy; override;
      property Parent:pointer write Fparent;
  end;
  
implementation

constructor TFTCG_Tools_EM.Create;
begin
  inherited Create;
end;

destructor TFTCG_Tools_EM.Destroy;
begin
  inherited Destroy;
end;

end.
