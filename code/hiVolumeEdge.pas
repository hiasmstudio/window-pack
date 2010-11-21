unit hiVolumeEdge;

interface

uses Kol,Share,Debug;

type
  THIVolumeEdge = class(TDebug)
   private
    Res:PStream;
   public
    _prop_Samplings:integer;

    _data_Stream:THI_Event;
    _event_onResult:THI_Event;

    destructor Destroy; override;
    procedure _work_doEdge(var _Data:TData; Index:word);
  end;

implementation

destructor THIVolumeEdge.Destroy;
begin
   res.free;
   inherited;
end;

procedure THIVolumeEdge._work_doEdge;
var st:PStream;
    k,mx,x1,x2,s:smallint;
    last:array of smallint;
begin
   if res = nil then
     res := newmemoryStream;
   st := ReadStream(_Data, _data_Stream);
   if st = nil then exit;
   
   st.Position := 0;
   res.size := st.size div _prop_Samplings;
   res.position := 0;
   SetLength(last, _prop_Samplings);
   k := 0;
   x1 := 0;
   x2 := 0;
   s := 0;
   while st.position < st.Size do
    begin         //last[k]
       st.Read(mx, sizeof(smallint));
//       if k = _prop_Samplings-1 then
        begin
//          mx := 0;
//          repeat
//            if last[k] > mx then mx := last[k];  
//            dec(k);
//          until k = -1;
          
          if(x2 >= x1)and(x2 <= mx)then 
           if x2 > 0 then 
            s := x2
           else s := 0;
          
          res.write(s, sizeof(s));
           
          x1 := x2;
          x2 := mx;            
        end;
       inc(k);
    end;  
   res.position := 0; 
   _hi_onEvent(_event_onResult, res); 
end;

end.
