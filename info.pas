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
    TabSheet3: TTabSheet;
    DrawGrid1: TDrawGrid;
    DrawGrid2: TDrawGrid;
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

    frame_number : array [1..2] of Integer;
    frame_size : array [1..2] of array of integer;
    frame_type : array [1..2] of array of integer;
  end;

var
  Form4: TForm4;

implementation

uses main, utils;

{$R *.dfm}

procedure TForm4.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  id, v, w : integer;
  inx : string;
begin
  if ACol = 0 then
  begin
    inx := IntToStr(ARow);
    (Sender As TDrawGrid).Canvas.TextOut(
        Rect.Left + (Rect.Right - Rect.Left - canvas.TextWidth(inx)) div 2,
        Rect.Top  + (Rect.Bottom - Rect.Top - canvas.TextHeight(inx)) div 2,
        inx)
  end
  else
  begin
    id := (Sender As TDrawGrid).Tag;
    inx := IntToStr(frame_size[id, ARow]) + ' ';
    if frame_type[id, ARow] = 0 then begin
      inx := inx + 'I';
      (Sender As TDrawGrid).Canvas.Brush.Color := RGB(235, 16, 16);
    end
    else if frame_type[id, ARow] = 1 then begin
      inx := inx + 'P';
      (Sender As TDrawGrid).Canvas.Brush.Color := RGB(16, 16, 235);
    end
    else if frame_type[id, ARow] = 2 then begin
      inx := inx + 'B';
      (Sender As TDrawGrid).Canvas.Brush.Color := RGB(16, 235, 16);
    end
    else begin
      inx := inx + 'N';
      (Sender As TDrawGrid).Canvas.Brush.Color := RGB(16, 16, 16);
    end;

    w := Round(frame_size[id, ARow] * (Rect.Right - Rect.Left) / frame_size[id, 0]);
    (Sender As TDrawGrid).Canvas.Rectangle(Rect.Left, Rect.Top, Rect.Left + w, Rect.Bottom);

    (Sender As TDrawGrid).Canvas.Brush.Color := RGB(255, 255, 255);
    (Sender As TDrawGrid).Canvas.Font.Color := RGB(16, 16, 16);
    (Sender As TDrawGrid).Canvas.TextOut(
        Rect.Right - canvas.TextWidth(inx) - 4,
        Rect.Top  + (Rect.Bottom - Rect.Top - canvas.TextHeight(inx)) div 2,
        inx);
  end;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  old_filename[1] := '';
  old_filename[2] := '';
  filename[1] := '';
  filename[2] := '';
  frame_number[1] := 0;
  frame_number[2] := 0;
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

  PageControl1.Pages[2].TabVisible := False;
  if (Form1.video[1].FrameInfo <> nil) AND (Form1.video[1].FrameInfo.Count > 0) then
  begin
    PageControl1.Pages[2].TabVisible := True;
    SetLength(frame_size[1], Form1.video[1].FrameInfo.Count);
    SetLength(frame_type[1], Form1.video[1].FrameInfo.Count);
    frame_number[1] := ParserFrameInfo(Form1.video[1].FrameInfo, frame_size[1], frame_type[1]);
    DrawGrid1.RowCount := frame_number[1];
    if (Form1.video[2].FrameInfo <> nil) AND (Form1.video[2].FrameInfo.Count > 0) then
    begin
      SetLength(frame_size[2], Form1.video[2].FrameInfo.Count);
      SetLength(frame_type[2], Form1.video[2].FrameInfo.Count);
      frame_number[2] := ParserFrameInfo(Form1.video[2].FrameInfo, frame_size[2], frame_type[2]);
      DrawGrid2.Visible := True;
      DrawGrid2.RowCount := frame_number[2];
    end
    else
      DrawGrid2.Visible := False;
  end;

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
end;

end.
