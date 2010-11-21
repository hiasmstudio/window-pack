unit hiFindWindow;

interface

uses Kol,Share,Debug,Windows;

type
  THIFindWindow = class(TDebug)
   private
    FHandle:integer;
   public
    _prop_Caption:string;
    _prop_ClassName:string;
    _prop_SkipParam:byte;

    _data_ParentHandle:THI_Event;
    _data_ClassName:THI_Event;
    _data_Caption:THI_Event;
    _data_ChildHandle:THI_Event;
    _event_onFind:THI_Event;

    procedure _work_doFind(var _Data:TData; Index:word);
    procedure _work_doFindChild(var _Data:TData; Index:word);
    procedure _var_Handle(var _Data:TData; Index:word);
  end;

implementation

procedure THIFindWindow._work_doFind;
var c,cl:PChar;
begin
   cl := PChar(ReadString(_Data,_data_ClassName,_prop_ClassName));
   c := PChar(ReadString(_Data,_data_Caption,_prop_Caption));
   case _prop_SkipParam of
    1: c := nil;
    2: cl := nil;
   end;
   FHandle := FindWindow(cl,c);
   _hi_OnEvent(_event_onFind,fhandle);
end;

procedure THIFindWindow._work_doFindChild(var _Data:TData; Index:word);
var h,ch:cardinal;
    c,cl:PChar;
begin
   h := ReadInteger(_Data,_data_ParentHandle,0);
   cl := PChar(ReadString(_Data,_data_ClassName,_prop_ClassName));
   c := PChar(ReadString(_Data,_data_Caption,_prop_Caption));
   ch := ReadInteger(_Data,_data_ChildHandle,0);
   case _prop_SkipParam of
    1: c := nil;
    2: cl := nil;
   end;  
   FHandle := FindWindowEx(h,ch,cl,c);
   _hi_OnEvent(_event_onFind,fhandle);
end;

procedure THIFindWindow._var_Handle;
begin
  dtInteger(_Data,FHandle);
end;

end.
