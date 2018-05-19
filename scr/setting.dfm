object Form2: TForm2
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Setting'
  ClientHeight = 222
  ClientWidth = 369
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 322
    Top = 24
    Width = 23
    Height = 22
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
      55555555FFFFFFFFFF55555000000000055555577777777775F55500B8B8B8B8
      B05555775F555555575F550F0B8B8B8B8B05557F75F555555575550BF0B8B8B8
      B8B0557F575FFFFFFFF7550FBF0000000000557F557777777777500BFBFBFBFB
      0555577F555555557F550B0FBFBFBFBF05557F7F555555FF75550F0BFBFBF000
      55557F75F555577755550BF0BFBF0B0555557F575FFF757F55550FB700007F05
      55557F557777557F55550BFBFBFBFB0555557F555555557F55550FBFBFBFBF05
      55557FFFFFFFFF7555550000000000555555777777777755555550FBFB055555
      5555575FFF755555555557000075555555555577775555555555}
    NumGlyphs = 2
    OnClick = SpeedButton1Click
  end
  object LabeledEdit1: TLabeledEdit
    Left = 16
    Top = 24
    Width = 297
    Height = 21
    EditLabel.Width = 67
    EditLabel.Height = 13
    EditLabel.Caption = 'Output Folder'
    ReadOnly = True
    TabOrder = 0
  end
  object RadioGroup1: TRadioGroup
    Left = 16
    Top = 64
    Width = 153
    Height = 145
    Caption = 'Output Extension'
    Items.Strings = (
      '.bmp'
      '.png'
      '.jpg'
      '.rgb'
      '.avi')
    TabOrder = 1
  end
  object CheckBox1: TCheckBox
    Left = 200
    Top = 80
    Width = 129
    Height = 17
    Caption = ' Use Segment mode'
    TabOrder = 2
  end
  object ComboBox1: TComboBox
    Left = 200
    Top = 135
    Width = 145
    Height = 21
    Enabled = False
    ItemIndex = 0
    TabOrder = 3
    Text = 'dxva2'
    Items.Strings = (
      'dxva2')
  end
  object CheckBox2: TCheckBox
    Left = 200
    Top = 112
    Width = 129
    Height = 17
    Caption = ' Use Hardware decoder'
    Enabled = False
    TabOrder = 4
  end
  object BitBtn1: TBitBtn
    Left = 270
    Top = 184
    Width = 75
    Height = 25
    Caption = 'OK'
    DoubleBuffered = True
    ModalResult = 1
    ParentDoubleBuffered = False
    TabOrder = 5
    OnClick = BitBtn1Click
  end
end
