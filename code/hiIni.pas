unit hiINI;

interface

uses Windows,Kol,Share,Debug;

type
   THIini = class(TDebug)
     private
      Ini: PIniFile;
      procedure Open(var _Data:TData;ifm: TIniFileMode);
     public
      _prop_FileName:string;
      _prop_Section:string;
      _prop_Key:string;
      _prop_Type:byte;

      _data_FileName:THI_Event;
      _data_Section:THI_Event;
      _data_Key:THI_Event;
      _data_Value:THI_Event;

     _event_onResult:THI_Event;
     _event_onSectionNames:THI_Event;
     _event_onSectionData:THI_Event;

     procedure _work_doRead(var _Data:TData; Index:word);
     procedure _work_doWrite(var _Data:TData; Index:word);
     procedure _work_doSectionNames(var _Data:TData; Index:word);
     procedure _work_doSectionData(var _Data:TData; Index:word);
     procedure _work_doDeleteKey(var _Data:TData; Index:word);
     procedure _work_doEraseSection(var _Data:TData; Index:word);
     procedure _work_doClearAll(var _Data:TData; Index:word);
   end;

implementation

procedure THIini.Open;
begin
   Ini := OpenIniFile(ReadFileName(ReadString(_Data,_data_FileName,_prop_FileName)));
   Ini.Section := ReadString(_Data,_data_Section,_prop_Section);
   //	ifmRead - флаг для чтения; ifmWrite - флаг для записи
   Ini.Mode := ifm;
end;

procedure THIini._work_doRead;
begin
   Open(_Data,ifmRead);
   if _prop_Type = 0 then
    _hi_CreateEvent(_Data, @_event_onResult,
      Ini.ValueInteger(ReadString(_Data,_data_Key,_prop_Key),0))
   else
     _hi_CreateEvent(_Data, @_event_onResult,
      Ini.ValueString(ReadString(_Data,_data_Key,_prop_Key),''));
   Ini.Free;
end;

procedure THIini._work_doWrite;
begin
   Open(_Data,ifmWrite);
   if _prop_Type = 0 then
     Ini.ValueInteger(ReadString(_Data,_data_Key,_prop_Key),
                     ReadInteger(_Data,_data_Value,0))
   else
     Ini.ValueString(ReadString(_Data,_data_Key,_prop_Key),
                     ReadString(_Data,_data_Value,''));
   Ini.Free;
end;

procedure THIini._work_doSectionNames;
var StrList:PStrList;
    I:integer;
begin
   Open(_Data,ifmRead);
   StrList := NewStrList;
   Ini.GetSectionNames(strList);
   Ini.Free;
   for i := 0 to strList.Count-1 do
     _hi_OnEvent(_event_onSectionNames,strList.Items[i]);
   strList.free;
end;

procedure THIini._work_doSectionData;
var StrList:PStrList;
    I:integer;
begin
   Open(_Data,ifmRead);
   StrList := NewStrList;
   Ini.SectionData(strList);
   Ini.Free;
   for i := 0 to strList.Count-1 do
     _hi_OnEvent(_event_onSectionData,strList.Items[i]);
   strList.free;
end;

procedure THIini._work_doDeleteKey;
begin
   Open(_Data,ifmWrite);
   Ini.ClearKey(ReadString(_Data,_data_Key,_prop_Key));
   Ini.Free;
end;

procedure THIini._work_doEraseSection;
begin
   Open(_Data,ifmWrite);
   Ini.ClearSection;
   Ini.Free;
end;

procedure THIini._work_doClearAll;
begin
   Open(_Data,ifmWrite);
   Ini.ClearAll;
   Ini.Free;
end;

end.
