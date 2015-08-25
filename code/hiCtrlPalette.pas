unit hiCtrlPalette;

interface

uses Windows,Messages,Kol,Share,Debug,Win,hiIconsManager,hiIndexManager,hiBoxDrawManager;

type
  THICtrlPalette = class(THIWin)
   private
    FBorder:HPEN;
    FBack:HBRUSH;
    FCaptionBack:HBRUSH;
    FCaptionH:integer;
    FList:PStrList;
    FActive:integer;
    FCFont   : PGraphicTool;
    FSelectedFont   : PGraphicTool;
    FArrow:HPEN;
    
    procedure SetNewCFont(Value:TFontRec);
    procedure SetNewSelectedFont(Value:TFontRec);
    procedure _OnClick( Sender: PObj );
    procedure _OnPaint( Sender: PControl; DC: HDC );
    procedure _onMouseDown(Sender: PControl; var Mouse: TMouseEventData); override;
    procedure _onMouseMove(Sender: PControl; var Mouse: TMouseEventData); override;
    procedure _onMouseLeave( Sender: PObj ); override;
    procedure SetText(const Value:string);
    procedure ReDraw(index:integer);
    procedure Invalidate;
   public
    _prop_DefDropDown:boolean;
    _prop_CollapseOnSelect:boolean;
    _prop_Caption:string;  
    _prop_CColor:TColor;
    _prop_BColor:TColor;
    _prop_IconsManager:IIconsManager;
    _prop_IndexManager:IIndexManager;   
    _prop_BoxDrawManager:IBoxDrawManager;
    _prop_ItemHeight:integer;
    _prop_Padding:integer;
    _prop_FileName:string;

    _data_str:THI_Event;    
    _data_FileName:THI_Event;
    _event_onClick:THI_Event;
    _event_onChangeState:THI_Event;
    _event_onChange:THI_Event;    
    
    constructor Create(Parent:PControl);
    destructor Destroy; override;
    procedure Init; override;
    property _prop_Strings:string write SetText;
    property _prop_CFont:TFontRec write SetNewCFont;
    property _prop_SelectedFont:TFontRec write SetNewSelectedFont;

    procedure _work_doAdd(var _Data:TData; Index:word);    
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doReplace(var _Data:TData; Index:word);
    procedure _work_doInsert(var _Data:TData; Index:word);
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
                
    procedure _work_doCaption(var _Data:TData; Index:word);
    procedure _work_doStrings(var _Data:TData; Index:word);
    
    procedure _var_Strings(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_EndIdx(var _Data:TData; Index:word);    
    
  end;

implementation

constructor THICtrlPalette.Create;
begin
   inherited Create(Parent);
   FList := NewStrList;
   Control := NewPaintbox(Parent);
//   Control := NewHiCtrlPalette(Parent);
//   TKOLCtrlPalette(Control).OnCtrlPaletteClick := nil;
   SetClassLong(Control.Handle,GCL_STYLE,GetClassLong(Control.GetWindowHandle,GCL_STYLE) and not CS_DBLCLKS);
end;

destructor THICtrlPalette.Destroy;
begin
   DeleteObject(FBorder);
   DeleteObject(FBack);
   DeleteObject(FCaptionBack);
   DeleteObject(FArrow);
   FCFont.free;
   FSelectedFont.free;
   FList.Free;
   inherited;
end;

procedure THICtrlPalette.Init;
begin
   inherited;
   with Control{$ifndef F_P}^{$endif} do
    begin
     OnClick := _OnClick;
     OnPaint := _OnPaint;
    end;
   FBorder := CreatePen(0, 1, Color2RGB(_prop_BColor));
   FArrow := CreatePen(0, 1, Color2RGB(clBlack));
   FBack := CreateSolidBrush(Color2RGB(Control.Color)); 
   FCaptionBack := CreateSolidBrush(Color2RGB(_prop_CColor));
   FCaptionH := 18;
   if _prop_DefDropDown then
     Control.Height := FCaptionH + FList.Count * _prop_ItemHeight + _prop_Padding*2 + 2
   else
     Control.Height := FCaptionH + 1;  
   FActive := -1; 
end;

procedure THICtrlPalette.SetText;
begin
   Flist.Text := Value;
end;

procedure THICtrlPalette.ReDraw(index:integer);
var 
    r:TRect;
begin
   r.Top := FCaptionH + _prop_Padding + index*_prop_ItemHeight + 1;
   r.Left := 0;
   r.Right := Control.Width;
   r.Bottom := r.Top + _prop_ItemHeight;
   InvalidateRect(Control.Handle, @r, false);
end;

procedure THICtrlPalette._OnClick;
begin
end;

procedure THICtrlPalette._onMouseDown;
var n:integer;
begin
   inherited;
   if Mouse.y < FCaptionH then
    if Control.height = FCaptionH + 1 then
      begin
       Control.Height := FCaptionH + FList.Count * _prop_ItemHeight + _prop_Padding*2 + 2;
       _hi_OnEvent(_event_onChangeState, 1);
      end
    else 
      begin
       Control.Height := FCaptionH + 1;
       _hi_OnEvent(_event_onChangeState, 0);
      end
   else
    begin
      n := (Mouse.y - FCaptionH - _prop_Padding) div _prop_ItemHeight;
      if n <> -1 then
      begin
        _hi_onEvent(_event_onClick, FList.Items[n]);
        if _prop_CollapseOnSelect then Control.Height := FCaptionH + 1;
      end;  
    end;
end;

procedure THICtrlPalette._onMouseMove;
var n,old:integer;
begin
   inherited;
   if Mouse.y > FCaptionH then
     n := (Mouse.y - FCaptionH - _prop_Padding) div _prop_ItemHeight
   else n := -1;
   if n <> FActive then
    begin
      old := FActive;
      FActive := n;
      ReDraw(old);
      ReDraw(FActive);
    end;  

end;

procedure THICtrlPalette._onMouseLeave;
var old:integer;
begin
   inherited;
   old := FActive;
   FActive := -1;
   ReDraw(old);
end;

procedure THICtrlPalette._OnPaint;
var idx : integer;
    imgsz,off : integer;
    i,y,a:integer;
    IList : PImageList;
    cbRect : TRect;
    st:TDrawState;
    tsz:integer;
begin
    tsz := PControl(Sender).Canvas.TextExtent('W').cy; 
    SelectObject(DC, FBorder);
    SelectObject(DC, FCaptionBack);
    Rectangle(DC,0,0,Control.Width,FCaptionH+1);
   
    SetTextColor(DC, FCFont.Color);
    SelectObject(DC, FCFont.Handle);
    SetBkMode(DC, TRANSPARENT);
    TextOut(DC, 5, 3, PChar(_prop_Caption), Length(_prop_Caption));
    
    a := 6;
    y := FCaptionH div 2 - a div 2 + 1;
    SelectObject(DC, FArrow);
    if Control.Height = FCaptionH+1 then
      i := 0
    else i := 1;
    MoveToEx(DC, Control.Width - 4 - a, y + (a div 2)*i, nil);
    LineTo(DC, Control.Width - 4 - a div 2, y + (a div 2)*(1 - i));
    LineTo(DC, Control.Width - 4 +  1, y + (a div 2)*i + i*2 - 1);
    
    SelectObject(DC, FBorder);     
    SelectObject(DC, FBack);
    Rectangle(DC,0,FCaptionH,Control.Width,Control.Height);
    for i := 0 to FList.Count-1 do
     begin
      y := FCaptionH + _prop_Padding + i*_prop_ItemHeight + 1;  
      if Assigned(_prop_BoxDrawManager) then 
        begin
         cbRect.left := 1;
         cbRect.top := y;
         cbRect.right := Control.Width-1;
         cbRect.bottom := y + _prop_ItemHeight;
         if i = FActive then
           st := [odsSelected]
         else st := []; 
         _prop_BoxDrawManager.draw(Control, DC, cbRect, i, st, false, PControl(Sender).Font.Handle);
         off := _prop_BoxDrawManager.shift;
        end
      else off := 0;

        if (Assigned(_prop_IndexManager)) and (Assigned(_prop_IconsManager)) then
          begin
             IList := _prop_IconsManager.iconList;
             if not Assigned(IList) then exit;
             idx := _prop_IndexManager.outidx(i);
             imgsz := _prop_IconsManager.imgsz;         
             with cbRect do
             begin
                Top:= FCaptionH + _prop_Padding + i*_prop_ItemHeight + (_prop_ItemHeight - imgsz) div 2;
                Left:= 2;
                Bottom:= Top + imgsz; 
                Right:= Left + imgsz;
             end;
             if (idx < 0) or (idx > IList.Count - 1) then
               idx := SKIP;      
             IList.Draw(idx, DC, cbRect.Left, cbRect.Top);   
          end;      
      if FActive = i then
       begin
        SelectObject(DC, FSelectedFont.Handle);
        SetTextColor(DC, FSelectedFont.Color);
       end 
      else
       begin
        SelectObject(DC, Control.Font.Handle);
        SetTextColor(DC, Control.Font.Color);
       end; 

      y := y + ((_prop_ItemHeight - tsz) div 2);
      TextOut(DC, 18 + off, y, PChar(FList.Items[i]), Length(FList.Items[i]));
     end;
end;

procedure THICtrlPalette.SetNewCFont;
begin
   if Assigned(FCFont) then FCFont.free;
   FCFont := NewFont;
   FCFont.Color:= Value.Color;
   Share.SetFont(FCFont,Value.Style);
   FCFont.FontName:= Value.Name;
   FCFont.FontHeight:= _hi_SizeFnt(Value.Size);
   FCFont.FontCharset:= Value.CharSet;
end;

procedure THICtrlPalette.SetNewSelectedFont;
begin
   if Assigned(FSelectedFont) then FSelectedFont.free;
   FSelectedFont := NewFont;
   FSelectedFont.Color:= Value.Color;
   Share.SetFont(FSelectedFont,Value.Style);
   FSelectedFont.FontName:= Value.Name;
   FSelectedFont.FontHeight:= _hi_SizeFnt(Value.Size);
   FSelectedFont.FontCharset:= Value.CharSet;
end;

procedure THICtrlPalette._work_doCaption;
begin
  _prop_Caption := ToString(_Data);
  InvalidateRect(Control.Handle, nil, false);
end;

procedure THICtrlPalette.Invalidate;
begin
  if Control.height > FCaptionH + 1 then
    Control.Height := FCaptionH + FList.Count * _prop_ItemHeight + _prop_Padding*2 + 2;
  InvalidateRect(Control.Handle, nil, false);
end;

procedure THICtrlPalette._work_doStrings;
begin
  _prop_Strings := ToString(_Data);
  Invalidate;
  _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THICtrlPalette._work_doAdd;
begin
  FList.Add(ReadString(_Data,_data_str,''));
  Invalidate;
  _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THICtrlPalette._work_doClear;
begin
  FList.Clear;
  Invalidate;
  _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THICtrlPalette._work_doDelete;
var
  ind:integer;
begin
  ind := ToIntIndex(_Data);
  if (ind < 0) or (ind > FList.Count - 1) then exit;
  FList.Delete(ind);
  Invalidate;
  _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THICtrlPalette._work_doInsert;
var
  ind:integer;
begin
  ind := ToIntIndex(_Data);
  if (ind < -1) or (ind > FList.Count) then exit
  else
    if ind = -1 then
      ind := FList.Count; 
  FList.Insert(ind, ReadString(_Data, _data_str, ''));
  Invalidate;  
  _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THICtrlPalette._work_doReplace;
var
  ind:integer;
begin
  ind := ToIntIndex(_Data);
  if (ind < 0) or (ind > FList.Count - 1) then exit;
  FList.Delete(ind);
  FList.Insert(ind, ReadString(_Data, _data_str, ''));
  Invalidate;     
  _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THICtrlPalette._work_doLoad;
var
  fn:string;
begin
  fn := ReadString(_Data,_data_FileName,_prop_FileName);
  if FileExists(fn) then
  begin
    FList.LoadFromFile(fn);
    Invalidate;
    _hi_CreateEvent(_Data, @_event_onChange);
  end;
end;

procedure THICtrlPalette._work_doSave;
var
  fn:string;
begin
  fn := ReadString(_Data,_data_FileName,_prop_FileName);
  FList.SaveToFile(fn);
end;

procedure THICtrlPalette._var_Strings;
begin
  dtString(_Data, FList.Text);
end;

procedure THICtrlPalette._var_Count;
begin
  dtInteger(_Data, FList.Count);
end;

procedure THICtrlPalette._var_EndIdx;
begin
 dtInteger(_Data, FList.Count - 1);
end;

end.
