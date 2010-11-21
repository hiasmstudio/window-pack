unit hiWaveProcessor;

interface

uses Windows,Kol,Share,Debug;

type
  TWave = record
    height: double;
    speed : double;
  end;
  TByteArray = array[0..0] of byte; 
  PByteArray = ^TByteArray;
  THIWaveProcessor = class(TDebug)
   private
    rep: string;
    
    bitmapWidth    : integer;
    bitmapHeight   : integer;
    backgroundLines: array of PByteArray;
    bitmapLines    : array of PByteArray;
    halfResolution : boolean;
    
    Image, bitmap: PBitmap;
    
    waves: array of array of TWave;
    
    lightIntensity: double; // Intensité de l'effet de lumière
    depth         : double; // Profondeur de l'eau pour la pseudo-réfraction
    viscosity     : double; // pseudo-viscosité pour l'animation
    wavesSpeed    : double; // paramêtre pour la vitesse des vagues (doit valoir au minimum 2.0)
    
    leftDown: boolean;
    
    lastT   : integer;
    fpsCount: integer;
    
    procedure init();
    procedure initWavesArray();
    procedure initWavesData();
    procedure initBackgroundLines();
    procedure initBitmapLines();

    procedure simul();
    procedure simulEdges();
    procedure ripple(centerX, centerY, radius: integer; height: double);    

    procedure render();
    procedure idle;
   public
    _prop_Viscosity:integer;
    _prop_Vitesse:integer;
    _prop_Luminosity:integer;
    _prop_Profondeur:integer;
    _prop_Radius:integer;
    _prop_Height:real;

    _data_Height:THI_Event;
    _data_Radius:THI_Event;
    _data_Y:THI_Event;
    _data_X:THI_Event;
    _data_Bitmap:THI_Event;
    _data_Image:THI_Event;
    _event_onProcess:THI_Event;

    procedure _work_doProcess(var _Data:TData; Index:word);
    procedure _work_doRipple(var _Data:TData; Index:word);
  end;

implementation

procedure THIWaveProcessor._work_doProcess;
var b,im:PBitmap;
begin
   im := ReadBitmap(_Data, _data_Image); 
   b := ReadBitmap(_Data, _data_Bitmap);
   if image <> im then
     begin
       image := im;
       bitmap := b;
       init();
     end; 
   initBackGroundLines();
   idle();
   _hi_onEvent(_event_onProcess);
end;

procedure THIWaveProcessor._work_doRipple;
var x,y,r:integer; 
    h:real;
begin
   x := ReadInteger(_Data, _data_X);
   y := ReadInteger(_Data, _data_Y);
   r := ReadInteger(_Data, _data_Radius, _prop_Radius);
   h := ReadReal(_Data, _data_Height, _prop_Height);
   ripple(x,y,r,h);
end;

procedure THIWaveProcessor.idle;
begin
  simulEdges();
  simul();
  render();
end;

procedure THIWaveProcessor.init();
begin
  halfResolution := false;
  bitmapWidth  := image.width;
  bitmapHeight := image.height;

  lightIntensity := _prop_Luminosity;
  wavesSpeed     := _prop_Vitesse;
  viscosity      := _prop_Viscosity/100;
  depth          := _prop_Profondeur/10.0;

  initBitmapLines();
  initBackGroundLines();

  initWavesArray();
  initWavesData();
end;

procedure THIWaveProcessor.initWavesArray();
var
  x: integer;
begin
  setLength(waves, bitmapWidth+1);
  for x:=0 to bitmapWidth do
    setLength(waves[x], bitmapHeight+1);
end;

procedure THIWaveProcessor.initWavesData();
var
  x: integer;
  y: integer;
begin
  for x:=0 to bitmapWidth do
  for y:=0 to bitmapHeight do
   begin
     waves[x, y].height := 0.0;
     waves[x, y].speed := 0.0;
   end;
end;

procedure THIWaveProcessor.initBackgroundLines();
var
  i: integer;
begin
  Bitmap.PixelFormat := pf24bit;
  setLength(backgroundLines, bitmap.Height);
  for i:=0 to bitmap.Height-1 do
    backgroundLines[i] := Bitmap.ScanLine[i];
end;

procedure THIWaveProcessor.initBitmapLines();
var
  i: integer;
begin
  image.PixelFormat := pf24bit;
  setLength(bitmapLines, bitmapHeight);
  for i:=0 to bitmapHeight-1 do
    bitmapLines[i] := image.ScanLine[i];
end;

procedure THIWaveProcessor.simul();
var
  x: integer;
  y: integer;
  d1: double;
  d2: double;
  ddx: double;
  ddy: double;
  viscosity1: double;
begin
  for x:=1 to bitmapWidth-1 do
  for y:=1 to bitmapHeight-1 do
    begin
    // Formule du calcul:
    // accèlération de la hauteur = double dérivée de la hauteur au point concerné
    //
    // d²h     d²h   d²h          1
    // --- = ( --- + --- ) x ------------
    // dt²     dx²   dy²      wavesSpeed
    //
    // La dérivée de la hauteur représente la "pente" au point concerné. 

    // Traitement sur X
    d1 := waves[x+1, y].height - waves[x, y].height;   // Dérivée première à "droite" de x
    d2 := waves[x, y].height   - waves[x-1, y].height; // Dérivée première à "gauche" de x
    ddx := d1 - d2;                                    // Dérivée seconde en x

    // Traitmement sur Y
    d1 := waves[x, y+1].height - waves[x, y].height;
    d2 := waves[x, y].height   - waves[x, y-1].height;
    ddy := d1 - d2;
    
    waves[x, y].speed := waves[x, y].speed + ddx/wavesSpeed + ddy/wavesSpeed;
    end;

  viscosity1 := 1.0-viscosity;  
  for x:=1 to bitmapWidth-1 do
  for y:=1 to bitmapHeight-1 do
    waves[x, y].height := (waves[x, y].height + waves[x, y].speed)*viscosity1;
end;

procedure THIWaveProcessor.simulEdges();
var
  x: integer;
begin
  // Les points (0, 0) et (bitmapWidth, 0) sont traités dans la seconde boucle.
  for x:=1 to bitmapWidth-1 do
    begin
    waves[x, 0] := waves[x, 1];
    waves[x, bitmapHeight] := waves[x, bitmapHeight-1];
    end;
  for x:=0 to bitmapHeight do
    begin
    waves[0, x] := waves[1, x];
    waves[bitmapWidth, x] := waves[bitmapWidth-1, x];
    end;
end; 


procedure THIWaveProcessor.ripple(centerX, centerY, radius: integer; height: double);
var
  x: integer;
  y: integer;
begin
  for x:=(centerX-radius) to centerX+radius-1 do
    begin

    if (x>=0) and (x<=bitmapWidth) then
    for y:=centerY-radius to centerY+radius-1 do
      begin

      if (y>=0) and (y<=bitmapHeight) then
        begin
        // Forme de la perturbation obtenue à l'aide de la fonction cosinus
        //                      ____
        //                   __/    \__
        //                 _/          \_
        //                /              \
        //              _/                \_
        //           __/                    \__
        // _________/                          \_________
        waves[x, y].height := waves[x, y].height +( (Cos((x-centerX+radius)/(2*radius)*2*PI - PI)+1)*(Cos((y-centerY+radius)/(2*radius)*2*PI - PI)+1)*height );
        end;

      end;

    end;
end; 

procedure THIWaveProcessor.render();
var
  x: integer;
  y: integer;

  background: PByteArray;
  buffer    : PByteArray;

  // Refraction
  dx: double;
  dy: double;
  light: integer;
  xMap: integer;
  yMap: integer;
begin
  // Pour chaque colone
  for y:=0 to bitmapHeight-1 do
    begin
    // Récupération de la colone du background et de l'image
    //buffer := image.picture.bitmap.scanLine[y];

    for x:=0 to bitmapWidth-1 do
      begin
      // Dérivée X et Y
      dx := waves[x+1, y].height-waves[x, y].height;
      dy := waves[x, y+1].height-waves[x, y].height;

      // Calcul déformation
      xMap := x + round(dx*(waves[x,y].height+depth));
      yMap := y + round(dy*(waves[x,y].height+depth));

      // Modification de xMap et yMap pour la faible résolution afin d'avoir une image de meme
      // taille à l'écran qu'en haute résolution
      if halfResolution then
        begin
        xMap := xMap * 2;
        yMap := yMap * 2;
        end;

      // Calcul lumière
      //light := max(0, round(dx*lightIntensity + dy*lightIntensity));
      light := round(dx*lightIntensity + dy*lightIntensity);

      if xMap>=0 then
        xMap := xMap mod Bitmap.Width
        else
        xMap := Bitmap.Width-((-xMap) mod Bitmap.Width)-1;

      if yMap>=0 then
        yMap := yMap mod Bitmap.Height
        else
        yMap := Bitmap.Height-((-yMap) mod Bitmap.Height)-1;

      bitmapLines[y][x*3+0] := min(255, max(0, backgroundLines[yMap][xMap*3+0] + light));
      bitmapLines[y][x*3+1] := min(255, max(0, backgroundLines[yMap][xMap*3+1] + light));
      bitmapLines[y][x*3+2] := min(255, max(0, backgroundLines[yMap][xMap*3+2] + light));
      end;

    end;
end;

end.
