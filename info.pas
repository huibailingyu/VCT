unit info;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ValEdit, ComCtrls;

type
  TForm4 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ValueListEditor1: TValueListEditor;
    ValueListEditor2: TValueListEditor;
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    old_filename : array [1..2] of string;
  public
    { Public declarations }
    picture_number : Integer;
    filename : array [1..2] of string;
  end;

var
  Form4: TForm4;

implementation

uses main, utils;

{$R *.dfm}

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
