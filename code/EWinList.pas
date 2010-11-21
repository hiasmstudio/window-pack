unit EWinList;

interface

uses Kol,Share,WinList,Windows,Debug,Messages;

type
 THIEWinList = class(THIWinList)
   protected
    procedure SetStrings(const Value:string); override;
   public
    procedure _work_doLoad(var _Data:TData; Index:word);
 end;

implementation

procedure THIEWinList._work_doLoad;
var
   fn:string;
   Strm: PStream;
   Text: string;
begin
   fn := ReadString(_Data,_data_FileName,_prop_FileName);
   if FileExists(fn) then
    begin
     Strm := NewReadFileStream(fn);
     SetLength(Text, Strm.Size);
     Strm.Read(Text[1], Strm.Size);
     SetStrings(Text);
     Strm.free;
     _hi_CreateEvent(_Data,@_event_onChange);
    end;
end;

procedure THIEWinList.SetStrings;
begin
  SetStringsBefore(Length(Value));
  Control.Perform(WM_SETTEXT, 0, Longint(@Value[1]));
  SetStringsAfter;
end;

end.