unit hiToolBarLayout;

interface

uses Kol,Share,Debug,WinLayout;

type
  THIToolBarLayout = class(TWinLayout)
   private
    procedure Sort; override;    
    procedure AddObject(otype:byte; obj:pointer; ws, hs:integer); override;
   public
    _prop_AutoSize:boolean;
    _prop_AddMode:procedure of object;
     
    procedure ReSize(PLeft, PTop, PWidth, PHeight:integer); override; 
    procedure adZOrder;
    procedure adPosition; 
  end;

implementation

procedure THIToolBarLayout.adZOrder;
begin
   // do nothing
end;

procedure THIToolBarLayout.adPosition; 
var i:integer;
    ok:boolean;
begin
   // sort by y
   repeat
       ok := false;
       for i := FList.Count-1 downto 1 do
         if ItemTop[i] < ItemTop[i-1] then
           begin FList.Move(i, i-1); ok := true; end;
   until not ok;
   // sort by x
   repeat
       ok := false;
       for i := FList.Count-1 downto 1 do
         if( abs(ItemTop[i] - ItemTop[i-1]) < ItemHeight[i] div 2 )and(ItemLeft[i] < ItemLeft[i-1]) then
           begin FList.Move(i, i-1); ok := true; end;
   until not ok;              
   if Assigned(FLayoutParent) then
     FLayoutParent.Sort;    
end;

procedure THIToolBarLayout.AddObject;
begin
   inherited;
   _prop_AddMode;
end;

procedure THIToolBarLayout.Sort;
begin
   _prop_AddMode;
end;

procedure THIToolBarLayout.ReSize;
var i,x,y,h:integer;
begin   
   inc(PLeft, _prop_Padding);
   inc(PTop, _prop_Padding);
   dec(PWidth, _prop_Padding*2);
   dec(PHeight, _prop_Padding*2);
   
   x := PLeft;
   y := PTop;
   h := 0;
   for i := 0 to FList.Count-1 do
    with PBoxRecord(FList.Objects[i])^ do
     if otype = OBJ_CONTROL then 
      with PControl(obj){$ifndef F_P}^{$endif} do
       begin
         if(x > PLeft)and(x + Width - PLeft > PWidth) then
          begin
           x := PLeft;
           inc(y, h + _prop_Space);
           h := 0;
          end;
         Left := x;
         Top := y;
         inc(x, Width + _prop_Space);
         if Height > h then
          h := Height;
       end
     else
      with TWinLayout(obj) do
       begin         
         {ReSize(x, y, Width, Height);
         inc(x, Width + _prop_Space);
         if Height > h then
           h := Height;
         if x > PWidth then
          begin
           x := PLeft;
           inc(y, h + _prop_Space);
           h := 0;
          end; }
       end;   
   if _prop_AutoSize then
     FParent.ClientHeight := y + h + _prop_Padding;     
end;

end.
