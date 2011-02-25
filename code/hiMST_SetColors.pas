unit hiMST_SetColors;

interface
     
uses Messages, Windows, Kol, Share, Debug, hiMTStrTbl;

type
  THIMST_SetColors = class(TDebug)
   private
     FIconColColor, FTextColor, FTextBkColor, FBkColor,
     FGradientColor, FShadowColor: TColor;
     FData: TData;
     FMSTControl: IMSTControl;
     procedure SetMSTControl(Value: IMSTControl); 
   public
     _prop_ColorItems: boolean;
     _event_onChangeProperty :THI_Event;     

     property _prop_MSTControl: IMSTControl read FMSTControl write SetMSTControl;
     destructor Destroy; override;

     property _prop_IconColColor: TColor  write FIconColColor;
     property _prop_TextColor: TColor     write FTextColor;
     property _prop_TextBkColor: TColor   write FTextBkColor;
     property _prop_BkColor: TColor       write FBkColor;
     property _prop_GradientColor: TColor write FGradientColor;
     property _prop_ShadowColor: TColor   write FShadowColor;

     procedure _work_doTextColor(var _Data: TData; Index: Word);
     procedure _work_doTextBkColor(var _Data: TData; Index: Word);
     procedure _work_doBkColor(var _Data: TData; Index: Word);
     procedure _work_doIconColColor(var _Data: TData; Index: Word);     
     procedure _var_GenColors(var _Data: TData; Index: Word);

  end;

implementation

destructor THIMST_SetColors.Destroy;
begin
  FreeData(@FData);
  inherited;
end;

procedure THIMST_SetColors.SetMSTControl;
begin
  if Value = nil then exit; 
  FMSTControl := Value;
  FMSTControl.stextcolor(FTextColor);
  FMSTControl.stextbkcolor(FTextBkColor);  
  FMSTControl.sbkcolor(FBkColor);
  FMSTControl.siconcolcolor(FIconColColor);
end;

procedure THIMST_SetColors._work_doTextColor;
begin
  FTextColor := ToInteger(_Data);
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.stextcolor(FTextColor);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_SetColors._work_doTextBkColor;
begin
  FTextBkColor := ToInteger(_Data);
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.stextbkcolor(FTextBkColor);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_SetColors._work_doBkColor;
begin
  FBkColor := ToInteger(_Data);
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.sbkcolor(FBkColor);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_SetColors._work_doIconColColor;
begin
  FIconColColor := ToInteger(_Data);
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.siconcolcolor(FIconColColor);
  _hi_onEvent(_event_onChangeProperty);  
end;

//-----------------------   MT-переменные   ---------------------------
//
// Содержит MT-элементы главных цветов таблицы
// ARG(BkColor, TextColor, TextBkColor, IconColColor)
//
procedure THIMST_SetColors._var_GenColors; // проверен
var
  da, db, dc, dd :TData;
begin
  if not Assigned(_prop_MSTControl) then exit;
  FreeData(@FData);
  dtNull(FData);
  dtInteger(da,Color2RGB(_prop_MSTControl.bkcolor));
  dtInteger(db,Color2RGB(_prop_MSTControl.textcolor));
  dtInteger(dc,Color2RGB(_prop_MSTControl.textbkcolor));
  dtInteger(dd,Color2RGB(_prop_MSTControl.iconcolcolor));
  da.ldata := @db;
  db.ldata := @dc;
  dc.ldata := @dd;
  CopyData(@FData,@da);
  _Data := FData;
end;

end.