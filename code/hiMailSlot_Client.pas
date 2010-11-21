unit hiMailSlot_Client;

interface

uses Kol,Share,Windows,Debug;

type
  THIMailSlot_Client = class(TDebug)
   private
   lol:string;
   public
    _prop_Name:string;
    _data_Name:THI_Event;
    _prop_Computer:string;

    _data_Text:THI_Event;
    _data_Computer:THI_Event;
    _event_onStatus:THI_Event;

    procedure _work_doWrite(var _Data:TData; Index:word);
  end;

implementation

procedure THIMailSlot_Client._work_doWrite;
var hf:cardinal;
    nBytesRead:cardinal;
    Comp,Text:string;
begin
   Text := ReadString(_Data,_data_Text,'');
   Comp := ReadString(_Data,_data_Computer,_prop_Computer);
   lol:= ReadString(_Data,_data_Name,_prop_Name);
   hf := CreateFile(PChar('\\'+Comp+'\mailslot\' + lol),GENERIC_WRITE,
      FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
   if hf <> INVALID_HANDLE_VALUE then
      _hi_OnEvent(_event_onStatus,byte(WriteFile(hf,Text[1],Length(Text),nBytesRead,nil)))
   else
      _hi_OnEvent(_event_onStatus,0);
   CloseHandle(hf);
end;

end.
