unit hiWinBorders;

interface

uses Kol,Share,Debug,Windows,Win;

type
  THIWinBorders = class(TDebug)
   private
    procedure SetBorderStyle(h, Value:Cardinal);
    procedure SetWinStyle(h, Value:Cardinal);
   public
    _prop_BorderStyle:byte;
    _prop_WinStyle:byte;

    _data_Handle:THI_Event;

    procedure _work_doSetBorderStyle(var _Data:TData; Index:word);
    procedure _work_doSetWinStyle(var _Data:TData; Index:word);
  end;

implementation

procedure THIWinBorders.SetBorderStyle;
begin
  if Value >= Cardinal(Length(BorderStyle_Set)) then exit;
  SetWindowLong(h, GWL_STYLE, BorderStyle_Set[Value] or (BorderStyle_Mask and GetWindowLong(h, GWL_STYLE)));
  SetWindowLong(h, GWL_EXSTYLE, BorderStyle_ExSet[Value] or (BorderStyle_ExMask and GetWindowLong(h, GWL_EXSTYLE)));
  SetWindowPos(h, 0, 0,0,0,0, SWP_FRAMECHANGED or SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOOWNERZORDER);
end;

procedure THIWinBorders.SetWinStyle;
begin
  if Value > Cardinal(Length(WinStyle_ExSet)) then exit;
  SetWindowLong(h, GWL_EXSTYLE, WinStyle_ExSet[Value] or (WinStyle_ExMask and GetWindowLong(h, GWL_EXSTYLE)));
  SetWindowPos(h, 0, 0,0,0,0, SWP_FRAMECHANGED or SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOOWNERZORDER);
end;

procedure THIWinBorders._work_doSetBorderStyle;
var h:cardinal;
    v:integer;
begin
  h := ReadInteger(_Data, _data_Handle);
  if _prop_BorderStyle = 2 then
    v := ToInteger(_Data)
  else
    v := ReadInteger(_Data, NULL, _prop_BorderStyle);
  SetBorderStyle(h, v);
end;

procedure THIWinBorders._work_doSetWinStyle;
var h:cardinal;
    v:integer;
begin
  h := ReadInteger(_Data, _data_Handle);
  if _prop_WinStyle = 1 then
    v := ToInteger(_Data)
  else
    v := ReadInteger(_Data, NULL, _prop_WinStyle);
  SetWinStyle(h, v);
end;

end.
