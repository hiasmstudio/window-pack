unit hiPC_Image;

interface

uses Windows,Kol,Share,Debug,hiDocumentTemplate,hiPrint_Image,PrintController;

type
  THIPC_Image = class(TPrintController)
   private
   public
    _data_Bitmap:THI_Event;
    _event_onPicture:THI_Event;
    _event_onSetStyle:THI_Event;    
    
    _prop_VisibleApply: boolean;
    _prop_Visible:      boolean;

    _prop_ViewStyleApply:  boolean;
    _prop_ViewStyle:  byte;

    _prop_FrameApply:  boolean;
    _prop_FrameStyle:  byte;
    _prop_FrameSize:   byte;
    _prop_FrameColor:  TColor;
        
    _prop_BgApply:     boolean;
    _prop_BackStyle:   byte;
    _prop_BackColor:   TColor;
    
    _prop_AlphaBlendApply: boolean;
    _prop_AlphaBlendValue:byte;    

    procedure _work_doPicture(var _Data:TData; Index:word);
    procedure _var_CurrentPicture(var _Data:TData; Index:word);
    
    procedure _work_doSetStyle(var _Data:TData; Index:word);    

    procedure _work_doFrameApply(var _Data:TData; Index:word);
    procedure _work_doFrameStyle(var _Data:TData; Index:word);
    procedure _work_doFrameSize(var _Data:TData; Index:word);
    procedure _work_doFrameColor(var _Data:TData; Index:word);
        
    procedure _work_doBgApply(var _Data:TData; Index:word);
    procedure _work_doBackStyle(var _Data:TData; Index:word);
    procedure _work_doBackColor(var _Data:TData; Index:word);    

    procedure _work_doAlphaBlendApply(var _Data:TData; Index:word);
    procedure _work_doAlphaBlendValue(var _Data:TData; Index:word);

    procedure _work_doViewStyleApply(var _Data:TData; Index:word);
    procedure _work_doViewStyle(var _Data:TData; Index:word);

    procedure _work_doVisibleApply(var _Data:TData; Index:word);
    procedure _work_doVisible(var _Data:TData; Index:word);

  end;

implementation

procedure THIPC_Image._work_doPicture;
begin  
  InitItem(_Data);
  THIPrint_Image(FItem).FImage.Image.assign(ReadBitmap(_Data, _data_Bitmap));
  _hi_onEvent(_event_onPicture);
end;

procedure THIPC_Image._var_CurrentPicture;
begin
  InitItem;
  dtBitmap(_Data, THIPrint_Image(FItem).FImage.Image);
end;

procedure THIPC_Image._work_doSetStyle;
begin
  InitItem(_Data);
  if _prop_VisibleApply then
    THIPrint_Image(FItem)._prop_Visible := _prop_Visible;
  if _prop_ViewStyleApply then
    THIPrint_Image(FItem)._prop_ViewStyle := _prop_ViewStyle;
  if _prop_AlphaBlendApply then
    THIPrint_Image(FItem)._prop_AlphaBlendValue := _prop_AlphaBlendValue;
  if _prop_FrameApply then
  begin
    THIPrint_Image(FItem)._prop_FrameStyle := _prop_FrameStyle;
    THIPrint_Image(FItem)._prop_FrameSize  := _prop_FrameSize;
    THIPrint_Image(FItem)._prop_FrameColor := _prop_FrameColor;
  end;
  if _prop_BgApply then
  begin
    THIPrint_Image(FItem)._prop_BackStyle  := _prop_BackStyle;
    THIPrint_Image(FItem)._prop_BackColor  := _prop_BackColor;
  end;
  _hi_onEvent(_event_onSetStyle);  
end; 

procedure THIPC_Image._work_doFrameApply;
begin
  _prop_FrameApply := ReadBool(_Data);
end;

procedure THIPC_Image._work_doFrameStyle;
begin
  _prop_FrameStyle := ToInteger(_Data);
end;

procedure THIPC_Image._work_doFrameSize;
begin
  _prop_FrameSize := ToInteger(_Data);
end;

procedure THIPC_Image._work_doFrameColor;
begin
  _prop_FrameColor := ToInteger(_Data);
end;

procedure THIPC_Image._work_doBgApply;
begin
  _prop_BgApply := ReadBool(_Data);
end;

procedure THIPC_Image._work_doBackStyle;
begin
  _prop_BackStyle := ToInteger(_Data);
end;

procedure THIPC_Image._work_doBackColor;
begin
  _prop_BackColor := ToInteger(_Data);
end;

procedure THIPC_Image._work_doViewStyleApply;
begin
  _prop_ViewStyleApply := ReadBool(_Data);
end;

procedure THIPC_Image._work_doViewStyle;
begin
  _prop_ViewStyle := ToInteger(_Data);
end;

procedure THIPC_Image._work_doAlphaBlendApply;
begin
  _prop_AlphaBlendApply := ReadBool(_Data);
end;

procedure THIPC_Image._work_doAlphaBlendValue;
begin
  _prop_AlphaBlendValue := ToInteger(_Data);
end;

procedure THIPC_Image._work_doVisibleApply;
begin
  _prop_VisibleApply := ReadBool(_Data);
end;

procedure THIPC_Image._work_doVisible;
begin
  _prop_Visible := ReadBool(_Data);
end;

end.