unit hiImg_Edge;

interface

uses Windows,Kol,Share,Img_Draw;

const
Edge: array[0..7] of cardinal = (EDGE_RAISED,EDGE_SUNKEN,EDGE_BUMP,EDGE_ETCHED,BDR_RAISEDINNER,BDR_SUNKENINNER,BDR_RAISEDOUTER,BDR_SUNKENOUTER);         
 
{$I share.inc}

type
  THIImg_Edge = class(THIDraw2PR)
   private
   public
    _prop_View: integer;
    _prop_bfLeft: boolean;
    _prop_bfTop: boolean;        
    _prop_bfRight: boolean;
    _prop_bfBottom: boolean;    
    _prop_bfSoft: boolean;
    _prop_bfFlat: boolean; 
    _prop_bfMono: boolean; 
    _prop_bfMiddle: boolean; 
    _prop_bfDiagonal: boolean; 
    _prop_bfAdjust: boolean; 
            
    _data_View: THI_Event;
    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIImg_Edge._work_doDraw;
var   dt: TData;
      rct: TRect;
      tp: integer;
      flags: cardinal;
      mTransform: PTransform;
begin
   dt := _Data;
TRY
   if not ImgGetDC(_Data) then exit;
   ReadXY(_Data);

   ImgNewSizeDC;
   tp := ReadInteger(_Data,_data_View,_prop_View);
   if (tp < 0) or (tp > 7) then tp := 0;
   flags := $0;
   if _prop_bfLeft then flags := flags OR $1; 
   if _prop_bfTop then flags := flags OR $2; 
   if _prop_bfRight then flags := flags OR $4; 
   if _prop_bfBottom then flags := flags OR $8; 
   if _prop_bfDiagonal then flags := flags OR $10;  
   if _prop_bfMiddle then flags := flags OR $800; 
   if _prop_bfSoft then flags := flags OR $1000; 
   if _prop_bfAdjust then flags := flags OR $2000; 
   if _prop_bfFlat then flags := flags OR $4000; 
   if _prop_bfMono then flags := flags OR $8000; 

   mTransform := ReadObject(_Data, _data_Transform, TRANSFORM_GUID);
   if mTransform <> nil then
    if mTransform._Set(pDC,x1,y1,x2,y2) then  //если необходимо изменить координаты (rotate, flip)
     PRect(@x1)^ := mTransform._GetRect(MakeRect(x1,y1,x2,y2));
   SetRect(rct, x1, y1, x2, y2);
   DrawEdge(pDC, rct, Edge[tp], flags);
   if mTransform <> nil then mTransform._Reset(pDC); // сброс трансформации
   
FINALLY
   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
END;
end;

end.