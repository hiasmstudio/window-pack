unit hiBASS_ChannelVisibleSpectrum;

interface

uses Kol,Share,Debug,bass;

type
  THIBASS_ChannelVisibleSpectrum = class(TDebug)
   private
    VisBuff:PBitmap;
    FFTPeacks  : array [0..128] of Integer;
    FFTFallOff : array [0..128] of Integer;
   public
    _prop_SoundStream:^cardinal;
    _prop_BackColor:TColor;
    _prop_Width:integer;
    _prop_Height:integer;
    _prop_Pen:TColor;
    _prop_Peak:TColor;
    _prop_Mode:byte;
    _prop_Res:byte;
    _prop_FrameClear:boolean;
    _prop_PeakFallOff:integer;
    _prop_LineFallOff:integer;
    _prop_DrawPeak:boolean;

    _data_BackBitmap:THI_Event;
    _data_WindowsHandle:THI_Event;
    _event_onDraw:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

 Type TFFTData  = array [0..512] of Single;

procedure THIBASS_ChannelVisibleSpectrum._work_doDraw;
var i, YPos : LongInt; X,Y : SmallInt; YVal : single;
   FFTData:TFFTData;
   h:cardinal;
   Scr:PBitmap;
begin
  //dc := ReadInteger(_Data,_data_WindowsHandle);
  VisBuff := ReadBitmap(_Data,_data_WindowsHandle);
  h := _prop_SoundStream^;
  scr := ReadBitmap(_Data,_data_BackBitmap);

  X := 0;
  Y := -2;

  if _prop_FrameClear then
    begin
     VisBuff.Canvas.Pen.Color := _prop_BackColor;
     VisBuff.Canvas.Brush.Color := _prop_BackColor;
     VisBuff.Canvas.Rectangle(0, 0, VisBuff.Width, VisBuff.Height);
     if Scr <> nil then
       Scr.Draw(VisBuff.Canvas.Handle,0,0);
    end;

  if BASS_ChannelIsActive(h) <> BASS_ACTIVE_PLAYING then Exit;
  BASS_ChannelGetData(h, @FFTData, BASS_DATA_FFT1024 or BASS_DATA_FFT_NOWINDOW);

  VisBuff.Canvas.Pen.Color := _prop_Pen;
  for i := 0 to 128 do
   begin
    YVal := FFTData[i*_prop_Res + 5];
    if YVal < 0.0 then YVal := - YVal;
    YPos := Trunc(YVal*500);
    if YPos > _prop_Height then YPos := _prop_Height;

    if YPos >= FFTPeacks[i] then FFTPeacks[i] := YPos
    else dec(FFTPeacks[i],_prop_PeakFallOff);

    if YPos >= FFTFallOff[i] then FFTFallOff[i] := YPos
    else dec(FFTFallOff[i],_prop_LineFallOff);

    if (VisBuff.Height - FFTPeacks[i]) > VisBuff.Height then FFTPeacks[i] := 0;
    if (VisBuff.Height - FFTFallOff[i]) > VisBuff.Height then FFTFallOff[i] := 0;

    case _prop_Mode of
     0:
      begin
        VisBuff.Canvas.MoveTo(X + i, Y + VisBuff.Height);
        VisBuff.Canvas.LineTo(X + i, Y + VisBuff.Height - FFTFallOff[i]);
        if _prop_DrawPeak then
          VisBuff.Pixels[X + i, Y + VisBuff.Height - FFTPeacks[i]] := _prop_Pen;
      end;
     1:
      begin
        if _prop_DrawPeak then
         begin
          VisBuff.Canvas.Pen.Color := _prop_Peak;
          VisBuff.Canvas.MoveTo(X + i * (_prop_Width + 1), Y + VisBuff.Height - FFTPeacks[i]);
          VisBuff.Canvas.LineTo(X + i * (_prop_Width + 1) + _prop_Width, Y + VisBuff.Height - FFTPeacks[i]);
         end;

        VisBuff.Canvas.Pen.Color := _prop_Pen;
        VisBuff.Canvas.Brush.Color := _prop_Pen;
        VisBuff.Canvas.Rectangle(X + i * (_prop_Width + 1), Y + VisBuff.Height - FFTFallOff[i], X + i * (_prop_Width + 1) + _prop_Width, Y + VisBuff.Height);
      end;
    end;
   end;
  _hi_onEvent(_event_onDraw); 
end;

end.
