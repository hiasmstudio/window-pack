unit hiBASS_ChlVisibleOcilloScope;

interface

uses Windows,Kol,Share,Debug,BASS;

type
  THIBASS_ChlVisibleOcilloScope = class(TDebug)
   private
    VisBuff:PBitmap;
   public
    _prop_BackColor:TColor;
    _prop_Offset:integer;
    _prop_Pen:TColor;
    _prop_Mode:byte;
    _prop_Res:byte;
    _prop_FrameClear:boolean;

    _data_BackBitmap:THI_Event;
    _data_ChannelHandle:THI_Event;
    _data_WindowsHandle:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

Type TWaveData = array [ 0..2048] of DWORD;

procedure THIBASS_ChlVisibleOcilloScope._work_doDraw;
var i, YPos : LongInt; X,Y,R,L : SmallInt; YVal : single;
   WaveData:TWaveData;
   h:cardinal;
   Scr:PBitmap;
begin
  VisBuff := ReadBitmap(_Data,_data_WindowsHandle);
  h := ReadInteger(_Data,_data_ChannelHandle);
  scr := ReadBitmap(_Data,_data_BackBitmap);

  if _prop_FrameClear then
    begin
      VisBuff.Canvas.Pen.Color := _prop_BackColor;
      VisBuff.Canvas.Brush.Color := _prop_BackColor;
      VisBuff.Canvas.Rectangle(0, 0, VisBuff.Width, VisBuff.Height);
      if Scr <> nil then
        Scr.Draw(VisBuff.Canvas.Handle,0,0);
    end;

  if BASS_ChannelIsActive(h) <> BASS_ACTIVE_PLAYING then Exit;
  BASS_ChannelGetData(h, @WaveData, 2048);
  //BASS_ChannelGetData(h, @FFTData, BASS_DATA_FFT1024 or BASS_DATA_FFT_NOWINDOW);

  X := 0;
  Y := VisBuff.Height div 2;

  VisBuff.Canvas.Pen.Color := _prop_Pen;
  R := SmallInt(LOword(WaveData[0]));
  L := SmallInt(HIword(WaveData[0]));
  YPos := Trunc(((R + L) / (2 * 65535)) * _prop_Offset) ;
  VisBuff.Canvas.MoveTo(X , Y + YPos);

  for i := 1 to 256*_prop_Res do
   begin
    R := SmallInt(Loword(WaveData[i]));
    L := SmallInt(HIword(WaveData[i]));
    YPos := Trunc(((R + L) / (2 * 65535)) * _prop_Offset) ;

    case _prop_Mode of
     0: VisBuff.Canvas.lineto(X + i, Y + YPos);
     1:
       begin
        VisBuff.Canvas.MoveTo(X + i, Y);
        VisBuff.Canvas.lineto(X + i, Y + YPos);
       end;
     2 : VisBuff.Pixels[X + i,  Y + YPos] := _prop_Pen;
    end;
   end;
end;

end.
