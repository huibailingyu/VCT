unit video1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MPlayer, ExtCtrls, OleCtrls, WMPLib_TLB;

type
  TForm6 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    WindowsMediaPlayer1: TWindowsMediaPlayer;
    WindowsMediaPlayer2: TWindowsMediaPlayer;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure WindowsMediaPlayer1KeyDown(ASender: TObject; nKeyCode,
      nShiftState: SmallInt);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    layout : integer;
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

uses main;

{$R *.dfm}

procedure TForm6.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form1.MediaPlayer1.Checked := False;
end;

procedure TForm6.FormResize(Sender: TObject);
begin
  Panel1.Left := 0;
  Panel1.Top := 0;
  if layout = 1 then
  begin
    Panel1.Width := ClientWidth div 2;
    Panel1.Height := ClientHeight;

    Panel2.Left := Panel1.Width;
    Panel2.Top := Panel1.Top;
  end
  else if layout = 2 then
  begin
    Panel1.Width := ClientWidth;
    Panel1.Height := ClientHeight div 2;

    Panel2.Left := Panel1.Left;
    Panel2.Top := Panel1.Height;
  end
  else if layout = 0 then
  begin
    Panel1.Width := ClientWidth;
    Panel1.Height := ClientHeight;
    Panel2.Visible := False;
  end;

  if layout > 0 then
  begin
    Panel2.Visible := True;
    Panel2.Width := Panel1.Width;
    Panel2.Height := Panel1.Height;
  end;
end;

procedure TForm6.FormShow(Sender: TObject);
var
  filename1, filename2 : string;
begin
  if Form1.picture_number > 1 then
  begin
    filename1 := '';
    if Form1.video[1].FullFileName <> '' then
      filename1 := Form1.video[1].FullFileName;

    filename2 := '';
    if Form1.video[2].FullFileName <> '' then
      filename2 := Form1.video[2].FullFileName;

    if (filename1 <> '') and (filename2 <> '') then
    begin
      if (FileExists(filename1)) and (not DirectoryExists(filename1)) and
         (FileExists(filename2)) and (not DirectoryExists(filename2)) then
      begin
        Caption := ExtractFileName(filename1) + ' | ' + ExtractFileName(filename2);
        layout := 1;
        WindowsMediaPlayer1.settings.setMode('loop', true);
        WindowsMediaPlayer1.URL := filename1;

        WindowsMediaPlayer2.settings.setMode('loop', true);
        WindowsMediaPlayer2.URL := filename2;

        Form6.SetBounds(Screen.Width div 4, Screen.Height div 4, Screen.Width div 2, Screen.Height div 2);
        WindowsMediaPlayer1.controls.play;
        WindowsMediaPlayer2.controls.play;
      end;
    end;
  end
  else if Form1.picture_number = 1 then
  begin
    filename1 := '';
    if Form1.video[1].FullFileName <> '' then
      filename1 := Form1.video[1].FullFileName;

    if filename1 <> ''then
    begin
      if (FileExists(filename1)) and (not DirectoryExists(filename1)) then
      begin
        Caption := ExtractFileName(filename1);
        layout := 0;
        WindowsMediaPlayer1.settings.setMode('loop', true);
        WindowsMediaPlayer1.URL := filename1;

        Form6.SetBounds(Screen.Width div 4, Screen.Height div 4, Screen.Width div 2, Screen.Height div 2);
        WindowsMediaPlayer1.controls.play;
      end;
    end;
  end;

end;

procedure TForm6.WindowsMediaPlayer1KeyDown(ASender: TObject; nKeyCode,
  nShiftState: SmallInt);
begin
  case nKeyCode of
    VK_LEFT:
    begin
      WindowsMediaPlayer1.controls.currentPosition := WindowsMediaPlayer1.controls.currentPosition - 1;
      WindowsMediaPlayer1.controls.pause;
    end;
    VK_RIGHT:
    begin
      WindowsMediaPlayer1.controls.currentPosition := WindowsMediaPlayer1.controls.currentPosition + 1;
      WindowsMediaPlayer1.controls.pause;
    end;
    VK_UP:
    begin
    end;
    VK_SPACE:
    begin
      if WindowsMediaPlayer1.playState = wmppsPaused then
      begin
        WindowsMediaPlayer1.controls.play;
        if layout > 0 then
          WindowsMediaPlayer2.controls.play;
      end
      else if  WindowsMediaPlayer1.playState = wmppsPlaying then
      begin
        WindowsMediaPlayer1.controls.pause;
        if layout > 0 then
        begin
          WindowsMediaPlayer2.controls.currentPosition := WindowsMediaPlayer1.controls.currentPosition;
          WindowsMediaPlayer2.controls.pause;
        end;
      end
      else
      begin
        WindowsMediaPlayer1.controls.play;
        if layout > 0 then
          WindowsMediaPlayer2.controls.play;
      end;
    end;
    VK_ESCAPE:
    begin
    end;
  end;
end;

end.
