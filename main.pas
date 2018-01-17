unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ExtDlgs, Menus, pngimage, StdCtrls, IdGlobal, ShellAPI,
  ComCtrls, Math, Jpeg, IdGlobalProtocols, inifiles;

type
  TVideo = record
    IsVideo: Boolean;
    FullFileName: String;
    FileName: String;
    FileNamePrefix: String;

    FileSize: Integer;
    FileSizeFormat: String;

    FileIndex: Integer;
    FileStream: TFileStream;
    StreamHeaderSize : Integer;
    FrameHeaderSize : Integer;

    FrameIndex: Integer;

    FrameNumber: Integer;
    CodecName: String;
    PixFormat: String;
    BitRate: String;
    FrameRate: Real;
    FrameWidth: String;
    FrameHeight: String;
    FileDuration: String;

    FrameInfo: TStrings;

    FrameData: TBitMap;

    ReadDuration: Integer;
  end;

  TRGBTriple = packed record
    rgbtBlue: Byte;
    rgbtGreen: Byte;
    rgbtRed: Byte;
  end;

  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array[0..4095] of TRGBTriple;

  TForm1 = class(TForm)
    PopupMenu1: TPopupMenu;
    OpenFile11: TMenuItem;
    OpenFile21: TMenuItem;
    N1: TMenuItem;
    GoToFrame1: TMenuItem;
    N2: TMenuItem;
    SaveFrame1: TMenuItem;
    N3: TMenuItem;
    Exit1: TMenuItem;
    N4: TMenuItem;
    ShowInformation1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Timer1: TTimer;
    SavePictureDialog1: TSavePictureDialog;
    SaveFrame21: TMenuItem;
    SaveFrm1Frm21: TMenuItem;
    N5: TMenuItem;
    Frame21: TMenuItem;
    Frame22: TMenuItem;
    Frame11: TMenuItem;
    Frame12: TMenuItem;
    ShowFrameInfo1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure OpenFile11Click(Sender: TObject);
    procedure GoToFrame1Click(Sender: TObject);
    procedure SaveFrame1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ShowInformation1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Frame21Click(Sender: TObject);
    procedure Frame12Click(Sender: TObject);
  private
    { Private declarations }
    extension : String;
    outfolder: String;
    scale_x : real;
    split1 : Integer;
    picture_number : Integer;
    mouse_down : Integer;

    show : TBitmap;
    show_rect: TRect;
    show_w: Integer;
    show_h: Integer;

    video : array[1..2] of TVideo;
    PrevThreadHandle: array[1..2] of THandle;

    log_file: TStrings;

    procedure VideoInit;
    procedure VideoSetParameters(id : integer; filename: String);

    function psnr(bmp1, bmp2: TBitMap): string;
    procedure ShowInformation;
    procedure InputFiles(Files: Tstrings);
    function OpenPicture(input_filename: String; id: Integer): Boolean;
    function FileReady(filename:String; filesize: int64): Boolean;
    function CallFFmpegDecode(id, fid:Integer; output_filename: String): THandle;
    function FindAVIHeader(fs : TFileStream; filesize: integer): integer;
    function LoadDBI(id, Width, Height : Integer; Pos: int64): Boolean;
    function LoadPicture(inx1, inx2, reset: integer): Boolean;
    procedure ShowPicture;
    procedure ResetWindow(VideoWidth, VideoHeight, ToSource: Integer);
    procedure ResetForm(input: Integer);

    function DeleteDirectory(NowPath: string): Boolean;
    procedure CheckResult(b: Boolean);
    function RunDOS(const CommandLine: string; timeout: DWORD): TStrings;
    procedure writelog(handle: Integer; command: string);
 protected
    procedure WMDROPFILES(var Msg : TMessage); message WM_DROPFILES;

 public
    { Public declarations }
    ChangeWindowMessageFilter:function(msg: UINT; dwFlag: DWORD): BOOL; stdcall;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
procedure TForm1.WMDROPFILES(var Msg: TMessage);
var
  n : Integer;
  Buffer: Array[0..255] of Char;
  Files: Tstrings;
begin
  Files := TStringList.Create;
  n := DragQueryFile(Msg.wParam, $FFFFFFFF, Buffer, 255);
  for n := 0 to n - 1 do
  begin
     DragQueryFile(Msg.wParam, n, Buffer, 255);
     Files.Add(Buffer);
  end;
  DragFinish(Msg.wParam);
  VideoInit;
  InputFiles(Files);
  Files.Free;
end;

function RunFFMPEG(param: String): Integer; stdcall;
begin
  WinExec(PAnsiChar(AnsiString(param)), SW_HIDE);
  Result := 0;
end;

procedure TForm1.writelog(handle: Integer; command: string);
var
  currentTime: TSystemTime;
  datetime: string;
begin
  if log_file = nil then
     log_file := TStringList.Create;

  GetSystemTime(currentTime);
  datetime:= Format('%4d/%d/%d %2d:%2d:%2d:%3d', [currentTime.wYear, currentTime.wMonth, currentTime.wDay,
                                                  currentTime.wHour, currentTime.wMinute, currentTime.wSecond,
                                                  currentTime.wMilliseconds]);
  log_file.Add(datetime + ' : P' + IntToStr(handle) + '  ' + command);
  log_file.SaveToFile('e:\log.file');
end;

procedure TForm1.CheckResult(b: Boolean);
begin
  if not b then
    raise Exception.Create(SysErrorMessage(GetLastError));
end;

function TForm1.RunDOS(const CommandLine: string; timeout: DWORD): TStrings;
var
  HRead, HWrite: THandle;
  StartInfo: TStartupInfo;
  ProceInfo: TProcessInformation;
  b: Boolean;
  sa: TSecurityAttributes;
  inS: THandleStream;
begin
  Result := TStringList.Create;
  Result.Text := '';

  FillChar(sa, sizeof(sa), 0);
  // Allow set inheritance, otherwise maybe no output on winodew2000
  sa.nLength := sizeof(sa);
  sa.bInheritHandle := True;
  sa.lpSecurityDescriptor := nil;
  b := CreatePipe(HRead, HWrite, @sa, 0);
  CheckResult(b);

  FillChar(StartInfo, SizeOf(StartInfo), 0);
  StartInfo.cb := SizeOf(StartInfo);
  StartInfo.wShowWindow := SW_HIDE;
  StartInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  StartInfo.hStdError := HWrite;
  StartInfo.hStdInput := GetStdHandle(STD_INPUT_HANDLE); //HRead;
  StartInfo.hStdOutput := HWrite;

  b := CreateProcess(nil,                //lpApplicationName: PChar
                     PChar(WideString(CommandLine)), //lpCommandLine: PChar
                     nil,                //lpProcessAttributes: PSecurityAttributes
                     nil,                //lpThreadAttributes: PSecurityAttributes
                     True,               //bInheritHandles: BOOL
                     CREATE_NEW_CONSOLE,
                     nil,
                     nil,
                     StartInfo,
                     ProceInfo);

  writelog(ProceInfo.hProcess, 'RunDOS: ' + CommandLine);

  CheckResult(b);
  if WAIT_TIMEOUT = WaitForSingleObject(ProceInfo.hProcess, timeout) then
  begin
    TerminateThread(ProceInfo.hProcess, 0);
    writelog(ProceInfo.hProcess, 'Timeout ' + IntToStr(timeout));
  end
  else
    writelog(ProceInfo.hProcess, 'Terminate');

  inS := THandleStream.Create(HRead);
  if inS.Size > 0 then
    Result.LoadFromStream(inS);
  inS.Free;

  CloseHandle(HRead);
  CloseHandle(HWrite);
end;

// Remove whole Directory
function TForm1.DeleteDirectory(NowPath: string): Boolean;
var
  search: TSearchRec;
  ret: integer;
  key: string;
begin
  if NowPath[Length(NowPath)] <> '\' then
    NowPath := NowPath + '\';
  key := NowPath + '*.*';
  ret := findFirst(key, faanyfile, search);
  while ret = 0 do
  begin
    if ((search.Attr and fadirectory) = fadirectory) then
    begin
      if (search.Name <> '.') and (search.name <> '..') then
        DeleteDirectory(NowPath + search.name);
    end
    else
    begin
      if ((search.Attr and fadirectory) <> fadirectory) then
      begin
        deletefile(NowPath + search.name);
      end;
    end;
    ret := FindNext(search);
  end;
  findClose(search);
  //removedir(NowPath);
  result := True;
end;

procedure TForm1.VideoInit;
var
 id : integer;
begin
  Timer1.Enabled := False;
  Form1.Canvas.FillRect(Form1.ClientRect);
  picture_number := 0;
  mouse_down := 0;

  show_rect := Rect(0, 0, 0, 0);
  show_w := 0;
  show_h := 0;

  for id:=1 to 2 do
  begin
    video[id].IsVideo := False;
    video[id].FullFileName := '';
    video[id].FileName := '';
    video[id].FileNamePrefix := '';
    video[id].FileSize := 0;
    video[id].FileSizeFormat := '';
    video[id].FrameIndex := 0;
    video[id].FrameNumber := 0;
    video[id].FrameRate := 0;
    if video[id].FrameData <> nil then
      video[id].FrameData.free;
    video[id].FrameData := TBitmap.create;
    video[id].ReadDuration := 2;
    video[id].FileIndex := -1;
    video[id].FileStream := nil;
    video[id].StreamHeaderSize := 0;
    video[id].FrameHeaderSize := 0;
  end;
end;

function FormatFileSize(nSize: integer): String;
begin
  if nSize > 1073741824 then
    Result := FormatFloat('###,##0.00G', nSize / 1073741824)
  else if nSize > 1048576 then
    Result := FormatFloat('###,##0.00M', nSize /1048576)
  else if nSize > 1024 then
    Result := FormatFloat('###,##00K', nSize / 1024)
  else
    Result := FormatFloat('###,#0B', nSize);
  if Length(Result) > 2 then
    if Result[1] = '0' then
      Delete(Result, 1, 1);
end;

procedure TForm1.VideoSetParameters(id : integer; filename: String);
var
  cmd, tmp: String;
  output : TStrings;
  d, w: integer;
begin
  video[id].FullFileName := filename;
  if video[id].FileName = '' then
    video[id].FileName := ExtractFileName(filename);
  video[id].FileNamePrefix := outfolder + ChangeFileExt(video[id].FileName, '') + '_' + IntToStr(id) + '_';
  video[id].FileSize := FileSizeByName(filename);
  video[id].FileSizeFormat := FormatFileSize(video[id].FileSize);
  video[id].FrameIndex := 0;

  if (Pos('.png', filename) > 0) OR (Pos('.jpg', filename) > 0) OR (Pos('.bmp', filename) > 0) then
  begin
    video[id].FrameNumber := 1;
    video[id].FrameRate := 25;
    video[id].IsVideo := False;
  end
  else
  begin
    video[id].IsVideo := True;
    video[id].FrameNumber := 0;
  end;

  Form1.Cursor := crHourGlass;
  caption := 'ffprobe stream';
  cmd := 'ffprobe -i ' + filename + ' -select_streams v -show_entries stream=codec_name,pix_fmt,nb_frames,width,height,r_frame_rate,bit_rate,duration';
  output := RunDOS(cmd, INFINITE);

  video[id].CodecName := output.Values['codec_name'];
  video[id].PixFormat := output.Values['pix_fmt'];
  video[id].FrameWidth := output.Values['width'];
  video[id].FrameHeight := output.Values['height'];
  video[id].FileDuration := output.Values['duration'];

  show.Width := StrToInt(video[id].FrameWidth);
  show.Height := StrToInt(video[id].FrameHeight);

  tmp := output.Values['r_frame_rate'];
  if tmp <> 'N/A' then
  begin
    d := Pos('/', tmp);
    try
      if d > 0 then
      begin
        w := length(tmp);
        video[id].FrameRate := StrToInt(Copy(tmp, 1, d-1)) * 1.0 / StrToInt(Copy(tmp, d+1, w-d));
        video[id].FrameRate := RoundTo(video[id].FrameRate, -2);
      end;
    except
      video[id].FrameRate := -1;
    end;
  end;

  tmp := output.Values['bit_rate'];
  if tmp <> 'N/A' then
    try
      video[id].BitRate := FormatFileSize(StrToInt(tmp));
    except
      video[id].BitRate := 'N/A';
  end;

  video[id].FrameNumber := -1;
  tmp := output.Values['nb_frames'];
  if tmp <>  'N/A' then
  begin
    try
      video[id].FrameNumber := StrToInt(tmp);
    except
    end;
  end;
  if video[id].FrameNumber = -1 then
  begin
    try
      if (video[id].FileDuration <> 'N/A') AND (video[id].FrameRate > 0) then
      begin
        video[id].FrameNumber := trunc(StrToFloat(video[id].FileDuration) * video[id].FrameRate);
      end;
    except
      video[id].FrameNumber := 1;
    end;
  end;
  output.Free;

  if ShowFrameInfo1.Checked then
  begin
    caption := 'ffprobe frames';
    cmd := 'ffprobe -i ' + filename + ' -select_streams v -show_entries frame=pkt_size,pict_type -of csv';
    // FIXME, why this ffprobe cannot terminate ??, need to add 3000 timeout.
    video[id].FrameInfo := RunDOS(cmd, 3000);
    Form1.Cursor := crDefault;
    if video[id].FrameNumber <> video[id].FrameInfo.Count then
      video[id].FrameNumber := video[id].FrameInfo.Count;
  end
  else
    video[id].FrameInfo := nil;
end;

// --------------------------------
function TForm1.psnr(bmp1, bmp2: TBitMap): string;
var
  x, y : Integer;
  y1, y2: Integer;
  mse : Real;
  r, g, b : Real;
  Pixels1: PRGBTripleArray;
  Pixels2: PRGBTripleArray;
begin
  r := 0.257;
  g := 0.504;
  b := 0.098;

  if (bmp1.Width = bmp2.Width) AND (bmp1.Height = bmp2.Height) then
  begin
    mse := 0;
    for y := 0 to bmp1.Height - 1 do
    begin
      Pixels1 := bmp1.ScanLine[y];
      Pixels2 := bmp2.ScanLine[y];
      for x := 0 to bmp1.Width - 1 do
      begin
        y1 := Round(r*Pixels1[x].rgbtRed + g*Pixels1[x].rgbtGreen + b*Pixels1[x].rgbtBlue + 0.5);
        y2 := Round(r*Pixels2[x].rgbtRed + g*Pixels2[x].rgbtGreen + b*Pixels2[x].rgbtBlue + 0.5);
        mse := mse + (y1-y2)*(y1-y2);
      end;
    end;
    mse := mse / (bmp1.Width * bmp1.Height);

    if mse > 0.0 then
    begin
      mse := 10*log10(255*255/mse);
      Result := 'PSNR Y: ' + FloatToStr(RoundTo(mse, -2))
    end
    else
      Result := 'Same';
  end
  else
    Result := 'Image Size not same';
end;

procedure TForm1.ShowInformation;
var
  id : Integer;
  info : string;
  str : TStrings;
begin
   info := '';
   for id:= 1 to picture_number do
   begin
     if id = 2 then
       info := info + ' || ';
     info := info + IntToStr(video[id].FrameIndex) + ' / ' + IntToStr(video[id].FrameNumber);
     info := info + ' , ' + IntToStr(video[id].FileIndex);
     info := info + ' , ' + video[id].FileName;
     info := info + ' , ' + video[id].FrameWidth + 'x' + video[id].FrameHeight;
     if video[id].IsVideo then
     begin
       info := info + '@' + FloatToStr(video[id].FrameRate) + 'fps';
       info := info + '@' + video[id].BitRate + 'bps';
       if video[id].FrameInfo <> nil then
       begin
         str := TStringList.Create;
         str.CommaText := video[id].FrameInfo[video[id].FrameIndex-1];
         str.Delimiter := ',';
         info := info + ' (' + str[2] + ') ' + str[1];
         str.Free;
       end;
     end;
     info := info + ' , ' + video[id].FileSizeFormat;
   end;

   if (ShowInformation1.Checked) AND (picture_number > 1) AND (Timer1.Enabled = False) Then
     info := info + ' || ' + psnr(video[1].FrameData, video[2].FrameData);
  caption := info;
end;

procedure TForm1.ShowPicture;
var
  pos : Integer;
begin
  if (show_w <= 0) OR (show_h <= 0) then
    ResetWindow(video[1].FrameData.Width, video[1].FrameData.Height, 0);

  if picture_number = 1 then
  begin
    Form1.Canvas.StretchDraw(show_rect, video[1].FrameData);
  end
  else if picture_number = 2 then
  begin

    scale_x := video[1].FrameData.Width / show_w;
    pos := Round(scale_x * (Split1 - show_rect.Left));

    show.Canvas.CopyRect(Rect(0, 0, pos, video[1].FrameData.Height),
                         video[1].FrameData.Canvas,
                         Rect(0, 0, pos, video[1].FrameData.Height));
    show.Canvas.CopyRect(Rect(pos, 0, video[2].FrameData.Width, video[2].FrameData.Height),
                         video[2].FrameData.Canvas,
                         Rect(pos, 0, video[2].FrameData.Width, video[2].FrameData.Height));
    Form1.Canvas.StretchDraw(show_rect, show);
    if (split1 > show_rect.Left) and (split1 < show_rect.Right) then
    begin
      Form1.Canvas.MoveTo(split1, show_rect.Top);
      Form1.Canvas.LineTo(split1, show_rect.Bottom - 1);
    end;
  end;
end;

procedure TForm1.ResetWindow(VideoWidth, VideoHeight, ToSource: Integer);
var
  old_w : Integer;
  sx, sy, ex, ey, nWidth, nHeight: Integer;
  alf1, alf2 : Real;
begin
  if VideoWidth*VideoHeight <= 0 then
    exit;

  old_w := show_w;

  if (Form1.ClientWidth >= VideoWidth) AND (Form1.ClientHeight >= VideoHeight) then
  begin
    nWidth := VideoWidth;
    nHeight := VideoHeight;
  end
  else
  begin
    nWidth := Form1.ClientWidth;
    nHeight := Form1.ClientHeight;
    alf1 := VideoWidth / Form1.ClientWidth;
    alf2 := VideoHeight / Form1.ClientHeight;
    if (VideoWidth * Form1.ClientHeight <= VideoHeight * Form1.ClientWidth) then
      nWidth := round(VideoWidth * Form1.ClientHeight/ VideoHeight)
    else
      nHeight := round(VideoHeight * Form1.ClientWidth/ VideoWidth);
  end;

  sx := (Form1.ClientWidth - nWidth) div 2;
  if sx < 0 then
    sx := 0;
  ex := sx + nWidth;
  if (ToSource = 0) AND (ex > Form1.ClientWidth) then
    ex := Form1.ClientWidth;

  sy := (Form1.ClientHeight - nHeight) div 2;
  if sy < 0 then
    sy := 0;
  ey := sy + nHeight;
  if (ToSource = 0) AND (ey > Form1.ClientHeight) then
    ey := Form1.ClientHeight;

  show_rect := Rect(sx, sy, ex, ey);
  show_w := ex - sx;
  show_h := ey - sy;

  if (old_w > 0) AND (old_w <> show_w) then
    Split1 := Round(1.0 * Split1 * show_w / old_w)
  else
    Split1 := Form1.ClientWidth div 2;
end;

procedure TForm1.ResetForm(input: Integer);
var
  changed : Boolean;
begin
  changed := False;
  if (input = 0) AND (Form1.Left <= 0) then       // nomormal
  begin
    Form1.ClientWidth := 664;
    Form1.ClientHeight := 480;
    Form1.Left := (Screen.Width - Form1.Width) div 2;
    Form1.Top := (Screen.Height - Form1.Height) div 2;
    Form1.Canvas.FillRect(Form1.ClientRect);
    changed := True;
  end
  else if (input > 0) AND (Form1.Left > 0) then  // max
  begin
    Form1.Width := Screen.Width;
    Form1.Height := Screen.Height;
    Form1.Left := 0;
    Form1.Top := 0;
    Form1.Canvas.FillRect(Form1.ClientRect);
    changed := True;
  end;

  if changed AND (picture_number > 0) then
    if input = 2 then
      ResetWindow(video[1].FrameData.Width, video[1].FrameData.Height, 1)
    else
      ResetWindow(video[1].FrameData.Width, video[1].FrameData.Height, 0);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  ini_filename, old_outfolder : String;
  ini_file: TInifile;
begin
  outfolder := 'E:\vct_temp_____output\';
  //extension := '.bmp';
  extension := '.png';
  ini_filename := ExtractFilePath(paramstr(0)) + 'setting.ini';
  if FileExists(ini_filename) then
  begin
    ini_file := TInifile.Create(ini_filename);
    outfolder := ini_file.ReadString('setting', 'outfolder', outfolder);
    extension := ini_file.ReadString('setting', 'extension', extension);
    ini_file.Free;
  end;

  old_outfolder := outfolder;
  while not DirectoryExists(outfolder) do
  begin
    if not CreateDir(outfolder) then
      outfolder := InputBox('Input Application Output Folder, this folder must be empty',
                            'Create output folder ' + outfolder + ' failed!', outfolder);
  end;
  if old_outfolder <> outfolder then
  begin
    ini_file := TInifile.Create(ini_filename);
    ini_file.WriteString('setting', 'outfolder', outfolder);
    ini_file.WriteString('setting', 'extension', extension);
    ini_file.Free;
  end;

  if DirectoryExists(outfolder) then
    DeleteDirectory(outfolder);

  Form1.DoubleBuffered := True;
  split1 := -1;
  mouse_down := 0;
  Form1.Canvas.Pen.Width := 2;
  Form1.Canvas.Pen.Mode  := pmWhite;
  if show = nil then
    show := Tbitmap.Create;
  VideoInit;
  log_file := nil;
  PrevThreadHandle[1] := 0;
  PrevThreadHandle[2] := 0;

  DragAcceptFiles(Handle, True);
  ResetForm(0);
end;

function TForm1.FileReady(filename:String; filesize: int64): Boolean;
begin
  Result := False;
  if FileExists(filename) then
  begin
    if FileSizeByName(filename) >= filesize  then
       Result := True;
  end;
end;

function TForm1.FindAVIHeader(fs : TFileStream; filesize: integer): integer;
var
  str, list_type : string;
  list_len : integer;
  buf : array [0..3] of byte;
begin
  Result := 0;
  if (fs = nil) OR (fs.size < filesize)  then
    exit;

  fs.ReadBuffer(buf, 4);
  list_type := char(buf[0]) + char(buf[1]) + char(buf[2]) + char(buf[3]);
  if list_type <> 'RIFF' then
    exit;

  fs.Position := 12;
  while fs.Position < fs.Size do
  begin
    fs.ReadBuffer(buf, 4);
    list_type := char(buf[0]) + char(buf[1]) + char(buf[2]) + char(buf[3]);

    fs.ReadBuffer(buf, 4);
    list_len := (buf[3] shl 24) + (buf[2] shl 16) + (buf[1] shl 8) + buf[0];
    if list_len > fs.Size then
       break;

    if list_type = 'LIST' then
    begin
      fs.ReadBuffer(buf, 4);
      list_type := char(buf[0]) + char(buf[1]) + char(buf[2]) + char(buf[3]);
      if list_type = 'movi' then
      begin
        Result := fs.position;
        break;
      end;
      list_len := list_len - 4;
    end;
    fs.position := fs.position + list_len;
  end;
end;

function TForm1.CallFFmpegDecode(id, fid:Integer; output_filename: String): THandle;
var
  param : string;
  TheThread : Dword;
begin
  Result := 0;
  if extension = '.avi' then
  begin
    param := 'ffmpeg.exe -ss ' + IntToStr(fid*video[id].ReadDuration) +
             ' -i ' + video[id].FullFileName +
             ' -t ' + IntToStr(video[id].ReadDuration) +
             ' -an -pix_fmt bgr24 -c:v rawvideo -y ' + output_filename;
  end
  else
  begin
    param := 'ffmpeg.exe -ss ' + IntToStr(fid*video[id].ReadDuration) +
             ' -i ' + video[id].FullFileName +
             ' -t ' + IntToStr(video[id].ReadDuration) +
             ' -an -f rawvideo -pix_fmt bgr24 -y ' + output_filename;
  end;

  if False OR (fid = 0) AND (video[id].FileIndex < 0) then
  begin
    Form1.Cursor := crHourGlass;
    RunDos(param, INFINITE);
    Form1.Cursor := crDefault;
  end
  else
  begin
    try
      Result := createthread(nil, 0, @RunFFMPEG, PChar(param), 0, TheThread);
      writelog(Result, 'createthread: ' + param);
    except
      if Result <> 0 then
      begin
        closehandle(Result);
        writelog(Result, 'closehandle');
        //sleep(50);
      end;
    end;
  end;
end;

function TForm1.LoadDBI(id, Width, Height : Integer; Pos: int64): Boolean;
var
  y: Integer;
  scanLine: PChar;
  list_type : string;
  list_len, size : integer;
  buf : array [0..3] of byte;
begin
  if video[id].FrameData = nil then
    video[id].FrameData := TBitMap.Create;

  if (video[id].FrameData.Width <> Width) OR (video[id].FrameData.Height <> Height) then
  begin
    video[id].FrameData.Width := Width;
    video[id].FrameData.Height := Height;
    video[id].FrameData.PixelFormat := pf24bit;
  end;

  try
    if extension  = '.avi' then
    begin
      size := Height*Width*3;
      for y := -8 to 16 do
      begin
        video[id].FileStream.Position := video[id].StreamHeaderSize + pos + y;
        video[id].FileStream.ReadBuffer(buf, 4);
        list_len := (buf[3] shl 24) + (buf[2] shl 16) + (buf[1] shl 8) + buf[0];
        if list_len = size then
          break;
      end;
      if y>16 then
      begin
        Result := False;
        exit;
      end;
    end
    else
      video[id].FileStream.Position := pos;

    for y:=0 to Height-1 do
    begin
      scanLine := video[id].FrameData.ScanLine[y];
      video[id].FileStream.Read(scanLine[0], Width*3);
    end;
    Result := True;
  except
    Result := False;
  end;
end;

function TForm1.LoadPicture(inx1, inx2, reset: integer): Boolean;
var
   inx, fid, FrameRate : array[1..2] of Integer;
   FrameWidth, FrameHeight, FrameSize, frame_pos: Integer;
   pos : int64;
   filename : array[1..2] of string;
   next_filename : string;
   id: Integer;
   ThreadHandle: array[1..2] of THandle;
begin
  Result := False;
  inx[1] := inx1;
  inx[2] := inx2;
  for id:=1 to picture_number do
  begin
    ThreadHandle[id] := 0;
    if (inx[id] > 0) and
       (inx[id] < video[id].FrameNumber) and
       (inx[id] <> video[id].FrameIndex) then
    begin
      inx[id] := inx[id] - 1;
      FrameRate[id] := ceil(video[id].FrameRate) * video[id].ReadDuration;
      fid[id] := inx[id] div FrameRate[id];
      filename[id] := video[id].FileNamePrefix + 'ss' + IntToStr(fid[id]) + extension;
      if Not FileExists(filename[id]) then
        ThreadHandle[id] := CallFFmpegDecode(id, fid[id], filename[id])
      else
      begin
        frame_pos := (inx[id] - fid[id] * FrameRate[id]);
        if frame_pos = 5 then
        begin
          next_filename := video[id].FileNamePrefix + 'ss' + IntToStr(fid[id] + 1) + extension;
          if Not FileExists(next_filename) then
            ThreadHandle[id] := CallFFmpegDecode(id, fid[id] + 1, next_filename);
        end;
      end;
      Result := True;
    end;
  end;

  if Not Result then
     exit;

  // waiting
  {
  Form1.Cursor := crHourGlass;
  if (PrevThreadHandle[1] <> 0) then
  begin
    writelog(PrevThreadHandle[1], 'wait start... ');
    WaitForSingleObject(PrevThreadHandle[1], 5000);
    writelog(PrevThreadHandle[1], 'wait end... ');
  end;
  PrevThreadHandle[1] := ThreadHandle[1];

  if (picture_number > 1) then
  begin
    if (PrevThreadHandle[2] <> 0) then
    begin
      writelog(PrevThreadHandle[2], 'wait start... ');
      WaitForSingleObject(PrevThreadHandle[2], 5000);
      writelog(PrevThreadHandle[2], 'wait end... ');
    end;
    PrevThreadHandle[2] := ThreadHandle[2];
  end;
  Form1.Cursor := crDefault;
   }

  // load filestrean
  Result := True;
  for id:=1 to picture_number do
  begin
    FrameWidth := StrToInt(video[id].FrameWidth);
    FrameHeight := StrToInt(video[id].FrameHeight);
    FrameSize := FrameWidth * FrameHeight * 3 + video[id].FrameHeaderSize;
    if FileReady(filename[id], FrameSize) then
    begin
      if (video[id].FileStream <> nil) AND (fid[id] <> video[id].FileIndex) then
        video[id].FileStream.Free;
      if (video[id].FileStream = nil) OR (fid[id] <> video[id].FileIndex) then
      begin
        try
          video[id].FileStream := TFileStream.Create(filename[id], fmOpenRead + fmShareDenyNone);
          if extension = '.avi' then
          begin
            video[id].FrameHeaderSize := 8;
            video[id].StreamHeaderSize := FindAVIHeader(video[id].FileStream, FrameSize);
            video[id].StreamHeaderSize := video[id].StreamHeaderSize + video[id].FrameHeaderSize;
          end
        except
          video[id].FileStream := nil;
          Result := False;
          break;
        end;
      end;

      pos := (inx[id] - fid[id] * FrameRate[id]) * FrameSize;
      if LoadDBI(id, FrameWidth, FrameHeight, pos) then
      begin
        video[id].FileIndex := fid[id];
        video[id].FrameIndex := inx[id] + 1;
      end
      else
      begin
        Result := False;
        break;
      end;
    end
    else
    begin
      Result := False;
      break;
    end;
  end;
end;

function TForm1.OpenPicture(input_filename: String; id: Integer): Boolean;
var
  FileExt : String;
  filename, cmd: String;
  png : TPngImage;
  jpg : TJPEGImage;
begin
  filename := ChangeFileExt(ExtractFileName(input_filename), '');
  FileExt := ExtractFileExt(input_filename);
  VideoSetParameters(id, input_filename);
  if (Pos('.mp4', FileExt) > 0) OR (Pos('.h264', FileExt) > 0) OR
            (Pos('.264', FileExt) > 0) OR (Pos('.flv', FileExt) > 0) OR
            (Pos('.avi', FileExt) > 0) then
    begin
      if (Pos('.h264', FileExt) > 0) OR (Pos('.264', FileExt) > 0) then
      begin
        filename := outfolder + 'h264_' + IntToStr(id) + '.mp4';
        cmd := 'ffmpeg.exe -i ' + video[id].FullFileName + ' -vcodec copy -an -y ' + filename;
        RunDOS(cmd, INFINITE);
        video[id].FileName := ExtractFileName(video[id].FullFileName);
        VideoSetParameters(id, filename);
      end
      else if Pos('.flv', FileExt) > 0 then
      begin
        filename := outfolder + 'flv_' + IntToStr(id) + '.mp4';
        cmd := 'ffmpeg.exe -i ' + video[id].FullFileName + ' -vcodec copy -an -y ' + filename;
        RunDOS(cmd, INFINITE);
        video[id].FullFileName := filename;
      end;

      if (picture_number = 1) and (id = 1) then
        LoadPicture(1, video[2].FrameIndex, 1)
      else if (picture_number = 2) and (id = 2) then
        LoadPicture(1, 1, 1)
    end
    else if Pos('.png', FileExt) > 0 then
    begin
      png := TPngImage.Create;
      png.LoadFromFile(input_filename);
      video[id].FrameData.Assign(png);
      png.Free;
      video[id].FrameIndex := 1;
      video[id].FrameNumber := 1;
    end
    else if Pos('.jpg', FileExt) > 0 then
    begin
      jpg := TJPEGImage.Create;
      jpg.LoadFromFile(input_filename);
      video[id].FrameData.Assign(jpg);
      jpg.Free;
      video[id].FrameIndex := 1;
      video[id].FrameNumber := 1;
    end
    else if Pos('.bmp', FileExt) > 0 then
    begin
      video[id].FrameData.LoadFromFile(input_filename);
      video[id].FrameIndex := 1;
      video[id].FrameNumber := 1;
    end;

    if (picture_number = id) then
    begin
      ResetWindow(video[1].FrameData.Width, video[1].FrameData.Height, 0);
      OpenFile21.Enabled := True;
    end;

    Result := True;
    if (picture_number = 2) and (id = 2) then
    begin
      if (video[2].FrameData.Width <> video[1].FrameData.Width) OR (video[2].FrameData.Height <> video[1].FrameData.Height) then
      begin
        ShowMessage('Two video frame size are not same file 1 is ' + IntToStr(video[1].FrameData.Width) + 'x' + IntToStr(video[1].FrameData.Height) +
                                                    ', file 2 is ' + IntToStr(video[2].FrameData.Width) + 'x' + IntToStr(video[2].FrameData.Height));
        Result := False;
      end;
    end;
end;

procedure TForm1.InputFiles(Files: Tstrings);
var
  id : Integer;
begin
  if Files.Count <= 0 then
    exit;

  Caption := 'Waiting...';
  if Files.Count > 1 then
    picture_number := 2
  else
    picture_number := 1;

  id := 1;
  OpenPicture(Files[0], id);
  if Files.Count > 1 then
  begin
    id := 2;
    OpenPicture(Files[1], id);
  end;

  ShowInformation;
  split1 := Form1.ClientWidth div 2;
  ShowPicture;
end;

procedure TForm1.OpenFile11Click(Sender: TObject);
var
  id : Integer;
begin
  id := (Sender as TMenuItem).tag;
  if OpenDialog1.Execute then
  begin
    if Form1.WindowState <> wsMaximized then
      Form1.WindowState := wsMaximized;
    Caption := 'Waiting...';
    if OpenDialog1.Files.Count > 1 then
      picture_number := 2
    else
      picture_number := 1;

    if id = 1 then
    begin
      OpenPicture(OpenDialog1.Files[0], id);
      if OpenDialog1.Files.Count > 1 then
      begin
        id := 2;
        OpenPicture(OpenDialog1.Files[1], id);
      end;
    end
    else
      OpenPicture(OpenDialog1.FileName, id);
    ShowInformation;
    split1 := Form1.ClientWidth div 2;
    ShowPicture;
  end;
end;

procedure TForm1.GoToFrame1Click(Sender: TObject);
var
 input : string;
 Vinx, Vmax : Integer;
begin
  Vmax := video[1].FrameNumber;
  if video[2].FrameNumber > 1 then
    Vmax := min(video[1].FrameNumber, video[2].FrameNumber);

  input := InputBox('Input Frame index',
                    'Frame index range [1.. ' + IntToStr(Vmax) + ']',
                    IntToStr(video[1].FrameIndex));
  try
    Vinx := StrToInt(input);
  except
    Vinx := video[1].FrameIndex;
  end;
  if LoadPicture(Vinx, Vinx, 1) then
  begin
    ShowInformation;
    ShowPicture;
  end;
end;

procedure TForm1.SaveFrame1Click(Sender: TObject);
var
  id, x : Integer;
begin
  if SavePictureDialog1.Execute then
  begin
    id := (Sender as TMenuItem).Tag;
    if (id = 1) OR (id = 2) then
      video[id].FrameData.SaveToFile(SavePictureDialog1.FileName)
    else
    begin
      x := Round(Split1 * video[1].FrameData.Width / show_w);
      show.Canvas.Pen.Color := clWhite;
      show.Canvas.Pen.Width := 2;
      show.Canvas.MoveTo(x, 0);
      show.Canvas.LineTo(x, show.Height);
      show.SaveToFile(SavePictureDialog1.FileName);
    end;
  end;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  if not Timer1.Enabled then
  begin
    Form1.Canvas.FillRect(Form1.ClientRect);
    ShowPicture;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  i: Integer;
  files: Tstrings;
begin
  if (ParamCount > 0) and (picture_number = 0) then
  begin
    files := TstringList.Create;
    for i := 1 to ParamCount do
      files.Add(ParamStr(i));
    InputFiles(files);
    files.free;
  end;
end;

procedure TForm1.Frame12Click(Sender: TObject);
var
  opened : Boolean;
begin
  opened := False;
  if picture_number > 1 then
    opened := LoadPicture(video[1].FrameIndex + (Sender as TMenuItem).Tag, video[2].FrameIndex, 0);
  if opened then
  begin
    ShowInformation;
    ShowPicture;
  end;
end;

procedure TForm1.Frame21Click(Sender: TObject);
var
  opened : Boolean;
begin
  opened := False;
  if picture_number > 1 then
    opened := LoadPicture(video[1].FrameIndex, video[2].FrameIndex + (Sender as TMenuItem).Tag, 0);
  if opened then
  begin
    ShowInformation;
    ShowPicture;
  end;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (picture_number > 1) then
    mouse_down := 1;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mouse_down := 0;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  if not Timer1.Enabled then
    ShowPicture;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if (abs(x - split1) < 3) AND (video[2].FrameNumber > 0) then
    Form1.Cursor := crHSplit
  else if Form1.Cursor <> crDefault then
    Form1.Cursor := crDefault;

  if (mouse_down = 1) and (x <> split1) and (x >= show_rect.Left) and (x < show_rect.Right) and
                                            (y >= show_rect.Top) and (y < show_rect.Bottom) then
  begin
    split1 := x;
    ShowPicture;
  end;
end;

procedure TForm1.ShowInformation1Click(Sender: TObject);
begin
  ShowInformation1.Checked := not ShowInformation1.Checked;
  if ShowInformation1.Checked then
    ShowInformation;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  opened : Boolean;
begin
  opened := False;
  case Key of
    VK_LEFT:
    begin
      opened := LoadPicture(video[1].FrameIndex - 1, video[2].FrameIndex - 1, 0);
    end;
    VK_RIGHT:
    begin
      opened := LoadPicture(video[1].FrameIndex + 1, video[2].FrameIndex + 1, 0);
    end;
    VK_UP:
    begin
      opened := LoadPicture(1, 1, 1);
    end;
    VK_DOWN:
    begin
      if video[1].FrameNumber > 1 then
        Timer1.Enabled := not Timer1.Enabled;
    end;
    VK_SPACE:
    begin
      if video[1].FrameNumber > 1 then
        Timer1.Enabled := not Timer1.Enabled;
    end;
    VK_ESCAPE:
    begin
      video[1].FullFileName := '';
      video[2].FullFileName := '';
      picture_number := 0;
      Form1.WindowState := wsNormal;
      Form1.Width := 658;
      Form1.Height := 548;
      Form1.Left := (Screen.Width - Form1.Width ) div 2;
      Form1.Top := (Screen.Height - Form1.Height ) div 2;
    end;
  end;

  if Timer1.Enabled AND ((Key <> VK_DOWN) AND (Key <> VK_SPACE))then
  begin
    Timer1.Enabled := False;
    Timer1.Interval := 30;
  end;

  if opened then
  begin
    ShowInformation;
    ShowPicture;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  show.Free;
  if DirectoryExists(outfolder) then
    DeleteDirectory(outfolder);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if LoadPicture(video[1].FrameIndex + 1, video[2].FrameIndex + 1, 0) then
  begin
    if Timer1.Interval > 30 then
       Timer1.Interval := 30;
    ShowInformation;
    ShowPicture;
  end
  else
  begin
    Timer1.Interval := 1000;
    //Timer1.Enabled := False;
  end;
end;

procedure TForm1.FormDblClick(Sender: TObject);
begin
  if (Form1.Left > 0) OR (Form1.Top > 0) then
    ResetForm(1)
  else
    ResetForm(0);
  if picture_number > 0 then
    ShowPicture;
          {
  if False AND (video[1].FrameNumber > 0) AND (video[1].FrameData.Width > Form1.ClientWidth) then
  begin
    if show_w < video[1].FrameData.Width then
      show_ex := video[1].FrameData.Width
    else
      show_ex := Form1.ClientWidth;
    if show_h < video[1].FrameData.Height then
      show_ey := video[1].FrameData.Height
    else
      show_ey := Form1.ClientHeight;
    show_w := show_ex - show_sx;
    show_h := show_ey - show_sy;
    ShowPicture;
  end;
  }
end;

end.
