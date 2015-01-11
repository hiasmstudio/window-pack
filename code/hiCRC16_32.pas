unit hiCRC16_32;

interface

uses 
  Kol, Share, Debug;

type

  ThiCRC16_32 = class(TDebug)
    private
      TABL: array[0..255] of LongWord;
      FCurrPoly: string;
      procedure CalcTable;
    public
      _prop_Type: Byte;
      _prop_Metod: Byte;
      _prop_Polynom: string;
      _prop_Init: string;  
      _prop_Revert: Boolean;
      
      _data_Data: THI_Event;  
      _data_Polynom: THI_Event;
      _data_Init: THI_Event;
      _event_onResult: THI_Event;

      procedure _work_doCalcCRC(var _Data: TData; Index: Word);
  end;

implementation


procedure ThiCRC16_32._work_doCalcCRC;
var 
  INIT: Integer;
  ST, SU: string;
  Q: ^Byte;
  CRC16: Word;
  CRC32: LongWord;
  i: Integer;
begin
  CRC16 := 0;
  CRC32 := 0;
  ST := ReadString(_Data, _data_Data);
  
  SU := ReadString(_Data, _data_Polynom, _prop_Polynom);
  if SU <> FCurrPoly then
  begin
    FCurrPoly := SU;
    CalcTable;
  end;
  
  INIT := Hex2Int(ReadString(_Data, _data_Init, _prop_Init));

  if _prop_Type = 1 then
  begin  
    Replace(ST,' ','');
    Replace(ST,'$','');
  end;       
  
  if _prop_Metod = 4 then CRC32 := INIT else CRC16 := INIT;
  
  if Length(ST) > 0 then
  begin
    if _prop_Type = 0 then
    begin
      Q := @(ST[1]);
      for i := 1 to Length(ST) do
      begin
        case _prop_Metod of
          0..2: CRC16 := Hi(CRC16) xor TABL[Q^ xor Lo(CRC16)];
          3:    CRC16 := (CRC16 shl 8) xor TABL[Q^ xor (CRC16 shr 8)];
          4:    CRC32 := (CRC32 shr 8) xor TABL[Q^ xor (CRC32 and $000000FF)];
        end;
        Inc(Q);
      end;
    end
    else 
    begin
      i := 1;
      while i <= Length(ST) do
      begin
        SU := Char(Hex2Int(Copy(ST, i, 2)));
        Q := @(SU[1]);  
        case _prop_Metod of
          0..2: CRC16 := Hi(CRC16) xor TABL[Q^ xor Lo(CRC16)];
          3:    CRC16 := (CRC16 shl 8) xor TABL[Q^ xor (CRC16 shr 8)];
          4:    CRC32 := (CRC32 shr 8) xor TABL[Q^ xor (CRC32 and $000000FF)];
        end;
        i := i + 2;
      end;
    end;
                       
    case _prop_Metod of
      0, 3: CRC16 := CRC16;
      1: 
         begin
           //CRC16 := ((CRC16 and $ff00) shr 8) or ((CRC16 and $00ff) shl 8) ; // Здесь и дальше - перестановка байтов местами
           CRC16 := (CRC16 shr 8) or (CRC16 shl 8) ;
         end;
      2: 
        begin
          CRC16 := not CRC16;
          //CRC16 := ((CRC16 and $ff00) shr 8) or ((CRC16 and $00ff) shl 8) ;
          CRC16 := (CRC16 shr 8) or (CRC16 shl 8) ;
        end;
      4: CRC32 := not CRC32;
    end;      
  end;
 
  if _prop_Metod = 4 then
    _hi_CreateEvent(_Data,@_event_onResult, Int2Hex(CRC32,8))           
  else
    if _prop_Revert = False then
      _hi_CreateEvent(_Data, @_event_onResult, Int2Hex(CRC16, 4))  
    else
    begin                                                             
      //CRC16 := ((CRC16 and $ff00) shr 8) or ((CRC16 and $00ff) shl 8);
      CRC16 := (CRC16 shr 8) or (CRC16 shl 8) ;
      _hi_CreateEvent(_Data, @_event_onResult, Int2Hex(CRC16, 4));    
    end;
end;

       
procedure ThiCRC16_32.CalcTable;
var
  Poly: Integer;
  i, j: Integer;
  crc, L: LongWord;
begin
  L := 0;
  Poly := Hex2Int(FCurrPoly);
  for i := 0 to 255 do
  begin
    crc := 0;
    case _prop_Metod of
      0..2: L := i;
      3:    L := (i shl 8);
      4:    crc := i;
    end;
    for j := 0 to 7 do
    begin
      case _prop_Metod of
        0..2: if ((crc xor L) and $0001) <> 0 then crc := (crc shr 1) xor Poly else crc := crc shr 1;
        3:    if ((crc xor L) and $8000) <> 0 then crc := (crc shl 1) xor Poly else crc := crc shl 1;
        4:    if (crc and $00000001) <> 0 then crc := (crc shr 1) xor Poly else crc := crc shr 1;
      end;
      case _prop_Metod of   
        0..2: l := l shr 1;
        3:    l := l shl 1;
        4:    TABL[i] := crc;
      end;
    end;  
    if _prop_Metod <> 4 then TABL[i] := crc;      
  end;
end;

end.
