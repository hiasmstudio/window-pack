unit hiVolumeSmoothing;

interface

uses Kol,Share,Debug;

type
  THIVolumeSmoothing = class(TDebug)
   private
    Res:PStream;
   public
    _prop_Level:integer;

    _data_Stream:THI_Event;
    _event_onResult:THI_Event;

    destructor Destroy; override;
    procedure _work_doSmoothing(var _Data:TData; Index:word);
  end;

implementation

destructor THIVolumeSmoothing.Destroy;
begin
   res.free;
   inherited;
end;

procedure THIVolumeSmoothing._work_doSmoothing;
var st:PStream;
    s:smallint;
    ns:real;
begin
   if res = nil then
     res := newmemoryStream;
   st := ReadStream(_Data, _data_Stream);
   if st = nil then exit;
   
   st.Position := 0;
   res.size := st.size;
   res.position := 0;

   ns := 0;
   while st.position < st.Size do
    begin
       st.Read(s, sizeof(s));
       ns := ns + (s - ns) / _prop_Level;
       s := Round(ns);
       res.write(s, sizeof(s));
    end;  
   res.position := 0; 
   _hi_onEvent(_event_onResult, res); 
end;

end.
