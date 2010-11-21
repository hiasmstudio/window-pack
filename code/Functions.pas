unit Functions;

interface

uses Share,kol,Script,windows,mmsystem,Messages;

type
  TFunctions = class
    private
     FList:PStrListEx;
     //____________________________________
     function _Message(Args:TRealFuncArg):TData;
     function _Beep(Args:TRealFuncArg):TData;
     function _PlaySound(Args:TRealFuncArg):TData;
     function _TickCount(Args:TRealFuncArg):TData;
     function _Time(Args:TRealFuncArg):TData;

     //______________FILES______________________
     function IsFHandle(f:cardinal):boolean;
     procedure FHandleDelete(f:cardinal);

     function _OpenFile(Args:TRealFuncArg):TData;
     function _ReadString(Args:TRealFuncArg):TData;
     function _WriteString(Args:TRealFuncArg):TData;
     function _CloseFile(Args:TRealFuncArg):TData;
     function _Eof(Args:TRealFuncArg):TData;
     function _FileExists(Args:TRealFuncArg):TData;

     //_____________STRINGS_______________________
     function _Pos(Args:TRealFuncArg):TData;
     function _Copy(Args:TRealFuncArg):TData;
     function _Delete(Args:TRealFuncArg):TData;
     function _Replace(Args:TRealFuncArg):TData;
     function _Len(Args:TRealFuncArg):TData;
     function _StrTok(Args:TRealFuncArg):TData;

     function _SendMessage(Args:TRealFuncArg):TData;
     function _PostMessage(Args:TRealFuncArg):TData;
     function _SetWindowText(Args:TRealFuncArg):TData;
     function _GetWindowText(Args:TRealFuncArg):TData;
     function _GetActiveWindow(Args:TRealFuncArg):TData;
     function _WinExec(Args:TRealFuncArg):TData;

     function _Int(Args:TRealFuncArg):TData;
     function _Str(Args:TRealFuncArg):TData;
     function _Real(Args:TRealFuncArg):TData;
     //function _(Args:TRealFuncArg):TData;

     function _CreateThread(Args:TRealFuncArg):TData;
     function _AppMessages(Args:TRealFuncArg):TData;
    public
     constructor Create;
  end;

  function ToInteger(const Data:PData):integer;
  function ToString(const Data:PData):string;
  function ToReal(const Data:PData):real;

implementation

constructor TFunctions.Create;
begin
   inherited Create;
   {
   with GOop do
    begin
      with Add('User').Obj do
       begin
         AddProperty('Name',_Name);
         AddProperty('Mail',_Mail);
         AddProperty('Site',_Site);
       end;
    end;
   } 
   with RFuncs do
    begin
      Add('Message',_Message,['Text']);  
      Add('Beep',_Beep,['Freq','Delay']);  
      Add('PlaySound',_PlaySound,['FileName']); 
      Add('TickCount',_TickCount,['']);
      Add('Time',_Time,['Mask']);
      
      Add('fopen',_OpenFile,['FileName','Mode']);
      Add('fgets',_ReadString,['Handle']);
      Add('fputs',_WriteString,['Handle','Text']);
      Add('fclose',_CloseFile,['Handle']);
      Add('feof',_Eof,['Handle']);
      Add('FileExists',_FileExists,['FileName']);
      
      Add('Pos',_Pos,['SubStr','DestStr']);
      Add('Copy',_Copy,['DestStr','Start','Count']);
      Add('Delete',_Delete,['@DestStr','Start','Count']);
      Add('Replace',_Replace,['@DestStr','SubStr','RepStr']);
      Add('Len',_Len,['Str']);
      Add('StrTok',_StrTok,['@Str','Char']);
         
      //Add('SendMessage',_SendMessage,['Handle','Msg','wParam','lParam']);
      //Add('PostMessage',_PostMessage,['Handle','Msg','wParam','lParam']);
      //Add('SetWindowText',_SetWindowText,['Handle','Text']);
      //Add('GetWindowText',_GetWindowText,['Handle']);
      Add('GetActiveWindow',_GetActiveWindow,['']);
      Add('WinExec',_WinExec,['FileName','Param','Mode']);

      Add('Int',_Int,['Value']);
      Add('Str',_Str,['Value']);
      Add('Real',_Real,['Value']);

      Add('AppMessages',_AppMessages,['']);
    end;
  
   with Def do
    begin
     //Add('WM_CLOSE',WM_CLOSE);
     //Add('WM_KEYDOWN',WM_KEYDOWN);
     //Add('WM_USER',WM_USER);
     Add('FM_READ',0);
     Add('FM_WRITE',1);
     Add('FM_APPEND',2);

     Add('SW_NORMAL',SW_NORMAL);
     Add('SW_SHOWNOACTIVATE',SW_SHOWNOACTIVATE);
    end;
end;

function ToInteger(const Data:PData):integer;
begin
   case Data.data_type of
    data_int: Result := data.idata;
    data_str: Result := str2int(data.sdata);
    data_real: Result := Round(Data.rdata);
    else Result := 0;
   end;
end;

function ToString(const Data:PData):string;
begin
   case Data.data_type of
    data_int: Result := int2str(data.idata);
    data_str: Result := data.sdata;
    data_real: Result := double2str(Data.rdata);
    else Result := '';
   end;
end;

function ToReal(const Data:PData):real;
begin
   case Data.data_type of
    data_int: Result := data.rdata;
    data_str: Result := str2double(data.sdata);
    data_real: Result := Data.rdata;
    else Result := 0;
   end;
end;

function TFunctions._Message;
var s:string;
begin
   case Args[0].Data_type of
    0: s := 'NULL';
    1: s := int2str(Args[0].idata);
    2: s := Args[0].sdata;
    3: s := Double2Str(Args[0].rdata);
   end;
   MessageBox(0,PChar(s),'Info',MB_OK);
end;

function TFunctions._Beep;
var f:integer;
begin
   f := ToInteger(Args[0]);
   if f = 0 then
     sleep(ToInteger(Args[1]))
   else  Beep(f,ToInteger(Args[1]));
end;

function TFunctions._PlaySound;
begin
  PlaySound(PChar(ToString(Args[0])),0,1);
end;

function TFunctions._TickCount;
begin
  Result.data_type := data_int;
  Result.idata := timeGetTime;
end;

function GetTime(const Mask:string):string;
const namstr:string = 'YMWDhms';
type TTimeValue = array[0..6] of WORD;
     PTimeValue = ^TTimeValue;
var
  SystemTime: TSystemTime;
  i:byte;
  function TwoDigit(value:integer):string;
  begin
    if Value < 10 then
      Result := '0' + Int2Str(value)
    else Result := Int2Str(value);
  end;
begin
   GetLocalTime(SystemTime);
   Result := Mask;
   for i := 0 to 6 do
     Replace(Result,namstr[i+1],TwoDigit(PTimeValue(@SystemTime)^[i]));
end;

function TFunctions._Time;
begin
   Result.data_type := data_str;
   Result.sdata := GetTime(ToString(Args[0]));
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ FILES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function TFunctions.IsFHandle;
var i:word;
begin
   Result := false;
   if FList.Count > 0 then
    for i := 0 to FList.Count-1 do
     if FList.Objects[i] = f then
      begin
        Result := true;
        break;
      end;
end;

procedure TFunctions.FHandleDelete;
var i:word;
begin
   if FList.Count > 0 then
    for i := 0 to FList.Count-1 do
     if FList.Objects[i] = f then
      begin
        FList.Delete(i);
        break;
      end;
end;

function TFunctions._OpenFile;
var
    f:^TextFile;
begin
   new(f);
   Result.data_type := data_int;
   Result.idata := integer(f);
   AssignFile(f^,ToString(Args[0]));
   case ToInteger( Args[1] ) of
    0: Reset(f^);
    1: Rewrite(f^);
    2: Append(f^);
   end;
   if FList = nil then
    FList := NewStrListEx;
   FList.AddObject('',cardinal(f));
end;

function TFunctions._ReadString;
var
  f:^TextFile;
begin
   f := pointer(ToInteger(Args[0]));
   if IsFHandle(cardinal(f)) then
    begin
     Result.data_type := data_str;
     Readln(f^,Result.sdata);
    end
   else ;
end;

function TFunctions._WriteString;
var
    f:^TextFile;
begin
   f := pointer(ToInteger(Args[0]));
   if IsFHandle(cardinal(f)) then
     WriteLn(f^,ToString(Args[1]))
   else ;
end;

function TFunctions._CloseFile;
var  f:^TextFile;
begin
   f := pointer(ToInteger(Args[0]));
   if IsFHandle(cardinal(f)) then
    begin
     CloseFile(f^);
     Dispose(f);
     FHandleDelete(cardinal(f));
    end
   else ;
end;

function TFunctions._Eof;
var  f:^TextFile;
begin
  f := pointer(ToInteger(Args[0]));
  if IsFHandle(cardinal(f)) then
   begin
    Result.idata := integer(eof(f^));
    Result.data_type := data_int;
   end
  else ;
end;

function TFunctions._FileExists;
begin
  Result.Data_type := data_int;
  Result.idata := integer(FileExists(ToString(Args[0])));
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ STRING ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function TFunctions._Pos;
begin
   Result.Data_type := data_int;
   Result.idata := Pos(ToString(Args[0]),ToString(Args[1]));
end;

function TFunctions._Copy;
begin
   Result.Data_type := data_str;
   Result.sdata := copy(ToString(Args[0]),ToInteger(Args[1]),ToInteger(Args[2]));
end;

function TFunctions._Delete;
begin
   Result.Data_type := data_str;
   Result.sdata := ToString(Args[0]);
   delete(Result.sdata,ToInteger(Args[1]),ToInteger(Args[2]));
end;

function TFunctions._Replace;
begin
   Result.Data_type := data_str;
   Result.sdata := ToString(Args[0]);
   Replace(Result.sdata,ToString(Args[1]),ToString(Args[2]));
end;

function TFunctions._Len;
begin
   Result.Data_type := data_int;
   Result.idata := Length(ToString(Args[0]));
end;

function TFunctions._StrTok;
var s:string;
begin
   Result.data_type := data_str;
   if Args[0].data_type <> data_str then
    begin
      Args[0].sdata := ToString(Args[0]);
      Args[0].data_type := data_str;
    end;
   s := ToString(Args[1]);
   if s = '' then
    s := ' ';
   Result.sdata := GetTok(Args[0].sdata,s[1]);
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ STRING ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function TFunctions._SendMessage;
begin
   SendMessage(ToInteger(Args[0]),ToInteger(Args[1]),ToInteger(Args[2]),ToInteger(Args[3]))
end;

function TFunctions._PostMessage;
begin
   PostMessage(ToInteger(Args[0]),ToInteger(Args[1]),ToInteger(Args[2]),ToInteger(Args[3]))
end;

function TFunctions._SetWindowText;
begin
   SetWindowText(ToInteger(Args[0]),PChar(toString(Args[1])));
end;

function TFunctions._GetWindowText;
begin
   Result.Data_type := data_str;
   SetLength(Result.sdata,300);
   SetLength(Result.sdata,GetWindowText(ToInteger(Args[0]),PChar(@Result.sdata[1]),300))
end;

function TFunctions._GetActiveWindow;
begin
   Result.Data_type := data_int;
   Result.idata := GetForegroundWindow;
end;

function TFunctions._WinExec;
begin
   WinExec(PChar(ToString(Args[0]) + ' ' + ToString(Args[1])),ToInteger(Args[2]));
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ TYPE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function TFunctions._Int;
begin
   Result.Data_type := data_int;
   Result.idata := ToInteger(Args[0]);
end;

function TFunctions._Str;
begin
   Result.Data_type := data_str;
   Result.sdata := ToString(Args[0]);
end;

function TFunctions._Real;
begin
   Result.Data_type := data_real;
   Result.rdata := ToReal(Args[0]);
end;

function TFunctions._CreateThread;
begin
  //CreateThread(nil,1024,_Proc,nil,0,)
end;

function TFunctions._AppMessages;
begin
   if Applet <> nil then
     Applet.ProcessMessages;
end;

end.
