unit yuvsetting;

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
    procedure MaskEdit1Change(Sender: TObject);
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
    procedure guess_height;
    procedure calculate_value(linesize0, linesize1 : integer);

    procedure yuv_get_y(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var luma: Byte);
    procedure yuv_get_uv(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte; x, y:integer; var u, v: Byte);

    function yuv_read_one_frame(filename: string; frm_inx: integer; frame_size: integer) : PByte;
    function yuv_show_one_frame(width, height, stride : array of Integer; pix_fmt: Integer; data: PByte):TBitMap;
    function get_yuv_frame(filename: string; frame_inx: integer) : TBitmap;
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
end;

procedure TForm3.guess_height;
//var
  //i : integer;
  //pair : array[0..4, 0..1] of integer = ((176, 144), (352, 288), (720, 576), (1920, 1080), (2048, 1024));
begin
  height[0] := 0;
  //for I := 0 to 4 do
  //  if width = pair[i,0] then
  //    height := pair[i,1];
  if height[0] = 0 then
    height[0] := width[0];
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
  caption := IntToStr(width[0]) + 'x' + IntToStr(height[0]) + '  ' + IntToStr(stride[0]) + 'x' + IntToStr(stride[1])
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
  width[0] := 720;
  height[0] := 360;
  calculate_value(width[0], width[0] div 2);
  pix_fmt := YUV420p;
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  ComboBox1.ItemIndex := pix_fmt;
  MaskEdit1.Text := IntToSTr(width[0]);
  MaskEdit2.Text := IntToSTr(height[0]);
  MaskEdit3.Text := IntToStr(stride[0]);
  MaskEdit4.Text := IntToStr(stride[1]);
end;

procedure TForm3.MaskEdit1Change(Sender: TObject);
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

function TForm3.yuv_read_one_frame(filename: string; frm_inx: integer; frame_size: integer) : PByte;
var
  fp : THandle;
  len : integer;
begin
  Result := PByte(AllocMem(frame_size + 1));
  if Result <> nil then begin
    fp := FileOpen(filename, fmOpenRead);
    if (fp <> invalid_handle_value) then begin
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
end;

function TForm3.get_yuv_frame(filename: string; frame_inx: integer) : TBitmap;
var
  yuv_data : PByte;
begin
  yuv_data := yuv_read_one_frame(filename, frame_inx, framesize);
  Result := yuv_show_one_frame(width, height, stride, pix_fmt, yuv_data);
  FreeMem(yuv_data);
end;

end.
