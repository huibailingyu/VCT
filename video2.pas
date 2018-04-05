unit video2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, WMPLib_TLB;

type
  TForm7 = class(TForm)
    WindowsMediaPlayer1: TWindowsMediaPlayer;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form7: TForm7;

implementation

uses main, video1;

{$R *.dfm}

procedure TForm7.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if NOT Form6.Showing then
  begin
    Form1.LeftRight1.Checked := False;
    Form1.TopBottom1.Checked := False;
  end;
end;

procedure TForm7.FormShow(Sender: TObject);
var
  filename : string;
begin
  filename := '';
  if Form1.video[2].FullFileName <> '' then
    filename := Form1.video[2].FullFileName;

  if filename <> '' then
  begin
    if (FileExists(filename)) and (not DirectoryExists(filename)) then
    begin
      Width := Form6.Width;
      Height := Form6.Height;
      if Form6.layout = 1 then
      begin
        Top := Form6.Top;
        Left := Form6.Left + Form6.Width;
      end
      else if Form6.layout = 2 then
      begin
        Left := Form6.Left;
        Top := Form6.Top + Form6.Height;
      end;

      Caption := ExtractFileName(filename);
      WindowsMediaPlayer1.settings.setMode('loop', true);
      //Caption := IntToStr(Width) + ' X ' + IntToStr(Height);
      WindowsMediaPlayer1.URL := filename;
      //WindowsMediaPlayer1.controls.play;
    end;
  end;
end;

end.
