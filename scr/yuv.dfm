object Form3: TForm3
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'YUV Setting'
  ClientHeight = 199
  ClientWidth = 289
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 40
    Top = 107
    Width = 59
    Height = 13
    Caption = 'Pixel Format'
  end
  object Label2: TLabel
    Left = 24
    Top = 24
    Width = 28
    Height = 13
    Caption = 'Width'
  end
  object Label3: TLabel
    Left = 152
    Top = 24
    Width = 31
    Height = 13
    Caption = 'Height'
  end
  object Label4: TLabel
    Left = 24
    Top = 67
    Width = 37
    Height = 13
    Caption = 'Y Stride'
  end
  object Label5: TLabel
    Left = 144
    Top = 67
    Width = 44
    Height = 13
    Caption = 'UV Stride'
  end
  object ComboBox1: TComboBox
    Left = 113
    Top = 104
    Width = 121
    Height = 21
    ItemIndex = 0
    TabOrder = 2
    Text = 'YUV420P'
    OnChange = ComboBox1Change
    Items.Strings = (
      'YUV420P'
      'YUV400P'
      'NV12'
      'YUV444P'
      'RGB24'
      'BGR24'
      'RGB888'
      'BGR888')
  end
  object Button1: TButton
    Left = 144
    Top = 148
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 5
    OnClick = Button1Click
  end
  object MaskEdit1: TMaskEdit
    Left = 67
    Top = 21
    Width = 46
    Height = 21
    EditMask = '!9999;1; '
    MaxLength = 4
    TabOrder = 0
    Text = '    '
    OnKeyUp = MaskEdit1KeyUp
  end
  object MaskEdit2: TMaskEdit
    Tag = 1
    Left = 196
    Top = 21
    Width = 46
    Height = 21
    EditMask = '!9999;1; '
    MaxLength = 4
    TabOrder = 1
    Text = '    '
    OnChange = MaskEdit2Change
    OnKeyUp = MaskEdit1KeyUp
  end
  object MaskEdit3: TMaskEdit
    Tag = 2
    Left = 67
    Top = 64
    Width = 46
    Height = 21
    EditMask = '!9999;1; '
    MaxLength = 4
    TabOrder = 3
    Text = '    '
    OnChange = MaskEdit3Change
  end
  object MaskEdit4: TMaskEdit
    Tag = 3
    Left = 194
    Top = 64
    Width = 46
    Height = 21
    EditMask = '!9999;1; '
    MaxLength = 4
    TabOrder = 4
    Text = '    '
    OnChange = MaskEdit4Change
  end
end
