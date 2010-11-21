unit hiRecord;

interface

uses Kol,Share,mmsystem,Debug,Windows;

const
  Mono = 1;
  Stereo = 2;

type
  THIRecord = class(TDebug)
   private
    s:array[0..256] of char;
    isOpen, isRun:boolean;
    procedure open;
   public
    _prop_Filename:string;
    _prop_AutoClose:boolean;
    _prop_Bits:integer;
    _prop_Stereo:integer;
    _prop_Speed:integer;

    _data_Filename:THI_Event;
    
    procedure _work_doRecord(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doPause(var _Data:TData; Index:word);
    procedure _work_doResume(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _var_isOpen(var _Data:TData; Index:word);
    procedure _var_isRun(var _Data:TData; Index:word);
  end;

implementation


procedure THIRecord.open;
begin
   if not isOpen then
    begin
      mciSendString('OPEN NEW TYPE WAVEAUDIO ALIAS dlma', nil, 0, 0);
      mciSendString(PChar('SET dlma TIME FORMAT MS ' +
       'BITSPERSAMPLE ' + int2str(_prop_Bits) +
       'CHANNELS ' + int2str(_prop_Stereo) +
       'SAMPLESPERSEC ' + int2str(_prop_Speed) +
       'BYTESPERSEC ' + int2str(round(_prop_Bits*_prop_Stereo*_prop_Speed/8))),
        nil, 0, 0);
   end;
   isOpen:=true;
   isRun:=true;
end;

procedure THIRecord._work_doRecord;
begin
   if not isOpen then open;

   if not isRun then 
      mciSendString('resume dlma ', @s, 255, 0)
   else begin
      mciSendString('record dlma notify', @s, 255, 0);
      isRun:=true
   end;
end;

procedure THIRecord._work_doPause;
begin
   if isOpen and isRun then mciSendString('pause dlma', @s, 255, 0);
   isRun:=false;
end;

procedure THIRecord._work_doSave;
var filename:string;
begin
   filename := ReadFileName( ReadString(_Data,_data_Filename,_prop_Filename) );
   if isOpen then begin
      mciSendString(PChar('save dlma "'+filename+'"'), @s, 255, 0);
      if _prop_AutoClose then begin
         if isOpen then mciSendString('close dlma ', @s, 255, 0);
         isOpen:=false;
         isRun:=false;
      end;
   end;
end;

procedure THIRecord._work_doClose;
begin
   if isOpen then mciSendString('close dlma ', @s, 255, 0);
   isOpen:=false;
   isRun:=false;
end;

procedure THIRecord._work_doResume;
begin
   if isOpen then begin
      if not isRun then mciSendString('resume dlma ', @s, 255, 0);
      isRun:=true;
   end;   
end;

procedure THIRecord._var_isOpen;
begin
    dtInteger(_Data,Integer(isOpen));
end;

procedure THIRecord._var_isRun;
begin
    dtInteger(_Data,Integer(isRun));
end;

end.
