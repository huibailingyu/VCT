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
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 200
    Top = 168
  end
end
