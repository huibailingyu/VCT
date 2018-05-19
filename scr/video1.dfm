object Form6: TForm6
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Form6'
  ClientHeight = 362
  ClientWidth = 704
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 352
    Height = 362
    Caption = 'Panel1'
    TabOrder = 0
    object WindowsMediaPlayer1: TWindowsMediaPlayer
      Left = 1
      Top = 1
      Width = 350
      Height = 360
      Align = alClient
      TabOrder = 0
      OnKeyDown = WindowsMediaPlayer1KeyDown
      ExplicitWidth = 245
      ExplicitHeight = 240
      ControlData = {
        000300000800000000000500000000000000F03F030000000000050000000000
        0000000008000200000000000300010000000B00FFFF0300000000000B00FFFF
        08000200000000000300320000000B00000008000A000000660075006C006C00
        00000B0000000B0000000B00FFFF0B00FFFF0B00000008000200000000000800
        020000000000080002000000000008000200000000000B0000002C2400003525
        0000}
    end
  end
  object Panel2: TPanel
    Left = 352
    Top = 0
    Width = 352
    Height = 362
    Caption = 'Panel2'
    TabOrder = 1
    object WindowsMediaPlayer2: TWindowsMediaPlayer
      Left = 1
      Top = 1
      Width = 350
      Height = 360
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 245
      ExplicitHeight = 240
      ControlData = {
        000300000800000000000500000000000000F03F030000000000050000000000
        0000000008000200000000000300010000000B00FFFF0300000000000B00FFFF
        08000200000000000300320000000B00000008000A000000660075006C006C00
        00000B0000000B0000000B00FFFF0B00FFFF0B00000008000200000000000800
        020000000000080002000000000008000200000000000B0000002C2400003525
        0000}
    end
  end
end
