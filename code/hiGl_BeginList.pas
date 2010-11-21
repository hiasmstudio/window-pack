unit hiGl_BeginList;

interface

uses Kol,Share,Debug,OpenGL;

const
 lmCompile = GL_COMPILE;
 lmCompileExecute = GL_COMPILE_AND_EXECUTE;

type
  THIGl_BeginList = class(TDebug)
   private
   public
    _prop_Index:integer;
    _prop_Mode:cardinal;

    _data_Index:THI_Event;
    _event_onBiginList:THI_Event;

    procedure _work_doBeginList(var _Data:TData; Index:word);
    procedure _work_doDeleteList(var _Data:TData; Index:word);
  end;

implementation

procedure THIGl_BeginList._work_doBeginList;
begin
   glNewList(ReadInteger(_Data,_data_Index,_prop_Index),_prop_Mode);
   _hi_CreateEvent(_Data,@_event_onBiginList);
end;

procedure THIGl_BeginList._work_doDeleteList;
begin
   glDeleteLists(ReadInteger(_Data,_data_Index,_prop_Index),1);
end;

end.
