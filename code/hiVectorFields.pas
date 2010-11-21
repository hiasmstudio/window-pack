unit hiVectorFields;

interface

uses Kol,Share,Debug;

type
  TOffset = record
    X,Y: ShortInt;
    I0, I1, I2, I3: Byte;
  end;
  PByte = ^byte;
  THIVectorFields = class(TDebug)
   private
     MaxX, MaxY, HalfX, HalfY:integer;
     
     ScanLine1, ScanLine2:array of Integer;
     A,A2:array of array of TOffset;

     Bitm1,Bitm2:PBitmap;

     procedure GenerateOffsets(LineNumber:Integer);
     procedure InitAll;
     procedure ProcessWaves;
     
     procedure SetHeight(value:integer);
   public
    _prop_Mode:byte;
    _prop_Width:integer;

    _event_onProcess:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doProcess(var _Data:TData; Index:word);
    procedure _work_doMode(var _Data:TData; Index:word);
    procedure _work_doWidth(var _Data:TData; Index:word);
    procedure _work_doHeight(var _Data:TData; Index:word);
    procedure _var_Bitmap(var _Data:TData; index:word);
    property _prop_Height:integer write SetHeight;
  end;

implementation

uses hiMathParse;

constructor THIVectorFields.Create;
begin
  inherited;

end;

destructor THIVectorFields.Destroy;
begin
   Bitm1.Free;   
   Bitm2.Free;
   inherited;
end;

procedure THIVectorFields.SetHeight(value:integer);
var i:integer;
begin
  Bitm1 := newbitmap(_prop_Width, value);
  Bitm1.PixelFormat := pf24bit;
  Bitm2 := newbitmap(_prop_Width, value);
  Bitm2.PixelFormat := pf24bit;
    
  MaxX := _prop_Width-1;
  MaxY := value-1;
  HalfX := MaxX div 2 + 1;
  HalfY := MaxY div 2 + 1;
  
  SetLength(ScanLine1, MaxY + 1);
  SetLength(ScanLine2, MaxY + 1);
  
  SetLength(A, MaxY + 1);
  SetLength(A2, MaxY + 1);
  for i := 0 to MaxY do
    begin
      SetLength(A[i], MaxX + 1);
      SetLength(A2[i], MaxX + 1);
    end;

  InitAll;
end;

function Abs(r:real):real; begin if r < 0 then Result := -1 else result := r end;

procedure THIVectorFields.GenerateOffsets(LineNumber:Integer);
var f:Integer;
    d,r,fX,fY, dx,dy, HI, VI:Single;
    flag:boolean;
begin
   if (LineNumber>MaxY) or (LineNumber<0) then EXIT;

   fY:=(LineNumber-HalfY)/(MaxX+1);
   for f:=0 to MaxX do
    begin
      with A2[LineNumber,f] do
      begin
        fX:=(f-HalfX)/(MaxX+1);
        //------------------------------------------------------------------------
        r:=Sqrt(Sqr(fX)+Sqr(fY));
        case _prop_Mode of
         0:begin
            {d}dx:=10*(r*fx)-1;
            {d}dy:=20*r*fy;
           end;
         1:begin
            {\}dx:=fx -fY/Sqr(r+0.1)*12 +fY/(r+0.1)*32 -1;// ROTATION
            {\}dy:=fy +fX/Sqr(r+0.1)*12 -fX/(r+0.1)*32 ;
           end;
         2:begin
            {5}d:=(Arctan2(fy,fx+0.00001)); // STAR and ROTATION
            {5}dx:=-23*fx*(1.1-Abs(Sin(d*4)))-1 +fY{*r}*2;
            {5}dy:=-23*fy*(1.1-Abs(Sin(d*4)))   -fX{*r}*2 ;
           end;
         3:begin
             d:=(-1.1-Cos(r*16.2)); // ??????
            {-}dx:=d*fX*18 -fY*r*3 -1;
            {-}dy:=d*fY*18 +fX*r*3;
           end;
         4:begin
            {-}d:=-1.1+0.5*Cos(r*100)+0.6*Cos((r+0.345)*113); // ??????
            {-}dx:=d*fX*18 -fY*r*3 -1;
            {-}dy:=d*fY*18 +fX*r*3;
           end;
         5:begin
            {+}dx:=-fX*16*(0.1+r) -fY*r*3 -1;
            {+}dy:=-fY*16*(0.1+r) +fX*r*3;
           end;
         6:begin
            {*}dx:=-fX*36*(0.5-r) -fY*r*3 -1;   // ???
            {*}dy:=-fY*36*(0.5-r) +fX*r*3;
           end;
         7:begin
            {2}dx:=-fX*36*(-0.3+r) -fY*r*3 -1;   //
            {2}dy:=-fY*36*(-0.3+r) +fX*r*3;
           end;
               //d:=-1.1+Sin((Abs(fX)+Abs(fY))*12); // ????
          else begin
             dx:=2*Sin(fX*26)-1{-fY*r*3};
             dy:=2*Sin(fY*26){+fX*r*3};
           end;
         end;
        //------------------------------------------------------------------------
        flag:=true;
        if (f+dx>MaxX-1.0) or (f+dx<1.0) then begin dx:=0.0; flag:=false; end;
        if (LineNumber+dy>MaxX-1.0) or (LineNumber+dy<1.0) then begin dy:=0.0; flag:=false; end;

        HI:=Frac(4000+dx);
        VI:=Frac(4000+dy);

        X:=Trunc(dx+32000)-32000;
        Y:=Trunc(dy+32000)-32000;

        if flag then
          begin
            I0:=Trunc(255*(1-HI)*(1-VI));
            I1:=Trunc(255*HI*(1-VI));
            I2:=Trunc(255*(1-HI)*VI);
            I3:=Trunc(255*HI*VI);
          end
          else
          begin
            I0:=0;
            I1:=0;
            I2:=0;
            I3:=0;
          end;
      end;
    end;
end;

procedure THIVectorFields.InitAll;
var f:Integer;
  i: Integer;
begin
  for f:=0 to MaxY do GenerateOffsets(f);
  A:=A2;

  for f:=0 to Bitm1.Height-1 do ScanLine1[f]:=Integer(Bitm1.ScanLine[f]);
  for f:=0 to Bitm2.Height-1 do ScanLine2[f]:=Integer(Bitm2.ScanLine[f]);
end;

procedure THIVectorFields.ProcessWaves;
var f,g,P,P2,P3:Integer;
    bt:integer;
begin
  for g:=1 to MaxY-1 do
  begin
    P:=ScanLine2[g];
    for f:=1 to MaxX-1 do       // ??? ??? ? ???? ???????? ???? ?????????
    with A[g,f] do
     for bt := 0 to 2 do 
      begin
        P2:=ScanLine1[g+Y]+(f+X)*3 + bt;
        P3:=ScanLine1[g+Y+1]+(f+X)*3 + bt;
        PByte(P)^:= Byte(
             (I0*PByte(P2)^+I1*PByte(P2+3)^+
              I2*PByte(P3)^+I3*PByte(P3+3)^) shr 8);
        Inc(P); 
      end;
  end; 
end;

procedure THIVectorFields._work_doProcess;
var f:Integer;
begin
   for f:=0 to Bitm1.Height-1 do ScanLine1[f]:=Integer(Bitm1.ScanLine[f]);
   ProcessWaves;
   Bitm2.Draw(Bitm1.Canvas.handle, 0, 0);
   _hi_onEvent(_event_onProcess, Bitm1);
end;

procedure THIVectorFields._var_Bitmap(var _Data:TData; index:word);
begin
   dtBitmap(_Data, Bitm1);
end;

procedure THIVectorFields._work_doMode(var _Data:TData; index:word);
begin
  _prop_Mode := ToInteger(_data);
  InitAll;
end;

procedure THIVectorFields._work_doWidth(var _Data:TData; Index:word);
var h:integer;
begin
  _prop_Width := toInteger(_data);
  h := Bitm1.Height; 
  Bitm1.free;
  Bitm2.free;
  SetHeight(h);
end;

procedure THIVectorFields._work_doHeight(var _Data:TData; Index:word);
begin
  Bitm1.free;
  Bitm2.free;
  SetHeight(toInteger(_data));
end;

end.
