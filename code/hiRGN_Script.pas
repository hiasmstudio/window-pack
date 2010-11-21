unit hiRGN_Script;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_Script = class(TDebug)
   private
    FRegion:HRGN; 
    function ParseScript(const sc:string):HRGN;
   public
    _prop_Script:string;

    _data_Script:THI_Event;
    _event_onCreateRgn:THI_Event;

    procedure _work_doCreateRgn(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

function THIRGN_Script.ParseScript;
var lst:PStrList;
    i,d:integer;
    s,rn:string;
    p:array of TPoint;
    c:integer;
    r:HRGN;
begin
   lst := NewStrList;
   lst.text := sc;
   Result := 0;
   for i := 0 to lst.count-1 do
    begin
      s := lst.items[i];
      rn := getTok(s, '(');
      c := 0;
      d := pos(',', s); 
      while d > 0 do
       begin
         inc(c); 
         Setlength(p, c);
         p[c-1].x := str2int(GetTok(s,','));
         d := pos(',', s);
         if d > 0 then
           p[c-1].y := str2int(GetTok(s,','))
         else p[c-1].y := str2int(GetTok(s,')'));          
       end;
       
      if rn = 'rect' then
        r := CreateRectRgn(p[0].x, p[0].y, p[1].x, p[1].y)
      else if rn = 'ellipse' then
        r := CreateEllipticRgn(p[0].x, p[0].y, p[1].x, p[1].y)
      else if rn = 'round' then
        r := CreateRoundRectRgn(p[0].x, p[0].y, p[1].x, p[1].y, p[2].x, p[2].y)
      else if rn = 'poly' then
        r := CreatePolygonRgn(p[0], c, Winding);        
       
      if Result = 0 then
        Result := r
      else CombineRgn(Result, Result, r, RGN_OR);  
    end;
   lst.free;
end;

procedure THIRGN_Script._work_doCreateRgn;
begin
   DeleteObject(FRegion);
   FRegion := ParseScript(ReadString(_data, _data_Script, _prop_Script));
   _hi_onEvent(_event_onCreateRgn, integer(FRegion));
end;

procedure THIRGN_Script._var_Result;
begin
   dtInteger(_Data, FRegion);
end;

end.
