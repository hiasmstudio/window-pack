unit hiMT_String;

interface

uses Kol,Share,Debug;

type
  THIMT_String = class(TDebug)
   private
    st,dl: string;
    procedure SetDl(d:string);
   public
    _prop_Mask:string;
    _data_str1:THI_Event;
    _event_onResult:THI_Event;

    procedure _work_doStr(var _Data:TData; Index:word);
    procedure _work_doMT(var _Data:TData; Index:word);
    procedure _work_doMTString(var _Data:TData; Index:word);
    procedure _work_doStrMask(var _Data:TData; Index:word);
    procedure _var_Str(var _Data:TData; Index:word);
    property _prop_Delimeter:string write SetDl;
  end;

procedure TextToMT(var st:string; var dt:TData; const dl:string);

implementation

procedure THIMT_String.SetDl;
begin
  dl := (d+#0)[1];
end;

//############# анализатор типов данных в строке. не самый конечно лучший
//############# да сложнее писать лениво :)  понимает int,real(без ≈) и string
function StrToTData(s: string):TData;
var i: integer;
    t: byte;
    s1: string;
begin
  t := data_Str;
  if length(s) = 1 then
     s1 := s
  else
     s1 := trim(s);
  
  for i := 1 to length(s1) do
    if (i = 1)and(s[i] = '-')and(length(s1) > 1) then
      t := data_int
    else if (s1[i] in ['0'..'9','.']) then 
      begin
        if s1[i] = '.' then 
          begin
            if t = data_real then 
              begin
                t := data_str;
                break;
              end;
            t := data_real;
          end
        else if t <> data_real then
          t := data_int;
      end
    else
      begin
        t := data_str;
        break;
      end;

  case t of
    data_str: dtString(result,s);
    data_int: dtInteger(result,str2int(s1));
    data_real: dtReal(result,str2double(s1));
  end;
end;

// ################## MT_String #######################

procedure THIMT_String._work_doStr;
var d: PData;s:string;
begin
  d := @_data;
  st:='';
  while (d<>nil)and not _IsNULL(d^) do begin
    s:=ToString(d^);
    if (_IsType(d^)=data_real)and(Pos('.',s)=0) then
      s:=s+'.0';
    st:=st+s+dl;
    d := d.ldata;
  end;
  //if st='' then exit;
  deleteTail(st,1);
  _hi_CreateEvent(_Data,@_event_onResult,st);
end;

procedure TextToMT(var st:string; var dt:TData; const dl:string);
var d:PData;
begin
  d := @dt;
  while st <> '' do 
    begin
      d^ := StrToTData(parse(st,dl));
      if st<>'' then 
        begin
          new(d.ldata);
          d := d.ldata;
        end;
    end;
end;

procedure THIMT_String._work_doMT;
var dt: TData;
begin
  st := ReadString(_Data,_data_Str1,'') + dl;
  TextToMT(st, dt, dl);
  _hi_OnEvent_(_event_onResult, dt);
  freedata(@dt);
end;

procedure THIMT_String._work_doMTString;
var d: PData;
    dt: TData;
begin
  d:=@dt;
  st := ReadString(_Data,_data_Str1,'') + dl;
  while st <> '' do begin
    dtString(d^, parse(st,dl));
    if st <> '' then begin
      new(d.ldata);
      d:=d.ldata;
    end;
  end;
  _hi_OnEvent_(_event_onResult, dt);
  freedata(@dt);
end;

procedure THIMT_String._work_doStrMask(var _Data:TData; Index:word);
var s:string; d:PData;
begin
  st := '';
  d := @_Data;
  while (d<>nil)and not _IsNULL(d^) do begin
    s := _prop_mask;
    Replace(s, '%1', ToString(d^));
    st := st + s + dl;
    d := d.ldata;
  end;
  deleteTail(st,1);
  _hi_CreateEvent(_data,@_event_onResult,st);
end;

procedure THIMT_String._var_Str;
begin
  dtString(_Data,st);
end;

end.
