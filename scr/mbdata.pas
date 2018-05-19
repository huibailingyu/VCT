unit mbdata;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Menus;

type
  TForm5 = class(TForm)
    DrawGrid0: TDrawGrid;
    DrawGrid3: TDrawGrid;
    DrawGrid1: TDrawGrid;
    DrawGrid2: TDrawGrid;
    DrawGrid4: TDrawGrid;
    DrawGrid5: TDrawGrid;
    PopupMenu1: TPopupMenu;
    hreshold01: TMenuItem;
    ShowUVdata1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure DrawGrid0DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure hreshold01Click(Sender: TObject);
    procedure ShowUVdata1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    diff_threshold : integer;
    show_uv : Boolean;
    data_pixels : array [1..2, 0..2, 0..255] of Byte;  // [id, chanel, pixel]
    procedure GetBlockData(mbx, mby : Integer);
    procedure RefreshData;
  end;

var
  Form5: TForm5;

implementation

uses main, utils, yuv;

{$R *.dfm}

procedure TForm5.GetBlockData(mbx, mby: Integer);
var
  id, x, y, xx, yy, s, k, k1: integer;
  r, g, b : Byte;
  rgb: PRGBTripleArray;
  rgba : PRGBATripleArray;
  p : pointer;
begin
  caption := '[' + IntToStr(mbx) + ',' + IntToStr(mby) + ']';
  xx := mbx * 16;
  yy := mby * 16;
  for id := 1 to Form1.picture_number do
  begin
    if not Form1.video[id].input_yuv then   // RGB
    begin
      k := 0;
      k1 := 0;
      for y := yy to yy + 15 do
      begin
         if Form1.video[id].BitMap.PixelFormat = pf24bit then
           rgb := Form1.video[id].BitMap.ScanLine[y]
         else
           rgba := Form1.video[id].BitMap.ScanLine[y];

        for x := xx to xx + 15 do
        begin
          if Form1.video[id].BitMap.PixelFormat = pf24bit then
          begin
            r := rgb[x].rgbtRed;
            g := rgb[x].rgbtGreen;
            b := rgb[x].rgbtBlue;
          end
          else
          begin
            r := rgba[x].rgbtRed;
            g := rgba[x].rgbtGreen;
            b := rgba[x].rgbtBlue;
          end;

          RGB2Y(r, g, b, data_pixels[id, 0, k]);
          if (((y-yy) mod 2) = 0) AND (((x-xx) mod 2) = 0) then
          begin
            RGB2UV(r, g, b, data_pixels[id, 1, k1], data_pixels[id, 2, k1]);
            k1 := k1 + 1;
          end;
          k := k + 1;
        end;
      end;
    end
    else                  // YUV
    begin
      k := 0;
      k1 := 0;
      for y := yy to yy + 15 do
        for x := xx to xx + 15 do
        begin
          Form3.yuv_get_y(Form3.yuv_width, Form3.yuv_height, Form3.yuv_stride,
                          Form3.pix_fmt, Form3.yuv_data[id], x, y, data_pixels[id, 0, k]);
          k := k + 1;

          if (y mod 2 = 0) AND (x mod 2 = 0) then
          begin
            Form3.yuv_get_uv(Form3.yuv_width, Form3.yuv_height, Form3.yuv_stride,
                             Form3.pix_fmt, Form3.yuv_data[id], x, y,
                             data_pixels[id, 1, k1], data_pixels[id, 2, k1]);
            k1 := k1 + 1;
          end;
        end;
    end;
  end;
end;

procedure TForm5.hreshold01Click(Sender: TObject);
var
  str : string;
  v : integer;
begin
  str := InputBox('Input', 'Input Pixel Different threshold', IntToStr(diff_threshold));
  try
    v := STrToInt(str);

  except
    v := diff_threshold;
  end;

  if diff_threshold <> v then
  begin
    diff_threshold := v;
    hreshold01.Caption := 'Threshold (' + IntToStr(v) + ')';
    RefreshData;
  end;
end;

procedure TForm5.DrawGrid0DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  v, cx, s, inx, id, k: Byte;
  sx : string;
begin
  inx := (Sender As TDrawGrid).Tag;
  s := 8;
  if (inx = 0) OR (inx = 3) then
    s := 16;

  id := 1;
  if inx >= 3 then
  begin
    id := 2;
    inx := inx - 3;
  end;

  k := ARow*s + ACol;
  v := data_pixels[id, inx, k];
  (Sender As TDrawGrid).Canvas.Brush.Color := RGB(v, v, v);

  sx := IntToStr(v);
  (Sender As TDrawGrid).Canvas.FillRect(Rect);

  if (Form1.picture_number > 1) AND
     (abs(data_pixels[1, inx, k] - data_pixels[2, inx, k]) > diff_threshold) then
    (Sender As TDrawGrid).Canvas.Font.Color := RGB(255, 16, 16)
  else
  begin
    if v < 64 then
      cx := 255
    else
      cx := 0;
    (Sender As TDrawGrid).Canvas.Font.Color := RGB(cx, cx, cx);
  end;

  (Sender As TDrawGrid).Canvas.TextOut(
           Rect.Left + (Rect.Right - Rect.Left - canvas.TextWidth(sx)) div 2,
           Rect.Top  + (Rect.Bottom - Rect.Top - canvas.TextHeight(sx)) div 2,
           sx);
end;

procedure TForm5.RefreshData;
begin
  DrawGrid0.Refresh;
  DrawGrid1.Refresh;
  DrawGrid2.Refresh;
  if Form1.picture_number = 2 then
  begin
    DrawGrid3.Refresh;
    DrawGrid4.Refresh;
    DrawGrid5.Refresh;
  end;
end;

procedure TForm5.ShowUVdata1Click(Sender: TObject);
begin
  ShowUVdata1.Checked := not ShowUVdata1.Checked;
  show_uv := ShowUVdata1.Checked;
  FormShow(Self);
end;

procedure TForm5.FormCreate(Sender: TObject);
begin
  diff_threshold := 0;
  show_uv := True;
  ShowUVdata1.Checked := show_uv;
end;

procedure TForm5.FormShow(Sender: TObject);
var
  id, c, x, y : integer;
  s : string;
begin
  if Form1.picture_number = 2 then
    Form5.Width := 734
  else
    Form5.Width := 367;

  if show_uv then
    Form5.Height := 430
  else
    Form5.Height := 290;

  RefreshData;
end;

end.
