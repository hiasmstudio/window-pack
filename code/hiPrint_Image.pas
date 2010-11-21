unit hiPrint_Image;

interface

uses Windows,Kol,Share,Debug,DrawControls,hiDocumentTemplate,Img_Draw;

type
  THIPrint_Image = class(TDocItem)
   private
    FInit:boolean; 
    procedure InitImage;
   public
    FImage:TDrawImage;

    _prop_Picture:HBITMAP;

    _prop_AutoSize:boolean;
    _prop_ViewStyle:byte;

    _prop_FrameStyle:byte;
    _prop_FrameSize:integer;
    _prop_FrameColor:TColor;

    _prop_BackStyle:byte;
    _prop_BackColor:TColor;

    constructor Create;
    destructor Destroy; override;
    procedure Draw(dc:HDC; x,y:integer; const Scale:TScale); override;    
  end;

implementation

constructor THIPrint_Image.Create;
begin
   inherited;
   FImage := TDrawImage.Create; 
end;

destructor THIPrint_Image.Destroy; 
begin      
   FImage.Destroy;
   inherited;
end;

procedure THIPrint_Image.InitImage;
begin           
   FImage.Image.Handle := _prop_Picture;
   
//   FImage.AutoSize := _prop_AutoSize;
   FImage.ViewStyle := _prop_ViewStyle;
   
   FImage.FrameStyle := _prop_FrameStyle;
   FImage.FrameSize := _prop_FrameSize;
   FImage.FrameColor := _prop_FrameColor;
   
   FImage.BackStyle := _prop_BackStyle = 0;
   FImage.BackColor := _prop_BackColor;
   
   FImage.Width := _prop_Width;
   FImage.Height := _prop_Height;
end;

procedure THIPrint_Image.Draw;
begin
    if not FInit then // тут надо все через property разводить...
     begin
       FInit := true;
       InitImage;
     end;
   FImage.Draw(dc, x + _prop_X, y + _prop_Y, Scale.X, Scale.Y);
end;

end.
