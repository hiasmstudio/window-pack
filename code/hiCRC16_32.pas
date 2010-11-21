
unit hiCRC16_32;

interface

uses Kol,Share,Debug;

type
  THICRC16_32 = class(TDebug)
   private
   public
   
    _prop_Type:byte;
    _prop_Metod:byte;
    _prop_Polynom:STRING;
    _prop_Init:STRING;  
    _prop_Revert:boolean;
    
    _data_Data:THI_Event;  
    _data_Polynom:THI_Event;
    _data_Init:THI_Event;
    _event_onResult:THI_Event;

   procedure _work_doCalcCRC(var _Data:TData; Index:word);
   procedure CrTabl (_MET,_POLY: integer);
  end;

implementation


var
TABL : ARRAY[0..255] OF LONGWORD;

PROCEDURE THICRC16_32._work_doCalcCRC;
VAR 
MET:INTEGER;
POLY:INTEGER;
INIT:INTEGER;
ST,SU:STRING;
Q:^Byte;
CRC16:WORD;
CRC32:LONGWORD;
HI_,LO_ : integer;
i,N:INTEGER;

BEGIN
CRC16:=0;
CRC32:=0;
ST := READSTRING(_Data,_data_Data);
POLY:=HEX2INT(READSTRING(_Data,_data_Polynom,_prop_Polynom));
INIT:=HEX2INT(READSTRING(_Data,_data_Init,_prop_Init));
MET := _prop_Metod;
CrTabl(MET,POLY);
IF _prop_Type=1 THEN BEGIN  
                     REPLACE(ST,' ','');
                     REPLACE(ST,'$','');
                     END;       
IF MET=4 THEN CRC32:=INIT ELSE CRC16:=INIT;  
IF LENGTH(ST) > 0 THEN
BEGIN
IF _prop_Type=0 THEN
 BEGIN
 Q := @(ST[1]);
 FOR i:=1 TO LENGTH(ST) DO
  BEGIN
  CASE MET OF
  0..2: CRC16:=HI(CRC16)XOR TABL[Q^ XOR LO(CRC16)];
     3: CRC16:=(CRC16 SHL 8)XOR TABL[Q^ XOR(CRC16 SHR 8)];
     4: CRC32:=(CRC32 SHR 8)XOR TABL[Q^ XOR(CRC32 AND $000000FF)];
  END;
  INC(Q);
  END;
END ELSE 
      BEGIN
      N:=1;
      WHILE N<= LENGTH(ST) DO
      BEGIN
      SU:=CHAR(Hex2Int(COPY(ST,N,2)));
      Q:= @(SU[1]);  
      CASE MET OF
      0..2: CRC16:=HI(CRC16)XOR TABL[Q^ XOR LO(CRC16)];
         3: CRC16:=(CRC16 SHL 8)XOR TABL[Q^ XOR(CRC16 SHR 8)];
         4: CRC32:=(CRC32 SHR 8)XOR TABL[Q^ XOR(CRC32 AND $000000FF)];
      END;
      N:= N+2;
      END;
      END;
                     
     CASE MET OF
     0,3: CRC16:=CRC16;
       1: BEGIN
          LO_:=(CRC16 AND $ff00) SHR 8;
          HI_:=(CRC16 AND $00ff) SHL 8;
          CRC16:=LO_ Or HI_ ;
          END;
       2: BEGIN
          CRC16:= Not CRC16;
          LO_:=(CRC16 AND $ff00) SHR 8;
          HI_:=(CRC16 AND $00ff) SHL 8;
          CRC16:=LO_ Or HI_ ;        
          END;
       4: CRC32:= NOT CRC32;
      END;      
   END;
 
IF MET=4 THEN _hi_CreateEvent(_Data,@_event_onResult, Int2Hex(CRC32,8))           
 ELSE
  IF _prop_Revert=FALSE THEN _hi_CreateEvent(_Data,@_event_onResult,Int2Hex(CRC16,4))  
   ELSE
   BEGIN                                                             
   LO_:=(CRC16 AND $ff00) SHR 8;                           
   HI_:=(CRC16 AND $00ff) SHL 8;
   CRC16:=LO_ Or HI_ ;
   _hi_CreateEvent(_Data,@_event_onResult, Int2Hex(CRC16,4));    
   END;   
END;

       
PROCEDURE THICRC16_32.CrTabl (_MET,_POLY: integer);
VAR
i,j   : INTEGER;
crc,L : LONGWORD;
BEGIN
L:=0;
FOR i:=0 TO 255 DO
 BEGIN
 crc := 0;
   CASE _MET OF
   0..2: L:=i;
      3: L:=(i SHL 8);                                                        
      4: crc:= i;
   END;
 FOR j:=0 TO 7 DO 
  BEGIN
   CASE _MET OF
   0..2: IF((crc XOR L)AND $0001)<>0 THEN crc:=(crc SHR 1)XOR _POLY ELSE crc:=crc SHR 1;
      3: IF((crc XOR L)AND $8000)<>0 THEN crc:=(crc SHL 1)XOR _POLY ELSE crc:=crc SHL 1;
      4: IF(crc AND $00000001)<>0 THEN crc:=(crc SHR 1) XOR _POLY ELSE crc:= crc SHR 1;  
   END;   
   CASE _MET OF   
   0..2: l:= l SHR 1;
      3: l:= l SHL 1;
      4: TABL[i]:= crc
   END;
  END;  
 IF _MET<>4 THEN TABL[i]:= crc;      
 END;
END;
END.
