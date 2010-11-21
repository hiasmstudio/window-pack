unit hiIconGraph; { Компонент для получения графиков на иконках ver 2.50 }

interface

uses Windows,Share,Debug,Kol;

const
   img_size = 16;

type
   TStyle = (Histogram, Graph, Numeric, Bar);
   TKind  = (Vertical, Horisontal);
   TChannels = (One, Two);
   
type
  ThiIconGraph = class(TDebug)
   private
    FIcon: PIcon;
    FBitmap: PBitmap;
    FBack: PBitmap;
    FMask: PBitmap;

    FGraphColor: TColor;
    FTranspColor: TColor;
    FFonColor: TColor;
    FFrameColor: TColor;
    FTextColor: TColor;
    FMinColor: TColor;
    FMidColor: TColor;
    FMaxColor: TColor;        

    FMax: Integer;
    FPosition: Real;
    FSensit: Integer;
    OldPos, PrevPos: Integer;
    GFont: PGraphicTool;
    FStyle: TStyle;
    FString: string;
    FTranspIcon: boolean;
    FKind: TKind;
    FChannels:TChannels;
    FFrame:boolean;

    procedure UpdateGraph(index:byte);
    procedure ClearImage;
   public
    _event_onIconGraph: THI_event;
    _event_onBmpGraph: THI_event;

    property _prop_Max: Integer           write FMax;

    property _prop_GraphColor: Integer    write FGraphColor;
    property _prop_FonColor: Integer      write FFonColor;
    property _prop_FrameColor: Integer    write FFrameColor;
    property _prop_TranspColor: Integer   write FTranspColor;
    property _prop_TextColor: Integer     write FTextColor;
    property _prop_MaxColor: Integer      write FMaxColor;    
    property _prop_MidColor: Integer      write FMidColor;
    property _prop_MinColor: Integer      write FMinColor;

    property _prop_FrameBar: boolean      write FFrame;
    property _prop_Sensit: Integer        write FSensit;
    property _prop_Style: TStyle          write FStyle;
    property _prop_TranspIcon: boolean    write FTranspIcon;
    property _prop_ChannelsBar: TChannels write FChannels;
    property _prop_KindBar: TKind         write FKind;
    
    constructor Create;
    procedure Init;
    destructor Destroy; override;
    procedure _work_doStyle(var _Data:TData; Index:word);
    procedure _work_doPosition1(var _Data:TData; Index:word);
    procedure _work_doPosition2(var _Data:TData; Index:word);
    procedure _work_doSensit(var _Data:TData; Index:word);
    procedure _work_doMax(var _Data:TData; Index:word);
    procedure _work_doTranspIcon(var _Data:TData; Index:word);
    procedure _work_doFrameBar(var _Data:TData; Index:word);
    procedure _work_doKindBar(var _Data:TData; Index:word);
    procedure _work_doChannelsBar(var _Data:TData; Index:word);

    procedure _work_doGraphColor(var _Data:TData; Index:word);
    procedure _work_doFonColor(var _Data:TData; Index:word);
    procedure _work_doTranspColor(var _Data:TData; Index:word);
    procedure _work_doTextColor(var _Data:TData; Index:word);
    procedure _work_doMinColor(var _Data:TData; Index:word);
    procedure _work_doMidColor(var _Data:TData; Index:word);
    procedure _work_doMaxColor(var _Data:TData; Index:word);
    procedure _work_doFrameColor(var _Data:TData; Index:word);
  end;

implementation

constructor ThiIconGraph.Create;
begin
   inherited;
   Init;
end;

procedure ThiIconGraph.Init;
begin
   if Assigned(FIcon)   then  FIcon.Free;
   if Assigned(FBack)   then  FBack.Free;
   if Assigned(FBitmap) then  FBitmap.Free;
   if Assigned(FMask)   then  FMask.Free;      
   if Assigned(GFont) then GFont.Free;

   FIcon := NewIcon;
   FBack := NewDIBBitmap(img_size,img_size,pf32bit);
   FBitmap := NewDIBBitmap(img_size,img_size,pf32bit);
   FMask := NewDIBBitmap(img_size,img_size,pf32bit);
   GFont := NewFont;

   GFont.FontName := 'MS Serif';
   GFont.FontHeight := 12;

   FBack.Canvas.Font.Assign(GFont);   
   ClearImage;
   OldPos := img_size-1;
end;

procedure ThiIconGraph.ClearImage;
begin
   with FBack.Canvas{$ifndef F_P}^{$endif} do begin
      Brush.Color := clFuchsia;
      Brush.BrushStyle := bsSolid;
      SelectObject(Handle,Brush.Handle);
      Windows.FillRect(Handle,MakeRect(0,0,img_size,img_size),Brush.Handle);
   end;
end;

destructor ThiIconGraph.Destroy;
begin
   FIcon.Free;
   FBack.Free;
   FBitmap.Free;
   FMask.Free;
   if Assigned(GFont) then GFont.free;
   inherited;
end;

procedure ThiIconGraph._work_doPosition1;
begin
   FPosition := ToReal(_Data);
   if FPosition > FMax then FPosition := FMax;
   if Fposition < 100 then
      FString := double2str(FPosition)
   else   
      FString := int2str(Round(FPosition));
   UpdateGraph(1);
end;

procedure ThiIconGraph._work_doPosition2;
begin
   FPosition := ToReal(_Data);
   if FPosition > FMax then FPosition := FMax;
   if Fposition < 100 then
      FString := double2str(FPosition)
   else
      FString := int2str(Round(FPosition));
   UpdateGraph(2);
end;

procedure ThiIconGraph._work_doMax;begin FMax := ToInteger(_Data);end;
procedure ThiIconGraph._work_doStyle;begin FStyle := TStyle(ToInteger(_Data));Init;end;
procedure ThiIconGraph._work_doSensit;begin FSensit := ToInteger(_Data);end;
procedure ThiIconGraph._work_doTranspIcon;begin FTranspIcon := ReadBool(_Data);end;
procedure ThiIconGraph._work_doFrameBar;begin FFrame := ReadBool(_Data);ClearImage;end;
procedure ThiIconGraph._work_doKindBar;begin FKind := TKind(ToInteger(_Data));ClearImage;end;
procedure ThiIconGraph._work_doChannelsBar;begin FChannels := TChannels(ToInteger(_Data));ClearImage;end;

procedure ThiIconGraph._work_doTextColor;begin FTextColor := ToInteger(_Data);end;
procedure ThiIconGraph._work_doMinColor;begin FMinColor := ToInteger(_Data);end;
procedure ThiIconGraph._work_doMidColor;begin FMidColor := ToInteger(_Data);end;
procedure ThiIconGraph._work_doMaxColor;begin FMaxColor := ToInteger(_Data);end;
procedure ThiIconGraph._work_doFrameColor;begin FFrameColor := ToInteger(_Data);end;
procedure ThiIconGraph._work_doTranspColor;begin FTranspColor := ToInteger(_Data);end;
procedure ThiIconGraph._work_doFonColor;begin FFonColor := ToInteger(_Data);end;
procedure ThiIconGraph._work_doGraphColor;begin FGraphColor := ToInteger(_Data);end;

procedure ThiIconGraph.UpdateGraph;
var   dt: TData;
      i,j: integer;
      IconInfo: TIconInfo;
      ARect: TRect;
      mid, max: integer;
      midpix, maxpix, prevpix: integer;
      pos: integer;
      
      procedure DrawColorRect(offset,prevpix: integer; Color: TColor);
      begin
         with FBack.Canvas{$ifndef F_P}^{$endif} do begin
            Brush.Color := Color;
            if FKind = Vertical then begin
               if (index = 1) and (FChannels = Two) then begin
                  ARect.Left := 1;
                  ARect.Right := img_size div 2 - 1;
               end;
               ARect.Bottom := img_size-1-offset;
               ARect.Top := ARect.Bottom-prevpix; 
            end else begin
               if (index = 1) and (FChannels = Two) then begin
                  Arect.Top := 1;
                  ARect.Bottom := img_size div 2-1;
               end;
               ARect.Left := offset+1;
               ARect.Right := ARect.Left+prevpix;
            end;
            FillRect(ARect);         
         end;
      end;

begin
   with FBack.Canvas{$ifndef F_P}^{$endif} do begin
      if FStyle in [Histogram, Graph] then begin 
         { Copy bitmap leftwards }
         PrevPos := img_size - Round(FPosition/(FMax/(img_size-3))+3);
         Pen.Color := FGraphColor;
         Pen.PenWidth := 1;
         CopyRect(MakeRect(0,0,img_size-1,img_size),FBack.Canvas,MakeRect(1,0,img_size,img_size));
         Pen.Color := clFuchsia;
         MoveTo(img_size-1,img_size-1);
         LineTo(img_size-1,0);
         Pen.Color := FGraphColor;                  
      end else if FStyle = Bar then begin 
         Pen.Color := FFrameColor;
         Pen.PenWidth := 1;
         Brush.Color := clFuchsia;
         Brush.BrushStyle := bsClear;
         if FChannels = One then begin
            if FFrame then Rectangle(0,0,img_size,img_size);
            Brush.Color := clFuchsia;
            Brush.BrushStyle := bsSolid;
            ARect.Left := 1;
            ARect.Right := img_size - 1;
            Arect.Top := 1;
            ARect.Bottom := img_size-1;
         end else begin
            if FKind = Vertical then begin
               if FFrame then begin
                  Rectangle(0,0,img_size div 2,img_size);
                  Rectangle(img_size div 2,0,img_size,img_size);
               end;
               Brush.Color := clFuchsia;
               Brush.BrushStyle := bsSolid;
               if index = 1  then begin
                  ARect.Left := 1;
                  ARect.Right := img_size div 2 - 1;
               end else begin   
                  ARect.Left := img_size div 2 + 1;
                  ARect.Right := img_size - 1;
               end;
               Arect.Top := 1;
               ARect.Bottom := img_size-1;
            end else begin
               if FFrame then begin
                  Rectangle(0,0,img_size,img_size div 2);
                  Rectangle(0,img_size div 2,img_size,img_size);
               end;
               Brush.Color := clFuchsia;
               Brush.BrushStyle := bsSolid;
               if index = 1  then begin
                  Arect.Top := 1;
                  ARect.Bottom := img_size div 2-1;
               end else begin   
                  Arect.Top := img_size div 2 + 1;
                  ARect.Bottom := img_size-1;
               end;
               ARect.Left := 1;
               ARect.Right := img_size-1;
            end;
         end;       
         FillRect(ARect);
      end;
      if FStyle = Histogram then begin
         MoveTo(0,img_size-1);
         LineTo(img_size-1,img_size-1);  
         LineTo(img_size-1,img_size-2);
         if FPosition >= FSensit then LineTo(img_size-1,PrevPos);
      end else if FStyle = Graph then begin
         MoveTo(img_size-2,OldPos+1);
         LineTo(img_size-1,PrevPos+1);
         if FPosition >= FSensit then OldPos := PrevPos else OldPos := img_size-1;            
      end else if FStyle = Numeric then begin
         ClearImage;
         Font.Color := FTextColor;
         ARect := MakeRect(0, 1, img_size, img_size);
         RequiredState( HandleValid or FontValid or BrushValid or ChangingCanvas );
         Windows.DrawText(Handle,PChar(FString),-1,ARect,DT_NOPREFIX or DT_VCENTER or DT_SINGLELINE or DT_CENTER);         
      end else begin
         mid := FMax div 2;
         max := mid + Round((4/7)*mid);
         midpix := (img_size-2) div 2;
         maxpix := midpix + Round((4/7)*midpix);
         Brush.BrushStyle := bsSolid;
         Pos := Round(FPosition+FMax/(img_size-2));
         if (FPosition >= FSensit) then begin
            prevpix := KOL.MIN(midpix,Round((midpix)*Pos/mid));
            DrawColorRect(0,prevpix,FMinColor);
         end;
         if (FPosition > mid) then begin
            prevpix := KOL.MIN(maxpix,Round((maxpix)*Pos/max))-midpix;
            DrawColorRect(midpix,prevpix,FMidColor);
         end;
         if FPosition > max then begin
            prevpix := KOL.MIN(img_size-2,Round((img_size-2)*FPosition/FMax))-maxpix;
            DrawColorRect(maxpix,prevpix,FMaxColor);
         end;
      end;
   end;
   FBitmap.Clear;
   FMask.Clear;
   FBitmap.Assign(FBack);
   FMask.Assign(FBack);
   if FTranspIcon then FMask.Convert2Mask(clFuchsia);
   for i := 0 to img_size-1 do
      for j := 0 to img_size-1 do
         if FBitmap.DIBPixels[i,j] = clFuchsia then
            FBitmap.DIBPixels[i,j] := FFonColor;
   IconInfo.fIcon := true;
   IconInfo.xHotspot := 0;
   IconInfo.yHotspot := 0;
   IconInfo.hbmMask := FMask.Handle;
   IconInfo.hbmColor := FBitmap.Handle;
   FIcon.Handle := CreateIconIndirect(IconInfo);
    dtIcon(dt,FIcon);
   _hi_onEvent(_event_onIconGraph,dt);
   FBitmap.Clear;
   FBitmap.Assign(FBack);   
   for i := 0 to img_size-1 do
      for j := 0 to img_size-1 do
         if FBitmap.DIBPixels[i,j] = clFuchsia then
            FBitmap.DIBPixels[i,j] := FTranspColor;   
    dtBitMap(dt,FBitmap);
   _hi_onEvent(_event_onBmpGraph,dt);
end;

end.