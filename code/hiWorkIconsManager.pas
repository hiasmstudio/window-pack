unit hiWorkIconsManager;

interface
     
uses Messages,Windows,Kol,Share,Debug,ShellAPI,hiIconsManager;

const
   LOAD_ICON          =  2 ;
   LOAD_PAK_ICONS     =  4 ;
   LOAD_ILIST         =  5 ;
   LOAD_EXTICON       =  7 ;

   SAVE_ICON_FILE     =  3 ;
   SAVE_ILIST         =  6 ;

   SKIP               =  -1;

   ITM_INSERT         =  -4;
   ITM_REPLACE        =  -5;

type

  THIWorkIconsManager = class(TDebug)
   private
     Icon:PIcon;
     FIconToBmp: boolean;
     FIconCount:integer;
     FTranspColor:TColor;
     procedure InsertIcon(Data:TData; Index:word);
     procedure SaveIListToFile(const FileName:string; Index:word);     
     procedure LoadIListFromFile(const FileName:string; Index:word);
     function SFileExists_MT(FileName:string;FileOperation:integer):boolean;
     function LFileExists_MT(FileName:string;FileOperation:integer):boolean;
     procedure MT_ActionIco(var Data:TData; Mode:integer);
   public

     _prop_IconFileName:string;
     _prop_IconsFileName:string;
     _prop_IListFileName:string;
     _prop_IconsManager:IIconsManager;

     _event_onChangeImgLst:THI_Event;
     _event_onCountPakIcons:THI_Event;
     _event_onGetIcon:THI_Event;
     _event_onExtIcon:THI_Event;
     
     _data_LFileExists_MT:THI_Event;
     _data_SFileExists_MT:THI_Event;
     _data_IconFileName:THI_Event;
     _data_IconsFileName:THI_Event;
     _data_IListFileName:THI_Event;

     constructor Create;
     destructor Destroy;override;

     property _prop_TranspColor:TColor write FTranspColor;
     property _prop_IconToBmp:boolean write FIconToBmp;
     
     procedure _work_doMT_ReplaceIcon(var _Data:TData; Index:word);
     procedure _work_doMT_InsertIcon(var _Data:TData; Index:word);
     procedure _work_doMT_LoadExtIcon(var _Data:TData; Index:word);
     procedure _work_doClearIcons(var _Data:TData; Index:word);

     procedure _work_doLoadIcon(var _Data:TData; Index:word);
     procedure _work_doSaveIcon(var _Data:TData; Index:word);
     procedure _work_doSaveIList(var _Data:TData; Index:word);
     procedure _work_doLoadIList(var _Data:TData; Index:word);
     procedure _work_doLoadPakIcons(var _Data:TData; Index:word);
     procedure _work_doGetIcon(var _Data:TData; Index:word);
     procedure _work_doCountPakIcons(var _Data:TData; Index:word);
     procedure _work_doTranspColor(var _Data:TData; Index:word);
     procedure _work_doDeleteIcon(var _Data:TData; Index:word);          
     
     procedure _var_IconArray(var _Data:TData; Index:word);
     procedure _var_CountIcons(var _Data:TData; Index:word);
     procedure _var_EndIdxIcons(var _Data:TData; Index:word);     
     procedure _var_ImgSize(var _Data:TData; Index:word);
     procedure _var_CountPakIcons(var _Data:TData; Index:word);      
     procedure _var_TranspColor(var _Data:TData; Index:word);
  end;

implementation

constructor THIWorkIconsManager.Create;
begin
   inherited;
   Icon:= NewIcon;
end;

destructor THIWorkIconsManager.Destroy;
begin
   Icon.free;
   inherited;
end;

//#####################################################################
//#                                                                   #
//#                     Проверка наличиљ файлов                       #
//#                                                                   #
//#####################################################################

//--------------   Проверка наличиљ загружаемых файлов   --------------

//LFileExists_MT - При отсутствии загружаемого файла выдает событие длљ генерации сообщениљ,
//                 после чего отменљет операцию загрузки. MT-поток запроса содержит -
//                 - (Код файловой операции (2 - LoadIcon, 4 - LoadPakIcons,
//                 5 - LoadIList, 7 - LoadExtIcon)(Имљ файла)
//
function THIWorkIconsManager.LFileExists_MT;
var dt1,dt2:TData;
begin
   Result:= True;
   if FileExists(FileName) then Exit;
   dtInteger(dt1, FileOperation);
   dtString(dt2, FileName);
   dt1.ldata := @dt2;
   _ReadData(dt1, _data_LFileExists_MT);
   Result:=False;
end;

//--------------   Проверка наличиљ сохранљемых файлов   --------------

//SFileExists_MT - Если при сохранении в файле эта точка содержит 0,
//                 то операциљ сохранениљ будет продолжена, иначе - отменена,
//                 MT-поток запроса содержит - (Код файловой операции (3 - SaveIcon,
//                 6 - SaveIList)(Имљ файла)
//
function THIWorkIconsManager.SFileExists_MT;
var dt1,dt2:TData;
begin
   Result:= False;
   if not FileExists(FileName) then Exit;
   dtInteger(dt1, FileOperation);
   dtString(dt2, FileName);
   dt1.ldata := @dt2;
   _ReadData(dt1, _data_SFileExists_MT);
   if ToInteger(dt1) <> 0 then Result:= True;
end;

//doClearIcons - Очищает список иконок
//
procedure THIWorkIconsManager._work_doClearIcons;
begin
   if _prop_IconsManager = nil then exit;
   _prop_IconsManager.clearicons;
   _hi_CreateEvent_(_Data,@_event_onChangeImgLst);
end;

//doDeleteIcon - Удаляет иконку из списка иконок по индексу из потока
//
procedure THIWorkIconsManager._work_doDeleteIcon;
var   ind:integer;
      IList : PImageList;
begin
   if _prop_IconsManager = nil then exit;
   IList := _prop_IconsManager.iconList;
   ind:= ToInteger(_Data);
   if not ((IList <> nil) and (ind >= 0) and (ind < IList.Count)) then Exit;
   IList.Delete(ind);
   _hi_CreateEvent_(_Data,@_event_onChangeImgLst);
end;


//----------------   Загрузка и сохранение иконок   -------------------

//doCountPakIcons - Получает количество иконок в файле ресурса (*.exe,*.dll,*.ocx,*.icl),
//выдавая полученное значение в поток
//
procedure THIWorkIconsManager._work_doCountPakIcons;
var  fn:string;
begin
   fn:= ReadString(_Data,_data_IconsFileName,_prop_IconsFileName);
   if not LFileExists_MT(fn,LOAD_PAK_ICONS) then Exit;
   FIconCount:= GetFileIconCount(fn);
   _hi_CreateEvent(_Data,@_event_onCountPakIcons, FIconCount);
end;

//doLoadPakIcons - Импортирует иконки из файлов ресурсов (*.exe,*.dll,*.ocx,*.icl) в список иконок
//
procedure THIWorkIconsManager._work_doLoadPakIcons;
var   i, IconCount:integer;
      fn:string;
      IList : PImageList;
begin
   if _prop_IconsManager = nil then exit;
   IList := _prop_IconsManager.iconList;
   if IList = nil then exit;
   fn:= ReadString(_Data,_data_IconsFileName,_prop_IconsFileName);
   if not LFileExists_MT(fn,LOAD_PAK_ICONS) then Exit;
   Icon.Clear;
   IconCount:= GetFileIconCount(fn);
   if IconCount <> 0 then begin
      _prop_IconsManager.clearicons;
      _prop_IconsManager.setprop;
      i:= 0;
      repeat
         Icon.LoadFromExecutable(fn,i);
         IList.AddIcon(Icon.Handle);
         inc(i);
      until i = IconCount;
   end;
   _hi_CreateEvent_(_Data,@_event_onChangeImgLst);
end;

//doLoadIcon - Загружает иконку из файла, вставлљљ ее на место в списке с индексом из потока,
//             если индекс больше длины списка, то вставляет в конец списка
//
procedure THIWorkIconsManager._work_doLoadIcon;
var   ind:integer;
      fn:string;
      dt:TData;
      IList : PImageList;
begin
   if _prop_IconsManager = nil then exit;
   IList := _prop_IconsManager.iconList;
   if IList = nil then exit;
   fn:= ReadString(_Data,_data_IconFileName,_prop_IconFileName);
   ind:=ReadInteger(_Data, NULL);
   if not LFileExists_MT(fn,LOAD_ICON) then Exit;
   Icon.Clear;
   Icon.LoadFromFile(fn);
   dtIcon(dt,Icon);
   if (ind >= IList.Count) or (ind < 0) then
     _prop_IconsManager.addicon(dt)
   else if (ind >= 0 ) and (ind < IList.Count ) then
     InsertIcon(dt,ind);
   _hi_CreateEvent_(_Data,@_event_onChangeImgLst);
end;

//doSaveIcon - Сохранљет иконку с индексом из потока в файле
//
procedure THIWorkIconsManager._work_doSaveIcon;
var   dt,di:TData;
      fn:string;
      Bitmaps:array of HBitmap;
      II:TIconInfo;
      st:PStream;
      IList : PImageList;
begin
   if _prop_IconsManager = nil then exit;
   IList := _prop_IconsManager.iconList;
   if IList = nil then exit;
   fn:= ReadString(_Data,_data_IconFileName,_prop_IconFileName);
   di:= ReadData(_Data, Null);
   if SFileExists_MT(fn,SAVE_ICON_FILE) then Exit;
   Icon.Clear;
   if _prop_IconsManager.geticon(di,dt) then
     Icon{$ifndef F_P}^{$endif} := ToIcon(dt){$ifndef F_P}^{$endif} ;
   st:= NewWriteFileStream(fn);
   SetLength(Bitmaps, 2);
   GetIconInfo(Icon.Handle,II);
   Bitmaps[0]:= II.hbmColor;
   Bitmaps[1]:= II.hbmMask;
   SaveIcons2StreamEx(Bitmaps,St);
   free_and_nil(st);
end;

//-------------------   Сохранние списка иконок   ---------------------

//doSaveIList - Сохранљет список иконок в файле
//
procedure THIWorkIconsManager._work_doSaveIList;
var   fn:string;
begin
   fn:= ReadString(_Data,_data_IListFileName,_prop_IListFileName);
   if SFileExists_MT(fn,SAVE_ILIST) then Exit;
   SaveIListToFile(fn,Index);
end;

procedure THIWorkIconsManager.SaveIListToFile;
var   Strm, st:PStream;
      i,Pos:Integer;
      Bitmaps:array of HBitmap;
      II:TIconInfo;
      Bmp:HBitmap;
      IList : PImageList;
begin
   if _prop_IconsManager = nil then exit;
   IList := _prop_IconsManager.iconList;
   if Ilist = nil then Exit;
   for I:= 0 to IList.Count - 1 do if IList.ExtractIcon(I) = 0 then Exit;
   Strm:= NewMemoryStream;
   Pos:= Strm.Position;
   SetLength(Bitmaps, IList.Count * 2);
   for I:= 0 to IList.Count - 1 do
   begin
      GetIconInfo(IList.ExtractIcon(I),II);
      Bitmaps[I * 2]:= II.hbmColor;
      Bitmaps[I * 2 + 1]:= II.hbmMask;
   end;
   if not SaveIcons2StreamEx(Bitmaps,Strm) then Strm.Seek(Pos,spBegin);
   for i:= 0 to High(Bitmaps) do
   begin
      Bmp:= Bitmaps[i];
      if Bmp <> 0 then DeleteObject(Bmp);
   end;
   st:= NewWriteFileStream(FileName);
   Strm.Position:= 0;
   Stream2Stream(st,Strm,Strm.Size);
   st.free;
   Strm.free;
end;

//-------------------   Загрузка списка иконок   ----------------------

//doLoadIList - Загружает список иконк из файла
//
procedure THIWorkIconsManager._work_doLoadIList;
var   fn:string;
begin
   fn:= ReadString(_Data,_data_IListFileName,_prop_IListFileName);
   if not LFileExists_MT(fn,LOAD_PAK_ICONS) then Exit;
   LoadIListFromFile(fn,1);
end;

procedure THIWorkIconsManager.LoadIListFromFile;
var   Strm, st: PStream;
      Pos: DWord;
      Data: TStreamData;
      IList : PImageList;

   function ReadIcon : Boolean;
   var   IDI, FoundIDI : TIconDirEntry;
         I, j: Integer;
         II : TIconInfo;
         BIH : TBitmapInfoheader;
         IH : TIconHeader;
         Mem: PStream;
         ImgBmp, MskBmp : PBitmap;
   begin
      ImgBmp:= nil;
      MskBmp:= nil;
      Result:= False;
      if Strm.Read(IH, Sizeof(IH)) <> Sizeof(IH) then Exit;
      if (IH.idReserved <> 0) or ((IH.idType <> 1) and (IH.idType <> 2)) or
         (IH.idCount < 1) then exit;
      for j:= 1 to IH.idCount do begin
         if Strm.Read(IDI, Sizeof(IDI)) <> Sizeof(IDI) then Exit;
         if (IDI.bWidth <> IDI.bHeight) and (IDI.bWidth * 2 <> IDI.bHeight) or
            (IDI.bWidth = 0) then exit;
         FoundIDI:= IDI;
         Strm.Seek(Integer(Pos) + (FoundIDI.dwImageOffset), spBegin);
         Data.fSize:= FoundIDI.bWidth;
         if Strm.Read(BIH, Sizeof(BIH)) <> Sizeof(BIH) then Exit;
         if (BIH.biWidth <> integer(Data.fSize)) or (BIH.biHeight <> integer(Data.fSize) * 2) and
            (BIH.biHeight <> integer(Data.fSize)) then exit;
         BIH.biHeight:= Data.fSize;
         Mem:= NewMemoryStream;
      TRY
         Mem.Write(BIH, Sizeof(BIH));
         if (FoundIDI.bColorCount >= 2) or (FoundIDI.bReserved = 1) or (FoundIDI.bColorCount = 0) then begin
            I:= 0;
            if BIH.biBitCount <= 8 then I := (1 shl BIH.biBitCount) * Sizeof(TRGBQuad);
            if I > 0 then if Stream2Stream(Mem, Strm, I) <> DWORD(I) then exit;
            I:= ((BIH.biBitCount * Data.fSize + 31) div 32) * 4 * Data.fSize;
            if Stream2Stream(Mem, Strm, I) <> DWORD(I) then exit;
            ImgBmp:= NewBitmap(Data.fSize, Data.fSize);
            Mem.Seek(0, spBegin);
            ImgBmp.LoadFromStream(Mem);
            if ImgBmp.Empty then exit;
         end;
         BIH.biBitCount:= 1;
         Mem.Seek(0, spBegin);
         Mem.Write(BIH, Sizeof(BIH));
         I:= 0;
         Mem.Write(I, Sizeof(I));
         I:= $FFFFFF;
         Mem.Write(I, Sizeof(I));
         I:= ((Data.fSize + 31) div 32) * 4 * Data.fSize;
         if Stream2Stream(Mem, Strm, I) <> DWORD(I) then exit;
         MskBmp:= NewBitmap(Data.fSize,Data.fSize);
         Mem.Seek(0, spBegin);
         MskBmp.LoadFromStream(Mem);
         if MskBmp.Empty then exit;
         FillChar(II, Sizeof(II), 0);
         II.fIcon:= True;
         II.xHotspot:= 0;
         II.yHotspot:= 0;
         II.hbmMask:= MskBmp.ReleaseHandle;
         II.hbmColor:= ImgBmp.ReleaseHandle;
         Data.fHandle:= CreateIconIndirect(II);
         _prop_IconsManager.setprop;
         IList.AddIcon(Data.fHandle);
         DestroyIcon(Data.fHandle);
         DeleteObject(II.hbmMask);
         DeleteObject(II.hbmColor);
         Strm.Seek(integer(Pos) + Sizeof(IH) +  Sizeof(IDI)*j, spBegin);
      FINALLY
         ImgBmp.free;
         MskBmp.free;
         Mem.free;
      END;
      end;
      Result:= Data.fHandle <> 0;
   end;

begin
   if _prop_IconsManager = nil then exit;
   IList := _prop_IconsManager.iconList;

   Strm:= NewMemoryStream;
   if (IList = nil) then exit;
   st:= NewReadFileStream(Filename);
   Stream2Stream(Strm,st,st.Size);
   free_and_nil(st);
   _prop_IconsManager.clearicons;
   Strm.Position:= 0;
   Data:= Strm.Data;
   Pos:= Data.fPosition;
   ReadIcon;
   Strm.free;
   _hi_onEvent(_event_onChangeImgLst);
end;

//------------------   Переменные списка иконок   ---------------------

//IconArray - Массив иконок
//
procedure THIWorkIconsManager._var_IconArray;
begin
   if _prop_IconsManager <> nil then
     _prop_IconsManager.iconarray(_Data);
end;

//CountIcons - Содержит количество иконок в списке иконок
//
procedure THIWorkIconsManager._var_CountIcons;
begin
   if _prop_IconsManager <> nil then
     dtInteger(_Data,_prop_IconsManager.counticons);
end;

//EndIdxIcons - Содержит индекс последней иконки в списке иконок
//
procedure THIWorkIconsManager._var_EndIdxIcons;
begin
   if _prop_IconsManager <> nil then
     dtInteger(_Data, _prop_IconsManager.counticons - 1);
end;


//Содержит количество иконок в файле ресурса.
//Значение действительно после вызова метода doCountPakIcons
//
procedure THIWorkIconsManager._var_CountPakIcons;
begin
  dtInteger(_Data,FIconCount);
end;

//ImgSize - Содержит размер иконок в списке иконок
//
procedure THIWorkIconsManager._var_ImgSize;
begin
   if _prop_IconsManager <> nil then
     dtInteger(_Data,_prop_IconsManager.imgsz);
end;

//TranspColor - Содержит цвет заливки прозрачных областей иконки
//при конвертации в формат BMP
//
procedure THIWorkIconsManager._var_TranspColor;
begin
  dtInteger(_Data, Color2RGB(FTranspColor));
end;


//doMT_InsertIcon - Вставлљет иконку в список иконок, используљ MT-потоки,
//                  где последовательность элементов -
//                  - (Индекс местоположениљ иконки в списке)(Иконка).
//                  При параметре индекса большем длины списка иконок, иконка добавлљетсљ в конец списка
//
procedure THIWorkIconsManager._work_doMT_InsertIcon;begin MT_ActionIco(_Data,ITM_INSERT);end;

//doMT_ReplaceIcon - Заменљет иконку в списке иконок, используљ MT-потоки,
//                   где последовательность элементов -
//                   - (Индекс местоположениљ иконки в списке)(Иконка)
//
procedure THIWorkIconsManager._work_doMT_ReplaceIcon;begin MT_ActionIco(_Data,ITM_REPLACE);end;

//-----------------   MT-извлечение отдельной иконки   -------------------
//
//doMT_LoadExtIcon - Извлекает отдельную иконку из файла ресурса (*.exe,*.dll,*.ocx,*.icl),
//                   где последовательность элементов -
//                   - (Имљ файла ресурса)(Номер извлекаемой иконки)(Размер иконки)(Иконка замены)
//
procedure THIWorkIconsManager._work_doMT_LoadExtIcon; // проверен
var   ico: PIcon;
      fn:string;
      dt,di:TData;
      idx:word;
      bmp:PBitmap;
      Licon,sIcon:hIcon;
      iSize:integer;
      Flags: Integer;
      SFI: TShFileInfo;
begin
//   if _IsNULL(_Data) then exit;

   bmp :=nil;
   fn := ReadString(_Data,Null);
   idx := ReadInteger(_Data,Null);
   iSize :=  ReadInteger(_Data,Null);
   di := ReadData(_Data,Null);

   if iSize = 0 then
     if _prop_IconsManager <> nil then
       iSize := _prop_IconsManager.imgsz
     else
       iSize := GetSystemMetrics(SM_CXICON);

   if not LFileExists_MT(fn,LOAD_EXTICON) then Exit;
   ico:= NewIcon;

   ExtractIconEx(PChar(fn),idx,Licon,sIcon,1);
   if iSize < 24 then
      ico.handle:= sIcon
    else
      ico.handle:= LIcon;

   if ico.Handle <> 0 then
      dtIcon(dt,ico)
   else if (_IsIcon(di)) and (ico.Handle = 0) then begin
      ico.free;
      ico:= NewIcon;
      dtData(dt,di);
      ico{$ifndef F_P}^{$endif} := ToIcon(dt){$ifndef F_P}^{$endif} ;
   end else begin
      if iSize < 24 then
         Flags:= SHGFI_ICON or SHGFI_ICONLOCATION or SHGFI_SMALLICON or SHGFI_TYPENAME or SHGFI_SYSICONINDEX
      else
         Flags:= SHGFI_ICON or SHGFI_ICONLOCATION or SHGFI_LARGEICON or SHGFI_TYPENAME or SHGFI_SYSICONINDEX;
         ShGetFileInfo(PChar(fn), 0, SFI, SizeOf(SFI), Flags);
         ico.handle:= SFI.hIcon;
         if ico.Handle <> 0 then dtIcon(dt,ico)
   end;
   if FIconToBmp then begin
      bmp:= NewBitmap(Ico.Size,Ico.Size);
      bmp.Handle:= Ico.Convert2Bitmap(Color2RGB(FTranspColor));
      dtBitmap(dt,bmp);
   end;
   _hi_onEvent_(_event_onExtIcon, dt);
   bmp.free;
   ico.free;
end;

//Универсальный MT-метод работы со списком иконок
//
procedure THIWorkIconsManager.MT_ActionIco; // проверен
var   idx:integer;
      di:TData;
      IList : PImageList;
begin
//   if _IsNULL(Data) then exit;
   idx:= ReadInteger(Data,Null);
   di:= ReadData(Data,Null);
   if _prop_IconsManager = nil then exit;
   IList := _prop_IconsManager.iconList;
   if not _IsIcon(di) or (Ilist = nil) or (idx < 0) then exit;

   if (Mode = ITM_INSERT) and (idx > IList.Count - 1) then
      _prop_IconsManager.addicon(di)
   else if (Mode = ITM_INSERT) and (idx < IList.Count) then
      InsertIcon(di,idx)
   else if (Mode = ITM_REPLACE) and (idx < IList.Count) then
      IList.ReplaceIcon(idx, ToIcon(di).handle)
   else exit;
   _hi_CreateEvent_(Data,@_event_onChangeImgLst);
end;

procedure THIWorkIconsManager.InsertIcon;
var   dt:TData;
      i,ind:integer;
      IList : PImageList;
begin
   if _prop_IconsManager = nil then exit;
   IList := _prop_IconsManager.iconList;
   dt:= Data;
   ind:= integer(Index);
   if not ((IList <> nil) and _IsIcon(dt)and(ind >= 0)and(ind < IList.Count)) then exit;
   i:= IList.Count - 1;
   IList.AddIcon(IList.ExtractIcon(i));
   repeat
      IList.ReplaceIcon(i,IList.ExtractIcon(i-1));
      dec(i);            
   until i <= ind;
   IList.ReplaceIcon(ind, ToIcon(dt).handle);
end;

//doGetIcon - Полуает иконку из списка иконок по индексу из потока
//
procedure THIWorkIconsManager._work_doGetIcon;
var   dt,di:TData;
      bmp:PBitmap;
      IList : PImageList;      
begin
   if _prop_IconsManager = nil then exit;
   IList := _prop_IconsManager.iconList;   
   dtNull(di);
   bmp:= nil;
   Icon.Clear;
   if Assigned(IList) and (Ilist.Count <> 0) then
      if _prop_IconsManager.geticon(_Data,dt) then Icon{$ifndef F_P}^{$endif} := ToIcon(dt){$ifndef F_P}^{$endif} ;
   if Icon.Handle <> 0 then
      if FIconToBmp then begin
         bmp:= NewDIBBitmap(Icon.Size,Icon.Size,pf32bit);
         bmp.Handle:= Icon.Convert2Bitmap(Color2RGB(FTranspColor));
         dtBitmap(di,bmp);
      end
      else dtIcon(di,Icon);
   _hi_onEvent(_event_onGetIcon,di);
   bmp.free;
end;

procedure THIWorkIconsManager._work_doTranspColor;
begin
  FTranspColor := ToInteger(_Data);
end;

//
//----------------------------   Конец   ------------------------------
end.