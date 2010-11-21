unit hiTabControl;

interface

{$I share.inc}

uses Kol,Share,Win;

type
 THITabControl = class(THIWin)
   private
    IconsIdx:TIconsIdx;
    procedure _OnChange(Obj:PObj);
   public
     Arr:array of AnsiString;
     Ars:array of string;
     ImgLst:PImageList;
 
     _prop_Tabs:string;
     _prop_Buttons:boolean;
     _prop_HotTrack:boolean;
     _prop_FocusTabs:boolean;
     _prop_Vertical:boolean;
     _prop_Bottom:boolean;
     _prop_Icons:boolean;
     _prop_Border:boolean;
     _prop_IconByIndex:boolean;
     _prop_Bitmaps:PStrListEx;

     _data_NewPageText:THI_Event;
     _data_Index:THI_Event;
     _data_IconIdx:THI_Event;
     _event_onChange:THI_Event;

    procedure Init; override;
    procedure _work_PageInsert(var _Data:TData;Index:word);
    procedure _work_PageTab(var _Data:TData;Index:word);
    procedure _var_CurTabIndx(var _Data:TData; Index:word);
    procedure _var_CurTabCaption(var _Data:TData; Index:word);
    procedure _work_PageDelete(var _Data:TData; Index:word);
    procedure _work_DeleteCurrent(var _Data:TData; Index:word);    
    procedure _work_ReplaceIdx(var _Data:TData; Index:word);
    procedure _var_TabCount(var _Data:TData; Index:word);
end;

implementation

procedure THITabControl.Init;
var i:integer;
    Lst:PStrList;
    tco:TTabControlOptions;
    s:string;
begin
  SetLength(IconsIdx, 1);
  tco := [];
  if _prop_Buttons then
    tco:=[tcoButtons];
  if _prop_HotTrack then
    include(tco,tcoHotTrack);
  if _prop_FocusTabs then
    include(tco,tcoFocusTabs);
  if _prop_Vertical then
    include(tco,tcoVertical);
  if _prop_Bottom then
    include(tco,tcoBottom);
  if _prop_Border then
    include(tco,tcoBorder);
//Создание array Of AnsiString;
  Lst := NewStrList;
  Lst.text := _prop_Tabs;
  if Lst.Count > 0 then 
    begin
        SetLength(Arr,Lst.Count);
        SetLength(Ars,Lst.Count);
        for i := 0 to Lst.Count-1 do 
         begin
              Ars[i] := Lst.Items[i];
              Arr[i] := PChar(Ars[i]);
         end;
    end;
//Создание ImageList
  if Assigned(_prop_Bitmaps) then 
    begin
        ImgLst := NewImageList(Applet);
        include(tco,tcoIconLeft);
        for i := 0 to _prop_Bitmaps.Count-1 do 
          begin
              ImgLst.ImgWidth := 16;
              ImgLst.ImgHeight := 16;
              ImgLst.AddMasked(_prop_Bitmaps.Objects[i], clWhite)
          end;
    end;
  Control := NewTabControl(FParent,Arr,tco,ImgLst,0);
  if _prop_IconByIndex then
     for i := 0 to Control.Count - 1 do 
      begin
        s := Control.TC_Items[i];
        ParseIconsIdx(s,IconsIdx,true);
        Control.TC_Images[i] := IconsIdx[0];
        Control.TC_Items[i] := s;
      end;   
  inherited;
  Control.OnSelChange := _OnChange;
  Lst.Free;
end;

procedure THITabControl._OnChange;
begin
  _hi_OnEvent(_event_onChange,Control.CurIndex);
end;

procedure THITabControl._work_PageInsert;
var   s:string;
      n:integer;
      ind:integer;
begin
   s := ReadString(_Data,_data_NewPageText,'');
   ind := ReadInteger(_Data,_data_Index,0);
   if _prop_IconByIndex then 
     begin
       ParseIconsIdx(s,IconsIdx,true);
       n := IconsIdx[0];
     end 
   else n := ind;
      
   Control.TC_Insert(ind,s,n);
end;

procedure THITabControl._work_PageDelete;
var ind:integer;
begin
  ind := ReadInteger(_Data,_data_Index,0);
  Control.TC_Delete(ind);
end;

procedure THITabControl._work_DeleteCurrent;
var ind:integer;
begin
  ind := Control.CurIndex;
  Control.TC_Delete(ind);
  if ind <> 0 then
    Control.CurIndex := ind - 1
  else  
    Control.CurIndex := ind;
end;

procedure THITabControl._work_PageTab;
begin
  Control.CurIndex := ToInteger(_Data);
end;

procedure THITabControl._work_ReplaceIdx;
var   ind,idx:integer;
begin
   ind := ReadInteger(_Data,_data_Index);
   idx := ReadInteger(_Data,_data_IconIdx); 
   Control.TC_Images[ind] := idx;
   Control.Invalidate;
end;

procedure THITabControl._var_CurTabIndx;
begin
  dtInteger(_Data,Control.CurIndex);
end;

procedure THITabControl._var_CurTabCaption;
begin
  dtString(_Data,Control.TC_Items[Control.CurIndex]);
end;

procedure THITabControl._var_TabCount;
begin
  dtInteger(_Data,Control.Count);
end;

end.

