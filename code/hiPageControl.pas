    unit hiPageControl;

interface

uses Windows,Kol,Share,Win,WinLayout,hiPolyMorphMulti,hiHintManager,hiIconsManager;

type
 THIPageControl = class(THIPolymorphMulti)
   private
     fHint:IHintManager;
     fLayout:IWinLayout;
     hid:pointer;
     Split:PControl;
     fIconsManager:IIconsManager;

     procedure SetLayout(value:IWinLayout);
     procedure SetHintManager(value:IHintManager);
     procedure SetIconsManager(value:IIconsManager);
   public
     Control:PControl;    
     ManFlags:cardinal;
     _prop_Name:string;
     _prop_Left:integer;
     _prop_Top:integer;
     _prop_Width:integer;
     _prop_Height:integer;
     _prop_Align:TControlAlign;
     _prop_TabOrder:integer;
     _prop_Color:TColor;
     _prop_Ctl3D:byte;
     _prop_Hint:string;
     _prop_HintIcon:integer;
     _prop_HintTitle:string;
     _prop_Font:TFontRec;
     _prop_ParentFont:boolean;
     _prop_Transparent:boolean;
     _prop_Visible:boolean;
     _prop_Enabled:boolean;
     _prop_Cursor:integer;
     _prop_MouseCapture:boolean;
     _prop_Flat:boolean;
     _prop_KeyPreview:boolean; //!!! KeyPreview
     //Ñâ-à Splitter-à
      _prop_ModeSp:TNewSpl;
      _prop_SizeSp:integer;
      _prop_ColorSp:TColor;
      _prop_MinOwn:integer;
      _prop_MinRest:integer;
      _prop_WinStyle:byte;

     _prop_WidthScale:integer;
     _prop_HeightScale:integer;
     
     _prop_AutoCreate:boolean;
     _prop_SelectAdd:boolean;

     _prop_Buttons:boolean;

     procedure Init; override;
     procedure Add(var _Data:TData; Index:word); override;
     procedure Select(var Data:TData; Index:word); override;
     procedure Delete(var Data:TData; Index:word); override;
     procedure HDelete(var Data:TData; Index:word); override;
     procedure Index(var Data:TData; Index:word); override;
     
     property _prop_Layout:IWinLayout write SetLayout;
     property _prop_HintManager:IHintManager read fHint write SetHintManager;
     property _prop_IconsManager:IIconsManager read fIconsManager write SetIconsManager;     
 end;

implementation

uses hiPagePanel, hiPolyBase;

procedure THIPageControl.Init;
const wpFlag = SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_HIDEWINDOW;
var i:integer;
    dt:TData;
    tco:TTabControlOptions;
begin
  tco := [];
  if _prop_Buttons then
    tco:=[tcoButtons];
   Control := NewTabControl(FControl,[],tco,nil,0);
   if _prop_AutoCreate then
       for i := 1 to ClassCount-1 do
        begin          
          dtString(dt, Classes[i]); 
          Add(dt, 0);
        end;
    
   with Control{$ifndef F_P}^{$endif} do begin
      Color := _prop_Color;
      SetPosition(_prop_Left,_prop_Top);
      SetSize(_prop_Width,_prop_Height);
      if _prop_Ctl3D<2 then Ctl3D := _prop_Ctl3D=0;
      Transparent := _prop_Transparent;
      Enabled := _prop_Enabled;
//      Cursor := _prop_Cursor;
      CursorLoad(0, MakeIntResource(_prop_Cursor));
      if _prop_Flat then
         Style := Style or BS_FLAT;
      if _prop_ParentFont then
         Font.Assign(Parent.Font)
      else begin
         Font.Color := _prop_Font.Color;
         SetFont(Font,_prop_Font.Style);
         Font.FontName :=  _prop_Font.Name;
         Font.FontHeight := _hi_SizeFnt(_prop_Font.Size);
         Font.FontCharset := _prop_Font.CharSet;
      end;

      if _prop_TabOrder > 0 then begin
         Style := Style or WS_TABSTOP;
         LookTabKeys := [tkTab];
         TabOrder := _prop_TabOrder;
      end else
         TabStop := _prop_TabOrder = 0;

      Align := _prop_Align;
      SetWindowPos(GetWindowHandle, HWND_TOP, 0, 0, 0, 0, wpFlag);
      Visible := _prop_Visible;
      CreateWindow;
      
      if assigned(_prop_ModeSp) then begin
         Split := _prop_ModeSp(FControl,_prop_MinOwn,_prop_MinRest,_prop_ColorSp,_prop_SizeSp);
         SetWindowPos(Split.GetWindowHandle, HWND_TOP, 0, 0, 0, 0, wpFlag);
         case Align of
           caTop,caBottom:
             begin
               Height := Height - (_prop_SizeSp + FControl.Border);
               Split.visible := _prop_Visible;
             end;
           caLeft,caRight:
             begin
               Width := Width - (_prop_SizeSp + FControl.Border);
               Split.visible := _prop_Visible;
             end;
           else Split.visible := false;
         end;
         Split.CreateWindow;
      end;
   end;
end;

procedure THIPageControl.Add(var _Data:TData; Index:word);
//var dt:TData; 
begin
   Control.TC_Insert(Control.Count, 'tab', -1);
   FControl := Control.Pages[Control.Count-1];
   inherited;
   if _prop_SelectAdd then
     begin
       Control.CurIndex := Control.Count-1;
       //dtInteger(dt, Control.Count-1);
       //Select(dt, 0);  
     end;
end;

procedure THIPageControl.Select(var Data:TData; Index:word);
begin
   Control.CurIndex := ToInteger(Data);
   inherited;
end;

procedure THIPageControl.Delete(var Data:TData; Index:word);
var 
  i:integer;
//  dt:TData;
begin
   i := Control.CurIndex;
   Control.TC_Delete(ToInteger(Data));
   inherited;
   if Control.Count > 0 then
    begin 
       if i > 0 then
         Control.CurIndex := i - 1
         //dtInteger(dt, i - 1)
       else  
         Control.CurIndex := 0;
         //dtInteger(dt, 0);
         
       //Select(dt, 0);  
    end;
end;

procedure THIPageControl.HDelete(var Data:TData; Index:word);
var 
  i:integer;
begin
   i := Control.CurIndex;
   Control.TC_Delete(FChilds.IndexOfObj(pointer(ToInteger(Data))));
   inherited;
   if Control.Count > 0 then
       if i > 0 then
         Control.CurIndex := i - 1
       else  
         Control.CurIndex := 0;
end;

procedure THIPageControl.Index(var Data:TData; Index:word);
begin
  dtInteger(data, Control.CurIndex);
end;

procedure THIPageControl.SetLayout;
begin
  if value <> nil then
    value.addControl(Control, _prop_WidthScale, _prop_HeightScale);
  fLayout := value;  
end;

procedure THIPageControl.SetHintManager;
begin
  if value <> nil then
   begin
      hid := value.init(Control.GetWindowHandle);
      value.hint(hid, _prop_Hint);
      value.title(hid, _prop_HintIcon, _prop_HintTitle);
   end;
  fHint := value; 
end;

procedure THIPageControl.SetIconsManager;
begin
  if value <> nil then      
    Control.ImageListNormal := value.iconList;
end;

end.