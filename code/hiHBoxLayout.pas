unit hiHBoxLayout;

interface

uses Kol,Share,Debug,WinLayout;

type
  THIHBoxLayout = class(TWinLayout)
   protected
    procedure Sort; override;    
    procedure AddObject(otype:byte; obj:pointer; ws, hs:integer); override;
   public
    _prop_AddMode:procedure of object;
    
    procedure ReSize(PLeft, PTop, PWidth, PHeight:integer); override;
    procedure adZOrder;
    procedure adPosition; 
  end;

implementation

procedure THIHBoxLayout.adZOrder;
begin
   // do nothing
end;

procedure THIHBoxLayout.adPosition; 
var i:integer;
begin
   for i := FList.Count-1 downto 1 do
     if ItemLeft[i] < ItemLeft[i-1] then
       FList.Move(i, i-1);
   if Assigned(FLayoutParent) then
     FLayoutParent.Sort;    
end;

procedure THIHBoxLayout.AddObject;
begin
   inherited;
   _prop_AddMode;
end;

procedure THIHBoxLayout.Sort;
begin
   _prop_AddMode;
end;

procedure THIHBoxLayout.ReSize;
var i,x,sp,w:integer;
begin
   inc(PLeft, _prop_Padding);
   inc(PTop, _prop_Padding);
   dec(PWidth, _prop_Padding*2);
   dec(PHeight, _prop_Padding*2);

   sp := PWidth;                
   for i := 0 to FList.Count-1 do
     if ItemWS[i] = 0 then dec(sp, ItemWidth[i]);
      
   dec(sp, _prop_Space*(FList.Count-1));
   x := PLeft;
   for i := 0 to FList.Count-1 do
    with PBoxRecord(FList.Objects[i])^ do
     begin
       if ws > 0 then
          w := Round(sp / 100 * ws)
       else w := ItemWidth[i];
       ItemResize(i, x, PTop, w, PHeight);
       inc(x, w + _prop_Space);
     end;
end;

end.
