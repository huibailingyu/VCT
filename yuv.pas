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
    procedure MaskEdit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    width : array [0..2] of Integer;
    height : array [0..2] of Integer;
    stride : array [0..2] of Integer;
    pix_fmt : Integer;
    ysize : integer;
    uvsize: integer;
    framesize : integer;
    yuv_display_mode : integer;
    yuv_data : array [1..2] of PByte;
    procedure guess_height;
    procedure calculate_value(linesize0, linesize1 : integer);
    procedure paser_filename(filename: string);

    procedure yuv_get_y(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var luma: Byte);
    procedure yuv_get_uv(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var u, v: Byte);

    function yuv_read_one_frame(filename: string; id, frm_inx: integer; frame_size: integer) : Boolean;
    function yuv_show_one_frame(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte):TBitMap;
    function get_yuv_frame(filename: string; id, frame_inx: integer) : TBitmap;
    function get_current_frame(id: integer): TBitmap;
  end;

var
  Form3: TForm3;

implementation

uses utils;

{$R *.dfm}
procedure TForm3.calculate_value(linesize0, linesize1 : integer);
begin
  stride[0] := linesize0;
  if pix_fmt = YUV420p then begin
    width[1] := width[0] div 2;
    height[1] := height[0] div 2;
    stride[1] := linesize1;
  end
  else if pix_fmt = YUV400p then begin
    width[1] := 0;
    height[1] := 0;
    stride[1] := 0;
  end
  else if pix_fmt = NV12 then begin
    width[1] := width[0];
    height[1] := height[0] div 2;
    stride[1] := linesize1;
  end
  else if pix_fmt = YUV444p then  begin
    width[1] := width[0];
    height[1] := height[0];
    stride[1] := linesize1;
  end
  else begin
    width[1] := width[0] div 2;
    height[1] := height[0] div 2;
    stride[1] := linesize1;
  end;

  width[2] := width[1];
  height[2] := height[1];
  stride[2] := stride[1];

  ysize := height[0] * stride[0];
  uvsize := height[1] * stride[1];
  framesize := ysize + uvsize + uvsize;
end;

procedure TForm3.guess_height;
begin
  if width[0] = 352 then
    height[0] := 176
  else if width[0] = 720 then
    height[0] := 576
  else if width[0] = 640 then
    height[0] := 320
  else if width[0] = 1024 then
    height[0] := 512
  else if width[0] = 1920 then
    height[0] := 1080
  else if width[0] = 2048 then
    height[0] := 1024
  else if width[0] = 4096 then
    height[0] := 2048
  else if width[0] < 2048 then
    height[0] := width[0]
  else
    height[0] := width[0] div 2;
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
      if n > 1 then
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
    width[0] := ww;
    height[0] := hh;
    calculate_value(ww, ww div 2);
  end;
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
  try
    width[0]  := StrToInt(Trim(MaskEdit1.Text));
    height[0] := StrToInt(Trim(MaskEdit2.Text));
    stride[0] := StrToInt(Trim(MaskEdit3.Text));
    stride[1] := StrToInt(Trim(MaskEdit4.Text));
    calculate_value(stride[0], stride[1]);
  finally

  end;

  ysize := height[0] * stride[0];
  uvsize := height[1] * stride[1];
  framesize := ysize + uvsize + uvsize;
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
  calculate_value(width[0], width[0] div 2);
  MaskEdit3.Text := IntToStr(stride[0]);
  MaskEdit4.Text := IntToStr(stride[1]);
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  yuv_data[1] := nil;
  yuv_data[2] := nil;
  yuv_display_mode := YUV_YUV;
  width[0] := 720;
  height[0] := 360;
  pix_fmt := YUV420p;
  calculate_value(width[0], width[0] div 2);
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
  MaskEdit1.Text := IntToSTr(width[0]);
  MaskEdit2.Text := IntToSTr(height[0]);
  MaskEdit3.Text := IntToStr(stride[0]);
  MaskEdit4.Text := IntToStr(stride[1]);
end;

procedure TForm3.MaskEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  try
    if Trim(MaskEdit1.Text) <> '' then begin
      width[0] := StrToInt(Trim(MaskEdit1.Text));
      guess_height;
      MaskEdit2.Text := IntToStr(height[0]);
      calculate_value(width[0], width[0] div 2);
      MaskEdit3.Text := IntToStr(stride[0]);
      MaskEdit4.Text := IntToStr(stride[1]);
    end;
  finally
  end;
end;

procedure TForm3.MaskEdit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Return then
  begin
    Button1Click(self);
    ModalResult := mrOk;
  end;
end;

procedure TForm3.MaskEdit2Change(Sender: TObject);
begin
  if Trim(MaskEdit2.Text) <> '' then
    height[0] := StrToInt(Trim(MaskEdit2.Text));
end;

procedure TForm3.MaskEdit3Change(Sender: TObject);
begin
  if Trim(MaskEdit3.Text) <> '' then
    stride[0] := StrToInt(Trim(MaskEdit3.Text));
end;

procedure TForm3.MaskEdit4Change(Sender: TObject);
begin
  if Trim(MaskEdit4.Text) <> '' then
    stride[1] := StrToInt(Trim(MaskEdit4.Text));
  stride[2] := stride[1];
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

procedure TForm3.yuv_get_y(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var luma: Byte);
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

procedure TForm3.yuv_get_uv(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var u, v: Byte);
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

function TForm3.yuv_show_one_frame(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte):TBitMap;
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
          R := Y + 1.403 * (V - 128) + 0.5;
          G := Y - 0.343 * (U - 128) - 0.714 * (V - 128) + 0.5;
          B := Y + 1.770 * (U - 128) + 0.5;
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
end;

function TForm3.get_yuv_frame(filename: string; id, frame_inx: integer): TBitmap;
begin
  if yuv_read_one_frame(filename, id, frame_inx, framesize) then
    Result := yuv_show_one_frame(width, height, stride, pix_fmt, yuv_data[id])
  else
    Result := nil;
end;

function TForm3.get_current_frame(id: integer): TBitmap;
begin
  Result := yuv_show_one_frame(width, height, stride, pix_fmt, yuv_data[id])
end;

end.
