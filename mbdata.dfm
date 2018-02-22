object Form5: TForm5
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Form5'
  ClientHeight = 399
  ClientWidth = 726
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object DrawGrid0: TDrawGrid
    Left = 2
    Top = 0
    Width = 356
    Height = 260
    ColCount = 16
    DefaultColWidth = 22
    DefaultRowHeight = 16
    Enabled = False
    FixedCols = 0
    RowCount = 16
    FixedRows = 0
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine]
    PopupMenu = PopupMenu1
    ScrollBars = ssNone
    TabOrder = 0
    OnDrawCell = DrawGrid0DrawCell
  end
  object DrawGrid3: TDrawGrid
    Tag = 3
    Left = 368
    Top = 0
    Width = 356
    Height = 260
    ColCount = 16
    DefaultColWidth = 22
    DefaultRowHeight = 16
    Enabled = False
    FixedCols = 0
    RowCount = 16
    FixedRows = 0
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine]
    PopupMenu = PopupMenu1
    ScrollBars = ssNone
    TabOrder = 1
    OnDrawCell = DrawGrid0DrawCell
  end
  object DrawGrid1: TDrawGrid
    Tag = 1
    Left = 0
    Top = 266
    Width = 180
    Height = 132
    ColCount = 8
    DefaultColWidth = 22
    DefaultRowHeight = 16
    Enabled = False
    FixedCols = 0
    RowCount = 8
    FixedRows = 0
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine]
    PopupMenu = PopupMenu1
    ScrollBars = ssNone
    TabOrder = 2
    OnDrawCell = DrawGrid0DrawCell
  end
  object DrawGrid2: TDrawGrid
    Tag = 2
    Left = 180
    Top = 266
    Width = 180
    Height = 132
    ColCount = 8
    DefaultColWidth = 22
    DefaultRowHeight = 16
    Enabled = False
    FixedCols = 0
    RowCount = 8
    FixedRows = 0
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine]
    PopupMenu = PopupMenu1
    ScrollBars = ssNone
    TabOrder = 3
    OnDrawCell = DrawGrid0DrawCell
  end
  object DrawGrid4: TDrawGrid
    Tag = 4
    Left = 366
    Top = 266
    Width = 180
    Height = 132
    ColCount = 8
    DefaultColWidth = 22
    DefaultRowHeight = 16
    Enabled = False
    FixedCols = 0
    RowCount = 8
    FixedRows = 0
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine]
    PopupMenu = PopupMenu1
    ScrollBars = ssNone
    TabOrder = 4
    OnDrawCell = DrawGrid0DrawCell
  end
  object DrawGrid5: TDrawGrid
    Tag = 5
    Left = 546
    Top = 266
    Width = 180
    Height = 132
    ColCount = 8
    DefaultColWidth = 22
    DefaultRowHeight = 16
    Enabled = False
    FixedCols = 0
    RowCount = 8
    FixedRows = 0
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine]
    PopupMenu = PopupMenu1
    ScrollBars = ssNone
    TabOrder = 5
    OnDrawCell = DrawGrid0DrawCell
  end
  object PopupMenu1: TPopupMenu
    Left = 296
    Top = 40
    object hreshold01: TMenuItem
      Caption = 'Threshold (0)'
      OnClick = hreshold01Click
    end
    object ShowUVdata1: TMenuItem
      Caption = 'Show UV data'
      Checked = True
      OnClick = ShowUVdata1Click
    end
  end
end
