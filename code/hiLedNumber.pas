
(**************************************************************************)
(*
(*             Компонент для отрисовки цифр на табло без использования
(*             дополнительного Bitmap из ресурсов. Весь вывод делается
(*             вручную, а как следствие размер будет меньше.
(*
(*             // Выравнивание по горизонтали (TTextAlign = ( taLeft, taRight, taCenter ))
(*             property TextAlign: TTextAlign;
(*             // Цвет фона
(*             property Background: TColor;
(*             // Цвет активной полосы в цифре
(*             property Foreground: TColor;
(*             // Цвет не активной полосы в цифре
(*             property Shadow: TColor;
(*             // Текст выводимый на табло (0123456789+' '+'_'+'-'+':'+'.')
(*             property Text: String;
(*             // Показывать ли неактивне линии
(*             property ShowLines: Boolean;
(*
(**************************************************************************)

unit hiLedNumber; { Цифровое табло ver 2.45 }

interface

uses Windows,Messages,Kol,Share,Win;

type
  THILedNumber = class(THIWin)

  private
    FShowLines: Boolean; // показывать точки цветом FShadow?
    STextAlign: TTextAlign;
    FShadow,FForeground,FBackground: TColor;

    FFonColor,FSegColor,FNoSegColor: TColor;
    FFonHover,FSegHover,FNoSegHover: TColor;
    FDigits: Integer;
    FColorHover : boolean;
    FText: String;  // Содержится текст
    FDrawBuffer : PBitmap;

    procedure _OnClick( Sender: PObj );
    procedure _OnMouseEnter( Sender: PObj );override;
    procedure _OnMouseLeave( Sender: PObj );override;
    procedure UpdateDrawBuffer;

  public
    _prop_Text: String;   
    _event_OnClick : THI_Event;
    _data_Text : THI_Event;

    property _prop_Alignment: TTextAlign write STextAlign;
    property _prop_FonColor: TColor      write FFonColor;
    property _prop_SegColor: TColor      write FSegColor;
    property _prop_NoSegColor: TColor    write FNoSegColor;
    property _prop_ShowLines: Boolean    write FShowLines;
    property _prop_ColorHover: Boolean   write FColorHover;
    property _prop_FonHover: TColor      write FFonHover;
    property _prop_SegHover: TColor      write FSegHover;
    property _prop_NoSegHover: TColor    write FNoSegHover;

    destructor Destroy; override;
    procedure Init; override;

    procedure _work_doText(var _Data:TData; Index : word);
    procedure _work_doAlignment(var _Data:TData; Index : word);
    procedure _work_doFonColor(var _Data:TData; Index : word);
    procedure _work_doSegColor(var _Data:TData; Index : word);
    procedure _work_doNoSegColor(var _Data:TData; Index : word);
    procedure _work_doShowLines(var _Data:TData; Index : word);
    procedure _work_doColorHover(var _Data:TData; Index : word);
    procedure _work_doFonHover(var _Data:TData; Index : word);
    procedure _work_doSegHover(var _Data:TData; Index : word);
    procedure _work_doNoSegHover(var _Data:TData; Index : word);

    procedure _var_Caption(var Data:TData; Index:word);

end;

implementation

function WndProcLedNumber(Sender: PControl; var Msg: TMsg; var Rslt: Integer ): Boolean;
var   P: TPaintstruct;
      fControl: THILedNumber;
begin
   fControl := THILedNumber(Sender.Tag); 
   if msg.Message = WM_PAINT then begin
      BeginPaint(Sender.Handle,P);
      fControl.FDrawbuffer.Draw( Sender.Canvas.Handle, 0, 0 );
      EndPaint(Sender.Handle,P);
   end else if msg.message = WM_PRINTCLIENT then begin
      fControl.FDrawbuffer.Draw( hDC(Msg.wParam), 0, 0 );
   end else if msg.message = WM_SIZE then begin
      fControl.fDrawBuffer.width:=sender.clientwidth;
      fControl.fDrawBuffer.height:=sender.clientheight;
      fControl.Updatedrawbuffer;
   end else begin
      Result := False;
      exit;
   end;
   Result := True;
   Rslt := 0;
end;

destructor THILedNumber.Destroy;
begin
   FDrawBuffer.free;
   inherited;
end;

procedure THILedNumber.Init;
begin
   FText := _prop_Text;
   Control := NewPaintBox(FParent);
   Control.Tag := longint(Self);
   Control.Attachproc(WndProcLedNumber);
   FBackground := FFonColor;
   FForeground := FSegColor;
   FShadow := FNoSegColor;
   FDrawBuffer:= NewDIBBitmap(Control.Width,Control.Height,pf32bit);
   Control.OnClick := _OnClick;
   Control.OnMouseEnter := _OnMouseEnter;
   Control.OnMouseLeave := _OnMouseLeave;
inherited;
   Control.Invalidate;
end;
   
procedure THILedNumber._work_doText;
begin
   FText := ReadString(_Data,_data_Text);
   UpdateDrawbuffer;
end;

procedure THILedNumber._work_doAlignment;
begin
   STextAlign := TTextAlign(ToInteger(_Data)); 
   UpdateDrawbuffer;
end;

procedure THILedNumber._work_doFonColor;
begin
   FFonColor := ToInteger(_Data);
   FBackGround := FFonColor;
   UpdateDrawbuffer;
end;

procedure THILedNumber._work_doSegColor;
begin
   FSegColor := ToInteger(_Data);
   FForeGround := FSegColor;   
   UpdateDrawbuffer;
end;

procedure THILedNumber._work_doNoSegColor;
begin
   FNoSegColor := ToInteger(_Data);
   FShadow := FNoSegColor;   
   UpdateDrawbuffer;
end;

procedure THILedNumber._work_doFonHover;
begin
   FFonHover := ToInteger(_Data);
end;

procedure THILedNumber._work_doSegHover;
begin
   FSegHover := ToInteger(_Data);
end;

procedure THILedNumber._work_doNoSegHover;
begin
   FNoSegHover := ToInteger(_Data);
end;

procedure THILedNumber._work_doColorHover;
begin
   FColorHover := ReadBool(_data);
end;

procedure THILedNumber._work_doShowLines;
begin
   FShowLines := ReadBool(_data);
   UpdateDrawbuffer;   
end;

procedure THILedNumber._OnClick;
begin
   _hi_OnEvent(_event_OnClick);
end;

procedure THILedNumber._OnMouseEnter;
begin
   if not FColorHover then exit;
   FBackGround := FFonHover;
   FForeGround := FSegHover;
   FShadow := FNoSegHover;
   UpdateDrawbuffer;
end;

procedure THILedNumber._OnMouseLeave;
begin
   if not FColorHover then exit;
   FBackGround := FFonColor;
   FForeGround := FSegColor;
   FShadow := FNoSegColor;
   UpdateDrawbuffer;
end;

procedure THILedNumber._var_Caption;
begin
   dtString(Data, FText);
end;

procedure THILedNumber.UpdateDrawBuffer;
var
  i, j, k: Integer;
  wn, hn: Integer; // Ширина и высота каждой цифры
  pw, ph: Integer; // Ширина и высота каждого "пикселя" рисунка
{
  1_
 2|_|6
 3|_|5
   4
 7 - внутри
}
  // Нарисовать линию в цифре цветом Color
  procedure DrawDigitLine(Number: Integer; X,Y: Integer; Color: TColor);
  var
    i1,j1, tmp1, tmp2: Integer;
  begin
    // wn, hn
    // pw, ph
    with PCanvas(FDrawBuffer.Canvas){$ifndef F_P}^{$endif} do begin
    Pen.Color := Color;
    Brush.Color := Color;
    i1 := 0;
    j1 := 0;
    tmp1 := pw;
    tmp2 := ph;
    case Number of
     1:
       begin
         while j1 <= tmp2 do begin
           MoveTo(X+i1+1,Y+j1);
           LineTo(X+wn-i1-1,Y+j1);
           j1 := j1+1;
           i1 := i1+1;
         end;
       end;
     2:
       begin
         while i1 <= tmp1 do begin
           MoveTo(X+i1,Y+j1+1);
           LineTo(X+i1,Y+hn div 2-j1-1);
           j1 := j1+1;
           i1 := i1+1;
         end;
       end;
     3:
       begin
         while i1 <= tmp1 do begin
           MoveTo(X+i1,Y+hn div 2+j1+1);
           LineTo(X+i1,Y+hn-j1-1);
           j1 := j1+1;
           i1 := i1+1;
         end;
       end;
     4:
       begin
         while j1 <= tmp2 do begin
           MoveTo(X+i1+1,Y+hn-j1-1);
           LineTo(X+wn-i1-1,Y+hn-j1-1);
           j1 := j1+1;
           i1 := i1+1;
         end;
       end;
     5:
       begin
         while i1 <= tmp1 do begin
           MoveTo(X+wn-i1,Y+hn div 2+j1);
           LineTo(X+wn-i1,Y+hn-j1);
           j1 := j1+1;
           i1 := i1+1;
         end;
       end;
     6:
       begin
         while i1 <= tmp1 do begin
           MoveTo(X+wn-i1,Y+j1);
           LineTo(X+wn-i1,Y+hn div 2-j1);
           j1 := j1+1;
           i1 := i1+1;
         end;
       end;
     7:
       begin
         while j1 <= tmp2 do begin
           MoveTo(X+i1+1,Y+hn div 2-j1-1);
           LineTo(X+wn-i1-1,Y+hn div 2-j1-1);
           j1 := j1+1;
           i1 := i1+1;
         end;

         i1 := 0;
         j1 := 0;
         while j1 <= tmp2 do begin
           MoveTo(X+i1+1,Y+hn div 2+j1);
           LineTo(X+wn-i1-1,Y+hn div 2+j1);
           j1 := j1+1;
           i1 := i1+1;
         end;
       end;
    end;
    end;
  end;

  procedure DrawSymbol(X,Y: Integer; ch: Char; Color: TColor);
  begin
      FDrawBuffer.Canvas.Brush.Color := Color;
      FDrawBuffer.Canvas.Pen.Color := Color;
      case ch of
      ':':
        begin
          FDrawBuffer.Canvas.MoveTo(X+wn div 2-pw,Y+hn div 4-ph);
          FDrawBuffer.Canvas.LineTo(X+wn div 2-pw,Y+hn div 4+ph);

          FDrawBuffer.Canvas.LineTo(X+wn div 2+pw,Y+hn div 4-ph);

          FDrawBuffer.Canvas.LineTo(X+wn div 2-pw,Y+hn div 4-ph);
          FDrawBuffer.Canvas.FloodFill(X+wn div 2, Y+(hn-ph) div 4, Color, fsBorder);


          FDrawBuffer.Canvas.MoveTo(X+wn div 2+pw,Y+hn-hn div 4-ph);
          FDrawBuffer.Canvas.LineTo(X+wn div 2+pw,Y+hn-hn div 4+ph);

          FDrawBuffer.Canvas.LineTo(X+wn div 2-pw,Y+hn-hn div 4+ph);

          FDrawBuffer.Canvas.LineTo(X+wn div 2+pw,Y+hn-hn div 4-ph);
          FDrawBuffer.Canvas.FloodFill(X+wn div 2+pw div 2, Y+hn-(hn) div 4+ph div 2, Color, fsBorder);
        end;
       '.', ',':
        begin
          FDrawBuffer.Canvas.Rectangle(X+wn-2*pw, Y+hn-3*ph,X+wn, Y+hn-ph);
        end;
      end;
    end;

begin
   with Control{$ifndef F_P}^{$endif} do begin
    FDrawBuffer.canvas.Brush.Color:=FBackground;
    FDrawBuffer.canvas.Pen.Color:=FBackground;
    FDrawBuffer.Canvas.Rectangle(0, 0, width, height);

    (*Получаем квадрат для каждой цифры*)
    hn := Height;
    wn := 6*Height div 10;//Width div Digits - 3;

    (*Получаем квадрат для каждого пикселя*)
    pw := wn div 7;
    ph := wn div 10;

    j := 0;

    FDigits := Length(FText);
    For i:=0 to Length(FText)-1 do begin
      // TextAlign = Left
      if STextAlign = taLeft then begin
        k := wn * i + j
      end
      else
      // TextAlign = Right
      if STextAlign = taRight then begin
        k := wn*i+j+(Width-(wn+3)*FDigits)
      end
      else begin
      // TextAlign = Center
        k := wn*i+j+(Width-(wn+3)*FDigits)div 2;
      end;
      if FShowLines then begin
        DrawDigitLine(1,k,0, fShadow);
        DrawDigitLine(2,k,0, fShadow);
        DrawDigitLine(3,k,0, fShadow);
        DrawDigitLine(4,k,0, fShadow);
        DrawDigitLine(5,k,0, fShadow);
        DrawDigitLine(6,k,0, fShadow);
        DrawDigitLine(7,k,0, fShadow);
      end;

      case FText[i+1] of
       '0':
         begin
           DrawDigitLine(1,k,0, FForeground);
           DrawDigitLine(2,k,0, FForeground);
           DrawDigitLine(3,k,0, FForeground);
           DrawDigitLine(4,k,0, FForeground);
           DrawDigitLine(5,k,0, FForeground);
           DrawDigitLine(6,k,0, FForeground);
         end;
       '1':
         begin
           DrawDigitLine(6,k,0, FForeground);
           DrawDigitLine(5,k,0, FForeground);
         end;
       '2':
         begin
           DrawDigitLine(1,k,0, FForeground);
           DrawDigitLine(6,k,0, FForeground);
           DrawDigitLine(7,k,0, FForeground);
           DrawDigitLine(3,k,0, FForeground);
           DrawDigitLine(4,k,0, FForeground);
         end;
       '3':
         begin
           DrawDigitLine(1,k,0, FForeground);
           DrawDigitLine(6,k,0, FForeground);
           DrawDigitLine(7,k,0, FForeground);
           DrawDigitLine(5,k,0, FForeground);
           DrawDigitLine(4,k,0, FForeground);
         end;
       '4':
         begin
           DrawDigitLine(2,k,0, FForeground);
           DrawDigitLine(7,k,0, FForeground);
           DrawDigitLine(6,k,0, FForeground);
           DrawDigitLine(5,k,0, FForeground);
         end;
       '5':
         begin
          DrawDigitLine(1,k,0, FForeground);
          DrawDigitLine(2,k,0, FForeground);
          DrawDigitLine(7,k,0, FForeground);
          DrawDigitLine(5,k,0, FForeground);
          DrawDigitLine(4,k,0, FForeground);
         end;
       '6':
         begin
           DrawDigitLine(1,k,0, FForeground);
           DrawDigitLine(2,k,0, FForeground);
           DrawDigitLine(3,k,0, FForeground);
           DrawDigitLine(4,k,0, FForeground);
           DrawDigitLine(5,k,0, FForeground);
           DrawDigitLine(7,k,0, FForeground);
         end;
       '7':
          begin
           DrawDigitLine(1,k,0, FForeground);
           DrawDigitLine(6,k,0, FForeground);
           DrawDigitLine(5,k,0, FForeground);
          end;
       '8':
         begin
           DrawDigitLine(1,k,0, FForeground);
           DrawDigitLine(2,k,0, FForeground);
           DrawDigitLine(3,k,0, FForeground);
           DrawDigitLine(4,k,0, FForeground);
           DrawDigitLine(5,k,0, FForeground);
           DrawDigitLine(6,k,0, FForeground);
           DrawDigitLine(7,k,0, FForeground);
         end;
       '9':
         begin
           DrawDigitLine(1,k,0, FForeground);
           DrawDigitLine(2,k,0, FForeground);
           DrawDigitLine(6,k,0, FForeground);
           DrawDigitLine(7,k,0, FForeground);
           DrawDigitLine(5,k,0, FForeground);
           DrawDigitLine(4,k,0, FForeground);
         end;
       ' ':
         begin
         end;
       '-':
          begin
           DrawDigitLine(7,k,0, FForeground);
          end;
       '_':
          begin
           DrawDigitLine(4,k,0, FForeground);
          end;
       ':': // Рисуем треугольниками :)
         begin
           DrawSymbol(k,0,':', FForeground);
         end;
       '.', ',':
         begin
           DrawSymbol(k, 0, '.', FForeground);
         end;
      end;
      j := j+3;
    end;
    Control.Invalidate;
   end;
end;

end.