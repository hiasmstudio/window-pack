unit hiPBlur;

interface

uses Windows,Kol,Share,Debug;

type
  THIPBlur = class(TDebug)
   private
    src:PBitmap;
   public
    _prop_Method:procedure (bmp,theBitmap: PBitmap; radius: real) of object;
    _prop_Step:integer;

    _data_Bitmap:THI_Event;
    _data_Step:THI_Event;
    _event_onBlur:THI_Event;

    destructor Destroy; override;
    procedure _work_doBlur(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);    
    procedure Gaus(bmp,theBitmap: PBitmap; radius: real);
    procedure Simple(bmp,src: PBitmap; radius: real);
  end;

    procedure Gaus_Method(bmp,theBitmap: PBitmap; radius: real);
implementation

destructor THIPBlur.Destroy;
begin
   if Assigned(src) then src.free;
   inherited;
end;

const
  MaxKernelSize = 100;

type
  PRow = ^TRow;
  TRow = array[0..1000000] of TRGBTriple;

  PPRows = ^TPRows;
  TPRows = array[0..1000000] of PRow;

  TKernelSize = 1..MaxKernelSize;

  TKernel = record
    Size: TKernelSize;
    Weights: array[-MaxKernelSize..MaxKernelSize] of single;
  end;

procedure MakeGaussianKernel(var K: TKernel; radius: real; MaxData, DataGranularity: real);
var   j: integer;
      temp, delta: real;
      KernelSize: TKernelSize;
begin
   for j := Low(K.Weights) to High(K.Weights) do begin
      temp := j / radius;
      K.Weights[j] := exp(-temp * temp / 2);
   end;

   temp := 0;
   for j := Low(K.Weights) to High(K.Weights) do
      temp := temp + K.Weights[j];
   for j := Low(K.Weights) to High(K.Weights) do
      K.Weights[j] := K.Weights[j] / temp;

   KernelSize := MaxKernelSize;
   delta := DataGranularity / (2 * MaxData);
   temp := 0;
   while (temp < delta) and (KernelSize > 1) do begin
      temp := temp + 2 * K.Weights[KernelSize];
      dec(KernelSize);
   end;

   K.Size := KernelSize;

   temp := 0;
   for j := -K.Size to K.Size do
      temp := temp + K.Weights[j];
   for j := -K.Size to K.Size do
      K.Weights[j] := K.Weights[j] / temp;
end;

function TrimInt(Lower, Upper, theInteger: integer): integer;
begin
   if (theInteger <= Upper) and (theInteger >= Lower) then
      result := theInteger
   else if theInteger > Upper then
      result := Upper
   else
      result := Lower;
end;

function TrimReal(Lower, Upper: integer; x: real): integer;
begin
   if (x < upper) and (x >= lower) then
      result := trunc(x)
   else if x > Upper then
      result := Upper
   else
      result := Lower;
end;

procedure BlurRow(var theRow: array of TRGBTriple; max:integer; K: TKernel; P: PRow);
var   j, n, m: integer;
      w, tr, tg, tb: real;
begin
   m := max - 1;
   for j := 0 to m do begin
      tb := 0;
      tg := 0;
      tr := 0;
      for n := -K.Size to K.Size do begin
         w := K.Weights[n];
         with theRow[TrimInt(0, m, j - n)] do begin
            tb := tb + w * rgbtBlue;
            tg := tg + w * rgbtGreen;
            tr := tr + w * rgbtRed;
         end;
      end;
      with P[j] do begin
         rgbtBlue  := TrimReal(0, 255, tb);
         rgbtGreen := TrimReal(0, 255, tg);
         rgbtRed   := TrimReal(0, 255, tr);
      end;
   end;
   Move(P[0], theRow[0], max * Sizeof(TRGBTriple));
end;

type
 TGThreadRec = record
   handle:cardinal;
   theRows: PPRows;
   theBitmap:PBitmap;
   index,count:integer;
   K: TKernel;
 end;
 PGThreadRec = ^TGThreadRec;

function Gaus_proc(l:pointer):Integer; stdcall;
var   Row, Col: integer;      
      ACol: PRow;
      P: PRow;
      h,sh:integer;
begin
  Result := 0;
  with PGThreadRec(l)^ do
    begin 
       h := theBitmap.Height div count; 
       sh := (index - 1)*h; 
      
       GetMem(ACol, theBitmap.Height * SizeOf(TRGBTriple));
       P := AllocMem(theBitmap.Width * SizeOf(TRGBTriple));
       for Row := sh to sh + h - 1 do
          BlurRow(theRows[Row]^, theBitmap.Width, K, P);
    
       ReAllocMem(P, theBitmap.Height * SizeOf(TRGBTriple));
       h := theBitmap.Width div count; 
       sh := (index - 1)*h; 
       for Col := sh to sh + h - 1 do
         begin
           for Row := 0 to theBitmap.Height - 1 do
             ACol[Row] := theRows[Row][Col];
          
          BlurRow(ACol^, theBitmap.Height, K, P);
          
          for Row := 0 to theBitmap.Height - 1 do
             theRows[Row][Col] := ACol[Row];
         end;
       FreeMem(ACol);
       ReAllocMem(P, 0);
    end;
end;

procedure Gaus_Method(bmp,theBitmap: PBitmap; radius: real);
var   Row: integer;
      theRows: PPRows;
      K: TKernel;
      
      rc:PGThreadRec;
      i,c:integer;
      id:LongWord;
      lpSystemInfo:_SYSTEM_INFO;
      FEvents:array of cardinal;
      lst:PList;
begin
   theBitmap.Assign(bmp);
   theBitmap.PixelFormat := pf24bit;
   if (theBitmap.HandleType <> bmDIB) or (theBitmap.PixelFormat <> pf24Bit) then exit;

   MakeGaussianKernel(K, radius, 255, 1);
   GetMem(theRows, theBitmap.Height * SizeOf(PRow));

   for Row := 0 to theBitmap.Height - 1 do
      theRows[Row] := theBitmap.Scanline[Row];

   if(theBitmap.Width > 256)and(theBitmap.Height > 256)then
     begin
       GetSystemInfo(lpSystemInfo);
       c := lpSystemInfo.dwNumberOfProcessors;
     end
   else c := 1;

   lst := NewList;
   SetLength(FEvents, c);
   for i := 1 to c do
     begin
       new(rc);
       rc.theRows := theRows;
       rc.k := k;
       rc.index := i;
       rc.count := c;
       rc.theBitmap := theBitmap;
       rc.handle := CreateThread(0, 0, @Gaus_proc, rc, 0, id);
       
       FEvents[i-1] := rc.handle;
       lst.Add(rc); 
       SetThreadPriority(rc.handle, THREAD_PRIORITY_HIGHEST);
     end;
   WaitForMultipleObjects(c, PWOHandleArray(@FEvents[0]), true, cardinal(-1));
   for i := 0 to c-1 do
     begin
       CloseHandle(FEvents[i]);
       dispose(PGThreadRec(lst.Items[i]));
     end;
   lst.Free; 
   
   FreeMem(theRows);
end;

procedure THIPBlur.Gaus;
begin
  Gaus_Method(bmp, theBitmap, radius);
end;

type
 TThreadRec = record
   handle:cardinal;
   src,bmp:PBitmap;
   size,Start:integer;     
 end;
 PThreadRec = ^TThreadRec;

const 
   step = 3;
   d_step = (step - 1) div 2;

function Simple_proc(l:pointer):Integer; stdcall;
type   TArr = array[0..0] of record r,g,b:byte; end;
var    i, j, t, _r, _g, _b, cnt,_x,_y: integer;
      row:pointer;
begin
   Result := 0;
   with PThreadRec(l)^ do
      for j := Start to Start + Size-1 do
        begin
            row := Src.ScanLine[j]; 
            for i := 0 to bmp.Width-1 do  
              begin
                cnt := 0;
                _r := 0;
                _g := 0;
                _b := 0;
                for t := 0 to step*step-1 do
                  begin      
                   _x := i + t mod step - d_step;
                   _y := j + t div step - d_step; 
                   if (_x >= 0)and(_x < bmp.Width)and(_y >= 0)and(_y < bmp.Height)then
                      with TArr(Bmp.ScanLine[_y]^)[_x] do begin
                         inc(cnt);
                         inc(_r,r);
                         inc(_g,g);
                         inc(_b,b);
                      end;
                  end;
                with TArr(row^)[i] do 
                  begin
                    r := _r div cnt;
                    g := _g div cnt;
                    b := _b div cnt;
                  end;
              end;
        end;
end;

procedure THIPBlur.Simple;
var rc:PThreadRec;
    i,c:integer;
    id:LongWord;
    lpSystemInfo:_SYSTEM_INFO;
    FEvents:array of cardinal;
    lst:PList;
begin
   bmp.PixelFormat := pf24bit;
   src.PixelFormat := pf24bit;
   if(bmp.Width > 256)and(bmp.Height > 256)then
     begin
       GetSystemInfo(lpSystemInfo);
       c := lpSystemInfo.dwNumberOfProcessors;
     end
   else c := 1;
   
   lst := NewList;
   SetLength(FEvents, c);
   for i := 1 to c do
     begin
       new(rc);
       rc.src := src;
       rc.bmp := bmp;
       rc.size := bmp.height div c;
       rc.Start := (i-1)*rc.size;
       rc.handle := CreateThread(0, 0, @Simple_proc, rc, 0, id);
       FEvents[i-1] := rc.handle;
       lst.Add(rc); 
       SetThreadPriority(rc.handle, THREAD_PRIORITY_HIGHEST);
     end;
   WaitForMultipleObjects(c, PWOHandleArray(@FEvents[0]), true, cardinal(-1));
   for i := 0 to c-1 do
     begin
       CloseHandle(FEvents[i]);
       dispose(PThreadRec(lst.Items[i]));
     end;
   lst.Free; 
end;

procedure THIPBlur._work_doBlur;
var   Bmp:PBitmap;
begin
   bmp := ReadBitmap(_Data,_data_Bitmap,nil);
   if (bmp = nil) or bmp.Empty then exit;
   if Assigned(src) then src.free;
   src := NewBitmap(bmp.Width,bmp.Height);
   _prop_Method(bmp, src, ReadInteger(_Data,_data_Step, _prop_Step));
   _hi_OnEvent(_event_onBlur,src);
end;

procedure THIPBlur._var_Result;
begin
   if (src = nil) or src.Empty then exit;
   dtBitmap(_Data, src);
end;

end.
