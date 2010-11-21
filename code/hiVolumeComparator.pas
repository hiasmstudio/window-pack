unit hiVolumeComparator;

interface

uses windows,Kol,Share,Debug;

type
  THIVolumeComparator = class(TDebug)
   private
    FList:PStrListEx;
    FDir:string;
    procedure Add(const name:string; mem:PStream);
    procedure setVolumes(const dir:string);
   public
    _data_Name:THI_Event;
    _data_Stream:THI_Event;
    _event_onFailed:THI_Event;
    _event_onOk:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doCompare(var _Data:TData; Index:word);
    procedure _work_doAdd(var _Data:TData; Index:word);
    property _prop_Volumes:string write setVolumes;
  end;

implementation

constructor THIVolumeComparator.Create;
begin
   inherited;
   FList := NewStrListEx;
end;

destructor THIVolumeComparator.Destroy;
begin
   FList.free;
   inherited;
end;

procedure THIVolumeComparator.setVolumes;
var Lst:PDirList;
    i:integer;
    mem,fs:PStream;
begin
   Lst := NewDirList(Dir,'*.*',FILE_ATTRIBUTE_NORMAL);
   for i := 0 to Lst.Count-1 do
    begin
      mem := NewMemoryStream;
      fs := NewReadFileStream(Dir + Lst.Items[i].cFileName);
      stream2stream(mem, fs, fs.size);
      Add(Lst.Items[i].cFileName, mem);
      fs.free;
    end;
   lst.free;
   FDir := Dir;
end;

procedure THIVolumeComparator.Add;
begin
   FList.AddObject(name, cardinal(mem));
end;

function abs(x:real):real; begin if x < 0 then result := -x else result := x end;
function _abs(x:integer):integer; begin if x < 0 then result := -x else result := x end;

procedure THIVolumeComparator._work_doCompare;
const scount = 20;
var i,j,t:integer;
    smp,s:PStream;
    st1, st2:integer;
    ost1, ost2, o:integer;
    fOk,fFailed,fBreak:integer;
    k1,k2:real;
    m1,m2:real;
    res:array of record 
       a:real;
       b:integer;
    end;
begin
   s := ReadStream(_Data, _data_Stream); 
   
   SetLength(res, FList.Count);
   _hi_onEvent(_event_onFailed, 'Size of: ' + int2str(s.size));
   for i := 0 to FList.Count-1 do
    begin
      smp := PStream(FList.Objects[i]);
      fOk := 0;
      fFailed := 0;
      fBreak := 0;
      if s.Size > smp.Size then
       begin
         k1 := 1;
         k2 := smp.Size/s.Size;
       end
      else
       begin
         k1 := s.Size/smp.Size;
         k2 := 1;
       end;
      if _abs(s.Size - smp.Size) > 1500 then
//        Memo1.Lines.Add(ListBox1.Items[i] + ' skipped')
      else
        for j := 0 to max(s.Size, smp.Size) div (2*scount)-scount do
         begin
           st1 := 0;
           st2 := 0;
           for t := j*scount to j*scount+scount-1 do
            begin
              st1 := st1 + smallint(pointer(integer(smp.memory) + Round(t*k2)*2)^);
              st2 := st2 + smallint(pointer(integer(s.memory) + Round(t*k1)*2)^);
            end;
           st1 := st1 div scount;
           st2 := st2 div scount;

           if st1 = 0 then
             m1 := ost1
           else m1 := ost1/st1;
           if st2 = 0 then
             m2 := ost2
           else m2 := ost2/st2;

           if(ost1 > st1)and(ost2 > st2)or(ost1 < st1)and(ost2 < st2)then
           else inc(fBreak);

           if m2 = 0 then
             if abs(m1) < 0.1 then
               inc(fOk)
             else inc(fFailed)
           else if abs(m1 - m2) < 0.1 then
             inc(fOk)
           else inc(fFailed);

           ost1 := st1;
           ost2 := st2;
         end;
      _hi_onEvent(_event_onFailed, FList.Items[i] + ' - OK = ' + int2str(fOk) + ' fail = ' + int2str(fFailed) + ' br = ' + int2str(fBreak) + ' Size of: ' + int2str(smp.size));
      if fFailed = 0 then
        res[i].a := fOk
      else res[i].a := fOk/fFailed;
      res[i].b := fBreak; 
    end;
   m1 := -1;
   t := -1;
   fBreak := 1000;
   for i := 0 to FList.Count-1 do
     if(res[i].a > 1)and((res[i].b < fBreak)or(res[i].b = fBreak)and(res[i].a > m1))then
      begin
        m1 := res[i].a;
        fBreak := res[i].b; 
        t := i;
      end;

   if t = -1 then exit;

   _hi_onEvent(_event_onOk, FList.Items[t]);
end;

procedure THIVolumeComparator._work_doAdd;
var st,mem:PStream;
    n:string;
    i:integer;
begin
   st := ReadStream(_Data, _data_Stream);
   n := ReadString(_Data, _data_Name);
   mem := nil;
   for i := 0 to FList.Count-1 do
    if FList.Items[i] = n then
      begin
         mem := PStream(FList.Objects[i]);
         mem.position := 0;
         break;
      end;
   if mem = nil then
     mem := NewMemoryStream;
   st.position := 0;
   stream2stream(mem, st, st.size);
   add(n, mem);
   
   mem := NewWriteFileStream(FDir + n);
   st.position := 0;
   stream2stream(mem, st, st.size);
   mem.free;      
end;

end.
