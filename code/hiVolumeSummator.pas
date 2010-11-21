unit hiVolumeSummator;

interface

uses Kol,Share,Debug;

type
  THIVolumeSummator = class(TDebug)
   private
    Res:PStream;
   public
    _prop_Level:integer;
    _prop_Mode:procedure(st:PStream) of object;

    _data_Stream:THI_Event;
    _event_onResult:THI_Event;

    destructor Destroy; override;
    procedure _work_doSumm(var _Data:TData; Index:word);
    
    procedure Samples(st:PStream);
    procedure Blur(st:PStream);
  end;

implementation

destructor THIVolumeSummator.Destroy;
begin
   res.free;
   inherited;
end;

procedure THIVolumeSummator._work_doSumm;
var st:PStream;
begin
   if res = nil then
     res := newmemoryStream;
   st := ReadStream(_Data, _data_Stream);
   if st = nil then exit;
   st.Position := 0;
   _prop_Mode(st);
   res.position := 0; 
   _hi_onEvent(_event_onResult, res); 
end;

procedure THIVolumeSummator.Samples; 
var 
    s:smallint;
    i,sum:integer;
begin
   i := 0;
   sum := 0;
   res.size := st.size div _prop_Level;
   res.position := 0; 
   while st.position < st.Size do
    begin
       st.Read(s, sizeof(s));
       inc(sum, s);
       inc(i);
       if i = _prop_Level then
        begin
          i := 0;
          s := round(sum/_prop_Level);
          sum := 0;
          res.write(s, sizeof(s));
        end;
    end;  
end;

procedure THIVolumeSummator.Blur;
var k,s:integer;
    arr:array of smallint;
    i:smallint;
begin
   res.size := st.size;
   res.position := 0;
   k := 0; 
   setlength(arr, _prop_Level);
   while st.position < st.Size do
    begin
       st.Read(arr[k], sizeof(smallint));
       s := 0;
       for i := 0 to k do
         s := s + arr[i];
       i := s div (k+1);
       res.write(i, sizeof(i));    
       if k < _prop_Level-1 then
        inc(k)
       else
         for i := 0 to k-1 do
           arr[i] := arr[i+1];
    end;  
end; 

end.
