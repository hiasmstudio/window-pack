unit GenteeShare;

interface

uses kol, Windows;
//*****************************************************************************

const
// Флаги sgeinit
GEF_NOSYSOUT = $0001;  // Не выводить служебные сообщения
GEF_CONSOLE  = $0002;  // Консольное приложение
GEF_VM       = $0004;  // Для всех ge_load использовать одну виртуальную машину

// Флаги ge_load
GLOAD_ENTRYZERO = $01;    // Загрузить байт-код и выполнить entryzero функции
GLOAD_ENTRY     = $03;    // Загрузить байт-код и выполнить entry функции
GLOAD_MAIN      = $07;    // GLOAD_ENTRY и вызвать последнюю main функцию
GLOAD_ONE       = $08;    // Загрузить только один объект он должен быть в PMODE
GLOAD_FILE      = $10;    // Для ge_load загрузка из файла, а не из памяти

//--------------------------------------------------------------------------
// Флаги компиляции
COMPILE_NOSTD   = $2;   // Не подключать стандартную библиотеку

//--------------------------------------------------------------------------
{$A-}
// Структура для передачи сообщений
type Tmess = record
   code:       cardinal;
   text:       PChar;
   filename:   PChar;
   line:       cardinal;
   pos:        cardinal;
   iscompile:  cardinal;
end;
type pTmess = ^Tmess;
//--------------------------------------------------------------------------

type
Tmessagefunc = function ( mess: pTmess ): integer; stdcall;
Tprintfunc = procedure ( str: PChar ); stdcall;
Texportfunc = function ( str: PChar ): pointer; stdcall;

//--------------------------------------------------------------------------

// Структура для инициализации
type Tgeinit = record
   size:       cardinal;         // Размер даной структуры
   flags:      cardinal;         // Флаги инициализации
   messagef:   Tmessagefunc;     // Функция обработчик событий. Может быть нулем.
   printf:     Tprintfunc;       // Функция вывода сообщений
   exportf:    Texportfunc;      // Функция экспортирования функций
end;
type pTgeinit = ^Tgeinit;

//--------------------------------------------------------------------------

// Структура для вызова compile
type Tbcode = record
   data:     PChar;               // Указатель на байт-код
   size:     cardinal;            // Размер байт-кода
   reserved: array[0..9] of byte; // Зарезервировано
end;
type pTbcode = ^Tbcode;
     pcardinal = ^cardinal;
//--------------------------------------------------------------------------

Tge_compile    = function( filename: PChar; fileout: PChar; bcode: pTbcode;
                     cflag: cardinal; args: PChar ): cardinal; stdcall;
Tge_execute    = function( filename: PChar; args: PChar ): cardinal; stdcall;
Tge_call       = function( id: cardinal; result: pcardinal; Data:pointer ):
                     cardinal; cdecl; // varargs;
Tge_deinit     = procedure; stdcall;
Tge_freebcode  = procedure  ( psbcode: pTbcode ); stdcall;
Tge_getid      = function ( name: PChar ): cardinal; stdcall;
Tge_init       = procedure( geinit: pTgeinit ); stdcall;
Tge_load       = function( bytecode: PChar; loadflag: cardinal;
                     args: PChar ): cardinal; stdcall;

//*****************************************************************************
function shell_ge_init( flags: cardinal; messagef: Tmessagefunc;
                     printf: Tprintfunc; exportf: Texportfunc): integer;
procedure shell_ge_deinit( handle: integer );
function shell_ge_execute( filename: string;
                     const args: array of string ): cardinal;
//*****************************************************************************

var
   ge_compile:       Tge_compile;
   ge_execute:       Tge_execute;
   ge_call:          Tge_call;
   ge_deinit:        Tge_deinit;
   ge_freebcode:     Tge_freebcode;
   ge_getid:         Tge_getid;
   ge_init:          Tge_init;
   ge_load:          Tge_load;

implementation
{
function messagefunc( mess: pTmess ): integer; stdcall;
begin
   MessageDlg( strpas( mess^.text), mtInformation, [mbOk], 0);
   result := 0;
end;

procedure printfunc( str: PChar ); stdcall;
begin
   MessageDlg( strpas( str ), mtInformation, [mbOk], 0);
end;   }

function shell_ge_init( flags: cardinal; messagef: Tmessagefunc;
                     printf: Tprintfunc; exportf: Texportfunc): integer;
var geinit: Tgeinit;
    handle: integer;
begin
   handle := LoadLibrary('gentee.dll');
   if handle <> 0 then
   begin
      @ge_compile    := GetProcAddress( handle, 'ge_compile' );
      @ge_execute    := GetProcAddress( handle, 'ge_execute' );
      @ge_call       := GetProcAddress( handle, 'ge_call' );
      @ge_deinit     := GetProcAddress( handle, 'ge_deinit' );
      @ge_freebcode  := GetProcAddress( handle, 'ge_freebcode' );
      @ge_getid      := GetProcAddress( handle, 'ge_getid' );
      @ge_init       := GetProcAddress( handle, 'ge_init' );
      @ge_load       := GetProcAddress( handle, 'ge_load' );
      if @ge_init <> nil then
      begin
         geinit.size := sizeof( Tgeinit );
         geinit.flags := flags;
         geinit.messagef := messagef;
         geinit.printf := printf;
         geinit.exportf := exportf;
         ge_init( @geinit );
      end
      else
      begin
         FreeLibrary( handle );
         handle := 0;
      end;
   end;
   result := handle;
end;

procedure shell_ge_deinit( handle: integer );
begin
   ge_deinit;
   FreeLibrary( handle );
end;

function shell_ge_execute( filename: string;
                     const args: array of string ): cardinal;
var pc_filename, pc_args: PChar;
    i, len: integer;
begin
   result := 0;
   if length( filename ) = 0 then
      exit;
   pc_filename := AllocMem( length( filename ) + 1 );
   StrPCopy( pc_filename, filename );
   len := 0;
   for i := 0 to High(args) do
      len := len + length( args[i] ) + 1;
   if len = 0 then
      pc_args := Nil
   else
   begin
      pc_args := AllocMem( len );
      len := 0;
      for i := 0 to High(args) do
      begin
         StrPCopy( pc_args + len, args[i] );
         len := len + length( args[i] ) + 1;
      end;
   end;
   result := ge_execute( pc_filename, pc_args );
   if pc_args <> Nil then
      FreeMem( pc_args );
   FreeMem( pc_filename );
end;

end.







