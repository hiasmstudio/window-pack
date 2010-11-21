unit hiGridLayout;

interface

uses Kol,Share,Debug,WinLayout;

{$I def.inc}

type
  THIGridLayout = class(TWinLayout)
   private
    procedure Sort; override;    
    procedure AddObject(otype:byte; obj:pointer; ws, hs:integer); override;
   public
    _prop_Rows:integer;
    _prop_Cols:integer;
    _prop_AddMode:procedure of object;
     
    procedure ReSize(PLeft, PTop, PWidth, PHeight:integer); override; 
    procedure adZOrder;
    procedure adPosition; 
  end;

implementation

procedure THIGridLayout.adZOrder;
begin
   // do nothing
end;

procedure THIGridLayout.adPosition; 
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

procedure THIGridLayout.AddObject;
begin
   inherited;
   _prop_AddMode;
end;

procedure THIGridLayout.Sort;
begin
   _prop_AddMode;
end;

procedure THIGridLayout.ReSize;
var i,j,x,y,spx,spy,w,h:integer;
begin
   {$ifdef _PROTECT_MAX_}
   if _prop_Cols < 1 then exit;
   {$endif}
   
   inc(PLeft, _prop_Padding);
   inc(PTop, _prop_Padding);
   dec(PWidth, _prop_Padding*2);
   dec(PHeight, _prop_Padding*2);

   spx := PWidth;                
   for i := 0 to min(FList.Count, _prop_Cols)-1 do
     if ItemWS[i] = 0 then dec(spx, ItemWidth[i]);
   spy := PHeight;                
   if FList.Count > 0 then
     for i := 0 to (FList.Count-1) div _prop_Cols do
       if ItemHS[i*_prop_Cols] = 0 then dec(spy, ItemHeight[i*_prop_Cols]);              
           
   dec(spx, _prop_Space*(_prop_Cols-1));
   dec(spy, _prop_Space*(FList.Count div _prop_Cols - 1));
   x := PLeft;
   for i := 0 to min(FList.Count, _prop_Cols)-1 do
    begin
      if ItemWS[i] > 0 then
        w := Round(spx / 100 * ItemWS[i])
      else w := ItemWidth[i];

      y := PTop;
      for j := 0 to FList.Count div _prop_Cols do
        if j*_prop_Cols + i < FList.Count then  
           with PBoxRecord(FList.Objects[j*_prop_Cols + i])^ do
             begin
                 if ItemHS[j*_prop_Cols] > 0 then
                   h := Round(spy / 100 * ItemHS[j*_prop_Cols])
                 else h := ItemHeight[j*_prop_Cols];
                 ItemResize(j*_prop_Cols + i, x, y, w, h);
                 inc(y, h + _prop_Space);     
             end;
      inc(x, w + _prop_Space);     
    end;  
end;

end.
