library LedNumber;


uses
  Windows,drawShare,kol;

procedure Draw(PRec:PParamRec; ed:pointer; dc:HDC); cdecl;
var
   i, j, k: Integer;
   wn, hn: Integer;
   pw, ph: Integer;
   Width,Height:integer;
   FDigits: Integer;

   FDrawBuffer : PBitmap;
   STextAlign:byte;
   fText:string;
   fShowLines:boolean;

   FShadow:integer; {FNoSegColor}
   FForeground:integer; {FSegColor}
   FBackground:integer; {fFonColor}

  procedure DrawDigitLine(Number: Integer; X,Y: Integer; Color: TColor);
  var
    i1,j1, tmp1, tmp2: Integer;
  begin

    with PCanvas(FDrawBuffer.Canvas)^ do begin
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
   Width     := integer(SearchParam(PRec, 'width').Value^);
   Height    := integer(SearchParam(PRec, 'height').Value^);

   fBackground    := ColorRGB(integer(SearchParam(PRec, 'FonColor').Value^));
   fForeground    := ColorRGB(integer(SearchParam(PRec, 'SegColor').Value^));
   FShadow        := ColorRGB(integer(SearchParam(PRec, 'NoSegColor').Value^));
   STextAlign     := byte(SearchParam(PRec, 'Alignment').Value^);
   fText          := string(SearchParam(PRec, 'Text').Value^);
   fShowLines     := not boolean(SearchParam(PRec, 'ShowLines').Value^);

   FDrawBuffer:= NewDIBBitmap(Width,Height,pf32bit);
   FDrawBuffer.canvas.Brush.Color:=FBackground;
   FDrawBuffer.canvas.Pen.Color:=FBackground;
   FDrawBuffer.Canvas.Rectangle(0, 0, width, height);

   hn := Height;
   wn := 6*Height div 10;//Width div Digits - 3;

   pw := wn div 7;
   ph := wn div 10;

   j := 0;

   FDigits := Length(FText);
   For i:=0 to Length(FText)-1 do begin
      if STextAlign = 0 then begin
        k := wn * i + j
      end
      else if STextAlign = 1 then begin
        k := wn*i+j+(Width-(wn+3)*FDigits)
      end
      else begin
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
       ':':
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
   BitBlt(DC,0,0,Width,Height,FDrawBuffer.Canvas.Handle,0,0,SRCCOPY);
   FDrawBuffer.free;
end;

exports
    Draw;

begin
end.
 