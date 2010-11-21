unit hiDS_StaticData;

interface

uses Kol,Share,Debug;

type
  TDataArray = array of TData;
  TIDS_Table = record
    init:function:pointer of object;
    count:function(id:pointer):integer of object;
    columns:function(id:pointer):PStrList of object; 
    row:function(id:pointer; var data:TDataArray):boolean of object;
    readidx:function(id:pointer; var data:TDataArray; idx:integer):boolean of object;
    writeidx:function(id:pointer; idx, colidx:integer; value: TData):boolean of object;    
    close:procedure(id:pointer) of object;
  end;
  IDS_Table = ^TIDS_Table;
  THIDS_StaticData = class(TDebug)
   private
    dst:TIDS_Table;
    fCol:PStrList;
    fData:array of TDataArray;
    fCount:integer;
    
    function init:pointer;
    function count(id:pointer):integer;
    function columns(id:pointer):PStrList; 
    function row(id:pointer; var data:TDataArray):boolean;
    function readidx(id:pointer; var data:TDataArray; idx:integer):boolean;    
    function writeidx(id:pointer; idx, colidx:integer; value: TData):boolean;
    procedure close(id:pointer);
    
    procedure SetColumns(const col:string);
    procedure SetData(const data:string);
   public   
    _prop_Name:string;
    
    constructor Create;
    destructor Destroy; override;
    function getInterfaceDS_Table:IDS_Table;
    property _prop_Columns:string write SetColumns;    
    property _prop_Data:string write SetData;
  end;

implementation

constructor THIDS_StaticData.Create;
begin
   inherited;
   dst.init := init;
   dst.count := count;
   dst.columns := columns;
   dst.row := row;
   dst.readidx := readidx;   
   dst.writeidx := writeidx;   
   dst.close := close;
end;

destructor THIDS_StaticData.Destroy;
begin
   fCol.free;
   inherited;
end;

procedure THIDS_StaticData.SetColumns(const col:string);
begin
  fCol := NewStrList;
  fCol.text := col;
end;

procedure THIDS_StaticData.SetData(const data:string);
var lst:PStrList;
    i,j:integer;
    s:string;
begin
  lst := newStrList;
  lst.text := data;
  fCount := lst.count;
  Setlength(fData, fCount);
  for i := 0 to fCount-1 do
   begin
     SetLength(fData[i], fCol.count);
     s := lst.Items[i] + '|';
     for j := 0 to fCol.count-1 do
       dtString(fData[i][j], GetTok(s, '|'));
   end;
  lst.free;
end;

function THIDS_StaticData.getInterfaceDS_Table;
begin
  Result := @dst;
end;

function THIDS_StaticData.init:pointer;
var i:^integer;
begin
  new(i);
  i^ := 0;
  Result := i;
end;

function THIDS_StaticData.count(id:pointer):integer;
begin
  Result := fCount;
end;

function THIDS_StaticData.columns(id:pointer):PStrList; 
begin
   Result := fCol;
end;

function THIDS_StaticData.row(id:pointer; var data:TDataArray):boolean;
var i:^integer;
begin
   i := id;
   if (i^ < fCount) and (i^ >= 0) then
    begin  
      data := fData[i^];
      inc(i^);
      Result := true;
    end
   else Result := false;
end;

function THIDS_StaticData.readidx(id:pointer; var data:TDataArray; idx:integer):boolean;
var i:^integer;
    c: integer;
begin
   i := id;
   if (idx < fCount) and (idx >= 0) then
    begin
      for c := 0 to idx do 
        inc(i^);
      dec(i^);  
      data := fData[i^];
      Result := true;
    end
   else Result := false;
end;

function THIDS_StaticData.writeidx(id:pointer; idx, colidx:integer; value: TData):boolean;
var i:^integer;
    c: integer;
begin
   i := id;
   if (idx < fCount) and (idx >= 0) and (colidx < fCol.count) and (colidx >= 0) then
    begin
      for c := 0 to idx do 
        inc(i^);
      dec(i^);  
      dtString(fData[i^][colidx], ToString(value));
      Result := true;
    end
   else Result := false;
end;

procedure THIDS_StaticData.close(id:pointer);
begin
   dispose(id);
end;

end.
 