unit hiMinMaxSize;

interface
     
uses Windows, Messages, Kol, Share, Debug;

type
  THIMinMaxSize = class(TDebug)
   private
     Fp:PControl;
     OldMessage:TOnMessage;
     function onMessage( var Msg: TMsg; var Rslt: Integer ): Boolean;
   public
     _prop_MinWidth  : integer;
     _prop_MinHeight : integer;
     _prop_MaxWidth  : integer;
     _prop_MaxHeight : integer;
     _prop_MaxLeft   : integer;
     _prop_MaxTop    : integer;
     _prop_EnabledMinMax: boolean;     
     _prop_ControlMaxLeftTop: boolean;     
          
     constructor Create(Control:PControl);
     destructor Destroy; override;
     procedure _work_doMinWidth(var _Data:TData; Index:word);     
     procedure _work_doMinHeight(var _Data:TData; Index:word);     
     procedure _work_doMaxWidth(var _Data:TData; Index:word);     
     procedure _work_doMaxHeight(var _Data:TData; Index:word);
     procedure _work_doMaxLeft(var _Data:TData; Index:word);     
     procedure _work_doMaxTop(var _Data:TData; Index:word);
     procedure _work_doEnabledMinMax(var _Data:TData; Index:word);     
     procedure _work_doControlMaxLeftTop(var _Data:TData; Index:word);
  end;

implementation

//------------------------------------------------------------------------------
//

constructor THIMinMaxSize.Create;
begin
   inherited Create;
   Fp := Control;
   OldMessage := Control.OnMessage;
   Control.OnMessage := onMessage;
end;

destructor THIMinMaxSize.Destroy;
begin
   Fp.OnMessage := OldMessage;
   inherited Destroy;
end;

function THIMinMaxSize.onMessage;
var
  MinMax: PMinMaxInfo;
begin
  case Msg.message of
    WM_GETMINMAXINFO:
      if _prop_EnabledMinMax then
      begin
        MinMax := Pointer(Msg.lParam);

        if _prop_ControlMaxLeftTop then
          MinMax.ptMaxPosition.x := Fp.Left
        else  
          MinMax.ptMaxPosition.x := _prop_MaxLeft; 
        if _prop_ControlMaxLeftTop then
          MinMax.ptMaxPosition.y := Fp.Top
        else  
          MinMax.ptMaxPosition.y := _prop_MaxTop; 

        if _prop_MinWidth <> 0 then 
          MinMax.ptMinTrackSize.x := _prop_MinWidth; 
        if _prop_MinHeight <> 0 then
          MinMax.ptMinTrackSize.y := _prop_MinHeight; 
        if _prop_MaxWidth <> 0 then
          MinMax.ptMaxTrackSize.x := _prop_MaxWidth; 
        if _prop_MaxHeight <> 0 then
          MinMax.ptMaxTrackSize.y := _prop_MaxHeight;
      end;
  end;    
  Result := _hi_OnMessage(OldMessage,Msg,Rslt);
end;

procedure THIMinMaxSize._work_doMinWidth;
begin
  _prop_MinWidth := ToInteger(_Data);
end;
     
procedure THIMinMaxSize._work_doMinHeight;     
begin
  _prop_MinHeight := ToInteger(_Data);
end;

procedure THIMinMaxSize._work_doMaxWidth;     
begin
  _prop_MaxWidth := ToInteger(_Data);
end;

procedure THIMinMaxSize._work_doMaxHeight;     
begin
  _prop_MaxHeight := ToInteger(_Data);
end;

procedure THIMinMaxSize._work_doMaxLeft;     
begin
  _prop_MaxLeft := ToInteger(_Data);
end;

procedure THIMinMaxSize._work_doMaxTop;     
begin
  _prop_MaxTop := ToInteger(_Data);
end;

procedure THIMinMaxSize._work_doEnabledMinMax;     
begin
  _prop_EnabledMinMax := ReadBool(_Data);
end;

procedure THIMinMaxSize._work_doControlMaxLeftTop;     
begin
  _prop_ControlMaxLeftTop := ReadBool(_Data);
end;

end.