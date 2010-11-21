unit hiPC_Image;

interface

uses Windows,Kol,Share,Debug,hiDocumentTemplate,hiPrint_Image,PrintController;

type
  THIPC_Image = class(TPrintController)
   private
   public
    _data_Bitmap:THI_Event;
    _event_onPicture:THI_Event;

    procedure _work_doPicture(var _Data:TData; Index:word);
    procedure _var_CurrentPicture(var _Data:TData; Index:word);
  end;

implementation

procedure THIPC_Image._work_doPicture;
begin  
  InitItem(_Data);
  THIPrint_Image(FItem).FImage.Image.assign(ReadBitmap(_Data, _data_Bitmap));
  _hi_onEvent(_event_onPicture);
end;

procedure THIPC_Image._var_CurrentPicture;
begin
  InitItem;
  dtBitmap(_Data, THIPrint_Image(FItem).FImage.Image);
end;

end.
