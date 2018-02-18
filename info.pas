unit info;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ValEdit, ComCtrls, StdCtrls;

type
  TForm4 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ValueListEditor1: TValueListEditor;
    ValueListEditor2: TValueListEditor;
    TabSheet4: TTabSheet;
    PageControl2: TPageControl;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet3: TTabSheet;
    DrawGrid1: TDrawGrid;
    DrawGrid2: TDrawGrid;
    DrawGrid3: TDrawGrid;
    DrawGrid4: TDrawGrid;
    DrawGrid5: TDrawGrid;
    DrawGrid6: TDrawGrid;
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
    old_filename : array [1..2] of string;
  public
    { Public declarations }
    picture_number : Integer;
    filename : array [1..2] of string;
    data_pixels : array [0..2, 0..255] of Byte;
  end;

var
  Form4: TForm4;

implementation

uses main, utils;

{$R *.dfm}

procedure TForm4.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  v, cx, s, inx: Byte;
  sx : string;
begin
  s := 16;
  inx := (Sender As TDrawGrid).Tag;
  if (inx = 1) OR (inx = 2) then
    s := 8
  else
  begin
    if inx >= 3 then
      inx := inx - 3;
  end;
  v := data_pixels[inx, ARow*s + ACol];

  if (Sender As TDrawGrid).Tag < 3 then
    (Sender As TDrawGrid).Canvas.Brush.Color := RGB(v, v, v)
  else if (Sender As TDrawGrid).Tag = 3 then
    (Sender As TDrawGrid).Canvas.Brush.Color := RGB(v, 16, 16)
  else if (Sender As TDrawGrid).Tag = 4 then
    (Sender As TDrawGrid).Canvas.Brush.Color := RGB(16, v, 16)
  else if (Sender As TDrawGrid).Tag = 5 then
    (Sender As TDrawGrid).Canvas.Brush.Color := RGB(16, 16, v);

  sx := IntToStr(v);
  (Sender As TDrawGrid).Canvas.FillRect(Rect);
  if v < 128 then
    cx := 255
  else
    cx := 0;
  (Sender As TDrawGrid).Canvas.Font.Color := RGB(cx, cx, cx);
  (Sender As TDrawGrid).Canvas.TextOut(
           Rect.Left + (Rect.Right - Rect.Left - canvas.TextWidth(sx)) div 2,
           Rect.Top  + (Rect.Bottom - Rect.Top - canvas.TextHeight(sx)) div 2,
           sx);
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  old_filename[1] := '';
  old_filename[2] := '';
  filename[1] := '';
  filename[2] := '';
end;

procedure TForm4.FormHide(Sender: TObject);
begin
  Form1.ShowInformation2.Checked := False;
end;

procedure TForm4.FormShow(Sender: TObject);
var
  id : integer;
  output : Tstrings;
begin
  PageControl1.Pages[0].TabVisible := False;
  if picture_number > 0 then
    PageControl1.Pages[0].TabVisible := True;
  PageControl1.Pages[1].TabVisible := False;
  if picture_number > 1 then
    PageControl1.Pages[1].TabVisible := True;
  if Form1.show_data_type = 1 then
    PageControl1.Pages[2].TabVisible := True
  else
    PageControl1.Pages[2].TabVisible := False;
  if Form1.show_data_type = 2 then
    PageControl1.Pages[3].TabVisible := True
  else
    PageControl1.Pages[3].TabVisible := False;


  for id := 1 to picture_number do
  begin
    if (filename[id] <> '') AND (filename[id] <> old_filename[id]) then
    begin
      output := ffprobeStreamInfo(filename[id]);
      if output <> nil then
      begin
        if id = 1 then
        begin
          ValueListEditor1.Strings.Clear;
          ValueListEditor1.Strings.Add('filename=' + filename[id]);
          ValueListEditor1.Strings.AddStrings(output);
        end else begin
          ValueListEditor2.Strings.Clear;
          ValueListEditor2.Strings.Add('filename=' + filename[id]);
          ValueListEditor2.Strings.AddStrings(output);
        end;
        output.Free;
        old_filename[id] := filename[id];
      end;
    end;
  end;

  if PageControl1.Pages[2].TabVisible then
  begin
    DrawGrid1.Refresh;
    DrawGrid2.Refresh;
    DrawGrid3.Refresh;
  end;
  if PageControl1.Pages[3].TabVisible then
  begin
    DrawGrid4.Refresh;
    DrawGrid5.Refresh;
    DrawGrid6.Refresh;
  end;

end;

end.
