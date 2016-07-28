//Алгоритмы анимации взяты из компонента JvFormAnimation библиотеки JEDI VCL
//----------------------------------------------------------------------------
{The Original Code is: JvFormAnimation.PAS, released on 2001-02-28.

The Initial Developer of the Original Code is Sebastien Buysse [sbuysse att buypin dott com]
Portions created by Sebastien Buysse are Copyright (C) 2001 Sebastien Buysse.
All Rights Reserved.

Contributor(s): Michael Beck [mbeck att bigfoot dott com].

You may retrieve the latest version of this file at the Project JEDI's JVCL home page,
located at http://jvcl.sourceforge.net  }

unit hiWindowAnimation;

interface

uses Kol,Share,Debug,Windows;

type
   
  THIWindowAnimation = class(TDebug)
  private
    FRegions: array of HRGN;
    FSpeed:Byte;
    FType:Byte;
    FAnimInProcess:bool;
    FWinWidth, FWinHeight, FStep:integer;
    FWinHandle:HWND; 
    FThread:PThread;
    FL:Integer;
    
    procedure AnimateDisappear;
    procedure AnimateAppear;
    function AnimateAppearThread (Sender:PThread):Integer;
    function AnimateDisappearThread (Sender:PThread):Integer;
    procedure GenerateEvent;
    procedure DeleteRegions;
    procedure SetSpeed(Value:byte);
    function GetSpeed:byte;
    
    procedure AppearEllipse;
    procedure AppearRectangle;
    procedure AppearHorizontally;
    procedure AppearVertically;
    procedure AppearTelevision;
    procedure AppearFromTop;
    procedure AppearFromBottom;
    procedure AppearCW;
    procedure AppearFromLeft;
    procedure AppearFromRight;
    
  public
    _data_Speed:THI_Event;
    _data_Step:THI_Event;
    _data_Handle:THI_Event;
    _data_Type:THI_Event;
    _prop_Type:byte;
    _prop_Mode:byte;
    _prop_InNewThread:byte;
    _event_onEndAnimation:THI_Event;
    procedure _work_doAnimate(var _Data:TData; Index:word);
    property _prop_Speed:byte read GetSpeed write SetSpeed;
    property _prop_Step:integer read FStep write FStep;
    constructor Create;

  end;

implementation

constructor THIWindowAnimation.Create;
begin
  inherited Create;
  FSpeed:=10;
  FAnimInProcess:=false;
  FStep:=1;
end;

procedure THIWindowAnimation._work_doAnimate;
var WinRect:TRect; Rgn:HRGN;
begin
  if FAnimInProcess=true then exit;
  FWinHandle:=ReadInteger(_Data, _data_Handle);
  Rgn := CreateRectRgn(0, 0, 0, 0);//
  if Integer(GetWindowRgn(FWinHandle, Rgn))=0 then
  begin
    if Integer(GetWindowRect(FWinHandle,WinRect))=0 then
    begin
      DeleteObject(Rgn);
      exit;
    end; 
  end
  else
  begin
    GetRgnBox(Rgn,WinRect);
    DeleteObject(Rgn);
  end;     
  
  FAnimInProcess:=true;
  FWinWidth:=WinRect.Right-WinRect.Left;
  FWinHeight:=WinRect.Bottom-WinRect.Top;
  SetSpeed(ReadInteger(_Data, _data_Speed, _prop_Speed));
  FStep:=ReadInteger(_Data, _data_Step, _prop_Step);
  FType:=ReadInteger(_Data, _data_Type, _prop_Type);

/////////////////////////
  if _prop_InNewThread=1 then
  begin
    FThread:={$ifdef F_P}NewThreadforFPC{$else}NewThread{$endif};
    FThread.AutoFree:=true;
    if Frac(FType / 2)=0 then FThread.OnExecute:=AnimateDisappearThread  // Если FType четное, то анимация исчезновения, иначе - появления
    else FThread.OnExecute:=AnimateAppearThread;
  end;
////////////////////////

  Case FType of
    1,2:AppearEllipse;
    3,4:AppearRectangle;
    5,6:AppearHorizontally;
    7,8:AppearVertically;
    9,10:AppearTelevision;
    11,12:AppearFromTop;
    13,14:AppearFromBottom;
    15,16,17,18:AppearCW;
    19,20:AppearFromLeft;
    21,22:AppearFromRight;
  else
    begin
      if assigned(FThread) then FThread.free;
      FAnimInProcess:=false;
    end;  
  end;
end;

procedure THIWindowAnimation.SetSpeed(Value:byte);
begin
  if Value>254 then FSpeed:=1 else FSpeed:=255-Value;
end;

function THIWindowAnimation.GetSpeed:byte;
begin
  Result:=255-FSpeed;
end;


procedure THIWindowAnimation.AnimateDisappear;
var
  I, Res: Integer; OldRgn, TempRgn:HRGN;
begin
  ShowWindow(FWinHandle, SW_SHOW);  
  I:=0;
  OldRgn := CreateRectRgn(0, 0, FWinWidth, FWinHeight);
  Res:= Integer(GetWindowRgn(FWinHandle, OldRgn));
  
  while I<=FL do
  begin
    if FRegions[I]<>0 then
    begin
      TempRgn := CreateRectRgn(0, 0, 0, 0);
      CombineRgn(TempRgn, FRegions[I], OldRgn, RGN_AND);
      SetWindowRgn(FWinHandle, TempRgn, True);
      DeleteObject(TempRgn);
      if (Assigned(Applet)) and (_prop_InNewThread=0) then Applet.ProcessMessages;
      Sleep(FSpeed);
    end;  
    I:=I+FStep;
  end;
      
  ShowWindow(FWinHandle, SW_HIDE);
  if _prop_Mode=1 then SetWindowRgn(FWinHandle, 0, True) else
    if Res<2 then SetWindowRgn(FWinHandle, 0, True) else SetWindowRgn(FWinHandle, OldRgn, True); 
  DeleteObject(OldRgn);
  DeleteRegions;
  if _prop_InNewThread=0 then GenerateEvent;
end;


procedure THIWindowAnimation.AnimateAppear;
var
  I, Res: Integer;
  Rgn, OldRgn, TempRgn: HRGN;
begin
  OldRgn := CreateRectRgn(0, 0, FWinWidth, FWinHeight);
  ShowWindow(FWinHandle, SW_HIDE);
  Res:=Integer(GetWindowRgn(FWinHandle, OldRgn));
  Rgn := CreateRectRgn(0, 0, 0, 0);
  SetWindowRgn(FWinHandle, Rgn, true);
  ShowWindow(FWinHandle, SW_SHOW);
  I:=FL;

  while I>=0 do
  begin
    if FRegions[I]<>0 then
    begin
      TempRgn := CreateRectRgn(0, 0, 0, 0);
      CombineRgn(TempRgn, FRegions[I], OldRgn, RGN_AND);
      SetWindowRgn(FWinHandle, TempRgn, True);
      DeleteObject(TempRgn); 
      if (Assigned(Applet)) and (_prop_InNewThread=0) then Applet.ProcessMessages;
      Sleep(FSpeed);
    end;  
    I:=I-FStep;
  end;
  
  if _prop_Mode=1 then SetWindowRgn(FWinHandle, 0, True) else
    if Res<2 then SetWindowRgn(FWinHandle, 0, True) else SetWindowRgn(FWinHandle, OldRgn, True);
  DeleteObject(Rgn);
  DeleteObject(OldRgn);
  DeleteRegions;
  
  if _prop_InNewThread=0 then GenerateEvent;
end; 


function THIWindowAnimation.AnimateAppearThread (Sender:PThread):Integer;
begin
  AnimateAppear;
  FThread.Synchronize(GenerateEvent);
end;

function THIWindowAnimation.AnimateDisappearThread (Sender:PThread):Integer;
begin
  AnimateDisappear;
  FThread.Synchronize(GenerateEvent);
end;

procedure THIWindowAnimation.DeleteRegions;
var
  I: Integer;
begin
  for I := Low(FRegions) to High(FRegions) do DeleteObject(FRegions[I]);
  SetLength(FRegions, 0);
  FAnimInProcess:=false;
end;

procedure THIWindowAnimation.GenerateEvent;
begin
  if Frac(FType / 2)=0 then _hi_OnEvent(_event_onEndAnimation,1)
  else _hi_OnEvent(_event_onEndAnimation,0);
end;


procedure THIWindowAnimation.AppearEllipse;
var
  I, K, JJ: Integer;  DJ, J: real;
begin

  J := 0;
  I := 0;
  DJ:= FWinHeight * 2 / FWinWidth;
  
  SetLength(FRegions, Max(FWinWidth, FWinHeight));
  
  for K := 0 to High(FRegions) do
  begin
    if I < (FWinWidth div 2) then
    begin
      J := J + DJ;
      JJ:=Round(J);
      FRegions[K] := CreateEllipticRgn(I, JJ, FWinWidth - I, FWinHeight - JJ);
      I := I + 2;
    end
    else
    begin
      FL := K;
      Break;
    end;
  end;
  
  if _prop_InNewThread=1 then FThread.Resume else 
    if Frac(FType / 2)=0 then AnimateDisappear else AnimateAppear;
end;


procedure THIWindowAnimation.AppearRectangle;
var
  I, K, JJ: Integer;  DJ, J: real;
begin

  J := 0;
  I := 0;
  DJ:= FWinHeight * 2 / FWinWidth;
  
  SetLength(FRegions, Max(FWinWidth, FWinHeight));
  
  for K := 0 to High(FRegions) do
  begin
    if I < (FWinWidth div 2) then
    begin
      J := J + DJ;
      JJ:=Round(J);
      FRegions[K] := CreateRectRgn(I, JJ, FWinWidth - I, FWinHeight - JJ);
      I := I + 2;
    end
    else
    begin
      FL := K;
      Break;
    end;
  end;
  
  if _prop_InNewThread=1 then FThread.Resume else 
    if Frac(FType / 2)=0 then AnimateDisappear else AnimateAppear;
end;


procedure THIWindowAnimation.AppearHorizontally;
var
  I, J, K: Integer;
begin

  J := 0;
  I := 0;

  SetLength(FRegions, Max(FWinWidth, FWinHeight));
  for K := 0 to High(FRegions) do
  begin
    if I < (FWinWidth div 2) then
    begin
      if J > (FWinHeight div 2) then I := FWinWidth;
      FRegions[K] := CreateRectRgn(I, J, FWinWidth - I, FWinHeight - J);
      I := I + 2;
    end
    else
    begin
      FL := K;
      Break;
    end;
  end;

  if _prop_InNewThread=1 then FThread.Resume else 
    if Frac(FType / 2)=0 then AnimateDisappear else AnimateAppear;
end;


procedure THIWindowAnimation.AppearVertically;
var
  I, J, K: Integer;
begin

  J := 0;
  I := 0;

  SetLength(FRegions, Max(FWinWidth, FWinHeight));
  for K := 0 to High(FRegions) do
  begin
    if J < (FWinHeight div 2) then
    begin
      J := J + 2;
      if J > (FWinHeight div 2) then I := FWinWidth;
      FRegions[K] := CreateRectRgn(I, J, FWinWidth - I, FWinHeight - J);
    end
    else
    begin
      FL := K;
      Break;
    end;
  end;

  if _prop_InNewThread=1 then FThread.Resume else 
    if Frac(FType / 2)=0 then AnimateDisappear else AnimateAppear;
end;


procedure THIWindowAnimation.AppearTelevision;
var
  I, J, K: Integer;
begin

  J := 0;
  I := 0;

  SetLength(FRegions, Max(FWinWidth, FWinHeight));
  for K := 0 to High(FRegions) do
  begin
    if J + 2 < (FWinHeight div 2) then
    begin
      J := J + 2;
      if J > (FWinHeight div 2) then I := FWinWidth;
      FRegions[K] := CreateRectRgn(I, J, FWinWidth - I, FWinHeight - J);
    end
    else
    if I + 6 < (FWinWidth div 2) then
    begin
      I := I + 8;
      FRegions[K] := CreateRectRgn(I, J, FWinWidth - I, FWinHeight - J);
    end
    else
    begin
      FL := K;
      Break;
    end;
  end;
  
  if _prop_InNewThread=1 then FThread.Resume else 
    if Frac(FType / 2)=0 then AnimateDisappear else AnimateAppear;
end;


procedure THIWindowAnimation.AppearFromTop;
var
  I, J, K: Integer;
begin

  J := 0;
  I := 0;

  SetLength(FRegions, Max(FWinWidth, FWinHeight));
  for K := 0 to High(FRegions) do
  begin
    if J < FWinHeight then
    begin
      J := J + 2;
      FRegions[K] := CreateRectRgn(I, 0, FWinWidth, FWinHeight - J);
    end
    else
    begin
      FL := K;
      Break;
    end;
  end;

  if _prop_InNewThread=1 then FThread.Resume else 
    if Frac(FType / 2)=0 then AnimateDisappear else AnimateAppear;
end;


procedure THIWindowAnimation.AppearFromBottom;
var
  I, J, K: Integer;
begin

  J := 0;
  I := 0;

  SetLength(FRegions, Max(FWinWidth, FWinHeight));
  for K := 0 to High(FRegions) do
  begin
    if J < FWinHeight then
    begin
      J := J + 2;
      FRegions[K] := CreateRectRgn(I, J, FWinWidth, FWinHeight);
    end
    else
    begin
      FL := K;
      Break;
    end;
  end;

  if _prop_InNewThread=1 then FThread.Resume else 
    if Frac(FType / 2)=0 then AnimateDisappear else AnimateAppear;
end;


procedure THIWindowAnimation.AppearCW;
var K: byte; Points: array [0..2] of TPoint; Rgn1: HRGN; Ang, R, D: real;
begin
  Points[0].x := FWinWidth div 2;
  Points[0].y := FWinHeight div 2;
  Points[1].x := Points[0].x;
  Points[1].y := 0;
  R:= sqrt(sqr(Points[0].x) + sqr(Points[0].y)) + 2;
  Ang:=0;
  D:=pi/90;
  if FType<17 then D:=D*(-1); // Направление CW или CCW
  
  SetLength(FRegions, 180);
    
  For K:=0 to 179 do
  begin
    Points[2].x := Points[0].x + Round(R * Sin(Ang));
    Points[2].y := Points[0].y - Round(R * Cos(Ang));
    Rgn1 := CreatePolygonRgn(Points, 3, 2);
    FRegions[K] := CreateRectRgn(0, 0, FWinWidth, FWinHeight);
    CombineRgn(FRegions[K], FRegions[K-1], Rgn1, RGN_DIFF);
    DeleteObject(Rgn1);
    Points[1].x := Points[2].x;
    Points[1].y := Points[2].y;
    Ang:=Ang + D;
  end;
 
  FL:=179;
  
  if _prop_InNewThread=1 then FThread.Resume else 
    if Frac(FType / 2)=0 then AnimateDisappear else AnimateAppear;  
end;

procedure THIWindowAnimation.AppearFromLeft;
var
  I, J, K: Integer;
begin

  J := 0;
  I := 0;

  SetLength(FRegions, Max(FWinWidth, FWinHeight));
  for K := 0 to High(FRegions) do
  begin
    if J < FWinWidth then
    begin
      J := J + 2;
      FRegions[K] := CreateRectRgn(I, 0, FWinWidth - J, FWinHeight);
    end
    else
    begin
      FL := K;
      Break;
    end;
  end;

  if _prop_InNewThread=1 then FThread.Resume else 
    if Frac(FType / 2)=0 then AnimateDisappear else AnimateAppear;
end;


procedure THIWindowAnimation.AppearFromRight;
var
  I, J, K: Integer;
begin

  J := 0;
  I := 0;

  SetLength(FRegions, Max(FWinWidth, FWinHeight));
  for K := 0 to High(FRegions) do
  begin
    if I < FWinWidth then
    begin
      I := I + 2;
      FRegions[K] := CreateRectRgn(I, J, FWinWidth, FWinHeight);
    end
    else
    begin
      FL := K;
      Break;
    end;
  end;

  if _prop_InNewThread=1 then FThread.Resume else 
    if Frac(FType / 2)=0 then AnimateDisappear else AnimateAppear;
end;




end.
