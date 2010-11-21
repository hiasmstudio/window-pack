unit hiVBoxLayout;

interface

uses Kol,Share,Debug,WinLayout;

type
  THIVBoxLayout = class(TWinLayout)
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

procedure THIVBoxLayout.adZOrder;
begin
   // do nothing
end;

procedure THIVBoxLayout.adPosition; 
var i:integer;
begin
   for i := FList.Count-1 downto 1 do
     if ItemTop[i] < ItemTop[i-1] then
       FList.Move(i, i-1);
   if Assigned(FLayoutParent) then
     FLayoutParent.Sort;    
end;

procedure THIVBoxLayout.AddObject;
begin
   inherited;
   _prop_AddMode;
end;

procedure THIVBoxLayout.Sort;
begin
   _prop_AddMode;
end;

procedure THIVBoxLayout.ReSize;
var i,y,sp,h:integer;
begin   
   inc(PLeft, _prop_Padding);
   inc(PTop, _prop_Padding);
   dec(PWidth, _prop_Padding*2);
   dec(PHeight, _prop_Padding*2);
   
   sp := PHeight;                
   for i := 0 to FList.Count-1 do 
    if ItemHS[i] = 0 then dec(sp, ItemHeight[i]);
      
   dec(sp, _prop_Space*(FList.Count-1));
   y := PTop;
   for i := 0 to FList.Count-1 do
    with PBoxRecord(FList.Objects[i])^ do
     begin
       if hs > 0 then
          h := Round(sp / 100 * hs)
       else h := ItemHeight[i];
       ItemResize(i, PLeft, y, PWidth, h);
       inc(y, h + _prop_Space);
     end;
end;

end.