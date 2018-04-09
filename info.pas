unit info;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ValEdit, ComCtrls, StdCtrls, ExtCtrls;

type
  TForm4 = class(TForm)
    PageControl1: TPageControl;
    TabSheet3: TTabSheet;
    DrawGrid1: TDrawGrid;
    DrawGrid2: TDrawGrid;
    RadioGroup1: TRadioGroup;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    TabSheet4: TTabSheet;
    StringGrid1: TStringGrid;
    Label1: TLabel;
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DrawGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure DrawGrid2SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure DrawGrid1DblClick(Sender: TObject);
    procedure DrawGrid2DblClick(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CombinStrings;
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    old_filename : array [1..2] of string;
    info : array [1..2] of TstringList;
  public
    { Public declarations }
    picture_number : Integer;
    filename : array [1..2] of string;
    select_mode : Integer;
    frame_select : array [1..2] of Integer;
    frame_number : array [1..2] of Integer;
    frame_size : array [1..2] of array of integer;
    frame_type : array [1..2] of array of integer;
  end;

var
  Form4: TForm4;

implementation

uses main, utils;

{$R *.dfm}

procedure TForm4.DrawGrid1DblClick(Sender: TObject);
var
  dif : Integer;
begin
  if select_mode = 0 then
  begin
    dif := 0;
    if Form1.picture_number > 1 then
      dif := Form1.video[1].FrameIndex - Form1.video[2].FrameIndex;
    Form1.SkipShowPicture(frame_select[1], frame_select[1] - dif, 2);
  end;
end;

procedure TForm4.DrawGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  dif : Integer;
begin
  frame_select[1] := ARow;
  if select_mode = 1 then
  begin
    dif := 0;
    if Form1.picture_number > 1 then
      dif := Form1.video[1].FrameIndex - Form1.video[2].FrameIndex;
    Form1.SkipShowPicture(frame_select[1], frame_select[1] - dif, 2);
  end;
end;

procedure TForm4.DrawGrid2DblClick(Sender: TObject);
var
  dif : Integer;
begin
  if select_mode = 0 then
  begin
    dif := Form1.video[1].FrameIndex - Form1.video[2].FrameIndex;
    Form1.SkipShowPicture(frame_select[2] + dif, frame_select[2], 2);
  end;
end;

procedure TForm4.DrawGrid2SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  dif : Integer;
begin
  frame_select[2] := ARow;
  if select_mode = 0 then
  begin
    dif := Form1.video[1].FrameIndex - Form1.video[2].FrameIndex;
    Form1.SkipShowPicture(frame_select[2] + dif, frame_select[2], 2);
  end;
end;

procedure TForm4.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  id, w : integer;
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
  info[1] := TstringList.Create;
  info[2] := TstringList.Create;
  Label1.Font := StringGrid1.Font;
end;

procedure TForm4.FormDestroy(Sender: TObject);
begin
  info[1].Free;
  info[2].Free;
end;

procedure TForm4.FormHide(Sender: TObject);
begin
  Form1.ShowInformation2.Checked := False;
end;

procedure TForm4.FormResize(Sender: TObject);
var
  w : integer;
begin
  // stream info
  if PageControl1.Pages[0].TabVisible then
  begin
    StringGrid1.ColWidths[0] := Label1.Width + 4;
    w := StringGrid1.Width - StringGrid1.ColWidths[0];
    if (GetWindowlong(StringGrid1.Handle, GWL_STYLE) and WS_VSCROLL) <> 0 then
      w := w - GetSystemMetrics(SM_CYVSCROLL);
    if picture_number > 1 then
    begin
      StringGrid1.ColWidths[1] := w div 2;
      StringGrid1.ColWidths[2] := w div 2;
    end
    else
      StringGrid1.ColWidths[1] := w;
  end;

  // frame info
  if PageControl1.Pages[1].TabVisible then
  begin
    if picture_number > 1 then
    begin
      DrawGrid2.Width := PageControl1.Pages[1].ClientWidth div 2;
      w := DrawGrid1.Width - DrawGrid1.ColWidths[0];
      if (GetWindowlong(DrawGrid1.Handle, GWL_STYLE) and WS_VSCROLL) <> 0 then
        w := w - GetSystemMetrics(SM_CYVSCROLL);
      DrawGrid1.ColWidths[1] := w;
      DrawGrid2.ColWidths[1] := w;
    end
    else
    begin
      DrawGrid2.Width := 0;
      w := DrawGrid1.Width - DrawGrid1.ColWidths[0];
      if (GetWindowlong(DrawGrid1.Handle, GWL_STYLE) and WS_VSCROLL) <> 0 then
        w := w - GetSystemMetrics(SM_CYVSCROLL);
      DrawGrid1.ColWidths[1] := w;
    end;
  end;
end;

procedure TForm4.CombinStrings;
var
  c1, c2, i, j : integer;
  SL : TStringList;
begin
  c1 := info[1].Count;
  c2 := info[2].Count;
  if c2 > 0 then
  begin
    SL := TStringList.Create;
    for i := 0 to c2 - 1 do
    begin
      SL.Clear;
      ExtractStrings(['='], [' '], PChar(info[2][i]), SL);
      j := info[1].IndexOfName(SL[0]);
      if (0<= j) and (j < c1) then
        info[1][j] := info[1][j] + '=' + SL[1]
      else
        info[1].Add(SL[0] + '=N/A=' + SL[1]);
    end;
    SL.Free;
  end;
end;

procedure TForm4.FormShow(Sender: TObject);
var
  id, I, w : integer;
  output : Tstrings;
  refresh : boolean;
  SL : TStringList;
begin
  PageControl1.Pages[1].TabVisible := False;
  if (Form1.video[1].FrameInfo <> nil) AND (Form1.video[1].FrameInfo.Count > 0) then
  begin
    PageControl1.Pages[1].TabVisible := True;
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

  refresh := False;
  for id := 1 to picture_number do
  begin
    if (filename[id] <> '') AND (filename[id] <> old_filename[id]) then
    begin
      output := ffprobeStreamInfo(filename[id]);
      if output <> nil then
      begin
        refresh := True;
        if id = 1 then
        begin
          info[1].Clear;
          info[1].Add('filename=' + ExtractFileName(filename[id]));
          info[1].AddStrings(output);

        end else begin
          info[2].Clear;
          info[2].Add('filename=' + ExtractFileName(filename[id]));
          info[2].AddStrings(output);

          CombinStrings;
        end;
        output.Free;
        old_filename[id] := filename[id];
      end;
    end;
  end;

  if refresh then
  begin
    StringGrid1.ColCount := 1 + picture_number;
    StringGrid1.RowCount := info[1].Count;

    StringGrid1.ColWidths[0] := Label1.Width + 4;
    w := StringGrid1.Width - StringGrid1.ColWidths[0];
    if picture_number > 1 then
    begin
      StringGrid1.ColWidths[1] := w div 2;
      StringGrid1.ColWidths[2] := w div 2;
    end
    else
      StringGrid1.ColWidths[1] := w;

    SL := TStringList.Create;
    for I := 0 to info[1].Count - 1 do
    begin
      SL.Clear;
      ExtractStrings(['='], [' '], PChar(info[1][I]), SL);
      StringGrid1.Rows[I].AddStrings(SL);
    end;
    SL.Free;
  end;
end;

procedure TForm4.RadioButton1Click(Sender: TObject);
begin
  select_mode := (Sender as TRadioButton).Tag;
end;

procedure TForm4.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  SL : TStringList;
  text : string;
begin
  if (picture_number > 1) and (ACol > 0)then
  begin
    SL := TStringList.Create;
    ExtractStrings(['='], [' '], PChar(info[1][ARow]), SL);
    if (SL.Count > 2) and (SL[1] <> SL[2]) then
    begin
      text := SL[ACol];
      with (Sender As TStringGrid).Canvas do
      begin
        Font.Color := RGB(235, 16, 16);
        TextOut(Rect.Left + 2, Rect.Top  + (Rect.Bottom - Rect.Top - TextHeight(text)) div 2, text);
      end;
    end;
    SL.Free;
  end;
end;

end.
