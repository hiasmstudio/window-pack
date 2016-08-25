unit hiPC_Shape;

interface

uses Windows,Kol,Share,Debug,hiDocumentTemplate,hiPrint_Shape,PrintController,hiPrint_Table;

type
  THIPC_Shape = class(TPrintController)
   private
   public
    _event_onSetStyle:THI_Event;    
    
    _prop_VisibleApply: boolean;
    _prop_Visible:      boolean;
    
    _prop_TypeApply:   boolean;  
    _prop_Type:        byte;

    _prop_FrameApply:  boolean;
    _prop_FrameStyle:  byte;
    _prop_FrameSize:   byte;
    _prop_FrameColor:  TColor;
        
    _prop_BgApply:     boolean;
    _prop_BackStyle:   byte;
    _prop_BackColor:   TColor;
    
    _prop_AlphaBlendApply: boolean;
    _prop_AlphaBlendValue:byte;    
    
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

    procedure _work_doVisibleApply(var _Data:TData; Index:word);
    procedure _work_doVisible(var _Data:TData; Index:word);

    procedure _work_doTypeApply(var _Data:TData; Index:word);
    procedure _work_doType(var _Data:TData; Index:word);

  end;

implementation

procedure THIPC_Shape._work_doSetStyle;
begin
  InitItem(_Data);
  if _prop_VisibleApply then
    THIPrint_Shape(FItem)._prop_Visible := _prop_Visible;
  if _prop_AlphaBlendApply then
    THIPrint_Shape(FItem)._prop_AlphaBlendValue := _prop_AlphaBlendValue;
  if _prop_TypeApply then
    THIPrint_Shape(FItem)._prop_Type := _prop_Type;
  if _prop_FrameApply then
  begin
    THIPrint_Shape(FItem)._prop_FrameStyle := _prop_FrameStyle;
    THIPrint_Shape(FItem)._prop_FrameSize  := _prop_FrameSize;
    THIPrint_Shape(FItem)._prop_FrameColor := _prop_FrameColor;
  end;
  if _prop_BgApply then
  begin
    THIPrint_Shape(FItem)._prop_BackStyle  := _prop_BackStyle;
    THIPrint_Shape(FItem)._prop_BackColor  := _prop_BackColor;
  end;
  _hi_onEvent(_event_onSetStyle);  
end; 

procedure THIPC_Shape._work_doFrameApply;
begin
  _prop_FrameApply := ReadBool(_Data);
end;

procedure THIPC_Shape._work_doFrameStyle;
begin
  _prop_FrameStyle := ToInteger(_Data);
end;

procedure THIPC_Shape._work_doFrameSize;
begin
  _prop_FrameSize := ToInteger(_Data);
end;

procedure THIPC_Shape._work_doFrameColor;
begin
  _prop_FrameColor := ToInteger(_Data);
end;

procedure THIPC_Shape._work_doBgApply;
begin
  _prop_BgApply := ReadBool(_Data);
end;

procedure THIPC_Shape._work_doBackStyle;
begin
  _prop_BackStyle := ToInteger(_Data);
end;

procedure THIPC_Shape._work_doBackColor;
begin
  _prop_BackColor := ToInteger(_Data);
end;

procedure THIPC_Shape._work_doTypeApply;
begin
  _prop_TypeApply := ReadBool(_Data);
end;

procedure THIPC_Shape._work_doType;
begin
  _prop_Type := ToInteger(_Data);
end;

procedure THIPC_Shape._work_doAlphaBlendApply;
begin
  _prop_AlphaBlendApply := ReadBool(_Data);
end;

procedure THIPC_Shape._work_doAlphaBlendValue;
begin
  _prop_AlphaBlendValue := ToInteger(_Data);
end;

procedure THIPC_Shape._work_doVisibleApply;
begin
  _prop_VisibleApply := ReadBool(_Data);
end;

procedure THIPC_Shape._work_doVisible;
begin
  _prop_Visible := ReadBool(_Data);
end;

end.