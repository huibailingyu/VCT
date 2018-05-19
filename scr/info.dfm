object Form4: TForm4
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Video Information'
  ClientHeight = 419
  ClientWidth = 362
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 362
    Height = 419
    ActivePage = TabSheet4
    Align = alClient
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    ExplicitWidth = 372
    ExplicitHeight = 429
    object TabSheet4: TTabSheet
      Caption = 'Stream Information'
      ImageIndex = 3
      ExplicitWidth = 364
      ExplicitHeight = 401
      object Label1: TLabel
        Left = 176
        Top = 224
        Width = 151
        Height = 13
        Caption = 'DISPOSITION:timed-thumbnails'
        Visible = False
      end
      object StringGrid1: TStringGrid
        Left = 0
        Top = 0
        Width = 354
        Height = 391
        Align = alClient
        Color = clInfoBk
        ColCount = 3
        DefaultColWidth = 96
        DefaultRowHeight = 18
        FixedColor = clInfoBk
        FixedCols = 0
        FixedRows = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnDrawCell = StringGrid1DrawCell
        ExplicitWidth = 364
        ExplicitHeight = 401
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Frame Information'
      ImageIndex = 2
      ExplicitWidth = 364
      ExplicitHeight = 401
      object DrawGrid1: TDrawGrid
        Tag = 1
        Left = 0
        Top = 57
        Width = 172
        Height = 334
        Cursor = crHandPoint
        Align = alClient
        ColCount = 2
        DefaultColWidth = 32
        DefaultRowHeight = 18
        FixedCols = 0
        FixedRows = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
        ScrollBars = ssVertical
        TabOrder = 0
        OnDblClick = DrawGrid1DblClick
        OnDrawCell = DrawGrid1DrawCell
        OnSelectCell = DrawGrid1SelectCell
        ExplicitWidth = 182
        ExplicitHeight = 344
        ColWidths = (
          32
          139)
      end
      object DrawGrid2: TDrawGrid
        Tag = 2
        Left = 172
        Top = 57
        Width = 182
        Height = 334
        Cursor = crHandPoint
        Align = alRight
        ColCount = 2
        DefaultColWidth = 32
        DefaultRowHeight = 18
        FixedCols = 0
        FixedRows = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
        ScrollBars = ssVertical
        TabOrder = 1
        OnDblClick = DrawGrid2DblClick
        OnDrawCell = DrawGrid1DrawCell
        OnSelectCell = DrawGrid2SelectCell
        ExplicitLeft = 182
        ExplicitHeight = 344
        ColWidths = (
          32
          139)
      end
      object RadioGroup1: TRadioGroup
        Left = 0
        Top = 0
        Width = 354
        Height = 57
        Align = alTop
        Caption = ' Frame Select Mode '
        TabOrder = 2
        ExplicitWidth = 364
      end
      object RadioButton1: TRadioButton
        Left = 16
        Top = 24
        Width = 113
        Height = 17
        Caption = 'Double Click'
        Checked = True
        TabOrder = 3
        TabStop = True
        OnClick = RadioButton1Click
      end
      object RadioButton2: TRadioButton
        Tag = 1
        Left = 135
        Top = 24
        Width = 113
        Height = 17
        Caption = 'Single Click'
        TabOrder = 4
        OnClick = RadioButton1Click
      end
      object RadioButton3: TRadioButton
        Tag = 2
        Left = 248
        Top = 24
        Width = 113
        Height = 17
        Caption = 'Not Select'
        TabOrder = 5
        OnClick = RadioButton1Click
      end
    end
  end
end
