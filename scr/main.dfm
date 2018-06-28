object Form1: TForm1
  Left = 217
  Top = 277
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Video Compare Tool'
  ClientHeight = 485
  ClientWidth = 664
  Color = clWindowFrame
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image2: TImage
    Left = 64
    Top = 376
    Width = 561
    Height = 66
  end
  object Image1: TImage
    Left = 80
    Top = 290
    Width = 128
    Height = 128
    Stretch = True
    Transparent = True
  end
  object ProgressBar1: TProgressBar
    Left = 64
    Top = 448
    Width = 561
    Height = 16
    Cursor = crHandPoint
    BorderWidth = 3
    Max = 1
    ParentShowHint = False
    Smooth = True
    Style = pbstMarquee
    BarColor = clYellow
    BackgroundColor = clNavy
    SmoothReverse = True
    ShowHint = True
    TabOrder = 0
    Visible = False
    OnMouseMove = ProgressBar1MouseMove
    OnMouseUp = ProgressBar1MouseUp
  end
  object PopupMenu1: TPopupMenu
    Left = 240
    Top = 24
    object OpenFile11: TMenuItem
      Tag = 1
      Caption = 'Open Files'
      OnClick = OpenFile11Click
    end
    object MediaPlayer1: TMenuItem
      Caption = 'MediaPlayer'
      OnClick = MediaPlayer1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ShowInformation1: TMenuItem
      Caption = 'Enable PSNR'
      Checked = True
      OnClick = ShowInformation1Click
    end
    object ShowFrameInfo1: TMenuItem
      Caption = 'Enable Frame Information'
      OnClick = ShowFrameInfo1Click
    end
    object ShowInformation2: TMenuItem
      Caption = 'Show Stream Information'
      OnClick = ShowInformation2Click
    end
    object ShowMBData1: TMenuItem
      Caption = 'Show MB Data'
      Enabled = False
      OnClick = ShowMBData1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object GoToFrame1: TMenuItem
      Caption = 'GoTo Frame'
      OnClick = GoToFrame1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object SaveFrame1: TMenuItem
      Caption = 'Save Frame'
      object SaveFrame11: TMenuItem
        Tag = 1
        Caption = 'Save Frame 1'
        OnClick = SaveFrame1Click
      end
      object SaveFrame21: TMenuItem
        Tag = 2
        Caption = 'Save Frame 2'
        OnClick = SaveFrame1Click
      end
      object SaveFrm1Frm21: TMenuItem
        Tag = 4
        Caption = 'Save Frm1 Frm2'
        OnClick = SaveFrame1Click
      end
      object SaveFrm1Frm22: TMenuItem
        Tag = 3
        Caption = 'Save Frm1 and Frm2'
        OnClick = SaveFrame1Click
      end
    end
    object YUVSetting1: TMenuItem
      Caption = 'YUV Setting'
      object DisplayY1: TMenuItem
        Tag = 7
        Caption = 'Display YUV'
        Checked = True
        GroupIndex = 1
        RadioItem = True
        OnClick = DisplayY1Click
      end
      object DisplayY2: TMenuItem
        Tag = 1
        Caption = 'Display Y'
        GroupIndex = 1
        RadioItem = True
        OnClick = DisplayY1Click
      end
      object DisplayU1: TMenuItem
        Tag = 2
        Caption = 'Display U'
        GroupIndex = 1
        RadioItem = True
        OnClick = DisplayY1Click
      end
      object DisplayV1: TMenuItem
        Tag = 4
        Caption = 'Display V'
        GroupIndex = 1
        RadioItem = True
        OnClick = DisplayY1Click
      end
      object N8: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object ChangePixelFormat1: TMenuItem
        Caption = 'Change Format'
        GroupIndex = 1
        OnClick = ChangePixelFormat1Click
      end
    end
    object Differentmode1: TMenuItem
      Caption = 'Different mode'
      object None1: TMenuItem
        Caption = 'None'
        Checked = True
        GroupIndex = 1
        RadioItem = True
        OnClick = None1Click
      end
      object butterfly1: TMenuItem
        Tag = 5
        Caption = 'Butterfly'
        GroupIndex = 1
        RadioItem = True
        OnClick = None1Click
      end
      object RGBdiff1: TMenuItem
        Tag = 1
        Caption = 'RGB diff'
        GroupIndex = 1
        RadioItem = True
        OnClick = None1Click
      end
      object RGB1: TMenuItem
        Tag = 2
        Caption = 'RGB subtract'
        GroupIndex = 1
        RadioItem = True
        OnClick = None1Click
      end
      object Ydifference1: TMenuItem
        Tag = 3
        Caption = 'Y diff'
        GroupIndex = 1
        RadioItem = True
        OnClick = None1Click
      end
      object Ydifference2: TMenuItem
        Tag = 4
        Caption = 'Y subtract'
        GroupIndex = 1
        RadioItem = True
        OnClick = None1Click
      end
    end
    object Justify1: TMenuItem
      Caption = 'Justify'
      object Frame12: TMenuItem
        Tag = -1
        Caption = 'Frame1 --'
        OnClick = Frame12Click
      end
      object Frame11: TMenuItem
        Tag = 1
        Caption = 'Frame1 ++'
        OnClick = Frame12Click
      end
      object Frame21: TMenuItem
        Tag = -1
        Caption = 'Frame2 --'
        OnClick = Frame21Click
      end
      object Frame22: TMenuItem
        Tag = 1
        Caption = 'Frame2 ++'
        OnClick = Frame21Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Audo1: TMenuItem
        Caption = 'Audo'
        OnClick = Audo1Click
      end
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object Setting1: TMenuItem
      Caption = 'Setting'
      OnClick = Setting1Click
    end
    object About1: TMenuItem
      Caption = 'About'
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = Exit1Click
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 
      'All (*.png;*.jpg;*.jpeg;*.bmp;*.mp4;*.flv;*.h264; *.yuv)|*.png;*' +
      '.jpg;*.jpeg;*.bmp;*.mp4;*.flv;*.h264; *.yuv|Portable Network Gra' +
      'phics (*.png)|*.png|JPEG Image File (*.jpg)|*.jpg|JPEG Image Fil' +
      'e (*.jpeg)|*.jpeg|Bitmaps (*.bmp)|*.bmp|MP4 (*.mp4)|*.mp4|FLV (*' +
      '.flv)|*.flv|H264 (*.h264)|*.h264|YUV (*.yuv)|*.yuv'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 192
    Top = 16
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 30
    OnTimer = Timer1Timer
    Left = 144
    Top = 24
  end
  object SavePictureDialog1: TSavePictureDialog
    Ctl3D = False
    DefaultExt = '.jpg'
    Filter = 
      'JPEG Image File (*.jpg)|*.jpg|Portable Network Graphics (*.png)|' +
      '*.png|Bitmaps (*.bmp)|*.bmp'
    FilterIndex = 0
    OnTypeChange = SavePictureDialog1TypeChange
    Left = 192
    Top = 56
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = Timer2Timer
    Left = 288
    Top = 72
  end
end
