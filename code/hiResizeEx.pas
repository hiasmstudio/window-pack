unit hiResizeEx;

interface

uses Windows,Kol,Share,Debug;

type
 TObjectProc = procedure of object;
 TLongArray = array[0..65535] of longint;
 PLongArray = ^TLongArray;
 
type
  THIResizeEx = class(TDebug)
   private
    bmp_in: PBitmap;
    bmp_out: PBitmap;
    BltMode: dword;
    fNumIter: integer;
    procedure SetBltMode(ht: boolean);
    procedure Progress;        
   public
    _prop_Width:integer;
    _prop_Height:integer;
    _prop_XBR4x: boolean;
    _prop_Smooth: boolean;
    _prop_sX: byte;
    _prop_sY: byte;    

    _data_Height:THI_Event;
    _data_Width:THI_Event;
    _data_Bitmap:THI_Event;
    _data_sX:THI_Event;
    _data_sY:THI_Event;    

    _event_onStartProgress:THI_Event;
    _event_onProgress:THI_Event;    
    _event_onResult:THI_Event;

    property _prop_HalfTone:boolean write SetBltMode;
	constructor Create;
    destructor Destroy; override;
    procedure _work_doResize(var _Data:TData; Index:word);
    procedure _work_doHalfTone(var _Data:TData; Index:word);    
    procedure _work_doXBR4x(var _Data:TData; Index:word);
    procedure _work_doSmooth(var _Data:TData; Index:word);	    
    procedure _var_Result(var _Data:TData; Index:word);
  end;

  procedure xbr4x(const bm_in: PBitmap; const bm_out: PBitmap; const ProgressCallBack: TObjectProc = nil);
//  procedure xbr4xbis(const bm_in: PBitmap; const bm_out: PBitmap; const ProgressCallBack: TObjectProc = nil);
  procedure Smooth(sX, sY: integer; bmp: PBitmap; const ProgressCallBack: TObjectProc = nil);
  
implementation

type
 Tvoisins=array[-2..2, -2..2] of longint;

const
 pg_red_mask  = $00FF0000;
 pg_green_mask = $0000FF00;
 pg_blue_mask = $000000FF;
 pg_alpha_mask = $FF000000; 

function ifthen(AValue: boolean; const ATrue: integer; const AFalse: integer = 0): integer;
begin
  if AValue then Result := ATrue else Result := AFalse; 
end; 

procedure Smooth(sX, sY: integer; bmp: PBitmap; const ProgressCallBack: TObjectProc = nil);
type
  tScanYX = array of array of cardinal;
var
  X, Y, Z: Integer;
  clm: tRGBQuad;
  pixR: tScanYX;
  WR, HR: integer;
  Scan0: Integer;
  MLS: Integer;
  Bpp: Integer;

  function clQuadMix2(c1, c2: tRGBQuad): tRGBQuad;
  begin
    with Result do
    begin
      rgbRed := (c1.rgbRed + c2.rgbRed) shr 1;
      rgbGreen := (c1.rgbGreen + c2.rgbGreen) shr 1;
      rgbBlue := (c1.rgbBlue + c2.rgbBlue) shr 1;
      rgbReserved := (c1.rgbReserved + c2.rgbReserved) shr 1;    
    end;
  end;

  procedure SetPixelOut(xx, yy: integer; px: tRGBQuad);
  begin
    if (xx >= 0) and (yy >= 0) and (xx < WR) and (yy < HR) then PRGBQuad(pixR[yy, xx])^ := px;
  end;

begin
  if ((sX = 0) and (sY = 0)) or (sX < 0) or (sY < 0) then exit;

  WR := bmp.width;
  HR := bmp.height;   
  Scan0 := Integer(bmp.ScanLine[0]);
  MLS := Integer(bmp.ScanLine[1]) - Scan0;
  Bpp := 4; 
  
  SetLength(pixR, HR, WR);

  for Z := 1 to sX do
  begin
    for Y := 0 to HR - 1 do
    begin
	  for X := 0 to WR - sX - 1 do
	  begin
        pixR[y, x] := Scan0 + y * MLS + x * Bpp;
        pixR[y, x + 1] := Scan0 + y * MLS + (x + 1) * Bpp;        
        clm := clQuadMix2(PRGBQuad(pixR[Y, X])^, PRGBQuad(pixR[Y, X + 1])^);
        SetPixelOut(X + 1, Y, clm);
      end;
      if Assigned(ProgressCallBack) then ProgressCallBack;
    end;
  end;
  if sY = 0 then exit;
  for Z := 0 to sY - 1 do
  begin
    for y := 0 to HR - sY - 1 do
    begin
      for X := 0 to WR - 1 do
        begin
          pixR[y, x] := Scan0 + y * MLS + x * Bpp;
          pixR[y + 1, x] := Scan0 + (y + 1) * MLS + x * Bpp;          
          clm := clQuadMix2(PRGBQuad(pixR[Y, X])^, PRGBQuad(pixR[Y + 1, X])^);
          SetPixelOut(X, Y + 1, clm);
        end;
      if Assigned(ProgressCallBack) then ProgressCallBack;
    end;
  end;
end; // OptionFlou

procedure xbr4x(const bm_in: PBitmap; const bm_out: PBitmap; const ProgressCallBack: TObjectProc = nil);
var
  x, y: integer;
  Pbm_In, Pbm_Out: Cardinal;
  picth_In, pitch_Out: integer;
  nl, nl1, nl2: integer;
  e: PLongArray;
  pprev, pprev2: integer;
  sa0, sa1, sa2, sa3, sa4: PLongArray;
  B1, PB, PE, PH, H5: longint;
  A1, PA, PD, PG, G5: longint;
  A0, D0, G0: longint;
  C1, PC, PF, PI, I5: longint;
  C4, F4, I4: longint;
  Voisins: Tvoisins;

  function RGBtoYUV(c: longint): longint;
  var
    r, g, b, y, u, v: cardinal;
  begin
    r := (c and pg_red_mask)   shr 16;
    g := (c and pg_green_mask) shr  8;
    b := (c and pg_blue_mask);
    y := ((r shl 4) + (g shl 5) + (b shl 2));
    u := (      -r  - (g shl 1) + (b shl 2));
    v := ((r shl 1) - (g shl 1) - (b shl 1));
    result := y + u + v;
  end;

  procedure ALPHA_BLEND_64_W(var dst: longint; src: longint);
  begin
    dst := (
    (pg_red_mask and ((dst and pg_red_mask) +
        (((src and pg_red_mask) - (dst and pg_red_mask)) shr 2))) or
    (pg_green_mask and ((dst and pg_green_mask) +
        (((src and pg_green_mask) - (dst and pg_green_mask)) shr 2))) or
    (pg_blue_mask and ((dst and pg_blue_mask) +
        (((src and pg_blue_mask) - (dst and pg_blue_mask)) shr 2))) or
    (src and longint(pg_alpha_mask)) );
  end;

  procedure ALPHA_BLEND_128_W(var dst: longint; src: longint);
  begin
    dst := (
    (pg_red_mask and ((dst and pg_red_mask) +
        (((src and pg_red_mask) - (dst and pg_red_mask)) shr 1))) or
    (pg_green_mask and ((dst and pg_green_mask) +
        (((src and pg_green_mask) - (dst and pg_green_mask)) shr 1))) or
    (pg_blue_mask and ((dst and pg_blue_mask) +
        (((src and pg_blue_mask) - (dst and pg_blue_mask)) shr 1))) or
    (src and longint(pg_alpha_mask)) );
  end;

  procedure ALPHA_BLEND_192_W(var dst: longint; src: longint);
  begin
    dst := (
    (pg_red_mask and ((dst and pg_red_mask) +
        ((((src and pg_red_mask) - (dst and pg_red_mask)) * 192) shr 8))) or
    (pg_green_mask and ((dst and pg_green_mask) +
        ((((src and pg_green_mask) - (dst and pg_green_mask)) * 192) shr 8))) or
    (pg_blue_mask and ((dst and pg_blue_mask) +
        ((((src and pg_blue_mask) - (dst and pg_blue_mask)) * 192) shr 8))) or
    (src and longint(pg_alpha_mask)) );
  end;

  function df(A, B: longint): longint;
  begin
    result := abs(RGBtoYUV(A) - RGBtoYUV(B));
  end;

  function eq(A, B: longint): boolean;
  begin
    result := df(A, B) < 155;
  end;

  procedure FILTRE_4X(PE, PI, PH, PF, PG, PC, PD, PB, PA, G5, C4, G0, D0,
                      C1, B1, F4, I4, H5, I5, A0, A1, N0, N1, N2, N3, N4,
                      N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15: integer);
  var
    ex, ex2, ex3: boolean;
    le, li: integer;
    ke, ki, px: integer;
  begin
    ex := (PE <> PH) and (PE <> PF);
    if ex then
    begin
      le := (df(PE, PC) + df(PE, PG) + df(PI, H5) + df(PI, F4)) + (df(PH, PF) shl 2);
      li := (df(PH, PD) + df(PH, I5) + df(PF, I4) + df(PF, PB)) + (df(PE, PI) shl 2);

      if (le<li) and (not eq(PF, PB) and not eq(PF, PC) or not eq(PH, PD) and not eq(PH, PG) or eq(PE, PI) and
         (not eq(PF, F4) and not eq(PF, I4) or not eq(PH, H5) and not eq(PH, I5)) or eq(PE, PG) or eq(PE, PC)) then
      begin
        ke  := df(PF, PG);
        ki  := df(PH, PC);
        ex2 := (PE <> PC) and (PB <> PC);
        ex3 := (PE <> PG) and (PD <> PG);
        px  := ifthen((df(PE, PF) <= df(PE, PH)), PF, PH);

        if  ((ke shl 1) <= ki) and ex3 and (ke >= (ki shl 1)) and ex2 then
        begin // [0 0 0 2] /8
              // [0 0 0 6]
              // [0 0 2 8]
              // [2 6 8 8]
          ALPHA_BLEND_64_W( E[N3], px);
          ALPHA_BLEND_192_W(E[N7], px);
          E[N10] := E[N3]; 
          E[N11] := px;
          E[N12] := E[N3];
          E[N13] := E[N7];
          E[N14] := px;
          E[N15] := px;
        end
        else if ((ke shl 1) <= ki) and ex3 then
        begin // [0 0 0 0] /8
              // [0 0 0 0]
              // [0 0 2 6]
              // [2 6 8 8]
          ALPHA_BLEND_64_W( E[N10], px);
          ALPHA_BLEND_192_W(E[N11], px);
          E[N12] := E[N10]; 
          E[N13] := E[N11];
          E[N14] := px;
          E[N15] := px;
        end
        else if (ke >= (ki shl 1)) and ex2 then
        begin // [0 0 0 2] /8
              // [0 0 0 6]
              // [0 0 2 8]
              // [0 0 6 8]
          ALPHA_BLEND_64_W( E[N3], px);
          ALPHA_BLEND_192_W(E[N7], px);
          E[N10] := E[N3];
          E[N11] := px;           
          E[N14] := E[N7];
          E[N15] := px;
        end
        else
        begin // [0 0 0 0] /8
              // [0 0 0 0]
              // [0 0 0 4]
              // [0 0 4 8]
          ALPHA_BLEND_128_W(E[N11], px);
          E[N14] := E[N11];
          E[N15] := px;
        end
      end
      else if le <= li then
        ALPHA_BLEND_128_W(E[N15], ifthen(df(PE, PF) <= df(PE, PH), PF, PH));
    end;
  end;

begin
  bm_Out.Width  := bm_In.Width  * 4;
  bm_Out.Height := bm_In.Height * 4;

  bm_In.PixelFormat := pf32bit;
  bm_Out.PixelFormat := pf32bit;

  picth_In  := bm_In.Width  * 4;
  pitch_Out := bm_Out.Width * 4;

  Pbm_In  := Cardinal(bm_In.ScanLine[bm_In.Height   - 1]);
  Pbm_Out := Cardinal(bm_Out.ScanLine[bm_Out.Height - 1]);

  nl  := bm_Out.Width;
  nl1 := bm_Out.Width * 2;
  nl2 := bm_Out.Width * 3;

  for y := 0 to bm_In.Height - 1 do
  begin
    E   := PLongArray(Pbm_Out + cardinal(y     * pitch_Out * 4));
    sa2 := PLongArray(Pbm_In  + cardinal((y  ) * picth_In  - 8));
    sa1 := PLongArray(Pbm_In  + cardinal((y-1) * picth_In  - 8));
    sa0 := PLongArray(Pbm_In  + cardinal((y-2) * picth_In  - 8));
    sa3 := PLongArray(Pbm_In  + cardinal((y+1) * picth_In  - 8));
    sa4 := PLongArray(Pbm_In  + cardinal((y+2) * picth_In  - 8));

    if (y = 1) then sa0 := sa1;
    if (y = 0) then
    begin
      sa1 := sa2;
      sa0 := sa1;
    end;

    if (y = bm_In.Height - 2) then sa4 := sa3;
    if (y = bm_In.Height - 1) then
    begin
      sa3 := sa2;
      sa4 := sa3;
    end;

    pprev  := 2;
    pprev2 := 2;


    for x := 0 to bm_In.Width-1 do
    begin
      B1 := sa0[2];
      PB := sa1[2];
      PE := sa2[2];
      PH := sa3[2];
      H5 := sa4[2];

      A1 := sa0[pprev];
      PA := sa1[pprev];
      PD := sa2[pprev];
      PG := sa3[pprev];
      G5 := sa4[pprev];

      A0 := sa1[pprev2];
      D0 := sa2[pprev2];
      G0 := sa3[pprev2];

      if (x >= bm_In.Width - 2) then
      begin
        if (x = bm_In.Width - 1) then
        begin
          C1 := sa0[2];
          PC := sa1[2];
          PF := sa2[2];
          PI := sa3[2];
          I5 := sa4[2];

          C4 := sa1[2];
          F4 := sa2[2];
          I4 := sa3[2];
        end
        else
        begin
          C1 := sa0[3];
          PC := sa1[3];
          PF := sa2[3];
          PI := sa3[3];
          I5 := sa4[3];

          C4 := sa1[3];
          F4 := sa2[3];
          I4 := sa3[3];
        end
      end
      else
      begin
        C1 := sa0[3];
        PC := sa1[3];
        PF := sa2[3];
        PI := sa3[3];
        I5 := sa4[3];

        C4 := sa1[4];
        F4 := sa2[4];
        I4 := sa3[4];
      end;

      E[0]       := PE;
      E[1]       := PE;
      E[2]       := PE;
      E[3]       := PE;
      E[nl]      := PE;
      E[nl + 1]  := PE;
      E[nl + 2]  := PE;
      E[nl + 3]  := PE;
      E[nl1]     := PE;
      E[nl1 + 1] := PE;
      E[nl1 + 2] := PE;
      E[nl1 + 3] := PE;
      E[nl2]     := PE;
      E[nl2 + 1] := PE;
      E[nl2 + 2] := PE;
      E[nl2 + 3] := PE;

      FILTRE_4X(PE, PI, PH, PF, PG, PC, PD, PB, PA, G5, C4, G0, D0, C1, B1, F4, I4, H5, I5, A0, A1,    0,    1,    2,    3,   nl, nl+1, nl+2, nl+3,  nl1,nl1+1,nl1+2,nl1+3,  nl2,nl2+1,nl2+2,nl2+3);
      FILTRE_4X(PE, PC, PF, PB, PI, PA, PH, PD, PG, I4, A1, I5, H5, A0, D0, B1, C1, F4, C4, G5, G0,  nl2,  nl1,   nl,    0,nl2+1,nl1+1, nl+1,    1,nl2+2,nl1+2, nl+2,    2,nl2+3,nl1+3, nl+3,    3);
      FILTRE_4X(PE, PA, PB, PD, PC, PG, PF, PH, PI, C1, G0, C4, F4, G5, H5, D0, A0, B1, A1, I4, I5,nl2+3,nl2+2,nl2+1,  nl2,nl1+3,nl1+2,nl1+1,  nl1, nl+3, nl+2, nl+1,   nl,    3,    2,    1,    0);
      FILTRE_4X(PE, PG, PD, PH, PA, PI, PB, PF, PC, A0, I5, A1, B1, I4, F4, H5, G5, D0, G0, C1, C4,    3, nl+3,nl1+3,nl2+3,    2, nl+2,nl1+2,nl2+2,    1, nl+1,nl1+1,nl2+1,    0,   nl,  nl1,  nl2);

      sa0 := PLongArray(cardinal(sa0) + 4);
      sa1 := PLongArray(cardinal(sa1) + 4);
      sa2 := PLongArray(cardinal(sa2) + 4);
      sa3 := PLongArray(cardinal(sa3) + 4);
      sa4 := PLongArray(cardinal(sa4) + 4);

      E:=PLongArray(cardinal(E)+16);

      if (pprev2<>0) then
      begin
        dec(pprev2);
        pprev := 1;
      end;
    end;
    if Assigned(ProgressCallBack) then ProgressCallBack;
  end;
end;

//==============================================================================

constructor THIResizeEx.Create;
begin
  inherited;
  bmp_in := NewBitmap(0, 0);
  bmp_out := NewBitmap(0, 0);
end;

destructor THIResizeEx.Destroy;
begin
  bmp_in.free;
  bmp_out.free;
  inherited;
end;

procedure THIResizeEx.Progress;
begin
  inc(fNumIter);
  _hi_onEvent(_event_onProgress, fNumIter);
end;  

procedure THIResizeEx._work_doResize;
var
  Bitmap: PBitmap;
  tbmp: PBitmap;
  sX, sY: integer;
  bw, bh: integer;       
  Count: integer;
begin
  Bitmap := ReadBitmap(_Data, _data_Bitmap, nil);
  if (Bitmap = nil) or Bitmap.Empty then exit;

  bmp_in.Assign(Bitmap);

  bw := ReadInteger(_Data,_data_Width,_prop_Width);
  bh := ReadInteger(_Data,_data_Height,_prop_Height);

  sX := ReadInteger(_Data, _data_sX, _prop_sX);
  sY := ReadInteger(_Data, _data_sY, _prop_sY);

  if _prop_XBR4x then
  begin
    Count := bmp_in.height;
    if _prop_Smooth then
    begin
      if (sX <> 0) then 
        Count := Count + bmp_in.height * 4;
      if (sY <> 0) then
        Count := Count  + bmp_in.height * 4 - sY;       
      fNumIter := 0;
      _hi_onEvent(_event_onStartProgress, Count);

      xbr4x(bmp_in, bmp_out, Progress);
      if (sX <> 0) or (sY <> 0) then Smooth(sX, sY, bmp_out, Progress);
    end   
	else
	begin
      fNumIter := 0;
      _hi_onEvent(_event_onStartProgress, Count);
      xbr4x(bmp_in, bmp_out, Progress);
	end;
  end  
  else
  begin
    if _prop_Smooth then
    begin
	  if (sX <> 0) or (sY <> 0) then
	  begin
		Count := 0;
        if (sX <> 0) then 
          Count := bmp_in.height * 4;
        if (sY <> 0) then
          Count := Count + bmp_in.height * 4 - sY;       
        fNumIter := 0;
        _hi_onEvent(_event_onStartProgress, Count);

        bmp_in.PixelFormat := pf32bit;
        tbmp := NewBitmap(bmp_in.width * 4, bmp_in.height * 4);
        tbmp.pixelFormat := pf32bit;
        SetStretchBltMode(tbmp.Canvas.Handle, COLORONCOLOR);
        StretchBlt(tbmp.Canvas.Handle, 0, 0, tbmp.width, tbmp.height, bmp_in.Canvas.Handle, 0, 0, bmp_in.width, bmp_in.height, SRCCOPY);
        bmp_out.Assign(tbmp);
        tbmp.free;    
	    Smooth(sX, sY, bmp_out, Progress);    
	  end
	  else
	    bmp_out.assign(bmp_in);
	end
	else
      bmp_out.assign(bmp_in);	  
  end;  

  if not ((bw = bmp_out.width) and (bh = bmp_out.height)) then 
  begin
    tbmp := NewBitmap(bw, bh);
    tbmp.pixelFormat := pf32bit;
    SetStretchBltMode(tbmp.Canvas.Handle, BltMode);
    StretchBlt(tbmp.Canvas.Handle, 0, 0, bw, bh, bmp_out.Canvas.Handle, 0, 0, bmp_out.width, bmp_out.height, SRCCOPY);    
    bmp_out.Assign(tbmp);
    tbmp.free;
  end;

  _hi_OnEvent(_event_onResult, bmp_out);
end;

procedure THIResizeEx.SetBltMode;
begin
   if ht and (WinVer >= wvNT) then
      BltMode := HALFTONE
   else
      BltMode := COLORONCOLOR;
end;

procedure THIResizeEx._work_doHalfTone;
begin
  SetBltMode(ReadBool(_Data));
end;

procedure THIResizeEx._work_doXBR4x;
begin
  _prop_XBR4x := ReadBool(_Data);
end;

procedure THIResizeEx._work_doSmooth;
begin
  _prop_Smooth := ReadBool(_Data);
end;

procedure THIResizeEx._var_Result;
begin
   if (bmp_out = nil) or bmp_out.Empty then exit;
   dtBitmap(_Data, bmp_out);
end;

end.