unit hiIconAnimation; { Компонент для получения анимации на иконках ver 1.45 }

interface

uses Windows,Share,Debug,Kol;

type
  ThiIconAnimation = class(TDebug)
   private
    FTimer:PTimer;
    FStopCycle: boolean;
    FCurFrame : integer;
    FCurIndex : integer;
    FListIndex: PStrListEx;
    FListBitmap: PImageList;
    FIcon: PIcon;
    FBitmap: PBitmap; 
    FDelay: integer;
    FDelayCycle: integer;
    FImgSize: Integer;
    FCircleAnima: boolean;

    procedure _OnTimer(Obj:PObj);
    procedure SetIndex(Value:PStrListEx);
    procedure SetBitmap(Value:PStrListEx);    
    procedure SetImgSize(Value:integer);
    function onFrame(Frame:integer): boolean;
   public

    _event_onIconFrame: THI_event;
    _event_onBitmapFrame: THI_event;
    _event_onEndCycle: THI_event;    

    _data_Index: THI_event;
    _data_Frame: THI_event;

    _prop_MaskColor : integer;
    _prop_TranspColor : integer;
    _prop_Index       : integer;

    property _prop_IndexArray  : PStrListEx write SetIndex;    
    property _prop_Bitmaps     : PStrListEx write SetBitmap;
    property _prop_ImgSize     : integer write SetImgSize;
    property _prop_Delay       : integer read FDelay write FDelay;
    property _prop_DelayCycle  : integer read FDelayCycle write FDelayCycle;
    property _prop_CircleAnima : boolean read FCircleAnima write FCircleAnima;

    constructor Create;
    destructor Destroy; override;

    procedure _work_doAnimation(var _Data:TData; Index:word);
    procedure _work_doIndexFrame(var _Data:TData; Index:word);
    procedure _work_doFrame(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _work_doDelay(var _Data:TData; Index:word);
    procedure _work_doDelayCycle(var _Data:TData; Index:word);
    procedure _work_doCircleAnima(var _Data:TData; Index:word);
    procedure _var_FrameCount(var _Data:TData; Index:word);
    procedure _var_IndexCount(var _Data:TData; Index:word);
    
  end;

implementation

constructor ThiIconAnimation.Create;
begin
   inherited;
   FIcon := NewIcon;
   FBitmap := NewBitmap(0,0);
   FTimer := NewTimer(83);
   FTimer.Enabled := false;
   FTimer.OnTimer := _onTimer;
end;

destructor ThiIconAnimation.Destroy;
begin
   FIcon.free;
   FBitmap.free;
   if Assigned(FListIndex) then FListIndex.free; 
   if Assigned(FListBitmap) then FListBitmap.free;
   inherited;
end;

procedure ThiIconAnimation.SetBitmap;
var   Icon: PIcon;
      IconInfo: TIconInfo;
      bmp,mask,body: PBitmap;
      i: integer;      
begin
   FListBitmap := NewImageList(nil);
   for i := 0 to Value.Count - 1 do begin 
      FListBitmap.ImgWidth := FImgSize;
      FListBitmap.ImgHeight := FImgSize;
      FListBitmap.DrawingStyle := [dsTransparent];
      
      bmp := NewBitmap(FImgSize,FImgSize);
      bmp.Handle := Value.Objects[i];
      body := NewBitmap(0,0);
      if bmp.Handle <> 0 then body.Assign(bmp);
      mask := NewBitmap(0,0);
      mask.Assign(body);
      if not mask.Empty then mask.Convert2Mask(Color2RGB(_prop_MaskColor));

      IconInfo.fIcon := true;
      IconInfo.xHotspot := 0;
      IconInfo.yHotspot := 0;
      IconInfo.hbmMask := mask.Handle;
      IconInfo.hbmColor := body.Handle;
      Icon := NewIcon;
      Icon.Handle := CreateIconIndirect(IconInfo);
      FListBitmap.AddIcon(Icon.Handle);
      mask.Free;
      body.Free;   
      bmp.free;
      Icon.free;
   end;
end;

function ThiIconAnimation.onFrame;
var      db,di:TData;
begin
   Result := false;
   if not Assigned(FListBitmap) then exit;
   if (Frame < 0) or (Frame > FListBitmap.Count - 1) then exit;
   FIcon.Clear;
   FIcon.Handle := FListBitmap.ExtractIcon(Frame);
   if FIcon.Handle = 0 then exit;
   FBitmap.Clear;
   FBitmap.Handle := FIcon.Convert2Bitmap(_prop_TranspColor);
   dtBitmap(db,FBitmap);
   dtIcon(di,FIcon);
   _hi_OnEvent(_event_onIconFrame, di);
   _hi_OnEvent(_event_onBitmapFrame, db);
   Result := true;
end; 

procedure ThiIconAnimation._onTimer;
begin
   FTimer.Interval := FDelay;
   
   if not Assigned(FListIndex) then exit;
   if (FCurIndex < 0) or (FCurIndex > FListIndex.Count - 1) then exit;   

   FCurFrame := Integer(FListIndex.Objects[FCurIndex]);
   if not onFrame(FCurFrame) then exit;

   if not FTimer.Enabled then exit;
      
   inc(FCurIndex);
   if FCurIndex > FListIndex.Count - 1 then begin
      FCurIndex := 0;
      _hi_OnEvent(_event_onEndCycle);
      if FCircleAnima and FStopCycle then
         FTimer.Enabled := false
      else if FCircleAnima and not FStopCycle then
         FTimer.Interval := FDelayCycle
      else
         FTimer.Enabled := false;
   end;
end;

procedure ThiIconAnimation.SetIndex;
begin
   FListIndex := NewStrListEx;
   FListIndex := Value;
end;

procedure ThiIconAnimation.SetImgSize;
begin
   FImgsize := Value;
   if FImgsize < 16 then FImgsize:= GetSystemMetrics(SM_CXICON);
end;

procedure ThiIconAnimation._work_doAnimation;
begin
   FCurIndex := ReadInteger(_Data, _data_Index, _prop_Index);
   FStopCycle := false;
   FTimer.Enabled := true;
   _onTimer(nil);
end;

procedure ThiIconAnimation._work_doStop;
begin
   if FCircleAnima then FStopCycle := true;
end;

procedure ThiIconAnimation._work_doIndexFrame;
begin
   if FTimer.Enabled then exit;
   FCurIndex := ReadInteger(_Data, _data_Index, _prop_Index);
   _OnTimer(nil);
end;

procedure ThiIconAnimation._work_doFrame;
begin
   if FTimer.Enabled then exit;
   onFrame(ReadInteger(_Data, _data_Frame));
end;

procedure ThiIconAnimation._work_doDelay;
begin
   FDelay := ToInteger(_Data);
   if FDelay < 10 then FDelay := 10;  
end;

procedure ThiIconAnimation._work_doDelayCycle;
begin
   FDelayCycle := ToInteger(_Data);
   if FDelayCycle < 10 then FDelayCycle := 10;
end;

procedure ThiIconAnimation._work_doCircleAnima; begin FCircleAnima := ReadBool(_Data); end;

procedure ThiIconAnimation._var_FrameCount;
begin
   if not Assigned(FListBitmap) then exit;
   dtInteger(_Data, FListBitmap.Count);
end;

procedure ThiIconAnimation._var_IndexCount;
begin
   if not Assigned(FListIndex) then exit;
   dtInteger(_Data, FListIndex.Count);
end;

end.