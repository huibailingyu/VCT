unit utils;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Dialogs, pngimage, ShellAPI,
  Math, Jpeg, IdGlobalProtocols, inifiles;

  procedure writelog(handle: Integer; command: string);
  function RunDOS(const CommandLine: string; timeout: DWORD): TStrings;
  function checkFFmpegTools(const ApplicationName: string): Boolean;
  function CheckInputFile(input_filename: String): Boolean;
  function AssignImage(filename: string; bmp: TBitMap):Boolean;
  function FileReady(filename:String; filesize: int64): Boolean;
  function DeleteDirectory(NowPath: string): Boolean;
  function psnr(bmp1, bmp2: TBitMap): string;
  function FindAVIHeader(fs : TFileStream; filesize: integer): integer;
  function FormatFileSize(nSize: integer): String;
  function iniFileIO(ini_filename: string; var extension, outfolder, segment_mode: string): Boolean;
  function yuv_read_one_frame(filename: string; frm_inx: integer; frame_size: integer) : PByte;
  function yuv_show_one_frame(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte):TBitMap;
  var
    log_file: TStrings;

  type
  TRGBTriple = packed record
    rgbtBlue: Byte;
    rgbtGreen: Byte;
    rgbtRed: Byte;
  end;

  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array[0..4095] of TRGBTriple;

const
YUV420p = 0;
YUV400p = 1;
NV12    = 2;
YUV444p = 3;

implementation

procedure CheckResult(b: Boolean);
begin
  if not b then
    raise Exception.Create(SysErrorMessage(GetLastError));
end;

procedure writelog(handle: Integer; command: string);
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
  log_file.SaveToFile(ExtractFilePath(paramstr(0)) + 'log.file');
end;

function RunDOS(const CommandLine: string; timeout: DWORD): TStrings;
var
  HRead, HWrite: THandle;
  StartInfo: TStartupInfo;
  ProceInfo: TProcessInformation;
  b: Boolean;
  sa: TSecurityAttributes;
  inS: THandleStream;
  i : Integer;
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

  if Not b then
  begin
    for i := 0 to Length(CommandLine) - 1 do
      if CommandLine[i] = ' ' then
        break;
    Result.Text := '[Error] ' + copy(CommandLine, 1, i) + ' NOT find.' + #13 + #10 +
                   'Do not install or not in system path';
    ShowMessage(Result.Text);
    CloseHandle(HRead);
    CloseHandle(HWrite);
    exit;
  end;

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

function checkFFmpegTools(const ApplicationName: string): Boolean;
var
  cmd : string;
  output : TStrings;
begin
  Result := False;
  cmd := ApplicationName + ' -version';
  output := RunDOS(cmd, 30000);
  if Pos('Error', output.Text) = 0 then
    Result := True;
  output.Free;
end;

// Remove whole Directory
function DeleteDirectory(NowPath: string): Boolean;
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

function FileReady(filename:String; filesize: int64): Boolean;
begin
  Result := False;
  if FileExists(filename) then
  begin
    if FileSizeByName(filename) >= filesize  then
       Result := True;
  end;
end;

function CheckInputFile(input_filename: String): Boolean;
var
  FileExt, cmd : String;
  output : TStrings;
begin
  FileExt := ExtractFileExt(input_filename);
  if Not ((Pos('.mp4', FileExt) > 0) OR (Pos('.h264', FileExt) > 0) OR
          (Pos('.264', FileExt) > 0) OR (Pos('.flv', FileExt) > 0) OR
          (Pos('.avi', FileExt) > 0) OR (Pos('.ts', FileExt) > 0) OR
          (Pos('.bmp', FileExt) > 0) OR (Pos('.png', FileExt) > 0) OR
          (Pos('.jpg', FileExt) > 0)
          ) then
    Result := False
  else
  begin
    Result := False;
    try
      cmd := 'ffprobe -i ' + input_filename + ' -select_streams v -show_entries stream=width,height';
      output := RunDOS(cmd, 3000);
      if (output.Count > 1) AND
         (output.Values['width'] <> '0') AND (output.Values['height'] <> '0') then
        Result := True;
    except
      Result := False;
    end;
  end;
  if Not Result then
    ShowMessage('Input file is not an available Video or Image file');
end;

function AssignImage(filename: string; bmp: TBitMap):Boolean;
var
  png : TPngImage;
  jpg : TJpegImage;
  FileExt : string;
begin
  try
    Result := True;
    FileExt := ExtractFileExt(filename);
    if FileExt = '.bmp' then
      bmp.LoadFromFile(filename)
    else if FileExt = '.png' then
    begin
      png := TPngImage.Create;
      png.LoadFromFile(filename);
      bmp.Assign(png);
      png.Free;
    end
    else if FileExt = '.jpg' then
    begin
      jpg := TJpegImage.Create;
      jpg.LoadFromFile(filename);
      bmp.Assign(jpg);
      jpg.Free;
    end
    else
      Result := False;
  except
    Result := False;
  end;
end;

function FindAVIHeader(fs : TFileStream; filesize: integer): integer;
var
  list_type : string;
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

function psnr(bmp1, bmp2: TBitMap): string;
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

function iniFileIO(ini_filename: string; var extension, outfolder, segment_mode: string): Boolean;
var
  old_outfolder : String;
  ini_file: TInifile;
begin
  if FileExists(ini_filename) then
  begin
    ini_file := TInifile.Create(ini_filename);
    outfolder := ini_file.ReadString('setting', 'outfolder', outfolder);
    extension := ini_file.ReadString('setting', 'extension', extension);
    segment_mode := ini_file.ReadString('setting', 'use_segment_mode', extension);
    ini_file.Free;
  end;

  old_outfolder := outfolder;
  while not DirectoryExists(outfolder) do
  begin
    if not CreateDir(outfolder) then
      outfolder := InputBox('Input Application Output Folder, this folder must be empty',
                            'Create output folder ' + outfolder + ' failed!', outfolder);
  end;

  if outfolder[Length(outfolder)] <> '\' then
     outfolder := outfolder + '\';

  if old_outfolder <> outfolder then
  begin
    ini_file := TInifile.Create(ini_filename);
    ini_file.WriteString('setting', 'outfolder', outfolder);
    ini_file.WriteString('setting', 'extension', extension);
    ini_file.WriteString('setting', 'use_segment_mode', segment_mode);
    ini_file.Free;
  end;
  Result := True;
end;

function yuv_read_one_frame(filename: string; frm_inx: integer; frame_size: integer) : PByte;
var
  fp : THandle;
  len : integer;
begin
  Result := PByte(AllocMem(frame_size + 1));
  if Result <> nil then begin
    fp := FileOpen(filename, fmOpenRead);
    if (fp <> -1) then begin
      FileSeek(fp, 0, 0);
      len := FileRead(fp, Result^, frame_size);
      if (len > 0) AND (len < frame_size) then
        FillMemory(@Result[len], frame_size - len, 0);
      FileClose(fp);
    end
    else begin
      FreeMem(Result);
      Result := nil;
    end;
  end;
end;

procedure yuv_get_y(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var luma: Byte);
var
  inx : integer;
begin
  if (0<=x) AND (x<width[0]) AND (0<=y) AND (y<height[0]) then begin
    inx := y*stride[0] + x;
    luma := data[inx];
  end
  else
    luma := 0;
end;

procedure yuv_get_uv(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var u, v: Byte);
var
  inx : integer;
  ysize : integer;
  uvsize : integer;
begin
  ysize := stride[0] * height[0];
  uvsize := stride[1] * height[1];
  if pix_fmt = YUV420p then begin
     x := x div 2;
     y := y div 2;
  end else if pix_fmt = YUV400p then begin
    x := -1;
    y := -1;
  end else if pix_fmt = NV12 then begin
    y := y div 2;
  end;

  if (0<=x) AND (x<width[1]) AND (0<=y) AND (y<height[1]) then begin
    inx := ysize + y*stride[1] + x;
    u := data[inx];
    if pix_fmt <> NV12 then
      inx := inx + uvsize
    else
      inx := inx + 1;
    v := data[inx];
  end
  else begin
    u := 128;
    v := 128;
  end;
end;

function yuv_show_one_frame(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte):TBitMap;
var
  Y, U, V : Byte;
  R, G, B : Real;
  Pixels: PRGBTripleArray;
  w, h : integer;
begin
  Result := TBitMap.Create;
  Result.PixelFormat := pf24bit;
  Result.Width := width[0];
  Result.Height := height[0];

  for h := 0 to Result.Height - 1 do
    begin
      Pixels := Result.ScanLine[h];
      for w := 0 to Result.Width - 1 do
      begin
        yuv_get_y(width, height, stride, pix_fmt, data, w, h, Y);
        yuv_get_uv(width, height, stride, pix_fmt, data, w, h, U, V);

        R := Y + 1.403 * (V - 128) + 0.5;
        G := Y - 0.343 * (U - 128) - 0.714 * (V - 128) + 0.5;
        B := Y + 1.770 * (U - 128) + 0.5;

        if R > 255.0 then
          R := 255
        else if R < 0.0 then
          R := 0.0;

        if G > 255.0 then
          G := 255
        else if G < 0.0 then
          G := 0.0;

        if B > 255.0 then
          B := 255
        else if B < 0.0 then
          B := 0.0;

        Pixels[w].rgbtRed   := Round(R);
        Pixels[w].rgbtGreen := Round(G);
        Pixels[w].rgbtBlue  := Round(B);
      end;
    end;

    Result.SaveToFile('e:\tt.bmp');
end;

function get_yuv_frame(filename: string; frame_inx: integer) : TBitmap;
var
  yuv_data : PByte;
begin
  yuv_data := yuv_read_one_frame(filename, frame_inx, frame_size: integer) : PByte;
end;

end.
