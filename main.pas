unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ShellAPI, ExtDlgs, Menus, ComCtrls, Math,
  IdGlobalProtocols, utils, ImgList, StdCtrls;

type
  TVideo = record
    // stream basic info
    IsVideo: Boolean;
    FullFileName: String;
    FileName: String;
    FileNamePrefix: String;
    FileSizeFormat: String;

    // probe stream info
    FrameNumber: Integer;
    CodecName: String;
    PixFormat: String;
    BitRate: String;
    FrameRate: Real;
    FrameWidth: Integer;
    FrameHeight: Integer;
    FileDuration: Real;

    // for .avi, .rgb mode
    FileStream: TFileStream;
    StreamHeaderSize : Integer;
    FrameHeaderSize : Integer;

    FileIndex: Integer;
    FrameIndex: Integer;

    // each frame info, default not use
    FrameInfo: TStrings;

    BitMap: TBitMap;

    ReadDuration: Integer;

    IssueFrameIndex: array of Integer;
    FrameIndexList : array of Integer;

    // YUV infomation
    input_yuv : Boolean;
  end;

  TForm1 = class(TForm)
    PopupMenu1: TPopupMenu;
    OpenFile11: TMenuItem;
    N1: TMenuItem;
    GoToFrame1: TMenuItem;
    N2: TMenuItem;
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
    ProgressBar1: TProgressBar;
    Timer2: TTimer;
    Image1: TImage;
    Setting1: TMenuItem;
    N6: TMenuItem;
    About1: TMenuItem;
    YUVSetting1: TMenuItem;
    DisplayY1: TMenuItem;
    DisplayY2: TMenuItem;
    DisplayU1: TMenuItem;
    DisplayV1: TMenuItem;
    N8: TMenuItem;
    ChangePixelFormat1: TMenuItem;
    Differentmode1: TMenuItem;
    RGBdiff1: TMenuItem;
    RGB1: TMenuItem;
    Ydifference1: TMenuItem;
    None1: TMenuItem;
    Ydifference2: TMenuItem;
    Justify1: TMenuItem;
    SaveFrame1: TMenuItem;
    SaveFrame11: TMenuItem;
    ShowInformation2: TMenuItem;
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
    procedure Timer2Timer(Sender: TObject);
    procedure ProgressBar1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ProgressBar1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Setting1Click(Sender: TObject);
    procedure DisplayY1Click(Sender: TObject);
    procedure ChangePixelFormat1Click(Sender: TObject);
    procedure None1Click(Sender: TObject);
    procedure ShowInformation2Click(Sender: TObject);
  private
    { Private declarations }
    video : array[1..2] of TVideo;

    use_image : Boolean;

    split1 : Integer;
    picture_number : Integer;
    mouse_status : Integer;

    show : TBitmap;
    show_rect: TRect;
    show_w: Integer;
    show_h: Integer;

    diff_mode : Integer;
    diff_threshold : integer;
    diff : TBitmap;

    windows_size : integer;
    dlt_x : integer;
    dlt_y : integer;
    move_x : integer;
    move_y : integer;

    procedure InitVideo(which: integer);
    procedure ProbeVideoParameters(id : integer; filename: String);

    procedure ShowInformation;
    procedure InputFiles(Files: Tstrings);
    function OpenPicture(input_filename: String; id: Integer): Boolean;
    function CallFFmpegDecode(id, fid:Integer; output_filename: String): THandle;
    function LoadDBI(id, Width, Height : Integer; Pos: int64): Boolean;
    function LoadPicture(inx1, inx2, wait_flag: integer): Boolean;
    procedure ShowPicture;
    procedure ResetWindow(VideoWidth, VideoHeight, ToSource: Integer);
    procedure ResetForm(windows_size: Integer);

 protected
    procedure WMDROPFILES(var Msg : TMessage); message WM_DROPFILES;

 public
    { Public declarations }
    // setting parameters
    extension : String;
    outfolder: String;
    use_segment_mode : Boolean;
    ChangeWindowMessageFilter:function(msg: UINT; dwFlag: DWORD): BOOL; stdcall;
  end;

var
  Form1: TForm1;

implementation

uses setting, yuv, info;

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
  InitVideo(3);
  InputFiles(Files);
  Files.Free;
end;

function RunFFMPEG(param: String): Integer; stdcall;
begin
  WinExec(PAnsiChar(AnsiString(param)), SW_HIDE);
  Result := 0;
end;

procedure TForm1.InitVideo(which: integer);
var
 id, to_id : integer;
begin
  if which >= 3 then
  begin
    windows_size := 0;
    dlt_x := 0;
    dlt_y := 0;

    split1 := -1;
    if show = nil then
      show := Tbitmap.Create;
    log_file := nil;

    picture_number := 0;
    mouse_status := 0;

    show_rect := Rect(0, 0, 0, 0);
    show_w := 0;
    show_h := 0;
    to_id := 1;
  end
  else
    to_id := 2;

  for id:=2 downto to_id do
  begin
    video[id].IsVideo := False;
    video[id].FullFileName := '';
    video[id].FileName := '';
    video[id].FileNamePrefix := '';
    video[id].FileSizeFormat := '';
    video[id].FrameIndex := 0;
    video[id].FrameNumber := 0;
    video[id].FrameRate := 0;
    if video[id].BitMap <> nil then
      video[id].BitMap.free;
    video[id].BitMap := TBitmap.create;
    video[id].ReadDuration := 2;
    video[id].FileIndex := -1;
    video[id].FileStream := nil;
    video[id].StreamHeaderSize := 0;
    video[id].FrameHeaderSize := 0;
    if video[id].IssueFrameIndex <> nil then
      video[id].IssueFrameIndex := nil;
    if video[id].FrameIndexList <> nil then
      video[id].FrameIndexList := nil;
  end;
end;

procedure TForm1.ProbeVideoParameters(id : integer; filename: String);
var
  cmd, tmp, segment_filename: String;
  output : TStrings;
  d, w, i : integer;
  playlist, time_lists : string;
  MyText: TStringlist;
  info :TStrings;
  dur, fps : Real;
  segment_duration : Integer;
begin
  video[id].FullFileName := filename;
  if video[id].FileName = '' then
    video[id].FileName := ExtractFileName(filename);
  video[id].FileNamePrefix := outfolder + ChangeFileExt(video[id].FileName, '') + '_' + IntToStr(id) + '_';
  video[id].FileSizeFormat := FormatFileSize( FileSizeByName(filename));
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

  video[id].input_yuv := False;
  if Pos('.yuv', filename) > 0 then
  begin
    if id = 1 then
    begin
      Form3.Position := poMainFormCenter;
      Form3.paser_filename(filename);
      if Form3.ShowModal = mrOK then
      begin
        video[id].input_yuv := True;
        video[id].CodecName := 'RawYUV';
        video[id].PixFormat := Form3.ComboBox1.SelText;
        video[id].FrameWidth := Form3.width[0];
        video[id].FrameHeight := Form3.height[0];
        video[id].FrameRate := 25;
        video[id].BitRate := 'N/A' ;
        if Form3.framesize > 0 then
          video[id].FrameNumber := FileSizeByName(filename) div Form3.framesize
        else
          video[id].FrameNumber := 1;
        show.Width := video[id].FrameWidth;
        show.Height := video[id].FrameHeight;
        Exit;
      end;
    end
    else
    begin
      video[id].input_yuv := True;
      video[id].CodecName := 'RawYUV';
      video[id].PixFormat := video[1].PixFormat;
      video[id].FrameWidth := video[1].FrameWidth;
      video[id].FrameHeight := video[1].FrameHeight;
      video[id].FrameRate := video[1].FrameRate;
      video[id].BitRate := 'N/A' ;
      if Form3.framesize > 0 then
        video[id].FrameNumber := FileSizeByName(filename) div Form3.framesize
      else
        video[id].FrameNumber := 1;
      Exit;
    end;
  end;

  Form1.Cursor := crHourGlass;
  cmd := 'ffprobe -i ' + filename + ' -select_streams v -show_entries stream=codec_name,pix_fmt,nb_frames,width,height,r_frame_rate,avg_frame_rate,bit_rate,duration';
  output := RunDOS(cmd, INFINITE);

  try
    video[id].CodecName := output.Values['codec_name'];
    video[id].PixFormat := output.Values['pix_fmt'];
    video[id].FrameWidth := StrToInt(output.Values['width']);
    video[id].FrameHeight := StrToInt(output.Values['height']);
    if output.Values['duration'] <> 'N/A' then
    begin
      video[id].FileDuration := StrToFloat(output.Values['duration']);
      w := 1 + ceil(video[id].FileDuration / video[id].ReadDuration );
      SetLength(video[id].IssueFrameIndex, w);
      for i := 0 to w-1 do
        video[id].IssueFrameIndex[i] := -1;
    end;
  except
    ShowMessage('probe stream information error!');
    exit;
  end;

  show.Width := video[id].FrameWidth;
  show.Height := video[id].FrameHeight;

  tmp := output.Values['r_frame_rate'];
  if tmp = 'N/A' then
    tmp := output.Values['avg_frame_rate'];
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
      if (video[id].FileDuration > 0) AND (video[id].FrameRate > 0) then
      begin
        video[id].FrameNumber := trunc(video[id].FileDuration * video[id].FrameRate);
      end;
    except
      video[id].FrameNumber := 1;
    end;
  end;
  output.Free;

  if use_Segment_mode then
  begin
    fps := video[id].FrameRate;
    segment_duration := ceil(video[id].FileDuration / 20.0);
    if segment_duration < 2 then
       segment_duration := 2;

    time_lists := '2';
    d := 2;
    while d < video[id].FileDuration do
    begin
      time_lists := time_lists + ',' + IntToSTr(segment_duration);
      d := d + segment_duration;
    end;

    // ffmpeg -i Youtube_sample_Blue_Angels_360_30s.mp4 -vcodec copy -an
    // -f ssegment -segment_time 2 -segment_list_type csv -segment_list playlist.m3u8  e:\vct_temp_____output\out%d.mp4
    playlist := outfolder + 'playlist' + IntToSTr(id) + '.log';
    cmd := 'ffmpeg -i ' + filename +
           ' -v quiet' +
           ' -vcodec copy -an -f ssegment' +
           ' -segment_times ' + time_lists +
           ' -segment_list_type csv' +
           ' -segment_list ' + playlist + ' ' +
           video[id].FileNamePrefix + '%d.mp4';
    RunDOS(cmd, 10000);

    // for some Variable fps stream frm_cnt != duration * fps
    if FileExists(playlist) then
    begin
      MyText := TStringlist.Create;
      MyText.LoadFromFile(playlist);
      if (MyText <> nil) AND (MyText.Count > 0) then
      begin
        SetLength(video[id].FrameIndexList, MyText.Count+1);
        video[id].FrameIndexList[0] := 0;
        info := TStringList.Create;
        for i := 0 to MyText.Count - 1 do
        begin
          {
          segment_filename := video[id].FileNamePrefix + IntToStr(i) + '.mp4';
          cmd := 'ffprobe -i ' + segment_filename + ' -select_streams v -show_entries stream=nb_frames';
          output := RunDOS(cmd, INFINITE);
          try
            d := StrToInt(output.Values['nb_frames']);
          except
          }
            info.CommaText := MyText[i];
            if info.Count = 3 then
            begin
              dur := StrToFloat(info[2]) - StrToFloat(info[1]);
              d := ceil(dur*fps);
            end;
          //end;

          video[id].FrameIndexList[i+1] := video[id].FrameIndexList[i] + d;
        end;
        info.Free;
      end;
      MyText.Free;
    end;

  end;

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

procedure TForm1.ShowInformation;
var
  id, count : Integer;
  info : string;
  str : TStrings;
begin
   if picture_number <= 0 then
   begin
     Caption := 'Please input...';
     exit;
   end;

   info := '';
   for id:= 1 to picture_number do
   begin
     if id = 2 then
       info := info + ' || ';
     info := info + IntToStr(video[id].FrameIndex) + ' / ' + IntToStr(video[id].FrameNumber);
     info := info + ' , ' + IntToStr(video[id].FileIndex);
     info := info + ' , ' + video[id].FileName;
     info := info + ' , ' + IntToStr(video[id].FrameWidth) + 'x' + IntToStr(video[id].FrameHeight);
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
     info := info + ' || ' + psnr(video[1].BitMap, video[2].BitMap);
   caption := info;

   if picture_number = 1 then
     count := video[1].FrameNumber
   else
     count := min(video[1].FrameNumber, video[2].FrameNumber);
   if ProgressBar1.Max <> count then
     ProgressBar1.Max := count - 1;
   ProgressBar1.Position := video[1].FrameIndex;
   Image1.Height := Round(video[1].FrameHeight * Image1.Width / video[1].FrameWidth);
end;

procedure TForm1.ShowPicture;
var
  pos : Integer;
  sou : TRect;
  scale_x : Real;
begin
  if (show_w <= 0) OR (show_h <= 0) then
    ResetWindow(video[1].BitMap.Width, video[1].BitMap.Height, 0);

  if (windows_size = 2) then
  begin
    sou.Left := (video[1].BitMap.Width - Form1.ClientWidth - dlt_x) div 2;
    if sou.Left < 0 then
      sou.Left := 0
    else if sou.Left > video[1].BitMap.Width - Form1.ClientWidth then
      sou.Left := video[1].BitMap.Width - Form1.ClientWidth;

    sou.Top := (video[1].BitMap.Height - Form1.ClientHeight - dlt_y) div 2;
    if sou.Top < 0 then
      sou.Top := 0
    else if sou.Top > video[1].BitMap.Height - Form1.ClientHeight then
      sou.Top := video[1].BitMap.Height - Form1.ClientHeight;

    sou.Right := sou.Left + Form1.ClientWidth;
    sou.Bottom := sou.Top + Form1.ClientHeight;
  end
  else
    sou.Left := 0;

  if picture_number = 1 then
  begin
    if windows_size < 2 then
      Form1.Canvas.StretchDraw(show_rect, video[1].BitMap)
    else
      Form1.Canvas.CopyRect(Form1.ClientRect, video[1].BitMap.Canvas, sou);
  end
  else if picture_number = 2 then
  begin
    scale_x := video[1].BitMap.Width / show_w;
    pos := Round(scale_x * (Split1 - show_rect.Left)) + sou.Left;

    show.Canvas.CopyRect(Rect(0, 0, pos, video[1].BitMap.Height),
                         video[1].BitMap.Canvas,
                         Rect(0, 0, pos, video[1].BitMap.Height));

    if (diff <> nil) AND (diff_mode > 0) then
    begin
      show.Canvas.CopyRect(Rect(pos, 0, video[2].BitMap.Width, video[2].BitMap.Height),
                           diff.Canvas,
                           Rect(pos, 0, video[2].BitMap.Width, video[2].BitMap.Height));
    end
    else
      show.Canvas.CopyRect(Rect(pos, 0, video[2].BitMap.Width, video[2].BitMap.Height),
                           video[2].BitMap.Canvas,
                           Rect(pos, 0, video[2].BitMap.Width, video[2].BitMap.Height));

    if windows_size < 2 then
      Form1.Canvas.StretchDraw(show_rect, show)
    else
      Form1.Canvas.CopyRect(Form1.ClientRect, show.Canvas, sou);
    if (split1 > show_rect.Left) and (split1 < show_rect.Right) then
    begin
      Form1.Canvas.MoveTo(split1, show_rect.Top);
      Form1.Canvas.LineTo(split1, show_rect.Bottom - 1);
    end;
  end;
end;

procedure TForm1.ResetWindow(VideoWidth, VideoHeight, ToSource: Integer);
var
  sx, sy, ex, ey, nWidth, nHeight: Integer;
begin
  if VideoWidth*VideoHeight <= 0 then
    exit;

  if windows_size = 2 then
  begin
    show_rect := Rect(0, 0, VideoWidth, VideoHeight);
    show_w := VideoWidth;
    show_h := VideoHeight;
    Split1 := Form1.ClientWidth div 2;
    exit;
  end;

  if (Form1.ClientWidth >= VideoWidth) AND (Form1.ClientHeight >= VideoHeight) then
  begin
    nWidth := VideoWidth;
    nHeight := VideoHeight;
  end
  else
  begin
    nWidth := Form1.ClientWidth;
    nHeight := Form1.ClientHeight;
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

  Split1 := Form1.ClientWidth div 2;
end;

procedure TForm1.ResetForm(windows_size: Integer);
var
  changed : Boolean;
  x, y : integer;
begin
  changed := False;
  if windows_size = 0  then       // nomormal
  begin
    Form1.ClientWidth := 664;
    Form1.ClientHeight := 480;
    Form1.Left := (Screen.Width - Form1.Width) div 2;
    Form1.Top := (Screen.Height - Form1.Height) div 2;
    Form1.Canvas.FillRect(Form1.ClientRect);
    changed := True;
  end
  else if (windows_size = 1) AND (video[1].BitMap.Width > 0) then  // max
  begin
    Form1.Width := Screen.Width;
    Form1.Height := Screen.Height;
    Form1.Left := 0;
    Form1.Top := 0;
    Form1.Canvas.FillRect(Form1.ClientRect);
    changed := True;
  end
  else if (windows_size = 2) AND (video[1].BitMap.Width > 0) then  // original
  begin
    x := Form1.Width - Form1.ClientWidth;
    y := Form1.Height - Form1.ClientHeight;
    if (Screen.Width - x > video[1].BitMap.Width) AND
       (Screen.Height - y > video[1].BitMap.Height) then
    begin
      Form1.ClientWidth := video[1].BitMap.Width;
      Form1.ClientHeight := video[1].BitMap.Height;
      Form1.Left := (Screen.Width - Form1.Width) div 2;
      Form1.Top := (Screen.Height - Form1.Height) div 2;
    end
    else
    begin
      Form1.ClientWidth := video[1].BitMap.Width;
      Form1.ClientHeight := video[1].BitMap.Height;
      x := (Screen.Width - Form1.Width) div 2;
      if x < 0 then
        x := 0;
      Form1.Left := x;
      y := (Screen.Height - Form1.Height) div 2;
      if y < 0 then
        y := 0;
      Form1.Top := y;
    end;
    Form1.Canvas.FillRect(Form1.ClientRect);
    changed := True;
  end;

  if changed AND (picture_number > 0) then
    ResetWindow(video[1].BitMap.Width, video[1].BitMap.Height, 0);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  ini_filename, segment_mode : String;
begin
  if Not checkFFmpegTools('ffmpeg') or Not checkFFmpegTools('ffprobe')  then
    close;

  outfolder := 'E:\vct_temp_____output\';
  //extension := '.bmp';
  extension := '.png';
  segment_mode := '0';
  ini_filename := ExtractFilePath(paramstr(0)) + 'setting.ini';
  iniFileIO(ini_filename, extension, outfolder, segment_mode);

  if DirectoryExists(outfolder) then
    DeleteDirectory(outfolder);

  if segment_mode = '1' then
    use_segment_mode := True
  else
    use_segment_mode := False;
  if (extension = '.avi') OR (extension = '.rgb') then
    use_image := False
  else
    use_image := True;

  diff_mode := 0;
  diff_threshold := 8;

  Timer1.Enabled := False;
  Form1.DoubleBuffered := True;
  Form1.Canvas.Pen.Width := 2;
  Form1.Canvas.Pen.Mode  := pmWhite;
  Form1.Canvas.FillRect(Form1.ClientRect);

  InitVideo(3);

  DragAcceptFiles(Handle, True);
  ResetForm(0);
end;

function TForm1.CallFFmpegDecode(id, fid:Integer; output_filename: String): THandle;
var
  param : string;
  TheThread : Dword;
  filename : string;
  inx, i : integer;
  first_segment : Boolean;
begin
  Result := 0;
  if use_segment_mode then
  begin
    filename := video[id].FileNamePrefix + IntToSTr(fid) + '.mp4';
    if not FileExists(filename) then
      exit;
    param := 'ffmpeg -an' +
             ' -v quiet' +
             //' -hwaccel dxva2' +
             ' -i ' + filename;
  end
  else
  begin
    param := 'ffmpeg -an -ss ' + IntToStr(fid*video[id].ReadDuration) +
             ' -v quiet' +
             //' -hwaccel dxva2' +
             ' -i ' + video[id].FullFileName +
             ' -t ' + IntToStr(video[id].ReadDuration);
  end;

  if extension = '.avi' then
    param := param + ' -pix_fmt bgr24 -c:v rawvideo -y ' + output_filename
  else if use_image then
  begin
    if use_segment_mode then
      inx := video[id].FrameIndexList[fid]
    else
      inx := fid * ceil(video[id].FrameRate) * video[id].ReadDuration;
    for i := 0 to High(video[id].IssueFrameIndex) do
    begin
      if video[id].IssueFrameIndex[i] = -1 then
      begin
        video[id].IssueFrameIndex[i] := inx;
        break;
      end
      else if video[id].IssueFrameIndex[i] = inx then
        exit;
    end;
    if extension = '.jpg' then
      param := param + ' -f image2 -start_number ' +
                       IntToStr(inx) +
                       ' -q:v 1' +
                       ' -y ' + video[id].FileNamePrefix + '%d' + extension
    else
      param := param + ' -pix_fmt bgr24 -f image2 -start_number ' +
                       IntToStr(inx) +
                       ' -y ' + video[id].FileNamePrefix + '%d' + extension;
  end
  else
    param := param + ' -pix_fmt bgr24 -f rawvideo -y ' + output_filename;

  if use_image then
    first_segment := False
  else
    first_segment := False OR (fid = 0);
  if first_segment AND (video[id].FileIndex < 0) then
  begin
    Form1.Cursor := crHourGlass;
    RunDos(param, 30000);
    Form1.Cursor := crDefault;
  end
  else
  begin
    try
      caption := param;
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
  list_len, size : integer;
  buf : array [0..3] of byte;
begin
  Result := False;
  if pos >= video[id].FileStream.Size then
    exit;

  if video[id].BitMap = nil then
    video[id].BitMap := TBitMap.Create;

  if (video[id].BitMap.Width <> Width) OR (video[id].BitMap.Height <> Height) then
  begin
    video[id].BitMap.Width := Width;
    video[id].BitMap.Height := Height;
    video[id].BitMap.PixelFormat := pf24bit;
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
      scanLine := video[id].BitMap.ScanLine[y];
      video[id].FileStream.Read(scanLine[0], Width*3);
    end;
    Result := True;
  except
    Result := False;
  end;
end;

function TForm1.LoadPicture(inx1, inx2, wait_flag: integer): Boolean;
var
   inx, fid, FrameRate : array[1..2] of Integer;
   FrameWidth, FrameHeight, FrameSize, frame_pos: Integer;
   pos : int64;
   filename : array[1..2] of string;
   next_filename : string;
   i, id, k: Integer;
   ThreadHandle: array[1..2] of THandle;
   condition : Boolean;
   bmp : TBitMap;
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

      if video[id].input_yuv then
      begin
        bmp := Form3.get_yuv_frame(video[id].FullFileName, id, inx[id]);
        if bmp <> nil then
        begin
          video[id].BitMap.Assign(bmp);
          video[id].FrameIndex := inx[id] + 1;
          bmp.Free;
          Result := True;
        end;
        if id = picture_number then
        begin
          if (picture_number > 0) AND (Result = True) then
            diffTwoImage(video[1].BitMap, video[2].BitMap, diff_mode, diff_threshold, diff);
          Exit;
        end
        else
          continue;
      end;

      FrameRate[id] := ceil(video[id].FrameRate) * video[id].ReadDuration;
      if use_segment_mode then
      begin
        for i := 0 to High(video[id].FrameIndexList) - 1 do
          if (video[id].FrameIndexList[i] <= inx[id]) and (inx[id] < video[id].FrameIndexList[i+1]) then
            break;
        fid[id] := i;
      end
      else
        fid[id] := inx[id] div FrameRate[id];

      if use_image then
        filename[id] := video[id].FileNamePrefix + IntToStr(inx[id]) + extension
      else
        filename[id] := video[id].FileNamePrefix + 'ss' + IntToStr(fid[id]) + extension;

      if Not FileExists(filename[id]) then
        CallFFmpegDecode(id, fid[id], filename[id])
      else
      begin
        if use_segment_mode then
        begin
          frame_pos := inx[id] - video[id].FrameIndexList[fid[id]];
          condition := fid[id] < High(video[id].FrameIndexList);
        end
        else
        begin
          frame_pos := (inx[id] - fid[id] * FrameRate[id]);
          if use_image then
            condition := True
          else
            condition := inx[id] + FrameRate[id] < video[id].FrameNumber;
        end;

        if (frame_pos = 5) AND condition then
        begin
          if use_image then
            if use_segment_mode then
              next_filename := video[id].FileNamePrefix + IntToStr(video[id].FrameIndexList[fid[id]+1]) + extension
            else
              next_filename := video[id].FileNamePrefix + IntToStr((fid[id] + 1) * FrameRate[id]) + extension
          else
            next_filename := video[id].FileNamePrefix + 'ss' + IntToStr(fid[id] + 1) + extension;

          if Not FileExists(next_filename) then
            CallFFmpegDecode(id, fid[id] + 1, next_filename);
        end;
      end;
      Result := True;
    end;
  end;

  if Not Result then
     exit;

  // waiting
  if wait_flag = 2 then
  begin
    Form1.Cursor := crHourGlass;
    while not FileExists(filename[1]) do
      sleep(100);
    if picture_number > 1 then
      while not FileExists(filename[2]) do
         sleep(100);
    Form1.Cursor := crDefault;
  end;

  // load filestrean
  Result := True;
  k := 0;
  id := 1;
  while id <= picture_number do
  begin
    if use_image then
    begin
      if FileExists(filename[id]) then
      begin
        if AssignImage(filename[id], video[id].BitMap) then
        begin
          video[id].FileIndex := fid[id];
          video[id].FrameIndex := inx[id] + 1 + k;
        end
        else
          Result := False;
      end
      else
      begin
        if filename[id] = '' then
        begin
          id := id + 1;
          continue;
        end
        else
        begin
          k := k + 1;
          filename[id] := video[id].FileNamePrefix + IntToStr(inx[id] + k) + extension;
          if k < 10 then
            continue
          else
            Result := False;
        end;
      end;
      id := id + 1;
      continue;
    end;

    FrameWidth := video[id].FrameWidth;
    FrameHeight := video[id].FrameHeight;
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

      if use_image then
        pos := 0
      else
      begin
        if use_segment_mode then
          pos := (inx[id] - video[id].FrameIndexList[fid[id]]) * FrameSize
        else
          pos := (inx[id] - fid[id] * FrameRate[id]) * FrameSize;
      end;

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

  if (picture_number = 2) AND (Result = True) then
    diffTwoImage(video[1].BitMap, video[2].BitMap, diff_mode, diff_threshold, diff);
end;

procedure TForm1.None1Click(Sender: TObject);
var
  m : integer;
begin
  if picture_number > 1 then
  begin
    (Sender as TMenuItem).Checked := True;
    diff_threshold := 8;
    m := diff_mode;
    diff_mode := (Sender as TMenuItem).Tag;
    if m <> diff_mode then
    begin
      if diff_mode > 0 then
        diffTwoImage(video[1].BitMap, video[2].BitMap, diff_mode, diff_threshold, diff);
      ShowPicture;
    end;
  end;
end;

function TForm1.OpenPicture(input_filename: String; id: Integer): Boolean;
var
  FileExt : String;
  filename, cmd: String;
  bmp : TBitMap;
begin
  if Not utils.CheckInputFile(input_filename) then
  begin
    Result := False;
    exit;
  end;

  filename := ChangeFileExt(ExtractFileName(input_filename), '');
  FileExt := ExtractFileExt(input_filename);
  ProbeVideoParameters(id, input_filename);
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
        ProbeVideoParameters(id, filename);
      end
      else if Pos('.flv', FileExt) > 0 then
      begin
        filename := outfolder + 'flv_' + IntToStr(id) + '.mp4';
        cmd := 'ffmpeg.exe -i ' + video[id].FullFileName + ' -vcodec copy -an -y ' + filename;
        RunDOS(cmd, INFINITE);
        video[id].FullFileName := filename;
      end;

      if (picture_number = 1) and (id = 1) then
        LoadPicture(1, video[2].FrameIndex, 2)
      else if (picture_number = 2) and (id = 2) then
        LoadPicture(1, 1, 2)
    end
    else if (Pos('.png', FileExt) > 0) OR
            (Pos('.jpg', FileExt) > 0) OR
            (Pos('.bmp', FileExt) > 0) then
    begin
      if AssignImage(input_filename, video[id].BitMap) then
      begin
        video[id].FrameIndex := 1;
        video[id].FrameNumber := 1;
      end;
    end
    else if (Pos('.yuv', FileExt) > 0) then
    begin
      bmp := Form3.get_yuv_frame(input_filename, id, 0);
      if bmp <> nil then
      begin
        video[id].BitMap.Assign(bmp);
        video[id].FrameIndex := 1;
        bmp.Free;
      end;
    end
    else
    begin
      ShowMessage('Unknow file format!');
      Result := False;
      exit;
    end;

    if (picture_number = id) then
      ResetWindow(video[1].BitMap.Width, video[1].BitMap.Height, 0);

    Result := True;
    if (picture_number = 2) and (id = 2) then
    begin
      if (video[2].BitMap.Width <> video[1].BitMap.Width) OR (video[2].BitMap.Height <> video[1].BitMap.Height) then
      begin
        ShowMessage('Two video frame size are not same file 1 is ' + IntToStr(video[1].BitMap.Width) + 'x' + IntToStr(video[1].BitMap.Height) +
                                                    ', file 2 is ' + IntToStr(video[2].BitMap.Width) + 'x' + IntToStr(video[2].BitMap.Height));
        Result := False;
      end else if diff_mode > 0 then
        diffTwoImage(video[1].BitMap, video[2].BitMap, diff_mode, diff_threshold, diff);
    end;
end;

procedure TForm1.ProgressBar1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  inx : Integer;
  filename : string;
  bmp : TBitMap;
begin
  inx := Round(X * ProgressBar1.Max / ProgressBar1.Width);
  ProgressBar1.Hint := IntToStr(inx);

  if not video[1].input_yuv then
  begin
    filename := video[1].FileNamePrefix + IntToStr(inx) + extension;
    if FileExists(filename) then
    begin
      Image1.Left := x;
      AssignImage(filename, Image1.Picture.Bitmap);
      Image1.Visible := True;
    end;
  end
  else begin
    bmp := Form3.get_yuv_frame(video[1].FullFilename, 1, inx);
    if bmp <> nil then
    begin
      Image1.Left := x;
      Image1.Picture.Bitmap.Assign(bmp);
      Image1.Visible := True;
      bmp.Free;
    end;
  end;
end;

procedure TForm1.ProgressBar1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  inx : integer;
begin
  if Timer1.Enabled then
    Timer1.Enabled := False;

  inx := Round(X * ProgressBar1.Max / ProgressBar1.Width);
  if LoadPicture(inx, inx, 2) then
  begin
    ShowInformation;
    ShowPicture;
  end;
end;

procedure TForm1.InputFiles(Files: Tstrings);
var
  id : Integer;
  is_open: Boolean;
begin
  if Files.Count <= 0 then
    exit;

  Caption := 'Waiting...';
  if Files.Count > 1 then
    picture_number := 2
  else
    picture_number := 1;

  id := 1;
  is_open := OpenPicture(Files[0], id);
  if is_open and (Files.Count > 1) then
  begin
    id := 2;
    is_open := OpenPicture(Files[1], id);
  end;

  if is_open then
  begin
    ShowInformation;
    split1 := Form1.ClientWidth div 2;
    ShowPicture;
  end
  else
    Caption := 'Please input...';
end;

procedure TForm1.OpenFile11Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    InitVideo(3);
    InputFiles(OpenDialog1.Files);
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
    if Vinx < 1 then
       Vinx := 1
    else if Vinx >= Vmax then
       Vinx := Vmax;
  except
    Vinx := video[1].FrameIndex;
  end;
  if LoadPicture(Vinx, Vinx, 2) then
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
      video[id].BitMap.SaveToFile(SavePictureDialog1.FileName)
    else
    begin
      x := Round(Split1 * video[1].BitMap.Width / show_w);
      show.Canvas.Pen.Color := clWhite;
      show.Canvas.Pen.Width := 2;
      show.Canvas.MoveTo(x, 0);
      show.Canvas.LineTo(x, show.Height);
      show.SaveToFile(SavePictureDialog1.FileName);
    end;
  end;
end;

procedure TForm1.Setting1Click(Sender: TObject);
begin
  Form2.Left := Form1.Left + (Form1.Width - Form2.Width ) div 2;
  Form2.Top := Form1.Top + (Form1.Height - Form2.Height ) div 2;
  Form2.show;
end;

procedure TForm1.ChangePixelFormat1Click(Sender: TObject);
var
  id : integer;
  opened : Boolean;
  bmp : TBitMap;
begin
  if Form3.ShowModal = mrOK then
  begin
    opened := False;
    for id := 1 to 2 do
    begin
      if video[id].input_yuv then
        begin
          bmp := Form3.get_current_frame(id);
          if bmp <> nil then
          begin
            video[id].BitMap.Assign(bmp);
            bmp.Free;
            opened := True;
          end;
        end;
    end;

  if opened then
    ShowPicture;
  end;
end;

procedure TForm1.DisplayY1Click(Sender: TObject);
var
  id : integer;
  opened : Boolean;
  bmp : TBitMap;
begin
  (Sender as TMenuItem).Checked := True;
  opened := False;
  Form3.yuv_display_mode := (Sender as TMenuItem).Tag;
  for id := 1 to 2 do
  begin
    if video[id].input_yuv then
      begin
        bmp := Form3.get_current_frame(id);
        if bmp <> nil then
        begin
          video[id].BitMap.Assign(bmp);
          bmp.Free;
          opened := True;
        end;
      end;
  end;

  if opened then
    ShowPicture;
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
  begin
    mouse_status := 1;
    if (abs(x - split1) < 3) AND (video[2].FrameNumber > 0) then
      mouse_status := 2;
    if windows_size = 2 then
    begin
      move_x := X;
      move_y := Y;
    end;
  end;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  w : integer;
begin
  if (windows_size = 2) AND (mouse_status <> 2) then
  begin
    move_x := X - move_x;
    move_y := Y - move_y;
    dlt_x := dlt_x + move_x;
    dlt_y := dlt_y + move_y;
    w := video[1].BitMap.Width - Form1.ClientWidth;
    if dlt_x > w then
       dlt_x := w
    else if dlt_x < -w then
       dlt_x := -w;

    w := video[1].BitMap.Height - Form1.ClientHeight;
    if dlt_y > w then
       dlt_y := w
    else if dlt_y < -w then
       dlt_y := -w;
    ShowPicture;
  end;

  mouse_status := 0;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  if not Timer1.Enabled then
    ShowPicture;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  offset : Integer;
begin
  if picture_number = 0 then
    exit;
  if (abs(x - split1) < 3) AND (video[2].FrameNumber > 0) then
    Form1.Cursor := crHSplit
  else if Form1.Cursor <> crDefault then
    Form1.Cursor := crDefault;

  if (mouse_status = 2) and (x <> split1)
                      and (x >= show_rect.Left) and (x < show_rect.Right)
                      and (y >= show_rect.Top) and (y < show_rect.Bottom) then
  begin
    split1 := x;
    ShowPicture;
  end;

  if (Y > Form1.Height - 64) AND (ProgressBar1.Max > 1) AND Not ProgressBar1.Visible then
  begin
    offset := Image1.Width div 2;
    ProgressBar1.Left := offset;
    ProgressBar1.Top := Form1.ClientHeight - 40;
    ProgressBar1.Width := Form1.ClientWidth - ProgressBar1.Left - offset;
    Image1.Top := ProgressBar1.Top - Image1.Height - 16;
    ProgressBar1.Visible := True;
  end;

  if (Y < Form1.Height - 64) AND ProgressBar1.Visible then
    Timer2.Enabled := True;
end;

procedure TForm1.ShowInformation1Click(Sender: TObject);
begin
  ShowInformation1.Checked := not ShowInformation1.Checked;
  if ShowInformation1.Checked then
    ShowInformation;
end;

procedure TForm1.ShowInformation2Click(Sender: TObject);
var
  id : integer;
begin
  ShowInformation2.Checked := not ShowInformation2.Checked;
  if ShowInformation2.Checked then
  begin
    Form4.picture_number := picture_number;
    for id := 1 to picture_number do
      Form4.filename[id] := video[id].FullFileName;
    Form4.Position := poMainFormCenter;
    Form4.Show;
  end
  else
    Form4.Hide;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  opened : Boolean;
  offset, w: Integer;
begin
  offset := 16;
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
      if picture_number = 2 then
      begin
        initvideo(2);
        picture_number := 1;
        opened := True;
      end
      else if picture_number = 1 then
      begin
        initvideo(3);
        caption := 'Please input...';
        ResetForm(0);
      end;
    end;
  end;

  if windows_size = 2 then
  begin
    if Key = ord('W') then       // W up
    begin
      dlt_y := dlt_y + offset;
      opened := True;
    end
    else if Key = ord('X') then  // X down
    begin
      dlt_y := dlt_y - offset;
      opened := True;
    end
    else if Key = ord('A') then  // A left
    begin
      dlt_x := dlt_x - offset;
      opened := True;
    end
    else if Key = ord('D') then  // D right
    begin
      dlt_x := dlt_x + offset;
      opened := True;
    end
    else if Key = ord('S') then  // S cneter
    begin
      dlt_y := 0;
      dlt_x := 0;
      opened := True;
    end;

    w := video[1].BitMap.Width - Form1.ClientWidth;
    if dlt_x > w then
       dlt_x := w
    else if dlt_x < -w then
       dlt_x := -w;

    w := video[1].BitMap.Height - Form1.ClientHeight;
    if dlt_y > w then
       dlt_y := w
    else if dlt_y < -w then
       dlt_y := -w;
  end;

  if Timer1.Enabled AND ProgressBar1.Visible then
  begin
    ProgressBar1.Visible := False;
    Image1.Visible := False;
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
  if diff <> nil then
    diff.Free;
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
    Timer1.Interval := 500;
    //Timer1.Enabled := False;
  end;

  if video[1].FrameIndex + 1 >= video[1].FrameNumber then
  begin
    Timer1.Enabled := False;
    LoadPicture(video[1].FrameIndex, video[2].FrameIndex, 0);
    ShowPicture;
  end;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  if ProgressBar1.Visible then
  begin
    Timer2.Enabled := False;
    ProgressBar1.Visible := False;
    Image1.Visible := False;
  end;
end;

procedure TForm1.FormDblClick(Sender: TObject);
begin
  if picture_number > 0 then
  begin
    windows_size := windows_size + 1;
    if windows_size > 2 then
      windows_size := 0;

    ResetForm(windows_size);

    if ProgressBar1.Visible then
    begin
      ProgressBar1.Visible := False;
      Image1.Visible := False;
    end;


    if windows_size > 0 then
      Image1.Width := 256
    else
      Image1.Width := 128;
    Image1.Height := Round(video[1].FrameHeight * Image1.Width / video[1].FrameWidth);

    ShowPicture;
  end;
end;

end.
