unit hiVolumeDetector;

interface

uses Kol,Share,Debug;

type
  THIVolumeDetector = class(TDebug)
   private
    mode:byte;
    res:PStream;
    buf:PStream;
    pickCount:integer;
   public
    _prop_DetectLevel:integer;
    _prop_DetectLength:integer;
    _prop_Delay:integer;

    _data_Stream:THI_Event;
    _event_onDetect:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doDetect(var _Data:TData; Index:word);
    procedure _work_doDetectLevel(var _Data:TData; Index:word);
    procedure _work_doDetectLength(var _Data:TData; Index:word);
    procedure _work_doDelay(var _Data:TData; Index:word);
  end;

implementation

constructor THIVolumeDetector.Create;
begin
   inherited;
   buf := newmemorystream;
   res := newmemorystream;
end;

destructor THIVolumeDetector.Destroy;
begin
   res.free;
   buf.free;
   inherited;
end;

procedure THIVolumeDetector._work_doDetect;
var st:PStream;
    s:smallint;
begin
   st := ReadStream(_Data, _data_Stream);
   if st = nil then exit;
   
   if mode = 1 then
     stream2stream(res, st, st.size);
     
   st.position := 0;
     //res.write(st.memory^, st.size);
     
   while st.position < st.size do
    begin
      st.read(s, sizeof(s));
      if abs(s) > _prop_DetectLevel then
       begin
         case mode of
          0: 
           begin           
            inc(pickCount);
            if pickCount >= _prop_DetectLength then 
             begin
//               st.position := 0; 
//               buf.position := 0;
               //stream2stream(res, buf, buf.size);
               stream2stream(res, st, st.size);
               mode := 1;
               pickCount := 0;
               break;
             end;
           end;
          1:  
           begin
             pickCount := 0;
             //res.write(s, sizeof(s));
           end;
         end;
       end
      else if mode = 1 then
       begin
         inc(pickCount);
         if pickCount >= _prop_Delay then
          begin
            res.position := 0; 
            _hi_onEvent(_event_onDetect, res);
            res.size := 0;
            pickCount := 0;
            mode := 0;                    
          end;
       end;
    end;
    
   if mode = 0 then
    begin
      buf.position := 0;
      st.position := 0;
      stream2stream(buf, st, st.size)
    end; 
end;

procedure THIVolumeDetector._work_doDetectLevel;
begin
  _prop_DetectLevel := ToInteger(_Data);
end;

procedure THIVolumeDetector._work_doDetectLength;
begin
  _prop_DetectLength := ToInteger(_Data);
end;

procedure THIVolumeDetector._work_doDelay;
begin
  _prop_Delay := ToInteger(_Data);
end;

end.
