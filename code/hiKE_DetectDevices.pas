unit hiKE_DetectDevices;

interface

uses windows,Kol,Share,Debug;

type
  THIKE_DetectDevices = class(TDebug)
   private
   public  
    _event_onSearch:THI_Event;
    _event_onEndSearch:THI_Event;

    procedure _work_doSearch(var _Data:TData; Index:word);
  end;

implementation

procedure THIKE_DetectDevices._work_doSearch;
var
    hk:HKEY;
    List,devs:PStrList;
    i,c:smallint;
    s:string;
    dt,d:TData;
    f:PData;
begin
   hk := kol.RegKeyOpenRead(HKEY_LOCAL_MACHINE,'SYSTEM\ControlSet001\Enum\USB');
   List := NewStrList;
   devs := NewStrList;
   kol.RegKeyGetSubKeys(hk,List);
   kol.RegKeyClose(hk);
   c := 0;
   for i := 0 to List.Count-1 do
    begin
      s := 'SYSTEM\ControlSet001\Enum\USB\' + List.Items[i]; 
      hk := kol.RegKeyOpenRead(HKEY_LOCAL_MACHINE,s);
      kol.RegKeyGetSubKeys(hk,devs);
      kol.RegKeyClose(hk);
      
      hk := kol.RegKeyOpenRead(HKEY_LOCAL_MACHINE,s + '\' + devs.Items[0]);
      if kol.RegKeyGetStr(hk, 'Mfg') = 'KERNELCHIP' then
       begin
         dtString(dt, kol.RegKeyGetStr(hk, 'LocationInformation'));
         kol.RegKeyClose(hk);
         hk := kol.RegKeyOpenRead(HKEY_LOCAL_MACHINE,s + '\' + devs.Items[0] + '\Device Parameters');
         s := kol.RegKeyGetStr(hk, 'PortName');
         delete(s,1,3);
         dtInteger(d, str2int(s));
         AddMTData(@dt, @d, f);
         _hi_OnEvent(_event_onSearch, dt);
         FreeData(f);
         inc(c);
       end
      else kol.RegKeyClose(hk); 
    end;
   List.Free;
   devs.free;
   _hi_OnEvent(_event_onEndSearch, c);
end;

end.
