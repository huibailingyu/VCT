unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ExtDlgs, Menus, pngimage, StdCtrls, IdGlobal, ShellAPI,
  ComCtrls, Math, Jpeg, IdGlobalProtocols, inifiles;

type
  TLoadingThread = class(TThread)
  protected
    procedure Execute; override;
  end;

type
  TVideo = record
    IsVideo: Boolean;
    FullFileName: String;
    FileName: String;
    FileNamePrefix: String;

    FileSize: Integer;
    FileSizeFormat: String;

    FrameIndex: Integer;

    FrameNumber: Integer;
    CodecName: String;
    PixFormat: String;
    BitRate: String;
    FrameRate: Real;
    FrameWidth: String;
    FrameHeight: String;
    FileDuration: String;

    FrameType: TStrings;
    FrameSize: TStrings;

    FrameData: TBitMap;

    ReadDuration: Integer;
    ReadFrames: Integer;
    ReadFrameMax: Integer;
    ReadStartTime : Integer;
    ReadStartIndex: Integer;
  end;

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
  private
    { Private declarations }
    extension : String;
    outfolder: String;
    scale_x : real;
    split1 : Integer;
    picture_number : Integer;
    mouse_down : Integer;

    show : TBitmap;
    show_sx: Integer;
    show_sy: Integer;
    show_ex: Integer;
    show_ey: Integer;
    show_w: Integer;
    show_h: Integer;

    next_filename: array[1..2] of string;
    bmp_inx : Integer;
    bmp: array[1..2, 0..1] of TBitMap;
    png: array[1..2, 0..1] of TPngImage;
    video : array[1..2] of TVideo;

    procedure VideoInit;
    procedure VideoSetParameters(id : integer; filename: String);

    function CalculatePSNR: String;
    procedure ShowInformation;
    procedure InputFiles(Files: Tstrings);
    function OpenPicture(input_filename: String; id: Integer): Boolean;
    function LoadPicture(inx1, inx2: integer): Boolean;
    procedure ShowPicture;
    procedure ResetWindow(VideoWidth, VideoHeight, ToSource: Integer);
    procedure ResetForm(input: Integer);

    function DeleteDirectory(NowPath: string): Boolean;
    procedure CheckResult(b: Boolean);
    function RunDOS(const CommandLine: string): TStrings;

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
procedure LoadingCopyPicture;
var
  scale_x : Real;
  pos : Integer;
begin
  with Form1 do
  begin
    if extension = '.png' then
    begin
      png[1, 1 - bmp_inx].LoadFromFile(next_filename[1]);
      if picture_number = 3 then
        png[2, 1 - bmp_inx].LoadFromFile(next_filename[2]);
    end
    else
    begin
      bmp[1, 1 - bmp_inx].LoadFromFile(next_filename[1]);
      if picture_number = 3 then
        bmp[2, 1 - bmp_inx].LoadFromFile(next_filename[2]);
    end;

      if picture_number = 3 then
      begin
        scale_x := video[1].FrameData.Width / show_w;
        pos := Round(scale_x * (Split1 - show_sx));
        show.Canvas.CopyRect(Rect(0, 0, pos, video[1].FrameData.Height),
                             video[1].FrameData.Canvas,
                             Rect(0, 0, pos, video[1].FrameData.Height));
        show.Canvas.CopyRect(Rect(pos, 0, video[2].FrameData.Width, video[2].FrameData.Height),
                             video[2].FrameData.Canvas,
                             Rect(pos, 0, video[2].FrameData.Width, video[2].FrameData.Height));
      end
      else
      begin
        show.Assign(video[1].FrameData);
      end;
  end;
end;

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

procedure TForm1.CheckResult(b: Boolean);
begin
  if not b then
    raise Exception.Create(SysErrorMessage(GetLastError));
end;

function TForm1.RunDOS(const CommandLine: string): TStrings;
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
  //设置允许继承，否则在NT和2000下无法取得输出结果
  sa.nLength := sizeof(sa);
  sa.bInheritHandle := True;
  sa.lpSecurityDescriptor := nil;
  b := CreatePipe(HRead, HWrite, @sa, 0);
  CheckResult(b);

  FillChar(StartInfo, SizeOf(StartInfo), 0);
  StartInfo.cb := SizeOf(StartInfo);
  StartInfo.wShowWindow := SW_HIDE;
  //使用指定的句柄作为标准输入输出的文件句柄,使用指定的显示方式
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

  CheckResult(b);
  WaitForSingleObject(ProceInfo.hProcess, INFINITE);

  inS := THandleStream.Create(HRead);
  if inS.Size > 0 then
    Result.LoadFromStream(inS);
  inS.Free;

  CloseHandle(HRead);
  CloseHandle(HWrite);
end;

// 删除整个目录
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
  //removedir(NowPath); 如果需要删除文件夹则添加
  result := True;
end;

procedure TForm1.VideoInit;
var
 id : integer;
begin
  Timer1.Enabled := False;
  Form1.Canvas.FillRect(Form1.ClientRect);
  picture_number := 0;
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
    video[id].ReadDuration := 30;
    video[id].ReadFrames := 0;
    video[id].ReadFrameMax := 0;
    video[id].ReadStartTime := 0;
    video[id].ReadStartIndex := 1;
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
    video[id].ReadFrames := 1;
    video[id].FrameNumber := 1;
    video[id].FrameRate := 25;
    video[id].IsVideo := False;
  end
  else
  begin
    video[id].IsVideo := True;
    video[id].FrameNumber := 0;
  end;

  video[id].FrameSize := TStringList.Create;
  video[id].FrameType := TStringList.Create;

  cmd := 'ffprobe -i ' + filename + ' -select_streams v -show_entries stream=codec_name,pix_fmt,nb_frames,width,height,r_frame_rate,bit_rate,duration';
  output := RunDOS(cmd);

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

  video[id].ReadFrames := Ceil(video[id].FrameRate) * video[id].ReadDuration;

  {
  //'ffprobe -i f3_h264_nvenc_s0t-1_1M.mp4 -select_streams v -show_entries frame=pkt_size,pict_type'
  cmd := 'ffprobe -i ' + filename + ' -select_streams v -show_entries frame=pkt_size,pict_type -of csv';
  output := RunDOS(cmd);
  }
end;

// --------------------------------
function TForm1.CalculatePSNR: String;
var
  cmd, str1, str2 : string;
  output : TStrings;
  i, inx, inx1 : Integer;
begin
  str1 := video[1].FileNamePrefix + IntToStr(video[1].FrameIndex) + extension;
  str2 := video[2].FileNamePrefix + IntToStr(video[2].FrameIndex) + extension;
  if FileExists(str1) AND FileExists(str2) then
  begin
    cmd := 'ffmpeg -i ' + str1 + ' -i ' + str2 + ' -filter_complex psnr -f null -';
    output := RunDOS(cmd);
    for i:=output.Count-1 downto 1 do
    begin
      if Pos('average:', output.Strings[i]) > 0 then
      begin
        inx := Pos('PSNR', output.Strings[i]);
        if inx <= 0 then
          inx := 1;
        inx1 := Pos('min:', output.Strings[i]);
        if inx1 < inx then
          inx1 := length(output.Strings[i]);
        Result := Copy(output.Strings[i], inx, inx1 - inx - 1);
        break;
      end;
    end;
  end
  else
    Result := '';
end;

procedure TForm1.ShowInformation;
var
  id : Integer;
  info : string;
begin
   info := '';
   for id:= 1 to 2 do
   begin
     if (picture_number AND id) = 0 then
       continue;
     if id = 2 then
       info := info + ' || ';
     info := info + IntToStr(video[id].FrameIndex) + ' / ' + IntToStr(video[id].FrameNumber);
     info := info + ' , ' + video[id].FileName;
     info := info + ' , ' + video[id].FrameWidth + 'x' + video[id].FrameHeight;
     if video[id].IsVideo then
     begin
       info := info + '@' + FloatToStr(video[id].FrameRate) + 'fps';
       info := info + '@' + video[id].BitRate + 'bps';
     end;
     info := info + ' , ' + video[id].FileSizeFormat;
   end;

   if (ShowInformation1.Checked) AND (picture_number > 1) then
     info := info + ' || ' + CalculatePSNR;
  caption := info;
end;

procedure TForm1.ShowPicture;
var
  pos : Integer;
begin
  if (show_w <= 0) OR (show_h <= 0) then
    ResetWindow(video[1].FrameData.Width, video[1].FrameData.Height, 0);

  //Form1.Canvas.StretchDraw(Rect(show_sx, show_sy, show_ex, show_ey), show);
  if picture_number = 1 then
  begin
    Form1.Canvas.StretchDraw(Rect(show_sx, show_sy, show_ex, show_ey), video[1].FrameData);
  end
  else if picture_number = 3 then
  begin

    scale_x := video[1].FrameData.Width / show_w;
    pos := Round(scale_x * (Split1 - show_sx));

    show.Canvas.CopyRect(Rect(0, 0, pos, video[1].FrameData.Height),
                         video[1].FrameData.Canvas,
                         Rect(0, 0, pos, video[1].FrameData.Height));
    show.Canvas.CopyRect(Rect(pos, 0, video[2].FrameData.Width, video[2].FrameData.Height),
                         video[2].FrameData.Canvas,
                         Rect(pos, 0, video[2].FrameData.Width, video[2].FrameData.Height));
    Form1.Canvas.StretchDraw(Rect(show_sx, show_sy, show_ex, show_ey), show);
    if (split1 >= show_sx) and (split1 < show_ex) then
    begin
      Form1.Canvas.MoveTo(split1, show_sy);
      Form1.Canvas.LineTo(split1, show_ey);
    end;
  end;
end;

procedure TForm1.ResetWindow(VideoWidth, VideoHeight, ToSource: Integer);
var
  old_w : Integer;
begin
  old_w := show_w;
  show_sx := (Form1.ClientWidth - VideoWidth) div 2;
  if show_sx < 0 then
    show_sx := 0;
  show_ex := show_sx + video[1].FrameData.Width;
  if (ToSource = 0) AND (show_ex > Form1.ClientWidth) then
    show_ex := Form1.ClientWidth;

  show_sy := (Form1.ClientHeight - VideoHeight) div 2;
  if show_sy < 0 then
    show_sy := 0;
  show_ey := show_sy + video[1].FrameData.Height;
  if (ToSource = 0) AND (show_ey > Form1.ClientHeight) then
    show_ey := Form1.ClientHeight;

  show_w := show_ex - show_sx;
  show_h := show_ey - show_sy;

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

  bmp_inx := 0;
  bmp[1, 0] := TBitMap.Create;
  bmp[1, 1] := TBitMap.Create;
  bmp[2, 0] := TBitMap.Create;
  bmp[2, 1] := TBitMap.Create;
  png[1, 0] := TPngImage.Create;
  png[1, 1] := TPngImage.Create;
  png[2, 0] := TPngImage.Create;
  png[2, 1] := TPngImage.Create;

  DragAcceptFiles(Handle, True);
  ResetForm(0);
end;

procedure TLoadingThread.Execute;
begin
  // release thread after processing
  FreeOnTerminate := True;
  //LoadingCopyPicture;
  with Form1 do
  begin
    if extension = '.png' then
    begin
      png[1, 1 - bmp_inx].LoadFromFile(next_filename[1]);
      if picture_number = 3 then
        png[2, 1 - bmp_inx].LoadFromFile(next_filename[2]);
    end
    else
    begin
      bmp[1, 1 - bmp_inx].LoadFromFile(next_filename[1]);
      if picture_number = 3 then
        bmp[2, 1 - bmp_inx].LoadFromFile(next_filename[2]);
    end;
  end;
end;

function TForm1.LoadPicture(inx1, inx2: integer): Boolean;
var
  filename, param : String;
  id : Integer;
  inx : array[1..2] of Integer;
  counter : Integer;
  ThreadHandle: THandle;
  TheThread : Dword;
  label
  need_encode;
begin
  Result := False;
  inx[1] := inx1;
  inx[2] := inx2;
  for id:=1 to 2 do
  begin
    if video[id].FrameNumber <=1 then
      continue;
    if inx[id] <> video[id].FrameIndex then
    begin
      if (inx[id] > 0) and (inx[id] <= video[id].FrameNumber) then
      begin
        video[id].FrameIndex := inx[id];
need_encode:
        while video[id].FrameIndex >= video[id].ReadFrameMax do
        begin
          param := 'ffmpeg.exe -ss ' + IntToStr(video[id].ReadStartTime) +
                   ' -i ' + video[id].FullFileName +
                   ' -t ' + IntToStr(video[id].ReadDuration) +
                   ' -f image2 -start_number ' + IntToStr(video[id].ReadStartIndex) +
                   ' -y ' + video[id].FileNamePrefix + '%d' + extension;
          Caption := 'Waiting...' + param;

          try
            ThreadHandle := createthread(nil, 0, @RunFFMPEG, PChar(param), 0, TheThread);
          finally
            if ThreadHandle <> 0 then
              closehandle(ThreadHandle);
          end;

          video[id].ReadStartTime := video[id].ReadStartTime + video[id].ReadDuration;
          video[id].ReadStartIndex := video[id].ReadStartIndex + video[id].ReadFrames;
          video[id].ReadFrameMax := video[id].ReadFrameMax + video[id].ReadFrames;
          if video[id].ReadFrameMax > video[id].FrameNumber then
             video[id].ReadFrameMax := video[id].FrameNumber;
        end;

        filename := video[id].FileNamePrefix + IntToStr(video[id].FrameIndex) + extension;
        counter := 0;
        while (counter < 20) AND (not FileExists(filename)) do
        begin
          sleep(100);
          counter := counter + 1;
        end;

        if FileExists(filename) then
        begin
          try
            if Pos('.png', extension) > 0 then
            begin
              if video[id].FrameIndex = 1 then
                 png[id, bmp_inx].LoadFromFile(filename);
              video[id].FrameData.Assign(png[id, bmp_inx]);
              Form1.next_filename[id] := video[id].FileNamePrefix + IntToStr(video[id].FrameIndex + 1) + extension;
              if FileExists(filename) then
              begin
                //TLoadingThread.Create(False);
                png[id, 1-bmp_inx].LoadFromFile(Form1.next_filename[id]);
              end;
              bmp_inx := 1- bmp_inx;
            end
            else
            begin
              if video[id].FrameIndex = 1 then
                 bmp[id, bmp_inx].LoadFromFile(filename);
              video[id].FrameData.Assign(bmp[id, bmp_inx]);
              Form1.next_filename[id] := video[id].FileNamePrefix + IntToStr(video[id].FrameIndex + 1) + extension;
              if FileExists(Form1.next_filename[id]) then
              begin
                if ((picture_number = 1) and (id = 1)) OR ((picture_number = 3) and (id = 2)) then
                  TLoadingThread.Create(False);
              end;
              bmp_inx := 1- bmp_inx;
            end;
            Result := True;
          except
            Result := False;
          end;
        end
        else  // not exist
        begin
          if (video[id].FrameIndex < video[id].ReadFrameMax) AND
             (video[id].ReadFrameMax < video[id].FrameNumber) then
          begin
            video[id].ReadFrameMax := video[id].FrameIndex;
            video[id].ReadStartIndex := video[id].FrameIndex;
            goto need_encode;
          end
        end;
      end;
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
        cmd := 'ffmpeg -i ' + video[id].FullFileName + ' -vcodec copy -an -y ' + filename;
        RunDOS(cmd);
        video[id].FileName := ExtractFileName(video[id].FullFileName);
        VideoSetParameters(id, filename);
      end
      else if Pos('.flv', FileExt) > 0 then
      begin
        filename := outfolder + 'flv_' + IntToStr(id) + '.mp4';
        cmd := 'ffmpeg -i ' + video[id].FullFileName + ' -vcodec copy -an -y ' + filename;
        RunDOS(cmd);
        video[id].FullFileName := filename;
      end;

      if id = 1 then
      begin
        LoadPicture(1, video[2].FrameIndex);
      end
      else if id = 2 then
        LoadPicture(video[1].FrameIndex, video[1].FrameIndex)
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

    if id = 1 then
    begin
      ResetWindow(video[1].FrameData.Width, video[1].FrameData.Height, 0);
      OpenFile21.Enabled := True;
    end;

    Result := True;
    if id = 2 then
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
  id := 1;
  picture_number := picture_number or id;
  OpenPicture(Files[0], id);
  if Files.Count > 1 then
  begin
    id := 2;
    OpenPicture(Files[1], id);
    picture_number := picture_number or id;
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
    picture_number := picture_number or id;
    if id = 1 then
    begin
      OpenPicture(OpenDialog1.Files[0], id);
      if OpenDialog1.Files.Count > 1 then
      begin
        id := 2;
        OpenPicture(OpenDialog1.Files[1], id);
        picture_number := picture_number or id;
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
  if LoadPicture(Vinx, Vinx) then
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

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
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

  if (mouse_down = 1) and (x <> split1) and (x >= show_sx) and (x < show_ex) and
                                            (y >= show_sy) and (y < show_ey) then
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
      opened := LoadPicture(video[1].FrameIndex - 1, video[2].FrameIndex - 1);
    end;
    VK_RIGHT:
    begin
      opened := LoadPicture(video[1].FrameIndex + 1, video[2].FrameIndex + 1);
    end;
    VK_UP:
    begin
      opened := LoadPicture(1, 1);
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

  if opened then
  begin
    ShowInformation;
    ShowPicture;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  show.Free;
  bmp[1, 0].Free;
  bmp[1, 1].Free;
  bmp[2, 0].Free;
  bmp[2, 1].Free;
  png[1, 0].Free;
  png[1, 1].Free;
  png[2, 0].Free;
  png[2, 1].Free;
  if DirectoryExists(outfolder) then
    DeleteDirectory(outfolder);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if LoadPicture(video[1].FrameIndex + 1, video[2].FrameIndex + 1) then
  begin
    ShowInformation;
    ShowPicture;
  end
  else
    Timer1.Enabled := False;
end;

procedure TForm1.FormDblClick(Sender: TObject);
begin
  if (Form1.Left > 0) OR (Form1.Top > 0) then
    ResetForm(1)
  else
    ResetForm(0);
  if picture_number > 0 then
    ShowPicture;

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
end;

end.
