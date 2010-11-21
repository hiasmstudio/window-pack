unit hiMST_Virtual;

interface
     
uses Windows, Kol, Share, Debug, hiMTStrTbl;

type
  THIMST_Virtual = class(TDebug)
  private
    FMSTControl: IMSTControl;
    DefPage: integer;
    Page: integer;
    FVirtIdx: integer; 
    procedure InitPage;
    procedure SetPage(Value: integer);
    procedure SetMSTControl(Value: IMSTControl);
    procedure _OnLVData(Sender: PControl; Idx, SubItem: Integer; var Txt: String; var ImgIdx: Integer;
                        var State: DWORD; var Store: Boolean);
  public

    _prop_SubItemName: byte;
    _data_VirtIdx,
    _data_Page,
    _data_VirtualData: THI_Event;
    _event_onChangeVirtIdx: THI_Event;

    property _prop_MSTControl: IMSTControl read FMSTControl write SetMSTControl;
    property _prop_DefaultPage: integer read DefPage write SetPage; 
    procedure _work_doNextPage(var _Data: TData; Index: word);
    procedure _work_doPrevPage(var _Data: TData; Index: word);        
    procedure _work_doSetPage(var _Data: TData; Index: word);
    procedure _work_doResetPage(var _Data: TData; Index: word);
    procedure _work_doInitPage(var _Data: TData; Index: word);    
    procedure _work_doSetVirtIdx(var _Data: TData; Index: word);
    procedure _var_CurPage(var _Data: TData; Index: word);
    procedure _var_PerPage(var _Data: TData; Index: word);
    procedure _var_CurVirtIdx(var _Data: TData; Index: word);            
  end;

implementation

procedure THIMST_Virtual.InitPage;
var
  i, j: integer;
  sControl: PControl;
  ColCount, PerPage: integer;
begin
  if not Assigned(FMSTControl) then exit;
  sControl := FMSTControl.ctrlpoint;
  PerPage  := sControl.LVPerPage;
  ColCount := FMSTControl.clistcount;
  if (sControl.Count <> 0) and (FMSTControl.clistcount <> 0) then
    for i := 0 to PerPage - 1 do  
    begin
      sControl.LVItemImageIndex[i]:= I_SKIP;
      for j := 0 to ColCount - 1 do
        sControl.LVItems[i, j] := '';
    end; 
  InvalidateRect(sControl.Handle, nil, false);
  _hi_onEvent(_event_onChangeVirtIdx, FVirtIdx);
end;

procedure THIMST_Virtual.SetPage;
begin
  DefPage := Value;
  Page := Value;
end;

procedure THIMST_Virtual.SetMSTControl;
var
  sControl: PControl;
  l: TListViewOptions;
  i: integer;
begin
  if Value = nil then exit;
  FMSTControl := Value;
  sControl := Value.ctrlpoint;
  l := sControl.LVOptions;
  if (lvoOwnerData in l) then
  begin
    sControl.OnLVData := _OnLVData;
    for i := 0 to sControl.LVPerPage - 1 do
      sControl.LVItemAdd('');
  end;  
  FVirtIdx := Page * sControl.LVPerPage;
end;

procedure THIMST_Virtual._OnLVData;
var
  dvirt, didx, dsubitem: TData;
  PerPage, VirtIdx, OffsetIdx: integer;
begin
  PerPage := Sender.LVPerPage;
  Page := FVirtIdx div PerPage;
  OffsetIdx := FVirtIdx - Page * PerPage;  

  VirtIdx := Idx + Page * PerPage + OffsetIdx; 
  dtInteger(dvirt, VirtIdx);
  dtInteger(didx, Idx);
  case _prop_SubItemName of
    0: dtString(dsubitem, Sender.LVColText[SubItem]);
    1: dtInteger(dsubitem, SubItem);
  end;
  dvirt.ldata := @didx;
  didx.ldata := @dsubitem;
  _ReadData(dvirt, _data_VirtualData);
  case dvirt.data_type of
    data_null: exit;
  end;
  Txt := ReadString(dvirt, null);
  case dvirt.data_type of
    data_null: exit;
  end;
  ImgIdx := ReadInteger(dvirt, null);
end;

procedure THIMST_Virtual._work_doNextPage;
var
  sControl: PControl;
begin
  if not Assigned(FMSTControl) then exit;
  sControl := FMSTControl.ctrlpoint;
  inc(FVirtIdx, sControl.LVPerPage);
  InitPage; 
end;

procedure THIMST_Virtual._work_doPrevPage;        
var
  sControl: PControl;
begin
  if not Assigned(FMSTControl) then exit;
  sControl := FMSTControl.ctrlpoint;
  dec(FVirtIdx, sControl.LVPerPage);
  if FVirtIdx < 0 then
    FVirtIdx := 0;
  InitPage;
end;

procedure THIMST_Virtual._work_doSetPage;
var
  sControl: PControl;
begin
  if not Assigned(FMSTControl) then exit;
  sControl := FMSTControl.ctrlpoint;
  Page := ReadInteger(_Data, _data_Page, DefPage);
  if Page < 0 then exit;
  FVirtIdx := Page * sControl.LVPerPage;
  InitPage;
end;

procedure THIMST_Virtual._work_doResetPage;
var
  sControl: PControl;
begin
  if not Assigned(FMSTControl) then exit;
  sControl := FMSTControl.ctrlpoint;
  Page := DefPage;
  FVirtIdx := Page * sControl.LVPerPage;
  InitPage;
end;

procedure THIMST_Virtual._work_doInitPage;
begin
  InitPage;
end;

procedure THIMST_Virtual._work_doSetVirtIdx;
var
  sControl: PControl;
begin
  if not Assigned(FMSTControl) then exit;
  sControl := FMSTControl.ctrlpoint;
  FVirtIdx := ReadInteger(_Data, _data_VirtIdx);
  if FVirtIdx < 0 then FVirtIdx := 0;
  _hi_onEvent(_event_onChangeVirtIdx, FVirtIdx);  
  InvalidateRect(sControl.Handle, nil, false);  
end;

procedure THIMST_Virtual._var_CurPage;
begin
  dtInteger(_Data, Page);
end;

procedure THIMST_Virtual._var_CurVirtIdx;
begin
  dtInteger(_Data, FVirtIdx);
end;

procedure THIMST_Virtual._var_PerPage;        
var
  sControl: PControl;
begin
  if not Assigned(FMSTControl) then exit;
  sControl := FMSTControl.ctrlpoint;  
  dtInteger(_Data, sControl.LVPerPage);
end;

end.