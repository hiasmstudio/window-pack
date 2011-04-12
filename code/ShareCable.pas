unit ShareCable;

interface

uses Kol, Share, Debug;

const data_cable = 23;
      CableNameDelimiter: Char='.';

Type
  TCable = class(TDebug)
   protected
     procedure SetCount(value:Word); virtual; 
   public
     _prop_From: byte;
     property _prop_Count:word write SetCount;
  end;

  TCableNamed = class(TDebug)
   protected
    Wire: PStrList;
    procedure SetWire(const value:string); virtual;
    procedure SetGroup(const value:string);
   public

    destructor Destroy; override;
    property _prop_Wire:string write SetWire;
    property _prop_GroupName: string write SetGroup;
  end;
      
procedure dtCable(var nCbl: TData; Data: PData; WireNumber: Integer); overload;
procedure dtCable(var nCbl: PData; Data: PData; WireName: String); overload;
function _IsCable(const Data: TData): boolean;
function Cparse(var S: String): String;
 
implementation

function Cparse(var S: String): String;
var i: Integer;
begin
  i := pos(CableNameDelimiter, S);
  if i=0 then begin 
     Result := S; S := ''; 
   end else begin 
     Result := copy(S, 1, i-1); delete(S,1,i); 
  end;
end;

procedure dtCable(var nCbl: TData; Data: PData; WireNumber: Integer);
begin
   nCbl.data_type := data_cable;
   nCbl.idata:= WireNumber;
   nCbl.Next := nil;
   nCbl.ldata := Data;
end;

procedure dtCable(var nCbl: PData; Data: PData; WireName: String);
begin
   if _isCable(data^) then begin
     data.sdata := WireName+CableNameDelimiter+data.sdata;
     nCbl := Data;
    end else begin
     new(nCbl);
     ncbl.data_type := data_cable;
     ncbl.sdata := WireName;
     ncbl.idata := 0;
     ncbl.next := nil;
     ncbl.ldata := data;
   end; 
End;                          

function _IsCable(const Data:TData):boolean;
begin
   Result := Data.Data_type = data_Cable;
end;

// =================== TCable ==================
procedure TCable.SetCount; begin end;

// =================== TCableNamed ==================
procedure TCableNamed.SetGroup;
var i: Integer;
begin 
  if (Value='') or (Wire.Count=0) then exit;
  for i:=0 to Wire.count-1 do 
    Wire.Items[i]:=LowerCase(Value)+CableNameDelimiter+Wire.Items[i];
end;

procedure TCableNamed.SetWire;
begin
   Wire := NewStrList;
   Wire.Text := LowerCase(Value);
end;

destructor TCableNamed.Destroy;
begin
   Wire.Free;
   inherited;
end;

end.
