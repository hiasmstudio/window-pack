unit hiPrint_Image;

interface

uses Windows,Kol,Share,Debug,DrawControls,hiDocumentTemplate,Img_Draw;

type
  THIPrint_Image = class(TDocItem)
   private
    procedure SetPicture(Value:HBITMAP);
    procedure SetAutosize(Value: boolean);
    procedure SetViewStyle(Value:byte);
    procedure SetFrameStyle(Value:byte);
    procedure FrameSize(Value:integer);
    procedure FrameColor(Value:TColor);
    procedure SetBackStyle(Value:byte);
    procedure SetBackColor(Value:TColor);
    procedure SetAlphaBlend(Value:byte);   
   public
    FImage:TDrawImage;

	_prop_Visible: boolean;
    constructor Create;
    destructor Destroy; override;
    procedure Draw(dc:HDC; x,y:integer; const Scale:TScale; alpha: boolean=false); override;    

    property _prop_Picture:HBITMAP write SetPicture;
    property _prop_AutoSize:boolean write SetAutosize;
    property _prop_ViewStyle:byte write SetViewStyle;

    property _prop_FrameStyle:byte write SetFrameStyle;
    property _prop_FrameSize:integer write FrameSize;
    property _prop_FrameColor:TColor write FrameColor;

    property _prop_BackStyle:byte write SetBackStyle;
    property _prop_BackColor:TColor write SetBackColor;
    
    property _prop_AlphaBlendValue:byte write SetAlphaBlend;
    
  end;

implementation

constructor THIPrint_Image.Create;
begin
   inherited;
   _NameType := _IMAGE;  
   FImage := TDrawImage.Create; 
end;

destructor THIPrint_Image.Destroy; 
begin      
   FImage.Destroy;
   inherited;
end;

procedure THIPrint_Image.SetPicture;
begin
   FImage.Image.Handle := Value;
end;

procedure THIPrint_Image.SetAutosize;
begin
//   FImage.AutoSize := Value;
end;

procedure THIPrint_Image.SetViewStyle;
begin
   FImage.ViewStyle := Value;
end;

procedure THIPrint_Image.SetFrameStyle;
begin
   FImage.FrameStyle := Value;
end;

procedure THIPrint_Image.FrameSize;
begin
   FImage.FrameSize := Value;
end;

procedure THIPrint_Image.FrameColor;
begin
   FImage.FrameColor := Value;
end;

procedure THIPrint_Image.SetBackStyle;
begin
   FImage.BackStyle := Value = 0;
end;

procedure THIPrint_Image.SetBackColor;
begin
   FImage.BackColor := Value;
end;

procedure THIPrint_Image.SetAlphaBlend;
begin
   FImage.AlphaBlendValue := Value;
end;

procedure THIPrint_Image.Draw;
begin
  if not _prop_Visible then exit;
  FImage.Width := _prop_Width;
  FImage.Height := _prop_Height;
  FImage.Draw(dc, x + _prop_X, y + _prop_Y, Scale.X, Scale.Y, alpha);
end;

end.
