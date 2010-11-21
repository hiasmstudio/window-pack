unit hiGVarContainer;

interface

uses Kol,Share,Debug;

type
  THIGVarContainer = class(TDebug)
   private
    FList:PStrList;
    procedure SetList(const Value:string);
   public
    _prop_Section:string;
    _prop_FileName:string;
    _event_onLoad:THI_Event;
    _data_FileName:THI_Event;
    _data_Section:THI_Event;

    destructor Destroy;override;
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    property _prop_VarList:string write SetList;
  end;

implementation

uses hiGlobalVar;

procedure THIGVarContainer._work_doLoad;
var Ini:PIniFile;
    s,fn:string;
    i:smallint;
begin
    s := ReadString(_Data,_data_Section,_prop_Section);
    fn := ReadFileName( ReadString(_Data,_data_FileName,_prop_FileName) );
    Ini := OpenIniFile(fn);
    Ini.Section := S;
    Ini.Mode := ifmRead;
    for i := 0 to FList.Count-1 do
     begin
      fn := FList.Items[i];
      if pos('=',fn) > 0 then s := gettok(fn,'=')
      else
       begin
        s := fn;
        fn := '';
       end;
      case ForceGVar(s).data_type of
       data_null,data_str: dtString(ForceGVar(s)^,Ini.ValueString(s,fn));
       data_int: dtInteger(ForceGVar(s)^,Ini.ValueInteger(s,str2int(fn)));
       data_real: dtReal(ForceGVar(s)^,str2double(Ini.ValueString(s,fn)));
      end;
     end;
    Ini.Free;
    _hi_CreateEvent(_Data,@_event_onLoad);
end;

procedure THIGVarContainer._work_doSave;
var Ini:PIniFile;
    s,fn:string;
    i:smallint;
begin
    s := ReadString(_Data,_data_Section,_prop_Section);
    fn := ReadFileName( ReadString(_Data,_data_FileName,_prop_FileName) );
    Ini := OpenIniFile(fn);
    Ini.Section := S;
    Ini.Mode := ifmWrite;
    for i := 0 to FList.Count-1 do
     begin
      fn := FList.Items[i];
      if pos('=',fn) > 0 then
       s := gettok(fn,'=')
      else
       begin
         s := fn;
         fn := '';
       end;

      Ini.ValueString(s,ToString(ForceGVar(s)^));
     end;
    Ini.Free;
end;

procedure THIGVarContainer.SetList;
begin
   FList := newstrlist;
   FList.Text := Value;
end;

destructor THIGVarContainer.Destroy;
begin
   FList.free;
   inherited;
end;

end.
