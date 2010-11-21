unit hiAS_DrawRect;

interface

uses Windows,Kol,Share,Debug,hiActionSkin;

type
  THIAS_DrawRect = class(TDebug)
   private
    FParam:PDRectParam;
   public
    _prop_Name:string;

    _data_ASHandle:THI_Event;
    _event_onPaint:THI_Event;

    procedure _work_doRefresh(var _Data:TData; Index:word);
    procedure _var_Bitmap(var _Data:TData; Index:word);
    procedure _var_Rect(var _Data:TData; Index:word);
  end;

implementation

procedure THIAS_DrawRect._work_doRefresh;
var
  i:integer;
  dt:TData;
  _as:THIActionSkin;
begin
   dt := ReadData(_Data,_data_ASHandle);
   if _isObject(dt,AS_GUID) then
    begin
     _as := THIActionSkin(ToObject(dt));
     FParam := nil;
     for i := 0 to _as.DrawList.Count-1 do
      if LowerCase(_prop_Name) = lowercase( _as.DrawList.Items[i] ) then
       begin
        FParam := pointer(_as.DrawList.Objects[i]);
        Break;
       end;
     if FParam <> nil then
      begin
       if not FParam.Transp then
         begin
           FParam.Bmp.Canvas.Brush.Color := FParam.Color;
           FParam.Bmp.Canvas.Brush.BrushStyle := bsSolid;
           FParam.Bmp.Canvas.FillRect(MakeRect(0,0,FParam.Bmp.Width,FParam.Bmp.Height));
         end
       else
        if _as.Bmp <> nil then
         with FParam.R do
          BitBlt(FParam.Bmp.Canvas.Handle,0,0,FParam.Bmp.Width,FParam.Bmp.Height,
                _as.Bmp.Canvas.Handle,Left,Top,SRCCOPY);
       _hi_OnEvent(_event_onPaint);
       if _as.Main <> nil then
         FParam.Bmp.Draw(_as.Main.Canvas.Handle,FParam.R.Left,FParam.R.Top);
       InvalidateRect(_as.Control.Handle,@FParam.R,false);
      end;
    end;
end;

procedure THIAS_DrawRect._var_Bitmap;
begin
  if FParam <> nil then
    dtBitmap(_Data,FParam.Bmp)
  else dtNull(_Data);
end;

procedure THIAS_DrawRect._var_Rect;
begin
  if FParam <> nil then
    dtRect(_Data,@FParam.R)
  else dtNull(_Data);
end;

end.
