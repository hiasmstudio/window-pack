unit hiScrollBar;

interface

uses Kol,Share,Win,Windows,Messages;

type
  THIScrollBar = class(THIWin)
   private
    OldMes:TOnMessage;
    si:TScrollInfo;
    function GetPos:integer;
    procedure Update;
    function _Message(var Msg: TMsg; var Rslt: Integer):boolean;
   public
    _prop_ScrollMode:byte;
    _prop_Kind:byte;
    _prop_Max:integer;
    _event_onPosition:THI_Event;
    _event_onEndScroll:THI_Event;
    
    procedure Init; override;
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doMax(var _Data:TData; Index:word);
    procedure _work_doMin(var _Data:TData; Index:word);
    procedure _work_doPage(var _Data:TData; Index:word);
    procedure _work_doVisible(var Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
    property _prop_Min:integer read si.nMin write si.nMin;
    property _prop_Position:integer read si.nPos write si.nPos;
    property _prop_Page:dword read si.nPage write si.nPage;
  end;

implementation

procedure  THIScrollBar.Init;
const dir:array[0..1]of cardinal = (SBS_HORZ,SBS_VERT);
begin
   Control := _NewControl( FParent, 'SCROLLBAR', WS_VISIBLE or WS_CHILD or dir[_prop_Kind], FALSE, nil );
   OldMes := FParent.OnMessage;
   FParent.OnMessage := _Message;
   inherited;
   si.cbSize := sizeof(si);
   Update;
end;

procedure THIScrollBar._work_doVisible(var Data:TData; Index:word);
begin
   Update;
   Control.Visible := ReadBool(Data);
end;

function THIScrollBar._Message;
begin
  Result := false;
  case Msg.message of
   WM_HSCROLL,WM_VSCROLL:
    if dword(Msg.lParam) = control.Handle then
    begin
     GetPos;
     case LOWORD(Msg.wParam)  of
      SB_BOTTOM,SB_LINERIGHT: inc(si.nPos);
      SB_LINELEFT,SB_TOP:     dec(si.nPos);
      SB_PAGELEFT:            dec(si.nPos, _prop_Page);
      SB_PAGERIGHT:           inc(si.nPos, _prop_Page);
      SB_THUMBPOSITION,
      SB_THUMBTRACK: si.nPos := si.nTrackPos;
      SB_ENDSCROLL:
      begin
        if _prop_ScrollMode = 1 then
         _hi_OnEvent(_event_onPosition,si.nPos);
        _hi_OnEvent(_event_onEndScroll);
      end;   
     end;
     Update;
     if _prop_ScrollMode = 0 then
        _hi_OnEvent(_event_onPosition,GetPos);
     result := true;
     Rslt := 0;
    end;
  end;
  Result := Result or _hi_OnMessage(OldMes,Msg,Rslt);
end;

procedure THIScrollBar._work_doPosition;
begin
  si.nPos := ToInteger(_data); 
  Update;
end;

procedure THIScrollBar._work_doMax;
begin
   _prop_Max := ToInteger(_Data);
   Update;
end;

procedure THIScrollBar._work_doPage;
begin
   _prop_Page := ToInteger(_Data);
   Update;
end;

procedure THIScrollBar._work_doMin;
begin
   _prop_Min := ToInteger(_Data);
   Update;
end;

procedure THIScrollBar._var_Position;
begin
   dtInteger(_Data,GetPos);
end;

function THIScrollBar.GetPos;
begin
   si.fMask := SIF_POS or SIF_TRACKPOS;
   GetScrollInfo(Control.Handle,SB_CTL,si);
   Result := si.nPos;
end;

procedure THIScrollBar.Update;
begin
   si.fMask := SIF_RANGE or SIF_PAGE or SIF_POS;
   si.nMax := _prop_Max + integer(_prop_Page) - 1;
   SetScrollInfo(Control.Handle,SB_CTL,si,false);
   Control.Invalidate;
end;

end.
