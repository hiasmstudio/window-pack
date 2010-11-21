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

// =================== Отладка ==================
procedure showdata(Var _data:TData; recur:byte);
 
implementation

procedure dtCable(var nCbl: TData; Data: PData; WireNumber: Integer);
begin
   //dtCable(Cbl, Data, chr(WireNumber+1));
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

// =================== Отладка ==================

const DataNames:array[0..22]of string =  
   ('NULL','Integer','String','Data','Combo','StrList','Icon','Real','Color',
     'data_script','Stream','Bitmap','Wave','data_array','combo Ex','Font',
     'matrix','jpeg','Menu','Code','object','break', 'Cable');

procedure showdata(var _data:TData; recur:byte);
 function mstr(dt:PData; sh: Integer):string;
  begin
    result:=copy('                ',1,sh*2)+ 'Data_type:'+int2str(dt.data_type and 128)+':'+DataNames[dt.data_type and 127]+#13#10+
         copy('                ',1,sh*2)+'idata:'+int2str(dt.idata)+#13#10+
         copy('                ',1,sh*2)+'rdata:'+int2str(Round(dt.rdata))+#13#10+
         copy('                ',1,sh*2)+'sdata:'+dt.sdata+#13#10+
         copy('                ',1,sh*2)+'next :'+int2str(integer(dt.next))+#13#10+
         copy('                ',1,sh*2)+'ldata:'+int2str(integer(dt.ldata))+#13#10;
    if (sh<recur) and (dt.ldata<>nil) then result:=result+mstr(dt.ldata,sh+1);
  end;

begin
  msgbox(mstr(@_data,0),1);
end;
end.
