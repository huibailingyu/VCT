object Form4: TForm4
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Video Information'
  ClientHeight = 429
  ClientWidth = 372
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
    Width = 372
    Height = 429
    ActivePage = TabSheet2
    Align = alClient
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Video1 Information'
      object ValueListEditor1: TValueListEditor
        Left = 0
        Top = 0
        Width = 364
        Height = 401
        Align = alClient
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goAlwaysShowEditor, goThumbTracking]
        TabOrder = 0
        ColWidths = (
          113
          245)
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Video2 Information'
      ImageIndex = 1
      object ValueListEditor2: TValueListEditor
        Left = 0
        Top = 0
        Width = 364
        Height = 401
        Align = alClient
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goAlwaysShowEditor, goThumbTracking]
        TabOrder = 0
        ColWidths = (
          114
          244)
      end
    end
  end
end
