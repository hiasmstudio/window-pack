unit hiMenu;

interface

{$I share.inc}

uses Windows,Kol,Share,Messages,Debug;

type
 THIMenu = class(TDebug)
  private
   Old:TOnMessage;
   SetMenuString: string;

   procedure SetMenu(const Value:string);
   function _OnMes( var Msg: TMsg; var Rslt: Integer ): Boolean;
  public
   Form:PControl;
   FMainMenu: PMenu;
   ListMenuStr: array  of string;

   _data_Array:THI_Event;

   _event_onSelectNum:THI_Event;
   _event_onSelectStr:THI_Event;

   constructor Create(Control:PControl);
   procedure _work_doInit(var _Data:TData; Index:word);
   procedure _var_Handle(var _Data:TData; Index:word);
  property _prop_Menu:string write SetMenu;
 end;

implementation

constructor THIMenu.Create;
begin
   inherited Create;
   Form := Control;
   Old := Form.OnMessage;
   Form.OnMessage := _OnMes;
end;

{$ifdef F_P}
var ListMenu: array[0..200] of PChar;
{$endif}

procedure THIMenu.SetMenu;
type TPCharArray = array[0..0] of PChar;
//     PPCharArray = ^TPCharArray;
var i:integer;
    List:PStrList;
   {$ifndef F_P}
   ListMenu: array of PChar;
   {$endif}
    //k:PPCharArray;
begin
   List := NewStrList;
   List.text := Value;
   if List.Count > 0 then
    begin
     SetLength(ListMenuStr,List.Count);
     {$ifndef F_P}
     SetLength(ListMenu,List.Count);
     {$endif}
     //getmem(k,4*10);
     for i := 0 to List.Count-1 do
      begin
       ListMenuStr[i] := List.Items[i];
       ListMenu[i] := PChar(@ListMenuStr[i][1]);
       //k[i] := PChar(ListMenuStr[i]);
      end;
    end;
   FMainMenu := NewMenu( Applet, 0, ListMenu, nil );
   Form.Menu := FMainMenu.Handle;
   List.free;      
end;

procedure THIMenu._work_doInit(var _Data:TData; Index:word);
var
   i:integer;
   Ind:TData;
   Item:TData;
   Arr:PArray;
   {$ifndef F_P}
   ListMenu: array of PChar;
   {$endif}
begin
   if FMainMenu <> nil then FMainMenu.Free;

   Ind.Data_type := data_int;
   Ind.idata := 0;
   Arr := ReadArray(_data_Array);
   if (Arr <> nil)and(Arr._Count>0) then
    begin
     SetLength(ListMenuStr,Arr._Count);
     {$ifndef F_P}
     SetLength(ListMenu,Arr._Count);
     {$endif}
     while Arr._Get(Ind,Item) do
      begin
       i := Ind.idata;
       ListMenuStr[i] := Item.sdata;
       ListMenu[i] := PChar(ListMenuStr[i]);
       inc(Ind.idata);
      end;
    end;
   FMainMenu := NewMenu( Applet, 0, ListMenu, nil );
   Form.Menu := FMainMenu.Handle;
end;

function THIMenu._OnMes;
var m:PMenu;
begin
 case Msg.message of
  WM_COMMAND:
   if (Msg.lParam = 0) and (HIWORD( Msg.wParam ) <= 1) then begin
     m := FMainMenu.Items[Msg.WParam];
   if m <> nil then begin
     _hi_OnEvent(_event_onSelectNum,FMainMenu.IndexOf(m));
     _hi_OnEvent(_event_onSelectStr,FMainMenu.Items[FMainMenu.IndexOf(m)].Caption);
   end;
  end;
 end;
 Result := Old(Msg,Rslt);
end;

procedure THIMenu._var_Handle(var _Data:TData; Index:word);
begin
  dtInteger(_Data,FMainMenu.Handle);
end;

end.
