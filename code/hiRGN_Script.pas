unit hiRGN_Script;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_Script = class(TDebug)
   private
    FRegion:HRGN; 
   public
    _prop_Script:string;

    _data_Script:THI_Event;
    _event_onCreateRgn:THI_Event;

    destructor Destroy; override;
    procedure _work_doCreateRgn(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

destructor THIRGN_Script.Destroy;
begin
   DeleteObject(FRegion);
   inherited;
end;

procedure THIRGN_Script._work_doCreateRgn;
var lst:PStrList;
    i,d:integer;
    s,rn:string;
    p:array of TPoint;
    c:integer;
    r:HRGN;
begin
   DeleteObject(FRegion);
   FRegion := CreateRectRgn(0, 0, 0, 0);
   lst := NewStrList;
   lst.text := ReadString(_data, _data_Script, _prop_Script);
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
      r := 0; 
      if rn = 'rect'    then r := CreateRectRgn(p[0].x, p[0].y, p[1].x, p[1].y);
      if rn = 'ellipse' then r := CreateEllipticRgn(p[0].x, p[0].y, p[1].x, p[1].y);
      if rn = 'round'   then r := CreateRoundRectRgn(p[0].x, p[0].y, p[1].x, p[1].y, p[2].x, p[2].y);
      if rn = 'poly'    then r := CreatePolygonRgn(p[0], c, Winding);        
      CombineRgn(FRegion, FRegion, r, RGN_OR);  
      DeleteObject(r);
    end;
   lst.free;
   _hi_onEvent(_event_onCreateRgn, integer(FRegion));
end;

procedure THIRGN_Script._work_doClear;
begin
  DeleteObject(FRegion);
  FRegion := 0;
end;

procedure THIRGN_Script._var_Result;
begin
   dtInteger(_Data, FRegion);
end;

end.
