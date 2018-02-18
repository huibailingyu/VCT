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
    ActivePage = TabSheet3
    Align = alClient
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    ExplicitWidth = 368
    ExplicitHeight = 464
    object TabSheet1: TTabSheet
      Caption = 'Video1 Information'
      ExplicitWidth = 358
      ExplicitHeight = 436
      object ValueListEditor1: TValueListEditor
        Left = 0
        Top = 0
        Width = 364
        Height = 401
        Align = alClient
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goAlwaysShowEditor, goThumbTracking]
        TabOrder = 0
        ExplicitWidth = 360
        ExplicitHeight = 436
        ColWidths = (
          113
          245)
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Video2 Information'
      ImageIndex = 1
      ExplicitWidth = 358
      ExplicitHeight = 436
      object ValueListEditor2: TValueListEditor
        Left = 0
        Top = 0
        Width = 364
        Height = 401
        Align = alClient
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goAlwaysShowEditor, goThumbTracking]
        TabOrder = 0
        ExplicitWidth = 360
        ExplicitHeight = 436
        ColWidths = (
          114
          244)
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'YUV'
      ImageIndex = 3
      ExplicitWidth = 360
      ExplicitHeight = 436
      object DrawGrid1: TDrawGrid
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
        ScrollBars = ssNone
        TabOrder = 0
        OnDrawCell = DrawGrid1DrawCell
      end
      object DrawGrid2: TDrawGrid
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
        ScrollBars = ssNone
        TabOrder = 1
        OnDrawCell = DrawGrid1DrawCell
      end
      object DrawGrid3: TDrawGrid
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
        ScrollBars = ssNone
        TabOrder = 2
        OnDrawCell = DrawGrid1DrawCell
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'RGB'
      ImageIndex = 3
      ExplicitWidth = 358
      ExplicitHeight = 523
      object PageControl2: TPageControl
        Left = 0
        Top = 0
        Width = 364
        Height = 401
        ActivePage = TabSheet5
        Align = alClient
        MultiLine = True
        Style = tsFlatButtons
        TabOrder = 0
        ExplicitWidth = 368
        ExplicitHeight = 436
        object TabSheet5: TTabSheet
          Caption = 'RGB - R'
          ExplicitWidth = 360
          ExplicitHeight = 405
          object DrawGrid4: TDrawGrid
            Tag = 3
            Left = 0
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
            ScrollBars = ssNone
            TabOrder = 0
            OnDrawCell = DrawGrid1DrawCell
          end
        end
        object TabSheet6: TTabSheet
          Caption = 'RGB - G'
          ImageIndex = 1
          ExplicitWidth = 360
          ExplicitHeight = 405
          object DrawGrid5: TDrawGrid
            Tag = 4
            Left = 0
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
            ScrollBars = ssNone
            TabOrder = 0
            OnDrawCell = DrawGrid1DrawCell
          end
        end
        object TabSheet7: TTabSheet
          Caption = 'RGB - B'
          ImageIndex = 2
          ExplicitWidth = 360
          ExplicitHeight = 405
          object DrawGrid6: TDrawGrid
            Tag = 5
            Left = 0
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
            ScrollBars = ssNone
            TabOrder = 0
            OnDrawCell = DrawGrid1DrawCell
          end
        end
      end
    end
  end
end
