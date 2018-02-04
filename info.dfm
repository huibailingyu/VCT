object Form4: TForm4
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Video Information'
  ClientHeight = 464
  ClientWidth = 366
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 366
    Height = 464
    ActivePage = TabSheet2
    Align = alClient
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    ExplicitWidth = 532
    ExplicitHeight = 454
    object TabSheet1: TTabSheet
      Caption = 'Video1 Information'
      ExplicitWidth = 281
      ExplicitHeight = 165
      object ValueListEditor1: TValueListEditor
        Left = 0
        Top = 0
        Width = 358
        Height = 436
        Align = alClient
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goAlwaysShowEditor, goThumbTracking]
        TabOrder = 0
        ExplicitWidth = 367
        ColWidths = (
          113
          239)
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Video2 Information'
      ImageIndex = 1
      ExplicitWidth = 281
      ExplicitHeight = 165
      object ValueListEditor2: TValueListEditor
        Left = 0
        Top = 0
        Width = 358
        Height = 436
        Align = alClient
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goAlwaysShowEditor, goThumbTracking]
        TabOrder = 0
        ExplicitWidth = 367
        ColWidths = (
          114
          238)
      end
    end
  end
end
