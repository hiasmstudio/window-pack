unit hiBASS_ChannelVisibleOcilloScope;

interface

uses WINDOWS,Kol,Share,Debug,BASS;

type
  THIBASS_ChannelVisibleOcilloScope = class(TDebug)
   private
    VisBuff:PBitmap;
   public
    _prop_SoundStream:^cardinal;
    _prop_BackColor:TColor;
    _prop_ScaleY:integer;
    _prop_Pen:TColor;
    _prop_Mode:byte;
    _prop_Res:byte;
    _prop_FrameClear:boolean;

    _data_BackBitmap:THI_Event;
    _data_WindowsHandle:THI_Event;
    _event_onDraw:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

  Type TWaveData = array [ 0..2047] of dword;

procedure THIBASS_ChannelVisibleOcilloScope._work_doDraw;
var 
   i,YPos : LongInt; 
   x,dx:real;
   Y,R,L : SmallInt; 
   YVal : single;
   WaveData:TWaveData;
   Scr:PBitmap;
begin
  VisBuff := ReadBitmap(_Data,_data_WindowsHandle);
  scr := ReadBitmap(_Data,_data_BackBitmap);

  if _prop_FrameClear then
    begin
      VisBuff.Canvas.Pen.Color := _prop_BackColor;
      VisBuff.Canvas.Brush.Color := _prop_BackColor;
      VisBuff.Canvas.Rectangle(0, 0, VisBuff.Width, VisBuff.Height);
      if Scr <> nil then
        Scr.Draw(VisBuff.Canvas.Handle,0,0);
    end;

  if BASS_ChannelIsActive(_prop_SoundStream^) <> BASS_ACTIVE_PLAYING then Exit;
  BASS_ChannelGetData(_prop_SoundStream^, @WaveData, 2048);
    
  X := 0;
  dx := VisBuff.Width / (256*_prop_Res); 
  Y := VisBuff.Height div 2;

  VisBuff.Canvas.Pen.Color := _prop_Pen;
  R := SmallInt(LOword(WaveData[0]));
  L := SmallInt(HIword(WaveData[0]));
  YPos := Trunc(((R + L) / (2 * 65535)) * _prop_ScaleY) ;
  VisBuff.Canvas.MoveTo(round(x) , Y + YPos);

  for i := 1 to 256*_prop_Res do
   begin
    R := SmallInt(Loword(WaveData[i]));
    L := SmallInt(HIword(WaveData[i]));
    YPos := trunc(((R + L) / (2*65536)) * _prop_ScaleY) ;

    case _prop_Mode of
     0: VisBuff.Canvas.lineto(round(X), Y + YPos);
     1:
       begin
        VisBuff.Canvas.MoveTo(round(X), Y);
        VisBuff.Canvas.lineto(round(X), Y + YPos);
       end;
     2 : VisBuff.Pixels[round(X),  Y + YPos] := _prop_Pen;
    end;
    x := x + dx;
   end;
  _hi_onEvent(_event_onDraw); 
end;

end.
