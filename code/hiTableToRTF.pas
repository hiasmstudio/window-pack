// Made by nesco
//
unit hiTableToRTF;

interface

uses Windows,kol,Share,Debug;

type
 THiTableToRTF = class(TDebug)
   private
     rtfTable: string;
   public
    _data_StringTable: THI_Event;
    _event_onTableToRTF: THI_Event;
    procedure _work_doTableToRTF(var _Data:TData; Index:word);
    procedure _var_RTFTable(var _Data:TData; Index:word);
 end;

implementation

procedure THiTableToRTF._work_doTableToRTF;
var
  sControl: PControl;
  Kx : Real;
  CellMargin: string;
  FontSize: string;
  IncCellWidth: integer;
  Col, Row: integer;
  fFrom: TRGB;
begin
  sControl := ReadControl(_data_StringTable,'StringTable');
  if not Assigned(sControl) then exit;
  Kx := 1440 / GetDeviceCaps(sControl.Canvas.Handle, LOGPIXELSX);
  CellMargin := int2str(Round(Int(2 * Kx)));
  FontSize := int2str(Round(2 * ((sControl.Font.FontHeight * -72) - 36) / GetDeviceCaps(sControl.Canvas.Handle,LOGPIXELSY)));
  rtfTable :=  '{\rtf1\ansi\ansicpg1251'#13#10 + '{\*\generator RTF-table 1.05;}'#13#10 +
               '{\fonttbl{\f0\fnil ' + sControl.Font.FontName + ';}}'#13#10;

  fFrom := TRGB(Color2RGB(clSilver));
  rtfTable := rtfTable + '{\colortbl ;\red' + int2str(fFrom.R) + '\green' + int2str(fFrom.G) +
                         '\blue' + int2str(fFrom.B) + ';}' + #13#10;

  rtfTable := rtfTable + '\trowd\f0\fs' + FontSize + '\trgaph' + CellMargin + 
                        '\trbrdrt\brdrs\brdrw10\trbrdrl\brdrs\brdrw10\trbrdrb\brdrs\brdrw10\trbrdrr\brdrs\brdrw10'#13#10;

  IncCellWidth := 0;
  for Col := 0 to sControl.LVColCount - 1 do begin
    IncCellWidth := Round(Int(IncCellWidth + sControl.LVColWidth[Col] * Kx));
    rtfTable := rtfTable + '\clcbpat1\clbrdrt\brdrw15\brdrs\clbrdrl\brdrw15\brdrs\clbrdrb\brdrw15\brdrs\clbrdrr\brdrw15\brdrs\cellx' + Int2Str(IncCellWidth) + #13#10;
  end;
  rtfTable := rtfTable + '\pard'#13#10 + '\intbl\highlight1\b'#13#10; 

  for Col := 0 to sControl.LVColCount - 1 do
    rtfTable := rtfTable + sControl.LVColText[Col] + '\cell'#13#10;
  rtfTable := rtfTable + '\highlight0\b0\row'#13#10;
  
  for Row := 0 to sControl.LVCount - 1 do
  begin
    rtfTable := rtfTable + '\trowd\f0\fs' + FontSize + '\trgaph' + CellMargin + 
                           '\trbrdrt\brdrs\brdrw10\trbrdrl\brdrs\brdrw10\trbrdrb\brdrs\brdrw10\trbrdrr\brdrs\brdrw10'#13#10;

    IncCellWidth := 0;
    for Col := 0 to sControl.LVColCount - 1 do begin
      IncCellWidth := Round(Int(IncCellWidth + sControl.LVColWidth[Col] * Kx));
      rtfTable := rtfTable + '\clbrdrt\brdrw15\brdrs\clbrdrl\brdrw15\brdrs\clbrdrb\brdrw15\brdrs\clbrdrr\brdrw15\brdrs\cellx' + Int2Str(IncCellWidth) + #13#10;
    end;
    rtfTable := rtfTable + '\pard'#13#10; 

    rtfTable := rtfTable + '\intbl'#13#10;
    for Col := 0 to sControl.LVColCount - 1 do
      rtfTable := rtfTable + sControl.LVItems[Row, Col] + '\cell'#13#10;
    rtfTable := rtfTable + '\row'#13#10;
  end;
  rtfTable := rtfTable + '}';

  _hi_OnEvent(_event_onTableToRTF, rtfTable);
end;

procedure THiTableToRTF._var_RTFTable;
begin
  dtString(_Data, rtfTable);
end;

end.