unit KOLBAPDriveBox;

interface

{$I share.inc}

uses Windows, Messages, KOL;

type
  TOnChangeDrive = procedure(Sender: PControl; Drive: string;
    const ReadErr: Boolean; var Retry: Boolean) of object;

  TOnChangeDriveLabel = procedure(Sender: PControl) of object;

  {$ifdef F_P}
  TBAPDriveBox = class;
  PBAPDriveBox = TBAPDriveBox;
  TBAPDriveBox = class(TControl)
  {$else}
  PBAPDriveBox = ^TBAPDriveBox;
  TBAPDriveBox = object(TControl)
  {$endif}
  {* Компонент для выбора дисков.}
  private
    procedure ChangeLabel(Sender: PObj);
    function GetDriveLabel: string;

    function GetDriveName: string;
    procedure SetDriveName(const Value: string);

    procedure SetSelDriveIcon(const Value: Boolean);

    function GetSelTextColor: TColor;
    procedure SetSelTextColor(const Value: TColor);

    function GetSelBackColor: TColor;
    procedure SetSelBackColor(const Value: TColor);

    function GetOnChangeDrive: TOnChangeDrive;
    procedure SetOnChangeDrive(const Value: TOnChangeDrive);

    function GetOnChangeDriveLabel: TOnChangeDriveLabel;
    procedure SetOnChangeDriveLabel(const Value: TOnChangeDriveLabel);

    function NewOnDrawItem(Sender: PObj; DC: HDC; const Rect: TRect;
      ItemIdx: Integer; DrawAction: TDrawAction; ItemState: TDrawState): Boolean;

  public
    property DriveLabel: string read GetDriveLabel;
    {* <1> метку текущего диска.}
    property DriveName: string read GetDriveName write SetDriveName;
    {* <0>/<1> текущий диск.
    |<br>'*' - устанавливает диск GetStartDir.}
    property SelDriveIcon: Boolean write SetSelDriveIcon;
    {* Влияет на закраску иконки при выборе элемента:
    |<br>True -  фон иконки как у <2>
    |<br>False - подсвечивать иконку цветом фона <2>}
    property SelTextColor: TColor read GetSelTextColor write SetSelTextColor;
    {* <0>/<1> цвет текста <2>}
    property SelBackColor: TColor read GetSelBackColor write SetSelBackColor;
    {* <0>/<1> цвет фона <2>}
    property OnChangeDrive: TOnChangeDrive read GetOnChangeDrive write SetOnChangeDrive;
    {* <4> выборе диска.}
    property OnChangeDriveLabel: TOnChangeDriveLabel read GetOnChangeDriveLabel write SetOnChangeDriveLabel;
    {* <4> смене метки выбранного диска.}
    procedure OpenDriveBox;
    {* Открыть <3>}
    procedure UpdateDriveBox;
    {* Обновить <3>}

    property Items: Boolean read FNotAvailable;
    property CurIndex: Boolean read fNotAvailable;
    property Options: Boolean read FNotAvailable;
    property OnClick: Boolean read FNotAvailable;
    property OnPaint: Boolean read FNotAvailable;
    property OnChange: Boolean read FNotAvailable;
    property OnDrawItem: Boolean read FNotAvailable;
    property OnSelChange: Boolean read FNotAvailable;
    property OnMeasureItem: Boolean read FNotAvailable;
  end;

  TKOLBAPDriveBox = PBAPDriveBox;

function NewBAPDriveBox(Sender: PControl; SelDriveIcon: Boolean;
  SelTextColor, SelBackColor: TColor): PBAPDriveBox;

implementation

uses ShellApi, MMSystem;

{$I DBTUtils.inc}

const
  dspc = #32 + #32;

var
  FBAPDriveBoxs: PList; // Список с указателями на BAPDriveBox'ы

(* ДАННЫЕ ДЛЯ НАШЕГО ОБЪЕКТА *)
type
  {$ifdef F_P}
  TDriveData = class;
  PDriveData = TDriveData;
  TDriveData = class(TObj)
  {$else}
  PDriveData = ^TDriveData;
  TDriveData = object(TObj)
  {$endif}
    FControl: PControl;
    IL: PImageList;
    Timer1: PTimer;
    VolList: PStrList;
    UpdDB: Boolean;
    DrvIdx: Integer;

    SelDriveIcon: Boolean; // Показ выделенной иконки
    SelTextColor: TColor;  // Цвет текста выделенного элемента
    SelBackColor: TColor;  // Цвет фона выделенного элемента
    OnChangeDrive: TOnChangeDrive; // Смена диска
    OnChangeDriveLabel: TOnChangeDriveLabel; // Изменение метки диска
    destructor Destroy; virtual;
  end;

(* ОБРАБОТЧИК WM_DEVICECHANGE *)

function WndProcDriveChange(Ctl: PControl; var Msg: TMsg;
  var Rslt: Integer): Boolean;
var
  Drv: Char;
  Idx: Integer;
  D: PDriveData;
  DB: PBAPDriveBox;
  pDevBroadcastHdr: PDEV_BROADCAST_HDR;
  pDevBroadcastVolume: PDEV_BROADCAST_VOLUME;
begin
  Result := False;

  if Msg.message = WM_DEVICECHANGE then
    for Idx := 0 to FBAPDriveBoxs.Count - 1 do
    begin
      DB := FBAPDriveBoxs.Items[Idx];
      D := Pointer(DB.CustomObj);

      // Address of a structure that contains event-specific data.
      // Its meaning depends on the given event.
      pDevBroadcastHdr := PDEV_BROADCAST_HDR(Msg.lParam);

      case Msg.wParam of
        DBT_DEVICEARRIVAL: //== ДОБАВЛЕНИЕ УСТРОЙСТВА
          if pDevBroadcastHdr.dbch_devicetype = DBT_DEVTYP_VOLUME then
          begin
            pDevBroadcastVolume := PDEV_BROADCAST_VOLUME(Msg.lParam);
            if (pDevBroadcastVolume.dbcv_flags and DBTF_MEDIA) = 1 then
              D.FControl.Perform(CB_SHOWDROPDOWN, 0, 0)
            else // Добавилось утсройство, а не вставили CD/DVD
              DB.UpdateDriveBox;
          end;

        DBT_DEVICEREMOVECOMPLETE: //== УДАЛЕНИЕ УСТРОЙСТВА
        begin
          pDevBroadcastVolume := PDEV_BROADCAST_VOLUME(Msg.lParam);
          if pDevBroadcastHdr.dbch_devicetype = DBT_DEVTYP_VOLUME then
            if (pDevBroadcastVolume.dbcv_flags and DBTF_MEDIA) = 1 then
            begin // Высунули CD/DVD из устройства
              D.FControl.Perform(CB_SHOWDROPDOWN, 0, 0);
              Drv := D.FControl.Items[D.FControl.CurIndex][3];
              if FirstDriveFromMask(pDevBroadcastVolume.dbcv_unitmask) = Drv then
                DB.SetDriveName(#99);
            end
            else // Удалили устройство из системы
              DB.UpdateDriveBox;
        end;
      end; // case
    end;   // for
end;

(* Destructor НАШИХ ДАННЫХ *)

destructor TDriveData.Destroy;
begin
  Timer1.Enabled := False;
  Free_And_Nil(Timer1);
  Free_And_Nil(IL);
  Free_And_Nil(VolList);
  FBAPDriveBoxs.Remove(FControl);
  if FBAPDriveBoxs.Count = 0 then
  begin
    Free_And_Nil(FBAPDriveBoxs);
    if (@WndProcDriveChange <> nil) and (Applet <> nil) then
      Applet.DetachProc(WndProcDriveChange);
  end;
  inherited;
end;

(* НОВЫЙ DropList *)

procedure NewDroppedList(Ctl: PControl);
var
  WD, Idx: Integer;
  Vol: string;
  D: PDriveData;
begin
  D := Pointer(Ctl.CustomObj);
  WD := 0;
  for Idx := 0 to Ctl.Count - 1 do
  begin
    D.VolList.Items[Idx] := dspc + GetLabelDisk(Ctl.Items[Idx][3], False);
    Vol := Ctl.Items[Idx] + D.VolList.Items[Idx];
    if WD < Ctl.Canvas.TextWidth(Vol) then
      WD := Ctl.Canvas.TextWidth(Vol);
  end;
  Inc(WD, 26);

  if Ctl.Count > 12 then
    Inc(WD, GetSystemMetrics(SM_CXVSCROLL));
  if fsItalic in Ctl.Font.FontStyle then
    if not Ctl.Font.IsFontTrueType then
      Inc(WD, 2);
  Ctl.Perform(CB_SETDROPPEDWIDTH, WD, 0);
end;

(* ОБРАБОТЧИК ОБЪЕКТА *)

function WndProcDrive(Ctl: PControl; var Msg: TMsg; var Rslt: Integer): Boolean;
var
  Drv: Char;
  D: PDriveData;
begin
  D := Pointer(Ctl.CustomObj);
  Result := False;

  case Msg.message of
    CM_COMMAND:
      case HIWORD(Msg.wParam) of
        CBN_DROPDOWN: // Установка ширины DropList'а и получение меток дисков
        begin
          D.DrvIdx := D.FControl.CurIndex;
          NewDroppedList(Ctl);
        end;

        CBN_SELENDOK: // Выбран элемент
        begin
          D.Timer1.Enabled := False;
          Drv := Ctl.Items[Ctl.CurIndex][3];

          //== Закрытие CD/DVD
          if (GetDriveType(PChar(Drv + ':\')) = DRIVE_CDROM) and
             (not DriveReady(Drv)) then
          begin
            Ctl.Perform(CB_SHOWDROPDOWN, 0, 0);
            if DriveReady(Drv) then
              if GetLabelDisk(Drv, True) <> '' then
                WaitLabelChange(Drv, D.VolList.Items[Ctl.CurIndex]);
          end;

          PBAPDriveBox(Ctl).SetDriveName(Drv);
        end;
      end; // case HiWord

    WM_KEYDOWN: // Нажатие клавиш
    begin
      case Msg.wParam of
        $01..$20, $29..$40, $5B..$FE: Exit;
      end;

      if Ctl.DroppedDown then
        Exit;
      Ctl.Perform(CB_SHOWDROPDOWN, 1, 0);
      Result := True;
    end;
  end;  // case Msg
end;

(* ОБРАБОТЧИК NewOnDrawItem *)

function TBAPDriveBox.NewOnDrawItem;
var
  Ico: Integer;
  cbRect, icRect: TRect;
  D: PDriveData;
begin
  D := Pointer(CustomObj);
  Result := False;
  if D.UpdDB then
    Exit;

  icRect := Rect;
  cbRect := Rect;
  cbRect.Left := 20;
  Ico := FileIconSystemIdx(PControl(Sender).Items[ItemIdx][3] + ':\');
  D.IL.BkColor := PControl(Sender).Color;

  if (odsSelected in ItemState) then
  begin  //== Selected Item
    PControl(Sender).Canvas.Brush.Color := D.SelBackColor;
    SetTextColor(DC, Color2RGB(D.SelTextColor));
    SetBkMode(DC, PControl(Sender).Font.Color);
    if D.SelDriveIcon then
      D.IL.DrawingStyle := [dsTransparent]
    else begin
      D.IL.BlendColor := Color2RGB(D.SelBackColor);
      D.IL.DrawingStyle := [dsBlend25];
    end;
  end
  else begin //== Normal Item
    PControl(Sender).Canvas.Brush.Color := PControl(Sender).Color;
    D.IL.DrawingStyle := [];
    SetTextColor(DC, PControl(Sender).Font.Color)
  end;

  if D.SelDriveIcon then
    FillRect(DC, Rect, PControl(Sender).Canvas.Brush.Handle)
  else
    FillRect(DC, cbRect, PControl(Sender).Canvas.Brush.Handle);

  if (odsComboboxEdit in ItemState) then
  begin //== Draw Icon in Edit
    icRect.Top := 5;
    icRect.Left := 3; // Точно указываем ширину = 16
    icRect.Right := 19;
    D.IL.StretchDraw(Ico, DC, icRect);
    Inc(cbRect.Left);
  end
  else begin //== Draw Icon in DropList
    icRect.Left := 2; // Точно указываем ширину = 16
    icRect.Right := 18;
    D.IL.StretchDraw(Ico, DC, icRect);
  end;

  DrawText(DC, PChar(PControl(Sender).Items[ItemIdx] + D.VolList.Items[ItemIdx]),
    -1, cbRect, DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
end;

(* ОБРАБОТЧИК ТАЙМЕРА *)

procedure TBAPDriveBox.ChangeLabel;
var
  Drv: Char;
  D: PDriveData;
begin
  D := PDriveData(CustomObj);
  {$ifdef F_P}
  with D, D.FControl do
  {$else}
  with D^, D.FControl^ do
  {$endif}
  begin
    Drv := Items[CurIndex][3];
    if TrimLeft(VolList.Items[CurIndex]) <> GetLabelDisk(Drv, False) then
    begin
      VolList.Items[CurIndex] := dspc + GetLabelDisk(Drv, False);
      Invalidate;
      if Assigned(OnChangeDriveLabel) then
        OnChangeDriveLabel(@Self);
    end;
  end;
end;

(* КОНСТРУКТОР KOL-ОБЪЕКТА *)

function NewBAPDriveBox;
var
  D: PDriveData;
begin
  Result := PBAPDriveBox(NewCombobox(Sender, [coReadOnly, coOwnerDrawFixed]));

  if FBAPDriveBoxs = nil then
    FBAPDriveBoxs := NewList;
  FBAPDriveBoxs.Add(Result);

  {$ifdef F_P}
  D := PDriveData.Create;
  {$else}
  New(D, Create);
  {$endif}
  Result.CustomObj := D;
  D.FControl := Result;

  D.IL := NewImageList(nil);
  D.IL.LoadSystemIcons(True);
  D.VolList := NewStrList;
  D.SelDriveIcon := SelDriveIcon;
  D.SelTextColor := SelTextColor;
  D.SelBackColor := SelBackColor;
  D.Timer1 := NewTimer(1000);
  D.Timer1.OnTimer := Result.ChangeLabel;

  Result.UpdateDriveBox;

  //== Установка обработчиков
  Result.SetOnDrawItem(Result.NewOnDrawItem);
  Result.AttachProc(WndProcDrive);
  if Applet <> nil then // WM_DEVICECHANGE
    Applet.AttachProc(WndProcDriveChange);
end;

(* ПОЛУЧИТЬ ДИСКИ *)

procedure TBAPDriveBox.UpdateDriveBox;
var
  Ch, Drv: Char;
  DrivesMask: Integer;
  D: PDriveData;
begin
  D := PDriveData(CustomObj);
  {$ifdef F_P}
  with D, D.FControl do
  {$elsE}
  with D^, D.FControl^ do
  {$endif}
  begin
    Timer1.Enabled := False;
    UpdDB := True;

    if Count > 0 then
    begin
      Drv := Items[CurIndex][3];
      VolList.Clear;
      Clear;
    end
    else
      Drv := '*'; // Диск по умолчанию

    DrivesMask := GetLogicalDrives;

    for Ch := 'a' to 'z' do
    begin
      if LongBool(DrivesMask and 1) then
      begin
        Add('[-' + Ch + '-]');
        VolList.Add('');
      end;
      DrivesMask := DrivesMask shr 1;
    end;

    UpdDB := False;
    SetDriveName(Drv);
  end;
end;

(* УСТАНОВКА ДИСКА *)

procedure TBAPDriveBox.SetDriveName;
var
  Retry, Err: Boolean;
  Drv: string;
  D: PDriveData;
begin
  if Value = '' then
    Exit;
  D := Pointer(CustomObj);
  D.Timer1.Enabled := False;

  if (Value = '*') then
    Drv := GetStartDir[1]
  else
    Drv := Value[1];
  Drv := UpperCase(Drv) + ':';

  repeat
    Err := False;
    Retry := False;
    if DriveReady(Drv[1]) then
      D.FControl.CurIndex := SearchFor(Drv[1], 0, True)
    else
      Err := True;
    if Assigned(D.OnChangeDrive) then
      D.OnChangeDrive(@Self, Drv, Err, Retry);
  until not Retry;

  {$ifdef F_P}
  with D, D.FControl do
  {$else}
  with D^, D.FControl^ do
  {$endif}
  begin
    if Err then
      if DriveReady(Items[DrvIdx][3]) then
        CurIndex := DrvIdx
      else begin // При возврате возникла ошибка
        Drv := #99 + ':';
        CurIndex := SearchFor(Drv[1], 0, True);
        if Assigned(D.OnChangeDrive) then
          D.OnChangeDrive(@Self, Drv, False, Retry);
      end
    else
      CurIndex := SearchFor(Drv[1], 0, True);

    VolList.Items[CurIndex] := dspc + GetLabelDisk(Drv[1], False);
    if FixedDrive(Drv[1]) then
      Timer1.Enabled := True;
  end;
end;

function TBAPDriveBox.GetDriveName;
begin
  {$ifdef F_P}
  with PDriveData(CustomObj).FControl do
  {$elsE}
  with PDriveData(CustomObj).FControl^ do
  {$endif}
    Result := UpperCase(Items[CurIndex][3]) + ':';
end;

(* ОТКРЫТЬ DriveBox *)

procedure TBAPDriveBox.OpenDriveBox;
begin
  Perform(WM_LBUTTONDOWN, 0, 0);
  Perform(WM_LBUTTONUP, 0, 0);
end;

(* ПОЛУЧИТЬ МЕТКУ ДИСКА *)

function TBAPDriveBox.GetDriveLabel;
begin
  {$ifdef F_P}
  with PDriveData(CustomObj).FControl do
  {$elsE}
  with PDriveData(CustomObj).FControl^ do
  {$endif}
    Result := GetLabelDisk(Items[CurIndex][3], True);
end;

(* ПОКАЗ ВЫДЕЛЕННОЙ ИКОНКИ *)

procedure TBAPDriveBox.SetSelDriveIcon;
begin
  PDriveData(CustomObj).SelDriveIcon := Value;
end;

(* УСТАНОВКА ЦВЕТОВ *)

procedure TBAPDriveBox.SetSelTextColor;
begin
  PDriveData(CustomObj).SelTextColor := Value;
end;

function TBAPDriveBox.GetSelTextColor;
begin
  Result := PDriveData(CustomObj).SelTextColor;
end;

procedure TBAPDriveBox.SetSelBackColor;
begin
  PDriveData(CustomObj).SelBackColor := Value;
end;

function TBAPDriveBox.GetSelBackColor;
begin
  Result := PDriveData(CustomObj).SelBackColor
end;

(* ОБРАБОТЧИК OnChangeDrive *)

procedure TBAPDriveBox.SetOnChangeDrive;
begin
  PDriveData(CustomObj).OnChangeDrive := Value;
end;

function TBAPDriveBox.GetOnChangeDrive;
begin
  Result := PDriveData(CustomObj).OnChangeDrive;
end;

(* ОБРАБОТЧИК OnChangeDriveLabel *)

procedure TBAPDriveBox.SetOnChangeDriveLabel;
begin
  PDriveData(CustomObj).OnChangeDriveLabel := Value;
end;

function TBAPDriveBox.GetOnChangeDriveLabel;
begin
  Result := PDriveData(CustomObj).OnChangeDriveLabel;
end;

end.