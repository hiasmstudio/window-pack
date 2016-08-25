unit hiPC_GradientRect;

interface

uses Windows,Kol,Share,Debug,hiDocumentTemplate,hiPrint_GradientRect,PrintController,hiPrint_Table;

type
  THIPC_GradientRect = class(TPrintController)
   private
   public
    _event_onSetStyle:THI_Event;    
    
    _prop_VisibleApply: boolean;
    _prop_Visible:      boolean;

    _prop_OrientApply: boolean;
    _prop_Orientation: byte;    

    _prop_FrameApply:  boolean;
    _prop_FrameStyle:  byte;
    _prop_FrameSize:   byte;
    _prop_FrameColor:  TColor;
        
    _prop_BgApply:     boolean;
    _prop_Grad1Color:  TColor;
    _prop_Grad2Color:  TColor;
    
    _prop_AlphaBlendApply: boolean;
    _prop_AlphaBlendValue:byte;    
    
    procedure _work_doSetStyle(var _Data:TData; Index:word);    

    procedure _work_doFrameApply(var _Data:TData; Index:word);
    procedure _work_doFrameStyle(var _Data:TData; Index:word);
    procedure _work_doFrameSize(var _Data:TData; Index:word);
    procedure _work_doFrameColor(var _Data:TData; Index:word);
        
    procedure _work_doBgApply(var _Data:TData; Index:word);
    procedure _work_doGrad1Color(var _Data:TData; Index:word);
    procedure _work_doGrad2Color(var _Data:TData; Index:word);
    
    procedure _work_doOrientApply(var _Data:TData; Index:word);
    procedure _work_doOrientation(var _Data:TData; Index:word);

    procedure _work_doAlphaBlendApply(var _Data:TData; Index:word);
    procedure _work_doAlphaBlendValue(var _Data:TData; Index:word);

    procedure _work_doVisibleApply(var _Data:TData; Index:word);
    procedure _work_doVisible(var _Data:TData; Index:word);

  end;

implementation

procedure THIPC_GradientRect._work_doSetStyle;
begin
  InitItem(_Data);
  if _prop_VisibleApply then
    THIPrint_GradientRect(FItem)._prop_Visible := _prop_Visible;
  if _prop_AlphaBlendApply then
    THIPrint_GradientRect(FItem)._prop_AlphaBlendValue := _prop_AlphaBlendValue;
  if _prop_OrientApply then
    THIPrint_GradientRect(FItem)._prop_Orientation  := _prop_Orientation;
  if _prop_FrameApply then
  begin
    THIPrint_GradientRect(FItem)._prop_FrameStyle := _prop_FrameStyle;
    THIPrint_GradientRect(FItem)._prop_FrameSize  := _prop_FrameSize;
    THIPrint_GradientRect(FItem)._prop_FrameColor := _prop_FrameColor;
  end;
  if _prop_BgApply then
  begin
    THIPrint_GradientRect(FItem)._prop_Grad1Color  := _prop_Grad1Color;
    THIPrint_GradientRect(FItem)._prop_Grad2Color  := _prop_Grad2Color;
  end;
  _hi_onEvent(_event_onSetStyle);  
end; 

procedure THIPC_GradientRect._work_doFrameApply;
begin
  _prop_FrameApply := ReadBool(_Data);
end;

procedure THIPC_GradientRect._work_doFrameStyle;
begin
  _prop_FrameStyle := ToInteger(_Data);
end;

procedure THIPC_GradientRect._work_doFrameSize;
begin
  _prop_FrameSize := ToInteger(_Data);
end;

procedure THIPC_GradientRect._work_doFrameColor;
begin
  _prop_FrameColor := ToInteger(_Data);
end;

procedure THIPC_GradientRect._work_doBgApply;
begin
  _prop_BgApply := ReadBool(_Data);
end;

procedure THIPC_GradientRect._work_doGrad1Color;
begin
  _prop_Grad1Color := ToInteger(_Data);
end;

procedure THIPC_GradientRect._work_doGrad2Color;
begin
  _prop_Grad2Color := ToInteger(_Data);
end;

procedure THIPC_GradientRect._work_doOrientApply;
begin
  _prop_OrientApply := ReadBool(_Data);
end;

procedure THIPC_GradientRect._work_doOrientation;
begin
  _prop_Orientation := ToInteger(_Data);
end;

procedure THIPC_GradientRect._work_doAlphaBlendApply;
begin
  _prop_AlphaBlendApply := ReadBool(_Data);
end;

procedure THIPC_GradientRect._work_doAlphaBlendValue;
begin
  _prop_AlphaBlendValue := ToInteger(_Data);
end;

procedure THIPC_GradientRect._work_doVisibleApply;
begin
  _prop_VisibleApply := ReadBool(_Data);
end;

procedure THIPC_GradientRect._work_doVisible;
begin
  _prop_Visible := ReadBool(_Data);
end;

end.