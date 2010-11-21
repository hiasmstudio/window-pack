unit hiGL_GluTools;

interface

uses Kol,Share,Debug,OpenGL,DGLUT;

const
  gldsPoint = glu_point;
  gldsLine  = glu_line;
  gldsFill  = glu_fill;
  gldsSilhouette = glu_Silhouette;

  gloInside  = glu_inside;
  gloOutside = glu_outside;

  glnSmooth = glu_Smooth;
  glnFlat   = glu_Flat;
  glnNone   = glu_None;

  gldsArr:array[0..3] of cardinal = (gldsPoint,gldsLine,gldsFill,gldsSilhouette);
  gloArr:array[0..1] of cardinal = (gloInside,gloOutside);
  glnArr:array[0..2] of cardinal = (glnSmooth,glnFlat,glnNone);

type
  THIGL_GluTools = class(TDebug)
   private
   public
    _prop_DrawStyle:cardinal;
    _prop_Orientation:cardinal;
    _prop_Normal:cardinal;
    _prop_Texture:boolean;

    _event_onInit:THI_Event;

    constructor Create;
    destructor destroy; override;
    procedure _work_doInit(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);

    procedure _work_doDrawStyle(var _Data:TData; Index:word);
    procedure _work_doOrientation(var _Data:TData; Index:word);
    procedure _work_doNormal(var _Data:TData; Index:word);
  end;

implementation

constructor THIGL_GluTools.Create;
begin
   inherited;
end;

destructor THIGL_GluTools.destroy;
begin
   inherited;
end;

procedure THIGL_GluTools._work_doInit;
begin
   quadObj := gluNewQuadric;
   gluQuadricDrawStyle(quadObj,_prop_DrawStyle);
   gluQuadricOrientation(quadObj,_prop_Orientation);
   gluQuadricNormals(quadObj,_prop_Normal);
   gluQuadricTexture (quadObj, _prop_Texture);
   _hi_CreateEvent(_Data,@_event_onInit);
end;

procedure THIGL_GluTools._work_doDelete;
begin
   gluDeleteQuadric(quadObj);
end;

procedure THIGL_GluTools._work_doDrawStyle(var _Data:TData; Index:word);
begin
   gluQuadricDrawStyle(quadObj,gldsArr[ToInteger(_Data)]);
end;

procedure THIGL_GluTools._work_doOrientation(var _Data:TData; Index:word);
begin
   gluQuadricOrientation(quadObj,gloArr[ToInteger(_Data)]);
end;

procedure THIGL_GluTools._work_doNormal(var _Data:TData; Index:word);
begin
   gluQuadricNormals(quadObj,glnArr[ToInteger(_Data)]);
end;

end.
