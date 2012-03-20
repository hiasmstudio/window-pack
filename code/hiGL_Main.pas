unit hiGL_Main;

interface

uses Windows,Kol,Share,Debug,OpenGL;

var
   // WGL_EXT_swap_control
   WGL_EXT_swap_control  : Boolean;
   
const
   VSyncOn  = 1;
   VSyncOff = 0;

   GL_MODULATE = OpenGL.GL_MODULATE;
   GL_DECAL = OpenGL.GL_DECAL;
   GL_BLEND = OpenGL.GL_BLEND;

type
   THIGL_Main = class(TDebug)
   private
   hrc: HGLRC;
   DC:HDC;
   fps_time: Integer;
   fps_cur : Integer;
   g_FPS   : Integer;
   AASamples : Boolean;
   MaxAnisotropy:Integer;
   MaxAASamples:Integer;

   public
   _data_Handle:THI_Event;
   _data_AALevel:THI_Event;

   _prop_EnvironmentMode:cardinal;

   _prop_Color:TColor;
   _prop_TwoSide:boolean;
   _prop_ClearStencil:integer;
   _prop_StencilMask:integer;
   _prop_StencilBits:integer;

   _prop_Fovy:real;
   _prop_zNear:real;
   _prop_zFar:real;
   _prop_AASamples:boolean;
   _prop_AALevel:integer;

   _event_onInit:THI_Event;
   _event_onViewPort:THI_Event;
   _event_onVSync:THI_Event;
   _event_onExtensions:THI_Event;

   destructor Destroy; override;
   procedure _work_doInit(var _Data:TData; Index:word);
   procedure _work_doViewPort(var _Data:TData; Index:word);
   procedure _work_doFlip(var _Data:TData; Index:word);
   procedure _work_doColor(var _Data:TData; Index:word);
   procedure _work_doVSync(var _Data:TData; Index:word);
   procedure _var_GLHandle(var _Data:TData; Index:word);
   procedure _var_Fps(var _Data:TData; Index:word);
   procedure _var_MaxTextureSize(var _Data:TData; Index:word);
   procedure _var_MaxAnisotropy(var _Data:TData; Index:word);
   procedure _var_MaxAASamples(var _Data:TData; Index:word);
   procedure _var_Vendor(var _Data:TData; Index:word);
   procedure _var_Renderer(var _Data:TData; Index:word);
   procedure _var_VersionGL(var _Data:TData; Index:word);
  end;

procedure glColor(C:TColor);
procedure glColora(C:TColor; Alpha:real);
function ReadAndCheck_WGL_EXT_swap_control: boolean;

implementation


function WGLisExtensionSupported(const extension: string): boolean;//Функция проверки необходимых расширений
var
   wglGetExtString: function(hdc: HDC): Pchar; stdcall;
   supported: PChar;
begin
   wglGetExtString := nil;
   supported := nil;
   wglGetExtString := wglGetProcAddress('wglGetExtensionsStringARB');
   if Assigned(wglGetExtString) then
   supported := wglGetExtString(wglGetCurrentDC());
   if supported = nil then
   supported := glGetString(GL_EXTENSIONS);
   if supported = nil then
   begin
      Result := false;
      exit;
   end;
   if Pos(extension,supported) = 0 then
   begin
      Result := false;
      exit;
   end;
   Result := true;
end;

function ReadAndCheck_WGL_EXT_swap_control;
var
   Extensions: String;
begin
   Extensions := glGetString(GL_EXTENSIONS);
   WGL_EXT_swap_control := Pos('WGL_EXT_swap_control', Extensions) <> 0;
   if WGL_EXT_swap_control then
   begin
      wglSwapIntervalEXT := wglGetProcAddress('wglSwapIntervalEXT');
      wglGetSwapIntervalEXT := wglGetProcAddress('wglGetSwapIntervalEXT');
   end
   else
   begin
      Result := false;
   end;
end;

procedure glColor(C:TColor);
begin
   with TRGB(c) do
   glColor3f(r/255, g/255, b/255);
end;

procedure glColora;
begin
   with TRGB(c) do
   glColor4f(r/255, g/255, b/255,alpha);
end;

destructor THIGL_Main.Destroy;
begin
   wglMakeCurrent(0, 0);
   wglDeleteContext(hrc);
   inherited;
end;

procedure THIGL_Main._work_doInit;
label
noAASamples,DelCont;
var
   AALev: integer;
   valid: boolean;
   numFormats: UINT;
   hwnd : Cardinal;
   Extensions: string;
   wnd  : TWndClassEx;
   pixelFormat: integer;
   nPixelFormat: Integer;
   CorrectHandle: integer;
   wglpixelFormat: integer;
   pfd: TPixelFormatDescriptor;
   fAttributes: array of GLfloat;
   iAttributes: array [0..17] of integer;
   wglChoosePixelFormatARB: function(hdc: HDC; const piAttribIList: PGLint; const pfAttribFList: PGLfloat; nMaxFormats: GLuint; piFormats: PGLint; nNumFormats: PGLuint): BOOL; stdcall;
begin
   if _prop_AASamples then
   begin
      //***Создаем временное окно, получаем дескриптор окна(DC)***//
      ZeroMemory(@wnd, SizeOf(wnd));
      with wnd do
      begin
         cbSize        := SizeOf(wnd);
         lpfnWndProc   := @DefWindowProc;
         lpszClassName := 'Temp';
      end;
      RegisterClassEx(wnd);
      hwnd := CreateWindow('Temp', nil, WS_POPUP, 0, 0, 0, 0, 0, 0, 0, nil);
      DC := GetDC(hwnd);
      if DC = 0 then
      begin
         ShowMessage('Ошибка при создании окна');
         exit;
      end;
      //**********************************************************//
      FillChar(pfd, SizeOf(pfd), 0);
      with pfd do
      begin
         nSize      := SizeOf(TPIXELFORMATDESCRIPTOR);
         dwFlags    := PFD_DRAW_TO_WINDOW or
         PFD_SUPPORT_OPENGL or
         PFD_DOUBLEBUFFER;
      end;
      //---Получаем формат пикселя временного окна, создаём контест вывода ---//
      nPixelFormat := ChoosePixelFormat(DC, @pfd); // Выбираем правильный формат пикселя
      SetPixelFormat(DC, nPixelFormat, @pfd);// Устанавливаем выбранный формат
      hrc := wglCreateContext(DC); // Создаем контекст
      wglMakeCurrent(DC, hrc); //Делаем его текущим
      //----------------------------------------------------------------------//
      if  WGLisExtensionSupported('WGL_ARB_multisample') then //Проверяем наличие необходимых расширений ARB
      begin
         wglChoosePixelFormatARB := wglGetProcAddress('wglChoosePixelFormatARB');

         iAttributes[0]  := WGL_DRAW_TO_WINDOW_ARB;
         iAttributes[1]  := 1;
         iAttributes[2]  := WGL_SUPPORT_OPENGL_ARB;
         iAttributes[3]  := 1;
         iAttributes[4]  := WGL_SAMPLE_BUFFERS_ARB;
         iAttributes[5]  := 1;
         iAttributes[6]  := WGL_SAMPLES_ARB;
         iAttributes[7]  := 2;
         iAttributes[8]  := WGL_DOUBLE_BUFFER_ARB;
         iAttributes[9]  := 1;
         iAttributes[10] := WGL_COLOR_BITS_ARB;
         iAttributes[11] := 32;
         iAttributes[12] := WGL_DEPTH_BITS_ARB;
         iAttributes[13] := 24;
         iAttributes[14] := WGL_STENCIL_BITS_ARB;
         iAttributes[15] := 1;
         iAttributes[16] := 0;
         iAttributes[17] := 0;

         // устанавливаем MaxAASamples
         MaxAASamples := 0;
         valid := wglChoosePixelFormatARB(DC,@iattributes,@fattributes,1,@pixelFormat,@numFormats);
         if valid and (numFormats >= 1) then
         MaxAASamples := 2;

         iAttributes[7] := 4;
         valid := wglChoosePixelFormatARB(DC,@iattributes,@fattributes,1,@pixelFormat,@numFormats);
         if valid and (numFormats >= 1) then
         MaxAASamples := 4;

         iAttributes[7] := 8;
         valid := wglChoosePixelFormatARB(DC,@iattributes,@fattributes,1,@pixelFormat,@numFormats);
         if valid and (numFormats >= 1) then
         MaxAASamples := 8;

         iAttributes[7] := 16;
         valid := wglChoosePixelFormatARB(DC,@iattributes,@fattributes,1,@pixelFormat,@numFormats);
         if valid and (numFormats >= 1) then
         MaxAASamples := 16;

         AALev:= ReadInteger(_Data,_data_AALevel,_prop_AALevel);
         begin
            if MaxAASamples >= AALev then
            begin
               iAttributes[7] := AALev;
            end
            else
            iAttributes[7] := MaxAASamples;
            wglChoosePixelFormatARB(DC,@iattributes,@fattributes,1,@pixelFormat,@numFormats);
            wglpixelFormat := pixelFormat;
         end;
      end;
      DestroyWindow(hwnd);
      UnRegisterClass('Temp', 0);
      wglDeleteContext(hrc);//Удаляем контекст временного окна
   end;
   // После получения значения wglpixelFormat, создаём контекст для основного окна и делаем его текущим
   DC := GetDC(ReadInteger(_Data,_data_handle,0));
   FillChar(pfd, SizeOf(pfd), 0);
   with pfd do
   begin
      nSize        := SizeOf(TPIXELFORMATDESCRIPTOR);
      nVersion     := 1;
      dwFlags      := PFD_DRAW_TO_WINDOW or
      PFD_SUPPORT_OPENGL or
      PFD_DOUBLEBUFFER;
      iPixelType   := PFD_TYPE_RGBA;
      cColorBits   := 32;
      cDepthBits   := 24;
      iLayerType   := PFD_MAIN_PLANE;
      cStencilBits := _prop_StencilBits;
   end;
   begin
      if _prop_AASamples and (MaxAASamples > 0) then
      begin
         nPixelFormat := wglpixelFormat
      end
      else
      nPixelFormat := ChoosePixelFormat(DC, @pfd) // Выбираем Правильный формат пикселя
   end;
   SetPixelFormat(DC, nPixelFormat, @pfd);// Устанавливаем выбранный формат
   hrc := wglCreateContext(DC); // Создаем контекст
   wglMakeCurrent(DC, hrc); //Делаем его текущим

   glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   //glShadeModel (GL_FLAT);

   with TRGB(_prop_Color) do
   glClearColor (r/255, g/255, b/255, 0.0);

   glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, _prop_EnvironmentMode);
   //glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB_ARB, GL_TEXTURE0);
   //glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB_ARB, GL_SRC_COLOR);

   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

   //glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST );

   glClearStencil(_prop_ClearStencil);
   glStencilMask(_prop_StencilMask);

   if _prop_TwoSide then
   glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);

   glGetIntegerv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, @MaxAnisotropy);
   _hi_CreateEvent(_Data,@_event_onInit);
   Extensions:= glGetString(GL_EXTENSIONS);
   _hi_onEvent(_event_onExtensions,Extensions);
end;

procedure THIGL_Main._work_doViewPort;
var h:cardinal;
   r:TRect;
begin
   h := ReadInteger(_Data,_data_handle,0);
   GetClientRect(h,r);

   glViewport(0,0,r.Right - r.Left,r.Bottom - r.Top);
   _hi_OnEvent(_event_onViewPort);

   InvalidateRect(h, nil, False);
end;
//Получение точного системного времени
function GetTime: Integer;
var
   T : LARGE_INTEGER;
   F : LARGE_INTEGER;
begin
   QueryPerformanceFrequency(Int64(F));
   QueryPerformanceCounter(Int64(T));
   Result := Trunc(1000 * T.QuadPart / F.QuadPart);
end;

procedure THIGL_Main._work_doFlip;
begin
   SwapBuffers(DC);
   // Считаем кол-во кадров в секунду
   if fps_time <= GetTime then
   begin
      fps_time := GetTime + 1000;
      g_FPS    := fps_cur;
      fps_cur  := 0;
   end;
   inc(fps_cur);
end;

procedure THIGL_Main._work_doColor;
var c:TColor;
begin
   c := ToInteger(_Data);
   with TRGB(c) do
   glClearColor (r/255, g/255, b/255, 0.0);
end;

procedure THIGL_Main._work_doVSync;
var
   vs : Integer;
   SwapIntervalEXT : Integer;
begin
   if ReadAndCheck_WGL_EXT_swap_control then
   begin
      vs := ToInteger(_Data);
      if vs = 0 then
      wglSwapIntervalEXT(0);
      if vs = 1 then
      wglSwapIntervalEXT(1);
      SwapIntervalEXT := wglGetSwapIntervalEXT;
   end
   else
   exit;
   _hi_onEvent(_event_onVSync,SwapIntervalEXT);
end;

procedure THIGL_Main._var_GLHandle(var _Data:TData; Index:word);
begin
   dtInteger(_Data,integer(DC));
end;

procedure THIGL_Main._var_Fps(var _Data:TData; Index:word);
begin
   dtInteger(_Data,g_FPS);
end;

procedure THIGL_Main._var_MaxAnisotropy(var _Data:TData; Index:word);
begin
   dtInteger(_Data,MaxAnisotropy);
end;

procedure THIGL_Main._var_MaxAASamples(var _Data:TData; Index:word);
begin
   dtInteger(_Data,MaxAASamples);
end;

procedure THIGL_Main._var_MaxTextureSize(var _Data:TData; Index:word);
var
   i: integer;
begin
   glGetIntegerv(GL_MAX_TEXTURE_SIZE, @i);
   dtString(_Data,Int2Str(i));
end;

procedure THIGL_Main._var_Vendor(var _Data:TData; Index:word);
var
   Vendor: string;
begin
   Vendor:= glGetString(GL_VENDOR);
   dtString(_Data,Vendor);
end;

procedure THIGL_Main._var_Renderer(var _Data:TData; Index:word);
var
   Renderer: string;
begin
   Renderer:= glGetString(GL_RENDERER);
   dtString(_Data,Renderer);
end;

procedure THIGL_Main._var_VersionGL(var _Data:TData; Index:word);
var
   VersionGL: string;
begin
   VersionGL:= glGetString(GL_VERSION);
   dtString(_Data,VersionGL);
end;

end.