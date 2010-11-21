unit LWinList;

interface

uses Kol,Share,WinList,Windows,Debug,Messages;

type
 THILWinList = class(THIWinList)
   protected
    procedure SetStrings(const Value:string); override;
   public
    procedure _work_doLoad(var _Data:TData; Index:word);
 end;

implementation

procedure THILWinList._work_doLoad;
var
   fn, s:string;
   F: TextFile;
   fsz: cardinal;
   BufIn : Array[0..65535] of Char;
begin
   fn := ReadString(_Data,_data_FileName,_prop_FileName);
   if FileExists(fn) then
   begin
     fsz := FileSize(fn);
     if fsz > 0 then
     begin
       SetStringsBefore(fsz);
       AssignFile(F, fn);
       Reset(F);
       SetTextBuf(F, BufIn);
       while not eof(F) do
       begin
         Readln(F, s);
         Add(s);
       end;
       CloseFile(F);
       SetStringsAfter;
     end;
     _hi_CreateEvent(_Data,@_event_onChange);
   end;
end;

procedure THILWinList.SetStrings;
var
   List:PStrList;
   i:integer;
begin
  SetStringsBefore(Length(Value));
  if Value <> '' then
  begin
    List := NewStrList;
    List.SetText(Value, false);
    for i := 0 to List.Count-1 do
       Add(List.Items[i]);
    List.free;
  end;
  SetStringsAfter;
end;

end.