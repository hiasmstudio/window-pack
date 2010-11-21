unit hiKeyboardLayout;

interface

uses Kol,Share,Debug,windows;

type
  THIKeyboardLayout = class(TDebug)
   public
    _data_handle:THI_Event;
    
    procedure _work_doRussianKbd(var _Data:TData; Index:word);
    procedure _work_doEnglishKbd(var _Data:TData; Index:word);
    procedure _work_doUkrainianKbd(var _Data:TData; Index:word);
    procedure _work_doBelorussionKbd(var _Data:TData; Index:word);
    procedure _work_doPolishKbd(var _Data:TData; Index:word);
    procedure _work_doEstoniaKbd(var _Data:TData; Index:word);   
    procedure _work_doLitovskiKbd(var _Data:TData; Index:word);
    procedure _work_doLatyshskijKbd(var _Data:TData; Index:word);
    procedure _var_CurrentKbd(var _Data:TData; Index:word);
    procedure _var_WindowKbd(var _Data:TData; Index:word);
  end;

implementation

procedure THIKeyboardLayout._work_doRussianKbd;
begin
   LoadKeyboardLayout('00000419',KLF_ACTIVATE);
end;

procedure THIKeyboardLayout._var_CurrentKbd(var _Data:TData; Index:word);
var s:array[0..100]of char;
begin
   GetKeyboardLayoutName(s);
   dtString(_Data,s);
end;

procedure THIKeyboardLayout._work_doEnglishKbd;
begin
   LoadKeyboardLayout('00000409',KLF_ACTIVATE);
end;

procedure THIKeyboardLayout._work_doUkrainianKbd;
begin
   LoadKeyboardLayout('00000422',KLF_ACTIVATE);
end;

procedure THIKeyboardLayout._work_doBelorussionKbd;
begin
   LoadKeyboardLayout('00000423',KLF_ACTIVATE);
end;

procedure THIKeyboardLayout._work_doPolishKbd;
begin
   LoadKeyboardLayout('00000415',KLF_ACTIVATE);
end;

procedure THIKeyboardLayout._work_doEstoniaKbd;
begin
   LoadKeyboardLayout('00000425',KLF_ACTIVATE);
end;

procedure THIKeyboardLayout._work_doLitovskiKbd;
begin
   LoadKeyboardLayout('00000427',KLF_ACTIVATE);
end;

procedure THIKeyboardLayout._work_doLatyshskijKbd;
begin
   LoadKeyboardLayout('00000426',KLF_ACTIVATE);
end;

procedure THIKeyboardLayout._var_WindowKbd;
begin
   dtInteger(_Data, GetKeyboardLayout(GetWindowThreadProcessId(ReadInteger(_data, _data_handle, 0), nil)));
end;

end.
