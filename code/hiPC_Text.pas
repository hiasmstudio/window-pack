unit hiPC_Text;

interface

uses Windows,Kol,Share,Debug,hiDocumentTemplate,hiPrint_Text,PrintController,hiPrint_Table;

type
  THIPC_Text = class(TPrintController)
   private
   public
    _data_Text:THI_Event;
    _event_onText:THI_Event;
    _event_onSetStyle:THI_Event;    
                                
    _prop_VisibleApply: boolean;
    _prop_Visible:      boolean;

    _prop_FontApply:    boolean;
    _prop_Font:         TFontRec;
    
    _prop_FrameApply:   boolean;
    _prop_FrameStyle:   byte;
    _prop_FrameSize:    byte;
    _prop_FrameColor:   TColor;
        
    _prop_BgApply:      boolean;
    _prop_BackStyle:    byte;
    _prop_BackColor:    TColor;
    
    _prop_AlignApply:   boolean;
    _prop_Vertical:     byte;
    _prop_Horizontal:   byte;

    _prop_MarginApply:  boolean;
    _prop_Left:         integer;
    _prop_Top:          integer;
    _prop_Right:        integer;
    _prop_Bottom:       integer;

    _prop_AlphaBlendApply: boolean;
    _prop_AlphaBlendValue:byte;    
    
    procedure _work_doText(var _Data:TData; Index:word);
    procedure _work_doSetStyle(var _Data:TData; Index:word);    
    procedure _var_CurrentText(var _Data:TData; Index:word);

    procedure _work_doFontApply(var _Data:TData; Index:word);
    procedure _work_doFont(var _Data:TData; Index:word);
    
    procedure _work_doFrameApply(var _Data:TData; Index:word);
    procedure _work_doFrameStyle(var _Data:TData; Index:word);
    procedure _work_doFrameSize(var _Data:TData; Index:word);
    procedure _work_doFrameColor(var _Data:TData; Index:word);
        
    procedure _work_doBgApply(var _Data:TData; Index:word);
    procedure _work_doBackStyle(var _Data:TData; Index:word);
    procedure _work_doBackColor(var _Data:TData; Index:word);
    
    procedure _work_doAlignApply(var _Data:TData; Index:word);
    procedure _work_doVertical(var _Data:TData; Index:word);
    procedure _work_doHorizontal(var _Data:TData; Index:word);

    procedure _work_doMarginApply(var _Data:TData; Index:word);
    procedure _work_doLeft(var _Data:TData; Index:word);
    procedure _work_doTop(var _Data:TData; Index:word);
    procedure _work_doRight(var _Data:TData; Index:word);
    procedure _work_doBottom(var _Data:TData; Index:word);

    procedure _work_doAlphaBlendApply(var _Data:TData; Index:word);
    procedure _work_doAlphaBlendValue(var _Data:TData; Index:word);

    procedure _work_doVisibleApply(var _Data:TData; Index:word);
    procedure _work_doVisible(var _Data:TData; Index:word);

  end;

implementation

procedure THIPC_Text._work_doText;
var s:string;
begin
  s := ReadString(_Data, _data_Text);
  InitItem(_Data);
  THIPrint_Text(FItem)._prop_Text := s;
  _hi_onEvent(_event_onText);
end;

procedure THIPC_Text._var_CurrentText;
begin
  InitItem;
  dtString(_Data, THIPrint_Text(FItem)._prop_Text);
end;

procedure THIPC_Text._work_doSetStyle;
begin
  InitItem(_Data);
  if _prop_VisibleApply then
    THIPrint_Text(FItem)._prop_Visible := _prop_Visible;
  if _prop_AlphaBlendApply then
    THIPrint_Text(FItem)._prop_AlphaBlendValue := _prop_AlphaBlendValue;
  if _prop_FontApply then
    THIPrint_Text(FItem)._prop_Font := _prop_Font;
  if _prop_FrameApply then
  begin
    THIPrint_Text(FItem)._prop_FrameStyle := _prop_FrameStyle;
    THIPrint_Text(FItem)._prop_FrameSize  := _prop_FrameSize;
    THIPrint_Text(FItem)._prop_FrameColor := _prop_FrameColor;
  end;
  if _prop_BgApply then
  begin
    THIPrint_Text(FItem)._prop_BackStyle  := _prop_BackStyle;
    THIPrint_Text(FItem)._prop_BackColor  := _prop_BackColor;
  end;
  if _prop_AlignApply then
  begin
    THIPrint_Text(FItem)._prop_Vertical   := _prop_Vertical;
    THIPrint_Text(FItem)._prop_Horizontal := _prop_Horizontal;
  end;   
  if _prop_MarginApply then
  begin
    THIPrint_Text(FItem)._prop_Left       := _prop_Left;
    THIPrint_Text(FItem)._prop_Top        := _prop_Top;
    THIPrint_Text(FItem)._prop_Right      := _prop_Right;
    THIPrint_Text(FItem)._prop_Bottom     := _prop_Bottom;
  end; 
  _hi_onEvent(_event_onSetStyle);  
end; 

procedure THIPC_Text._work_doFontApply;
begin
  _prop_FontApply := ReadBool(_Data);
end;

procedure THIPC_Text._work_doFont;
begin
  if _IsFont(_Data) then
    with pfontrec(_Data.idata)^ do
	begin
      _prop_Font.Name    := Name;
      _prop_Font.Size    := Size;
      _prop_Font.Style   := Style;
      _prop_Font.Color   := Color;
      _prop_Font.CharSet := CharSet;
    end;
end;
    
procedure THIPC_Text._work_doFrameApply;
begin
  _prop_FrameApply := ReadBool(_Data);
end;

procedure THIPC_Text._work_doFrameStyle;
begin
  _prop_FrameStyle := ToInteger(_Data);
end;

procedure THIPC_Text._work_doFrameSize;
begin
  _prop_FrameSize := ToInteger(_Data);
end;

procedure THIPC_Text._work_doFrameColor;
begin
  _prop_FrameColor := ToInteger(_Data);
end;

procedure THIPC_Text._work_doBgApply;
begin
  _prop_BgApply := ReadBool(_Data);
end;

procedure THIPC_Text._work_doBackStyle;
begin
  _prop_BackStyle := ToInteger(_Data);
end;

procedure THIPC_Text._work_doBackColor;
begin
  _prop_BackColor := ToInteger(_Data);
end;
    
procedure THIPC_Text._work_doAlignApply;
begin
  _prop_AlignApply := ReadBool(_Data);
end;

procedure THIPC_Text._work_doVertical;
begin
  _prop_Vertical := ToInteger(_Data);
end;

procedure THIPC_Text._work_doHorizontal;
begin
  _prop_Horizontal := ToInteger(_Data);
end;

procedure THIPC_Text._work_doMarginApply;
begin
  _prop_MarginApply := ReadBool(_Data);
end;

procedure THIPC_Text._work_doLeft;
begin
  _prop_Left := ToInteger(_Data);
end;

procedure THIPC_Text._work_doTop;
begin
  _prop_Top := ToInteger(_Data);
end;

procedure THIPC_Text._work_doRight;
begin
  _prop_Right := ToInteger(_Data);
end;

procedure THIPC_Text._work_doBottom;
begin
  _prop_Bottom := ToInteger(_Data);
end;

procedure THIPC_Text._work_doAlphaBlendApply;
begin
  _prop_AlphaBlendApply := ReadBool(_Data);
end;

procedure THIPC_Text._work_doAlphaBlendValue;
begin
  _prop_AlphaBlendValue := ToInteger(_Data);
end;

procedure THIPC_Text._work_doVisibleApply;
begin
  _prop_VisibleApply := ReadBool(_Data);
end;

procedure THIPC_Text._work_doVisible;
begin
  _prop_Visible := ReadBool(_Data);
end;

end.
