unit hiURLBuilder;

interface

uses Kol,Share,Debug;

type
  THIURLBuilder = class(TDebug)
   private
    FRes:string;
    lst:PStrList;
 
    procedure SetArgs(value:PChar);
   public
    _data_Args:array of THI_Event;

    onBuild:THI_Event;

    destructor Destroy; override;
    procedure doBuild(var _Data:TData; Index:word);
    procedure Result(var _Data:TData; Index:word);
    property _prop_Args:PChar write SetArgs; 
  end;

implementation

function codeURl(const URL:string):string;
var i:integer;
begin
   Result := '';
   for i := 1 to length(URL) do
    if not(URL[i] in ['a'..'z', 'A'..'Z', '0'..'9']) then
      Result := Result + '%' + int2hex(ord(url[i]),2)
    else Result := Result + URL[i];
end;

destructor THIURLBuilder.Destroy;
begin
   lst.Free;
   inherited;
end; 

procedure THIURLBuilder.SetArgs(value:PChar);
begin
   lst:= NewStrList;
   lst.Text := value;
   Setlength(_data_Args, lst.Count);
end;

procedure THIURLBuilder.doBuild;
var i:integer;
begin
   FRes := '';
   for i := 0 to lst.Count-1 do
    begin
      if i > 0 then
        FRes := FRes + '&';
      FRes := FRes + lst.items[i] + '=' + codeURl(ReadString(_Data, _data_Args[i]));
    end;  
   _hi_onEvent(onBuild, FRes);
end;

procedure THIURLBuilder.Result;
begin
   dtString(_Data, FRes);
end;

end.
