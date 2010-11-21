unit hiVolControl;

interface

uses Kol,Share,Debug,mmsystem,windows;

const
  lsDigital     = MIXERLINE_COMPONENTTYPE_SRC_DIGITAL;
  lsLine        = MIXERLINE_COMPONENTTYPE_SRC_LINE; 
  lsMicrophone  = MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE; 
  lsCompactDisk = MIXERLINE_COMPONENTTYPE_SRC_COMPACTDISC;
  lsTelephone   = MIXERLINE_COMPONENTTYPE_SRC_TELEPHONE;
  lsWaveOut     = MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT; 
  lsAuxiliary   = MIXERLINE_COMPONENTTYPE_SRC_AUXILIARY;
  lsAnalog      = MIXERLINE_COMPONENTTYPE_SRC_ANALOG; 
  lsLast        = MIXERLINE_COMPONENTTYPE_SRC_LAST; 

  Devs:array[0..8] of integer = (lsDigital,lsLine,lsMicrophone,lsCompactDisk,lsTelephone,lsWaveOut,lsAuxiliary,lsAnalog,lsLast);

type
  THIVolControl = class(TDebug)
   private
    VolArr,MuteArr:PArray;
    nMixerDevs:integer;

    procedure _volSet(var Item:TData; var Val:TData);
    function _volGet(Var Item:TData; var Val:TData):boolean;
    function _volCount:integer;
    procedure _muteSet(var Item:TData; var Val:TData);
    function _muteGet(Var Item:TData; var Val:TData):boolean;
   public
    _prop_Device:integer;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doVolume(var _Data:TData; Index:word);
    procedure _work_doMute(var _Data:TData; Index:word);
    procedure _var_Volume(var _Data:TData; Index:word);
    procedure _var_Mute(var _Data:TData; Index:word);
  end;

implementation

//MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE

function GetLineControlsID(Dev:integer; lc:cardinal; var ID:cardinal):HMIXER;
var
  mxlc: MIXERLINECONTROLS;
  mxc: MIXERCONTROL;
  mxl: TMixerLine;
begin
 Result := 0;
 if mixerGetNumDevs() < 1 then
   Exit;

 // open the mixer 
 if mixerOpen(@Result, 0, 0, 0, 0) = MMSYSERR_NOERROR then
  begin
   mxl.dwComponentType := dev;
   mxl.cbStruct := SizeOf(mxl);
 
   // get line info
   if mixerGetLineInfo(Result, @mxl, MIXER_GETLINEINFOF_COMPONENTTYPE) = MMSYSERR_NOERROR then
    begin
     ZeroMemory(@mxlc, SizeOf(mxlc));
     mxlc.cbStruct := SizeOf(mxlc);
     mxlc.dwLineID := mxl.dwLineID;
     mxlc.dwControlType := lc;
     mxlc.cControls := 1;
     mxlc.cbmxctrl := SizeOf(mxc);
     mxlc.pamxctrl := @mxc;
 
     if mixerGetLineControls(Result, @mxlc, MIXER_GETLINECONTROLSF_ONEBYTYPE) = MMSYSERR_NOERROR then
       ID := mxc.dwControlID
    end;
  end;
end;

procedure SetDeviceVolume(Dev:integer; bValue: Word);
var {0..65535}
  hMix: HMIXER;
  mxcd: TMIXERCONTROLDETAILS;
  vol: TMIXERCONTROLDETAILS_UNSIGNED;
begin
   ZeroMemory(@mxcd, SizeOf(mxcd));
   hMix := GetLineControlsID(Dev, MIXERCONTROL_CONTROLTYPE_VOLUME, mxcd.dwControlID);
   if hMix > 0 then
    begin
      mxcd.cbStruct := SizeOf(mxcd);
      mxcd.cMultipleItems := 0;
      mxcd.cbDetails := SizeOf(Vol);
      vol.dwValue := bValue;
      mxcd.paDetails := @vol;
      mxcd.cChannels := 1;
      mixerSetControlDetails(hMix, @mxcd,MIXER_SETCONTROLDETAILSF_VALUE);
      mixerClose(hMix);
    end;
end;

function GetDeviceVolume(Dev:integer):integer;
var {0..65535}
  hMix: HMIXER;
  mxcd: TMIXERCONTROLDETAILS;
  vol: TMIXERCONTROLDETAILS_UNSIGNED;
begin
   ZeroMemory(@mxcd, SizeOf(mxcd));
   hMix := GetLineControlsID(Dev, MIXERCONTROL_CONTROLTYPE_VOLUME, mxcd.dwControlID);
   if hMix > 0 then
    begin
      mxcd.cbStruct := SizeOf(mxcd);
      mxcd.cMultipleItems := 0;
      mxcd.cbDetails := SizeOf(Vol);
      mxcd.paDetails := @vol;
      mxcd.cChannels := 1;
      mixerGetControlDetails(hMix, @mxcd,MIXER_GETCONTROLDETAILSF_VALUE);
      mixerClose(hMix);
      Result := vol.dwValue;
    end
   else Result := -1;
end;


procedure SetMixerLineSourceMute(Dev: integer; bMute: Boolean);
var
  hMix: HMIXER;
  mxcd: TMIXERCONTROLDETAILS;
  mcdMute: MIXERCONTROLDETAILS_BOOLEAN;
begin
   ZeroMemory(@mxcd, SizeOf(mxcd));
   hMix := GetLineControlsID(Dev, MIXERCONTROL_CONTROLTYPE_MUTE, mxcd.dwControlID);
   if hMix > 0 then
    begin
      mxcd.cbStruct := SizeOf(TMIXERCONTROLDETAILS);
      mxcd.cChannels := 1;
      mxcd.cbDetails := SizeOf(MIXERCONTROLDETAILS_BOOLEAN);
      mcdMute.fValue := Ord(bMute);
      mxcd.paDetails := @mcdMute;

      mixerSetControlDetails(hMix, @mxcd, MIXER_SETCONTROLDETAILSF_VALUE);
      mixerClose(hMix);
    end
end;

function GetMixerLineSourceMute(Dev: integer):integer;
var
  hMix: HMIXER;
  mxcd: TMIXERCONTROLDETAILS;
  mcdMute: MIXERCONTROLDETAILS_BOOLEAN;
begin
   ZeroMemory(@mxcd, SizeOf(mxcd));
   hMix := GetLineControlsID(Dev, MIXERCONTROL_CONTROLTYPE_MUTE, mxcd.dwControlID);
   if hMix > 0 then
    begin
      mxcd.cbStruct := SizeOf(TMIXERCONTROLDETAILS);
      mxcd.cChannels := 1;
      mxcd.cbDetails := SizeOf(MIXERCONTROLDETAILS_BOOLEAN);
      mxcd.paDetails := @mcdMute;

      mixerGetControlDetails(hMix, @mxcd, MIXER_GETCONTROLDETAILSF_VALUE);
      mixerClose(hMix);
      Result := mcdMute.fValue;
    end
   else Result := 0;
end;

constructor THIVolControl.Create;
begin
   inherited;
   nMixerDevs := 9; // mixerGetNumDevs();
end;

destructor THIVolControl.Destroy;
begin
   dispose(volarr);
   dispose(mutearr);
   inherited;
end;

procedure THIVolControl._volSet;
begin
  SetDeviceVolume(Devs[ToInteger(Item)+1],ToInteger(Val));
end;

function THIVolControl._volGet;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < nMixerDevs)then
     begin
        Result := true;
        dtInteger(Val,GetDeviceVolume(Devs[ind]));
     end
   else Result := false;
end;

function THIVolControl._volCount;
begin
   Result := nMixerDevs;
end;

procedure THIVolControl._muteSet;
begin
  SetMixerLineSourceMute(Devs[ToInteger(Item)+1],ReadBool(Val));
end;

function THIVolControl._muteGet;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < nMixerDevs)then
     begin
        Result := true;
        dtInteger(Val,GetMixerLineSourceMute(Devs[ind]));
     end
   else Result := false;
end;

procedure THIVolControl._work_doVolume(var _Data:TData; Index:word);
begin
  SetDeviceVolume(_prop_Device,ToInteger(_Data));
end;

procedure THIVolControl._work_doMute(var _Data:TData; Index:word);
begin
   SetMixerLineSourceMute(_prop_Device,ReadBool(_Data));
end;

procedure THIVolControl._var_Volume;
begin
   if VolArr = nil then
      VolArr := CreateArray(_volSet,_volGet,_volCount,nil);
   dtArray(_Data,VolArr);
end;

procedure THIVolControl._var_Mute;
begin
   if MuteArr = nil then
      MuteArr := CreateArray(_MuteSet,_MuteGet,_volCount,nil);
   dtArray(_Data,MuteArr);
end;

end.
