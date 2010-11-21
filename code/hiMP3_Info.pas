unit hiMP3_Info;

interface

uses Kol,Share,Debug;

type
  THIMP3_Info = class(TDebug)
   private
    List:PStrList;
    Arr:PArray;
    function _Get(Var Item:TData; var Val:TData):boolean;
    function _Count:integer;
   public
    _data_FileName:THI_Event;

    destructor Destroy; override;
    procedure _work_doReadInfo(var _Data:TData; Index:word);
    procedure _var_Tags(var _Data:TData; Index:word);
  end;

implementation

destructor THIMP3_Info.Destroy;
begin
   List.free;
   inherited;
end;    

procedure THIMP3_Info._work_doReadInfo;
var
  Buffer: array [1..128] of Char;
  FS:PStream;
  FileName:string;
begin
  FileName := ReadString(_Data,_data_FileName,'');
  if not Assigned(List) then
    List := NewStrList
  else List.Clear;
  FS := NewReadFileStream(FileName);
  try
    FS.Seek(-128,spEnd);
    FS.Read(Buffer, 128);
    if Copy(Buffer, 1, 3) = 'TAG' then
     begin
      {ID}      List.Add( Copy(Buffer, 4,  30) );
      {Titel  } List.Add( Copy(Buffer, 34, 30) );
      {Album  } List.Add( Copy(Buffer, 64, 30) );
      {Year   } List.Add( Copy(Buffer, 94, 4) );
      {Comment} List.Add( Copy(Buffer, 98, 30) );
      {Genre  } List.Add( int2str(Ord(Buffer[128])) );
     end;
  finally
    FS.Free;
  end;
end;

function THIMP3_Info._Get;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < List.Count)then
     begin
        Result := true;
        dtString(Val,List.Items[ind]);
     end
   else Result := false;
end;

function THIMP3_Info._Count;
begin
   Result := List.Count;
end;

procedure THIMP3_Info._var_Tags;
begin
   if Arr = nil then
     Arr := CreateArray(nil,_Get,_Count,nil);

   dtArray(_Data,Arr);
end;

end.
