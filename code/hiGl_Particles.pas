unit hiGl_Particles;

interface

uses Kol,Share,Debug,OpenGL;

type
  TRealCoord = record
    x,y,z:real;    
    vx,vy,vz:real; // проекция вектора скорости по осем
    life:integer;
  end;
  THIGl_Particles = class(TDebug)
   private
    FCurLife:integer;
    FCount,FStepCount:integer;
    FParticles:array of array of TRealCoord;
    FColor:TRealCoord;
    FStepColor:TRealCoord;
    procedure SetCount(value:integer);
    procedure SetColor;
   public
    _prop_LifeTime:integer;
    _prop_Param1:real;
    _prop_Param2:real;
    _prop_Speed:real;
    _prop_Average:real;
    _prop_GX:real;
    _prop_GY:real;
    _prop_GZ:real;
    _prop_ColorStart:integer;
    _prop_ColorEnd:integer;
    _prop_Shape:procedure(var p:TRealCoord) of object;

    _event_onDraw:THI_Event;
    _event_onZLevel:THI_Event;

    procedure spCircle(var p:TRealCoord);
    procedure spRect(var p:TRealCoord);
    procedure spCylinder(var p:TRealCoord);
    procedure spSphere(var p:TRealCoord);

    procedure _work_doDraw(var _Data:TData; Index:word);
    procedure _work_doColorStart(var _Data:TData; Index:word);
    procedure _work_doColorEnd(var _Data:TData; Index:word);
    procedure _work_doCount(var _Data:TData; Index:word);
    procedure _work_doLifeTime(var _Data:TData; Index:word);
    procedure _work_doParam1(var _Data:TData; Index:word);
    procedure _work_doParam2(var _Data:TData; Index:word);
    procedure _work_doAverage(var _Data:TData; Index:word);
    procedure _work_doSpeed(var _Data:TData; Index:word);
    procedure _work_doGX(var _Data:TData; Index:word);
    procedure _work_doGY(var _Data:TData; Index:word);
    procedure _work_doGZ(var _Data:TData; Index:word);
    property _prop_Count:integer read FCount write SetCount; 
  end;

implementation

procedure THIGl_Particles.SetColor;
begin
   with TRGB(_prop_ColorStart) do
    begin
      FColor.x := r / 255;
      FColor.y := g / 255;
      FColor.z := b / 255;
    end;                
   with TRGB(_prop_ColorEnd) do
    begin
      FStepColor.x := (r - TRGB(_prop_ColorStart).r) / 255 / _prop_LifeTime;
      FStepColor.y := (g - TRGB(_prop_ColorStart).g) / 255 / _prop_LifeTime;
      FStepColor.z := (b - TRGB(_prop_ColorStart).b) / 255 / _prop_LifeTime;
    end;
end;

procedure THIGl_Particles._work_doColorStart;
begin
   _prop_ColorStart := ToInteger(_data); 
   SetColor(); 
end;

procedure THIGl_Particles._work_doColorEnd;
begin
   _prop_ColorEnd := ToInteger(_data); 
   SetColor();
end;

procedure THIGl_Particles._work_doCount;
begin
   SetCount(ToInteger(_Data));
end;

procedure THIGl_Particles._work_doLifeTime;
begin
   _prop_LifeTime := ToInteger(_data);
   if FCount > _prop_LifeTime then
      FCount := _prop_LifeTime;
   if FCurLife >= _prop_LifeTime then
    FCurLife := 0; 
   SetCount(FStepCount);
end;

procedure THIGl_Particles._work_doParam1;
begin
   _prop_Param1 := ToReal(_Data);
end;

procedure THIGl_Particles._work_doParam2;
begin
   _prop_Param2 := ToReal(_Data);
end;

procedure THIGl_Particles._work_doAverage;
begin
   _prop_Average := ToReal(_Data);
end;

procedure THIGl_Particles._work_doSpeed;
begin
   _prop_Speed := ToReal(_Data);
end;

procedure THIGl_Particles._work_doGX;
begin
   _prop_GX := ToReal(_Data);
end;

procedure THIGl_Particles._work_doGY;
begin
   _prop_GY := ToReal(_Data);
end;

procedure THIGl_Particles._work_doGZ;
begin
   _prop_GZ := ToReal(_Data);
end;

procedure THIGl_Particles.spCircle;
var u,r:real;
begin
   with p do
     begin
        u := random(1000)/500*3.1415;
        r := (_prop_Param2 - _prop_Param1)*Random(1000)/1000 + _prop_Param1; 
        x := r*sin(u); 
        y := r*cos(u);
        z := 0.0;
        vx := 0.0;
        vy := 0.0;
        vz := _prop_Speed; 
        life := 0;
     end
end;

procedure THIGl_Particles.spRect;
begin
   with p do
     begin
        x := _prop_Param1*(Random(1000)/1000 - 0.5);
        y := _prop_Param2*(Random(1000)/1000 - 0.5);
        z := 0.0;
        vx := 0.0;
        vy := 0.0;
        vz := _prop_Speed;
        life := 0; 
     end
end;

procedure THIGl_Particles.spCylinder;
var u:real;
begin
   with p do
     begin
        u := random(1000)/500*3.1415;
        x := _prop_Param1*sin(u);
        y := _prop_Param1*cos(u);
        z := _prop_Param2*(Random(1000)/1000 - 0.5);
        vx := _prop_Speed*sin(u);
        vy := _prop_Speed*cos(u);
        vz := 0.0;
        life := 0; 
     end
end;

procedure THIGl_Particles.spSphere;
var u1,u2,d:real;
begin
   with p do
     begin
        u1 := random(1000)/500*pi;
        u2 := _prop_Param2*random(1000)/500*pi/2;
        
        d := _prop_Param1*sin(u2);
        z := _prop_Param1*cos(u2); // z := d*sin(u2);
        x := d*sin(u1);
        y := d*cos(u1);
        
        d := _prop_Speed*sin(u2);
        vz := _prop_Speed*cos(u2);
        vx := d*sin(u1);
        vy := d*cos(u1);
        life := 0; 
     end
end;  

procedure THIGl_Particles.SetCount;
var i:integer;
begin
   FStepCount := value;
   SetLength(FParticles, _prop_LifeTime);
   for i := 0 to _prop_LifeTime-1 do
    SetLength(FParticles[i], FStepCount);
     
   SetColor;
end;

procedure THIGl_Particles._work_doDraw;
var i,j:integer;
    _r,_g,_b,lvl:real;
begin   
   if FCount < _prop_LifeTime then
     inc(FCount);
   
   for i := 0 to FStepCount-1 do
    with FParticles[FCurLife][i] do
     _prop_Shape(FParticles[FCurLife][i]);

   inc(FCurLife);
   if FCurLife >= _prop_LifeTime then
    FCurLife := 0;
   
   glBegin(Gl_POINTS);
     for j := 0 to FCount-1 do
      begin
          lvl := FParticles[j][0].life;
          with FColor do
            begin
              _r := x + lvl*FStepColor.x;
              _g := y + lvl*FStepColor.y;
              _b := z + lvl*FStepColor.z; 
            end;
          glColor3f(_r,_g,_b);
             
          for i := 0 to FStepCount-1 do
           with FParticles[j][i] do 
            begin
             glVertex3f(x,y,z);
             z := z + vz + _prop_Average*(random(100)/100 - 0.5); 
             x := x + vx + _prop_Average*(random(100)/100 - 0.5);
             y := y + vy + _prop_Average*(random(100)/100 - 0.5);
             vz := vz - _prop_GZ;
             vy := vy - _prop_GY;
             vx := vx - _prop_GX;
             inc(life);
            end;
      end; 
   glEnd();
   _hi_CreateEvent(_Data, @_event_onDraw)
end;

end.
