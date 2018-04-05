unit video1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MPlayer, ExtCtrls, OleCtrls, WMPLib_TLB;

type
  TForm6 = class(TForm)
    WindowsMediaPlayer1: TWindowsMediaPlayer;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure WindowsMediaPlayer1KeyDown(ASender: TObject; nKeyCode,
      nShiftState: SmallInt);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  protected
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
  private
    { Private declarations }
  public
    layout : integer;
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

uses main, video2;

{$R *.dfm}

procedure TForm6.WMMove(var Message: TWMMove);
begin
  if Assigned(Form7) then
  begin
    if layout = 1 then
    begin
      Form7.Left := Left + Width;
      Form7.Top := Top;
    end
    else if layout = 2 then
    begin
      Form7.Left := Left;
      Form7.Top := Top + Height;
    end;
  end;
  inherited;
end;

procedure TForm6.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if NOT Form7.Showing then
  begin
    Form1.LeftRight1.Checked := False;
    Form1.TopBottom1.Checked := False;
  end;
end;

procedure TForm6.FormResize(Sender: TObject);
begin
  if Assigned(Form7) then
  begin
    Form7.Width := Width;
    Form7.Height := Height;
    if layout = 1 then
    begin
      Form7.Top := Top;
      Form7.Left := Left + Width;
    end
    else if layout = 2 then
    begin
      Form7.Left := Left;
      Form7.Top := Top + Height;
    end;
  end;
end;

procedure TForm6.FormShow(Sender: TObject);
var
  filename : string;
begin
  filename := '';
  if Form1.video[1].FullFileName <> '' then
    filename := Form1.video[1].FullFileName;

  if filename <> '' then
  begin
    if (FileExists(filename)) and (not DirectoryExists(filename)) then
    begin
      Caption := ExtractFileName(filename);
      WindowsMediaPlayer1.settings.setMode('loop', true);
      WindowsMediaPlayer1.URL := filename;

      Top := 0;
      Left := 0;
      if layout = 2 then
      begin
        Width := Screen.Width;
        Height := Screen.Height div 2;
      end
      else
      begin
        Width := Screen.Width div 2;
        Height := Screen.Height;
      end;

      WindowsMediaPlayer1.controls.play;
      if Assigned(Form7) and (Form7.WindowsMediaPlayer1.URL <> '') then
        Form7.WindowsMediaPlayer1.controls.play;
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
      if WindowsMediaPlayer1.playState = wmppsPaused then //ÔÝÍ£
      begin
        WindowsMediaPlayer1.controls.play;
        if Assigned(Form7) and (Form7.WindowsMediaPlayer1.URL <> '') then
          Form7.WindowsMediaPlayer1.controls.play;
      end
      else if  WindowsMediaPlayer1.playState = wmppsPlaying then//Õý²¥·Å
      begin
        WindowsMediaPlayer1.controls.pause;
        if Assigned(Form7) and (Form7.WindowsMediaPlayer1.URL <> '') then
          Form7.WindowsMediaPlayer1.controls.pause;
      end
      else
      begin
        WindowsMediaPlayer1.controls.play;
        if Assigned(Form7) and (Form7.WindowsMediaPlayer1.URL <> '') then
          Form7.WindowsMediaPlayer1.controls.play;
      end;
    end;
    VK_ESCAPE:
    begin
    end;
  end;
end;

end.
