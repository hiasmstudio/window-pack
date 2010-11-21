unit hiStyleXP;

interface

uses Debug, Share;

{$I def.inc}
{$ifndef F_P} {$R WindowsXP.res} {$endif}

type
  THIStyleXP = TDebug;

implementation

initialization
{$ifdef F_P}
  {$ifndef _PROTECT_STD_}
    _debug('Компонент StyleXP не работает под FPC. Установите компилятор Delphi.');
  {$endif}
  {$ifdef _PROTECT_MAX_}
    _debug('Компонент StyleXP не работает под FPC. Установите компилятор Delphi.');
  {$endif}
{$endif F_P}
end.
