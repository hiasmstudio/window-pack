unit hiRichEdit;

interface

{$I share.inc}

uses Kol,Share,EWinList,Windows,Messages;

type
  THIRichEdit = class(THIEWinList)
   private
    procedure _OnChange(Obj:PObj);
    procedure _OnURLDetect(Obj:PObj);
//    procedure SetStrings(const Value:string); override;
    procedure SaveToList; override;
   protected
    procedure _Set(var Item:TData; var Val:TData); override;
    procedure _onMouseUp(Sender: PControl; var Mouse: TMouseEventData); override;
    procedure _onMouseMove(Sender: PControl; var Mouse: TMouseEventData); override;
   public
    _prop_ScrollBars:byte;
    _prop_ReadOnly:boolean;
    _prop_WantTab:boolean;
    _prop_Strings:string;
    _prop_CanDragOle:boolean;
    _prop_HideFrames:boolean;
    _prop_InsertCRLF:boolean;
    _prop_ParseLinks:boolean;

    _data_FileName:THI_Event;
    _data_Color:THI_Event;
    _data_Style:THI_Event;
    _data_MoveCursor:THI_Event;
    _event_onWordClick:THI_Event;
    _event_onURLClick:THI_Event;

    destructor Destroy; override;
    procedure _work_doAdd(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word); override;
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doAddBitmap(var _Data:TData; Index:word);
    procedure _work_doUndo(var _Data:TData; Index:word);
    procedure _work_doRedo(var _Data:TData; Index:word);      
    procedure _work_doFormatSel(var _Data:TData; Index:word);  
    procedure _var_RichEdit(var _Data:TData; Index:word);
    procedure _var_Text(var _Data:TData; Index:word); override;
    procedure Init; override;
  end;

implementation

{$ifndef F_P}
uses KOLOleRE;
{$endif}

procedure THIRichEdit._work_doFormatSel;
var
  p: byte;

begin
  if (Control.SelLength <> 0) then {no valid selection -> quit}
  begin
    Control.RE_CharFmtArea := raSelection; {apply attribute(s) only to selection}
    Control.RE_FmtFontColor := ReadInteger(_Data,_data_Color);

    p := ReadInteger(_Data,_data_Style);
    Control.RE_FmtBold := p and 1 > 0;
    Control.RE_FmtItalic := p and 2 > 0;
    Control.RE_FmtUnderline := p and 4 > 0;
    Control.RE_FmtStrikeout := p and 8 > 0;    
  end;
end;

procedure THIRichEdit._onMouseUp;
var s,p:string;
    i:integer;
begin
   inherited;
   if not _prop_ParseLinks then exit;
   s := '';
   i := Control.SelStart;
   p := Control.RE_Text[ reText, false ];
   replace(p,#13,'');
   while(i > 0)and(p[i] in ['à'..'ÿ','À'..'ß','a'..'z','A'..'Z'])do
    begin
      s := p[i] + s;
      dec(i);
    end;
   i := Control.SelStart+1;
   while(i < Length(p))and(p[i] in ['à'..'ÿ','À'..'ß','a'..'z','A'..'Z'])do
    begin
      s := s + p[i];
      inc(i);
    end;
   if s <> '' then
     _hi_onEvent(_event_onWordClick, s);
end;

procedure THIRichEdit._onMouseMove;
var s,p:string;
    i,t:integer;
    Pt: TPoint;
    dt:TData;
begin
   inherited;
   if not _prop_ParseLinks then exit;
   pt.x := Mouse.X;
   pt.y := Mouse.Y;
   t := SendMessage(Control.Handle, EM_CHARFROMPOS, 0, longint(@Pt));
    
   s := '';
   i := t;
   p := Control.RE_Text[ reText, false ];
   replace(p,#13,'');
   while(i > 0)and(p[i] in ['à'..'ÿ','À'..'ß','a'..'z','A'..'Z'])do
    begin
      s := p[i] + s;
      dec(i);
    end;
   i := t+1;
   while(i < Length(p))and(p[i] in ['à'..'ÿ','À'..'ß','a'..'z','A'..'Z'])do
    begin
      s := s + p[i];
      inc(i);
    end;
   dtString(dt, s);
   _ReadData(dt, _data_MoveCursor);
   if ToInteger(dt) <> 0 then
     Control.CursorLoad(0, MakeIntResource(crHandPoint))
   else Control.CursorLoad(0, MakeIntResource(crDefault));
   
end;

procedure THIRichEdit._Set(var Item:TData; var Val:TData);
var ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < Control.Count)then
     Control.Items[ind] := ToString(Val) + #13#10;
end;

procedure THIRichEdit._work_doLoad;
var fn:string;
    tf:TRETextFormat;
begin
   fn := ReadString(_Data,_data_FileName,_prop_FileName);
   if LowerCase(ExtractFileExt(fn)) = '.rtf' then
    tf := reRTF
   else tf := reText;
   Control.RE_LoadFromFile(fn,tf,false);
end;

procedure THIRichEdit._work_doClear;
begin
   Control.SelStart := 0;
   Control.SelLength := $FFFFFFFF;
   Control.RE_Text[ reText, True ] := '';
end;

procedure THIRichEdit._work_doSave;
var fn:string;
    tf:TRETextFormat;
begin
   fn := ReadString(_Data,_data_FileName,_prop_FileName);
   if LowerCase(ExtractFileExt(fn)) = '.rtf' then
    tf := reRTF
   else tf := reText;
   Control.RE_SaveToFile(fn,tf,false);
end;

{$ifdef F_P}
procedure THIRichEdit._work_doAddBitmap;
begin
   _debug('This method not support');
end;
{$else}
procedure THIRichEdit._work_doAddBitmap;
var bmp:kol.PBitmap;
   s:string;
begin
   bmp := ReadBitmap(_Data,NULL,nil);
   s := PKOLOleRichEdit(Control).BitmapToRTF(bmp);
   Control.RE_InsertRTF(s);
   if _prop_HideFrames then
    PKOLOleRichEdit(Control).HideFrames;
end;
{$endif}

procedure THIRichEdit._var_RichEdit;
begin
   _Data.Data_type := data_int;
   _Data.sdata := 'RichEdit';
   _Data.idata := integer(Control);
end;

procedure THIRichEdit._var_Text;
begin
   dtString(_Data,Control.RE_Text[reText,false]);
end;

procedure THIRichEdit._work_doAdd;
var Text:string;
    p:byte;
    function CRLF:string;
    begin
       if _prop_InsertCRLF then Result := #13#10 else result := '';
    end;
begin
  if _prop_AddType = 0 then
    Control.SelStart := Length(Control.Text)
  else Control.SelStart := 0;

  //debug(int2str(Control.SelStart));

  Text := ReadString(_Data,_data_Str,'');
  Control.RE_FmtFontColor := ReadInteger(_Data,_data_Color,0);
  p := ReadInteger(_Data,_data_Style,0);

  Control.RE_FmtBold := p and 1 > 0;
  Control.RE_FmtItalic := p and 2 > 0;
  Control.RE_FmtUnderline := p and 4 > 0;

  if _prop_AddType = 0 then
   begin
    if Control.Text = '' then
     Control.RE_Append(Text,true)
    else Control.RE_Append(CRLF + Text,true)
   end
  else
    if Control.Text = '' then
     Control.RE_Append(Text,true)
    else Control.Selection := Text + CRLF;

end;

//procedure THIRichEdit.SetStrings;
//begin
//   Control.Text := Value;
//end;

procedure THIRichEdit.SaveToList;
begin
   FList.text := Control.Text;
end;

procedure THIRichEdit.Init;
var Flags:TEditOptions;
begin
   Flags := [eoMultiline,eoNoHideSel,eoNoVScroll,eoNoHScroll];
   case _prop_ScrollBars of
    0: ;
    1: Exclude(Flags,eoNoHScroll);
    2: Exclude(Flags,eoNoVScroll);
    3: begin Exclude(Flags,eoNoHScroll); Exclude(Flags,eoNoVScroll); end;
   end;
   if _prop_ReadOnly then
     Include(Flags,eoReadonly);
   if _prop_WantTab then
     Include(Flags,eoWantTab); 

   {$ifdef F_P}
   Control := NewRichEdit1(FParent,Flags);
   {$else}
   if _prop_CanDragOle then
     Control := NewOLERichEdit(FParent,Flags)
   else Control := NewRichEdit1(FParent,Flags);
   {$endif}

   Control.OnChange := _OnChange;
   inherited;

   {$ifdef F_P}
   with Control do
    begin
   {$else}
   with PKOLOleRichEdit(Control)^ do
    begin
     CanDragOle := _prop_CanDragOle;
   {$endif}
     Text := _prop_Strings;
//     RE_AutoURLDetect := true;
     RE_FmtStandard;
     RE_FmtAutoColor := true;
     OnRE_URLClick := _OnURLDetect; 
    end;
end;

destructor THIRichEdit.Destroy;
begin
//   _debug('ok');
//   PKOLOleRichEdit(Control).Destroy;
//   Control := nil;
   inherited Destroy;
end;

procedure THIRichEdit._OnURLDetect;
begin
   _hi_onEvent(_event_onURLClick, Control.RE_URL);
end;

procedure THIRichEdit._OnChange;
begin
   _hi_OnEvent(_event_onChange,Control.text);
end;

procedure THIRichEdit._work_doUndo;
begin
  Control.Undo;
end;

procedure THIRichEdit._work_doRedo;
begin
  Control.Re_Redo;
end;

end.