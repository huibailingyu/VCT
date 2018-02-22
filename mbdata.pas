unit mbdata;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls;

type
  TForm5 = class(TForm)
    DrawGrid0: TDrawGrid;
    DrawGrid5: TDrawGrid;
    DrawGrid3: TDrawGrid;
    DrawGrid8: TDrawGrid;
    DrawGrid4: TDrawGrid;
    DrawGrid9: TDrawGrid;
    DrawGrid1: TDrawGrid;
    DrawGrid2: TDrawGrid;
    DrawGrid6: TDrawGrid;
    DrawGrid7: TDrawGrid;
    procedure FormShow(Sender: TObject);
    procedure DrawGrid0DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
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

procedure TForm5.DrawGrid0DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  v, cx, s, inx, id: Byte;
  sx : string;
begin
  inx := (Sender As TDrawGrid).Tag;
  s := 16;
  if (inx = 1) OR (inx = 2) OR (inx = 6) OR (inx = 7) then
    s := 8;

  id := 1;
  if inx > 4 then
  begin
    id := 2;
    inx := inx - 5;
  end;

  if (inx >= 3) then
      inx := inx - 2;

  v := data_pixels[id, inx, ARow*s + ACol];

  if (((Sender As TDrawGrid).Tag = 0) AND (Not Form1.video[1].input_yuv)) OR
     (((Sender As TDrawGrid).Tag = 5) AND (Not Form1.video[2].input_yuv)) then
    (Sender As TDrawGrid).Canvas.Brush.Color := RGB(v, 16, 16)
  else
    (Sender As TDrawGrid).Canvas.Brush.Color := RGB(v, v, v);

  if ((Sender As TDrawGrid).Tag = 1) OR ((Sender As TDrawGrid).Tag = 2) OR
     ((Sender As TDrawGrid).Tag = 6) OR ((Sender As TDrawGrid).Tag = 7) then
    (Sender As TDrawGrid).Canvas.Brush.Color := RGB(v, v, v)
  else if ((Sender As TDrawGrid).Tag = 3) OR ((Sender As TDrawGrid).Tag = 8) then
    (Sender As TDrawGrid).Canvas.Brush.Color := RGB(16, v, 16)
  else if ((Sender As TDrawGrid).Tag = 4) OR ((Sender As TDrawGrid).Tag = 9) then
    (Sender As TDrawGrid).Canvas.Brush.Color := RGB(16, 16, v);

  sx := IntToStr(v);
  (Sender As TDrawGrid).Canvas.FillRect(Rect);
  if v < 64 then
    cx := 255
  else
    cx := 0;
  (Sender As TDrawGrid).Canvas.Font.Color := RGB(cx, cx, cx);
  (Sender As TDrawGrid).Canvas.TextOut(
           Rect.Left + (Rect.Right - Rect.Left - canvas.TextWidth(sx)) div 2,
           Rect.Top  + (Rect.Bottom - Rect.Top - canvas.TextHeight(sx)) div 2,
           sx);
end;

procedure TForm5.RefreshData;
begin
  DrawGrid0.Refresh;
  if Form1.video[1].input_yuv then
  begin
    DrawGrid1.Refresh;
    DrawGrid2.Refresh;
    DrawGrid3.Visible := False;
    DrawGrid4.Visible := False;
  end
  else
  begin
    DrawGrid1.Visible := False;
    DrawGrid2.Visible := False;
    DrawGrid3.Refresh;
    DrawGrid4.Refresh;
  end;

  if Form1.picture_number = 2 then
  begin
    DrawGrid5.Refresh;
    if Form1.video[1].input_yuv then
    begin
      DrawGrid6.Refresh;
      DrawGrid7.Refresh;
      DrawGrid8.Visible := False;
      DrawGrid9.Visible := False;
    end
    else
    begin
      DrawGrid6.Visible := False;
      DrawGrid7.Visible := False;
      DrawGrid8.Refresh;
      DrawGrid9.Refresh;
    end;
  end;
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

  if Form1.video[1].input_yuv then
    Form5.Height := 438
  else
    Form5.Height := 832;
  RefreshData;
end;

end.
