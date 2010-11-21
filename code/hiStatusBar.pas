unit hiStatusBar;

interface

uses Kol,Share,Debug,Windows;

type
  THIStatusBar = class(TDebug)
   private
    FList:PStrList;
    Arr:PArray;
    Control:PControl;
    procedure SetText(const Value:string);
    procedure _Set(var Item:TData; var Val:TData);
    function _Get(Var Item:TData; var Val:TData):boolean;
    function _Count:integer;
    procedure _Add(var Val:TData);
    procedure SetPanel(const col:string);
   public
    _prop_SizeGrip:boolean;
    _prop_Text:string;
    _prop_TextAlign:integer;
    _prop_Visible:boolean;

    _event_onText:THI_Event;

    _data_Width:THI_Event;
    _data_Panel:THI_Event;
    _data_Text:THI_Event;

    constructor Create(Parent:PControl);
    destructor Destroy; override;
    procedure _work_doText(var _Data:TData; Index:word);
    procedure _work_doWidth(var _Data:TData; Index:word);
    procedure _work_doVisible(var _Data:TData; Index:word);
    procedure _work_doIndexText(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_Handle(var _Data:TData; Index:word);
    procedure _var_Array(var _Data:TData; Index:word);
    property _prop_Panels:string write SetPanel;
    property _prop_Strings:string write SetText;
  end;

implementation

constructor THIStatusBar.Create;
begin
  inherited Create;
  Control := Parent;
  FList := NewStrList;
end;

destructor THIStatusBar.Destroy;
begin
   if Arr <> nil then dispose (Arr);
   inherited;   
end;

procedure THIStatusBar.SetText;
begin
   Flist.Text := Value;
end;

procedure  THIStatusBar.SetPanel;
var lst:PStrList;
    i,x:integer;
    s,symbol:string;
begin
   Control.SizeGrip:=_prop_SizeGrip;
   lst := NewStrList;
   lst.text:=col;
   symbol:=Copy(#9#9,1,_prop_TextAlign);
   Control.SimpleStatusText:=PChar(symbol+_Prop_Text);
   if Lst.Count>0 then
     Control.StatusText[lst.Count]:=PChar(symbol+_Prop_Text);
   x:=0;
   for i:=0 to lst.Count-1 do
    begin
     s:=Lst.Items[i]+'=';
     Control.StatusText[i]:=PChar(symbol+GetTok(s,'='));
     if s<>'' then inc(x,Str2Int(s));
     Control.StatusPanelRightX[i]:=x;
    end;
   lst.Free;
   Control.StatusCtl.Align := caNone;
   Control.StatusCtl.Visible := _prop_Visible;
end;

procedure THIStatusBar._work_doText;
var
   Text,symbol:string;
   Panel:integer;
begin
   Text:=ReadString(_Data,_data_Text,_prop_Text);
   Panel:=ReadInteger(_Data,_data_Panel,0);
   symbol:=Copy(#9#9,1,_prop_TextAlign);
   if Panel=Control.StatusPanelCount then
     Control.SimpleStatusText:=PChar(symbol+Text)
   else
     Control.StatusText[Panel]:=PChar(symbol+Text);
   _hi_onEvent(_event_onText);
end;

procedure THIStatusBar._work_doWidth;
var
   Panel,Width,x:integer;
begin
   Panel:=ReadInteger(_Data,_data_Panel,0);
   Width:=ReadInteger(_Data,_data_Width,0);
   if Panel>=Control.StatusPanelCount then exit;
   x:=0;
   if Panel>0 then
     x:=Control.StatusPanelRightX[Panel-1];
   Control.StatusPanelRightX[Panel]:=Width+x;
end;

procedure THIStatusBar._work_doVisible;
begin
   Control.StatusCtl.Visible:=ReadBool(_Data);
end;

procedure THIStatusBar._work_doIndexText;
var
   symbol:string;
   Panel,Ind:integer;
begin
   Ind:=ReadInteger(_Data,null,0);
   Panel:=ReadInteger(_Data,_data_Panel,0);
   symbol:=Copy(#9#9,1,_prop_TextAlign);
   if Panel=Control.StatusPanelCount then
     Control.SimpleStatusText:=PChar(symbol+FList.Items[Ind])
   else
     Control.StatusText[Panel]:=PChar(symbol+FList.Items[Ind]);
   _hi_onEvent(_event_onText);
end;

procedure THIStatusBar._var_Count;
begin
   dtInteger(_Data,Control.StatusPanelCount);
end;

procedure THIStatusBar._var_Handle;
begin
   dtInteger(_Data,Integer(Control.StatusWindow));
end;

procedure THIStatusBar._Set;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FList.Count)then
     FList.Items[ind] := ToString(Val);
end;

procedure THIStatusBar._Add;
begin
   FList.Add(ToString(val));
end;

function THIStatusBar._Get;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FList.Count)then
     begin
        Result := true;
        dtString(Val,FList.Items[ind]);
     end
   else Result := false;
end;

function THIStatusBar._Count;
begin
   Result := FList.Count;
end;

procedure THIStatusBar._var_Array;
begin
   if Arr = nil then
     Arr := CreateArray(_Set,_Get,_Count,_Add);
   dtArray(_Data,Arr);
end;

end.
