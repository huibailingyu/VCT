unit yuv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask;

type
  TForm3 = class(TForm)
    ComboBox1: TComboBox;
    Label1: TLabel;
    Button1: TButton;
    MaskEdit1: TMaskEdit;
    Label2: TLabel;
    Label3: TLabel;
    MaskEdit2: TMaskEdit;
    Label4: TLabel;
    MaskEdit3: TMaskEdit;
    Label5: TLabel;
    MaskEdit4: TMaskEdit;
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MaskEdit2Change(Sender: TObject);
    procedure MaskEdit3Change(Sender: TObject);
    procedure MaskEdit4Change(Sender: TObject);
    procedure MaskEdit1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    yuv_width : Integer;
    yuv_height : Integer;
    yuv_stride : array [0..1] of Integer;
    pix_fmt : Integer;
    ysize : integer;
    uvsize: integer;
    framesize : integer;
    yuv_display_mode : integer;
    yuv_data : array [1..2] of PByte;
    function guess_height(width: integer) : integer;
    procedure autoset_value(width : integer);
    procedure calculate_value(width : integer);
    procedure paser_filename(filename: string);

    procedure yuv_get_y(width, height: integer; stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var luma: Byte);
    procedure yuv_get_uv(width, height: integer; stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var u, v: Byte);
    procedure rgb_get_rgb(width, height: integer; stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var r, g, b: Byte);

    function yuv_read_one_frame(filename: string; id, frm_inx: integer; frame_size: integer) : Boolean;
    function yuv_show_one_frame(width, height: integer; stride : array of Integer; pix_fmt: Integer; data: PByte):TBitMap;
    function get_yuv_frame(filename: string; id, frame_inx: integer) : TBitmap;
    function get_current_frame(id: integer): TBitmap;
  end;

var
  Form3: TForm3;

implementation

uses utils, main;

{$R *.dfm}
procedure TForm3.autoset_value(width : integer);
begin
  yuv_stride[0] := width;
  yuv_stride[1] := width div 2;

  if pix_fmt = YUV400p then
    yuv_stride[1] := 0
  else if (pix_fmt = NV12) OR (pix_fmt = YUV444p) OR
          (pix_fmt = RGB888) OR (pix_fmt = BGR888) then
    yuv_stride[1] := width
  else if (pix_fmt = RGB24) OR (pix_fmt = BGR24) then  begin
    yuv_stride[0] := 3*width;
    yuv_stride[1] := 0;
  end;
  MaskEdit3.Text := IntToStr(yuv_stride[0]);
  MaskEdit4.Text := IntToStr(yuv_stride[1]);
end;

procedure TForm3.calculate_value;
var
  h1 : integer;
begin
  h1 := yuv_height div 2;
  if (pix_fmt = YUV420p) OR (pix_fmt = NV12) then
    h1 := yuv_height div 2
  else if (pix_fmt = YUV400p) OR (pix_fmt = RGB24) OR (pix_fmt = BGR24) then
    h1 := 0
  else if (pix_fmt = YUV444p) OR (pix_fmt = RGB888) OR (pix_fmt = BGR888) then
    h1 := yuv_height;

  ysize := yuv_height * yuv_stride[0];
  uvsize := h1 * yuv_stride[1];
  framesize := ysize + uvsize + uvsize;
end;

function TForm3.guess_height(width: integer) : integer;
begin
  if width = 352 then
    result := 176
  else if width = 720 then
    result := 576
  else if width = 640 then
    result := 320
  else if width = 1024 then
    result := 512
  else if width = 1920 then
    result := 1080
  else if width = 2048 then
    result := 1024
  else if width = 4096 then
    result := 2048
  else if width < 2048 then
    result := width
  else
    result := width div 2;
end;

procedure TForm3.paser_filename(filename: string);
var
  i, n, ww, hh : integer;
  v: string;
begin
  n := 0;
  v := '';
  ww := 0;
  hh := 0;
  for I := 0 to length(filename) - 1 do
  begin
    if ('0' <= filename[i]) AND (filename[i] <= '9') then
    begin
      if ('0' = filename[i]) AND (n = 0) then
         continue;
      n := n + 1;
      v := v + filename[i];
    end
    else if ((ww = 0) AND (filename[i] = 'x') OR (filename[i] = 'X') OR (filename[i] = '_') OR (filename[i] = ' ') OR
             (ww > 0) ) then
    begin
      if (n > 2) AND (n < 5) then
      begin
        if ww = 0 then
        begin
          ww := StrToInt(v);
          n := 0;
          v := '';
        end
        else
        begin
          hh := StrToInt(v);
          break;
        end;
      end
      else
      begin
        n := 0;
        v := '';
      end;
    end;
  end;

  if (ww > 0) and (hh > 0) then
  begin
    yuv_width := ww;
    yuv_height := hh;
    autoset_value(ww);
  end;
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
  try
    yuv_width  := StrToInt(Trim(MaskEdit1.Text));
    yuv_height := StrToInt(Trim(MaskEdit2.Text));
    yuv_stride[0] := StrToInt(Trim(MaskEdit3.Text));
    yuv_stride[1] := StrToInt(Trim(MaskEdit4.Text));
  finally

  end;
  calculate_value(yuv_width);

  if yuv_data[1] <> nil then
     FreeMem(yuv_data[1]);
  if yuv_data[2] <> nil then
     FreeMem(yuv_data[2]);
  yuv_data[1] := PByte(AllocMem(framesize + 1));
  yuv_data[2] := PByte(AllocMem(framesize + 1));
end;

procedure TForm3.ComboBox1Change(Sender: TObject);
begin
  pix_fmt := ComboBox1.ItemIndex;
  autoset_value(StrToInt(Trim(MaskEdit1.Text)));
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  yuv_data[1] := nil;
  yuv_data[2] := nil;
  yuv_display_mode := YUV_YUV;
  yuv_width := 720;
  yuv_height := 360;
  pix_fmt := YUV420p;
  autoset_value(yuv_width);
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  if yuv_data[1] <> nil then
     FreeMem(yuv_data[1]);
  if yuv_data[2] <> nil then
     FreeMem(yuv_data[2]);
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  ComboBox1.ItemIndex := pix_fmt;
  MaskEdit1.Text := IntToSTr(yuv_width);
  MaskEdit2.Text := IntToSTr(yuv_height);
  MaskEdit3.Text := IntToStr(yuv_stride[0]);
  MaskEdit4.Text := IntToStr(yuv_stride[1]);
end;

procedure TForm3.MaskEdit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Return then
  begin
    Button1Click(self);
    ModalResult := mrOk;
  end
  else
  begin
    try
      if ((Sender as TMaskEdit).Tag = 0) AND (Trim(MaskEdit1.Text) <> '') then
      begin
        yuv_width := StrToInt(Trim(MaskEdit1.Text));
        caption := IntToStr(yuv_width);
        yuv_height := guess_height(yuv_width);
        MaskEdit2.Text := IntToStr(yuv_height);
        autoset_value(yuv_width);
      end;
    finally
    end;
  end;
end;

procedure TForm3.MaskEdit2Change(Sender: TObject);
begin
  if Trim(MaskEdit2.Text) <> '' then
    yuv_height := StrToInt(Trim(MaskEdit2.Text));
end;

procedure TForm3.MaskEdit3Change(Sender: TObject);
begin
  if Trim(MaskEdit3.Text) <> '' then
    yuv_stride[0] := StrToInt(Trim(MaskEdit3.Text));
end;

procedure TForm3.MaskEdit4Change(Sender: TObject);
begin
  if Trim(MaskEdit4.Text) <> '' then
    yuv_stride[1] := StrToInt(Trim(MaskEdit4.Text));
end;

function TForm3.yuv_read_one_frame(filename: string; id, frm_inx: integer; frame_size: integer) : Boolean;
var
  fp : THandle;
  len : integer;
begin
  Result := False;
  fp := FileOpen(filename, fmOpenRead);
  if (fp <> invalid_handle_value) then begin
    if FileSeek(fp, frm_inx*frame_size, 0) <> -1 then
    begin
      len := FileRead(fp, yuv_data[id]^, frame_size);
      if len = frame_size then
        Result := True
      else if (len > 0) AND (len < frame_size) then
        FillMemory(@yuv_data[id][len], frame_size - len, 0);
    end;
    FileClose(fp);
  end;
end;

procedure TForm3.yuv_get_y(width, height: integer; stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var luma: Byte);
var
  inx : integer;
begin
  if (0<=x) AND (x<width) AND (0<=y) AND (y<height) then begin
    inx := y*stride[0] + x;
    luma := data[inx];
  end
  else
    luma := 0;
end;

procedure TForm3.rgb_get_rgb(width, height: integer; stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var r, g, b: Byte);
var
  inx : integer;
begin
  r := 0;
  g := 0;
  b := 0;
  if (0<=x) AND (x<width) AND (0<=y) AND (y<height) then begin
    if pix_fmt = RGB24 then  begin
      inx := y*stride[0] + 3*x;
      r := data[inx];
      g := data[inx + 1];
      b := data[inx + 2];
    end
    else if pix_fmt = BGR24 then begin
      inx := y*stride[0] + 3*x;
      r := data[inx + 2];
      g := data[inx + 1];
      b := data[inx];
    end
    else if pix_fmt = RGB888 then begin
      inx := y*stride[0] + x;
      r := data[inx];
      g := data[inx + height*stride[0]];
      b := data[inx + height*stride[0]*2];
    end
    else if pix_fmt = BGR888 then begin
      inx := y*stride[0] + x;
      r := data[inx + height*stride[0]*2];
      g := data[inx + height*stride[0]];
      b := data[inx];
    end;
    r := data[inx];
  end
end;

procedure TForm3.yuv_get_uv(width, height: integer; stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var u, v: Byte);
var
  inx : integer;
  width1, height1 : integer;
begin
  if pix_fmt = YUV420p then begin
    x := x div 2;
    y := y div 2;
    width1 := width div 2;
    height1 := height div 2;
  end else if pix_fmt = YUV400p then begin
    x := -1;
    y := -1;
    width1 := 0;
    height1 := 0;
  end else if pix_fmt = NV12 then begin
    y := y div 2;
    width1 := width;
    height1 := height div 2;
  end;

  if (0<=x) AND (x<width1) AND (0<=y) AND (y<height1) then begin
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

function TForm3.yuv_show_one_frame(width, height: integer; stride : array of Integer; pix_fmt: Integer; data: PByte):TBitMap;
var
  Y, U, V : Byte;
  R, G, B : Byte;
  Pixels: PRGBTripleArray;
  w, h : integer;
begin
  Result := TBitMap.Create;
  Result.PixelFormat := pf24bit;
  Result.Width := width;
  Result.Height := height;

  for h := 0 to Result.Height - 1 do
    begin
      Pixels := Result.ScanLine[h];
      for w := 0 to Result.Width - 1 do
      begin
        if pix_fmt >= RGB24 then
        begin
          rgb_get_rgb(width, height, stride, pix_fmt, data, w, h,
                      Pixels[w].rgbtRed, Pixels[w].rgbtGreen, Pixels[w].rgbtBlue);
          continue;
        end;

        if (yuv_display_mode AND YUV_Y) > 0 then
          yuv_get_y(width, height, stride, pix_fmt, data, w, h, Y);
        if yuv_display_mode > YUV_Y then
          yuv_get_uv(width, height, stride, pix_fmt, data, w, h, U, V)
        else
        begin
          U := Y;
          V := Y;
        end;

        if yuv_display_mode = YUV_YUV then
        begin
          YUV2RGB(Y, U, V, R, G, B);
        end
        else if yuv_display_mode = YUV_Y then
        begin
          R := Y;
          G := Y;
          B := Y;
        end
        else if yuv_display_mode = YUV_U then
        begin
          R := U;
          G := U;
          B := U;
        end
        else if yuv_display_mode = YUV_V then
        begin
          R := V;
          G := V;
          B := V;
        end;

        Pixels[w].rgbtRed   := R;
        Pixels[w].rgbtGreen := G;
        Pixels[w].rgbtBlue  := B;
      end;
    end;
end;

function TForm3.get_yuv_frame(filename: string; id, frame_inx: integer): TBitmap;
begin
  if yuv_read_one_frame(filename, id, frame_inx, framesize) then
    Result := yuv_show_one_frame(yuv_width, yuv_height, yuv_stride, pix_fmt, yuv_data[id])
  else
    Result := nil;
end;

function TForm3.get_current_frame(id: integer): TBitmap;
begin
  Result := yuv_show_one_frame(yuv_width, yuv_height, yuv_stride, pix_fmt, yuv_data[id])
end;

end.
