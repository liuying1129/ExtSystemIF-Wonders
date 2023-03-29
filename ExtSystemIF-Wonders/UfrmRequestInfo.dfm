object frmRequestInfo: TfrmRequestInfo
  Left = 192
  Top = 123
  Width = 950
  Height = 506
  Caption = #26597#30475#30003#35831#21333
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 934
    Height = 161
    Align = alTop
    TabOrder = 0
    object BitBtn1: TBitBtn
      Left = 546
      Top = 64
      Width = 209
      Height = 25
      Caption = #25764#38144#30830#35748#30340#39033#30446'-'#29992#20110#36864#36153
      TabOrder = 0
      OnClick = BitBtn1Click
    end
    object RadioGroup1: TRadioGroup
      Left = 64
      Top = 59
      Width = 110
      Height = 32
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        #38376#35786
        #20303#38498)
      TabOrder = 1
    end
    object LabeledEdit2: TLabeledEdit
      Left = 194
      Top = 72
      Width = 137
      Height = 21
      EditLabel.Width = 60
      EditLabel.Height = 13
      EditLabel.Caption = 'HIS'#30149#21382#21495
      TabOrder = 2
    end
    object LabeledEdit3: TLabeledEdit
      Left = 346
      Top = 72
      Width = 137
      Height = 21
      EditLabel.Width = 99
      EditLabel.Height = 13
      EditLabel.Caption = 'HIS'#39033#30446#30003#35831#21333#21495
      TabOrder = 3
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 161
    Width = 934
    Height = 160
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 79
      Top = 20
      Width = 306
      Height = 13
      Caption = #22238#25910#25253#21578#21069#19968#33324#35201#21462#28040#23457#26680','#20197#20813#38169#35823#25253#21578#34987#20877#27425#21457#24067
    end
    object BitBtn4: TBitBtn
      Left = 207
      Top = 68
      Width = 75
      Height = 25
      Caption = #22238#25910#25253#21578
      TabOrder = 0
      OnClick = BitBtn4Click
    end
    object LabeledEdit1: TLabeledEdit
      Left = 79
      Top = 68
      Width = 121
      Height = 21
      EditLabel.Width = 99
      EditLabel.Height = 13
      EditLabel.Caption = 'LIS'#26816#39564#21333#21807#19968#21495
      TabOrder = 1
    end
  end
end
