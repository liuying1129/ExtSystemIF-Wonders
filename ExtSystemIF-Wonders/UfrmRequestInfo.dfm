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
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 934
    Height = 113
    Align = alTop
    TabOrder = 0
    object BitBtn1: TBitBtn
      Left = 402
      Top = 72
      Width = 209
      Height = 25
      Caption = #25764#38144#30830#35748#30340#39033#30446'-'#29992#20110#36864#36153
      TabOrder = 0
      OnClick = BitBtn1Click
    end
    object RadioGroup1: TRadioGroup
      Left = 8
      Top = 19
      Width = 249
      Height = 32
      Columns = 4
      ItemIndex = 0
      Items.Strings = (
        #38376#35786
        #20303#38498
        #19981#29992
        #20307#26816)
      TabOrder = 1
    end
    object LabeledEdit2: TLabeledEdit
      Left = 282
      Top = 32
      Width = 191
      Height = 21
      EditLabel.Width = 186
      EditLabel.Height = 13
      EditLabel.Caption = 'HIS'#30149#21382#21495'(chk_con.HIS_UNID)'
      TabOrder = 2
    end
    object LabeledEdit3: TLabeledEdit
      Left = 514
      Top = 32
      Width = 231
      Height = 21
      EditLabel.Width = 218
      EditLabel.Height = 13
      EditLabel.Caption = 'HIS'#39033#30446#30003#35831#21333#21495'(chk_valu.Surem1)'
      TabOrder = 3
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 113
    Width = 934
    Height = 144
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 24
      Top = 20
      Width = 306
      Height = 13
      Caption = #22238#25910#25253#21578#21069#19968#33324#35201#21462#28040#23457#26680','#20197#20813#38169#35823#25253#21578#34987#20877#27425#21457#24067
    end
    object Label2: TLabel
      Left = 24
      Top = 116
      Width = 629
      Height = 13
      Caption = 
        'chk_con.unid'#24050#22312#30149#20154#20449#24687#21457#24067#25509#21475'(usp_yjjk_jcbrfb)'#12289#30149#20154#32467#26524#21457#24067#25509#21475'(usp_yjjk_yjjgfb' +
        ')'#20256#36755#32473'HIS'
    end
    object BitBtn4: TBitBtn
      Left = 312
      Top = 68
      Width = 75
      Height = 25
      Caption = #22238#25910#25253#21578
      TabOrder = 0
      OnClick = BitBtn4Click
    end
    object LabeledEdit1: TLabeledEdit
      Left = 24
      Top = 68
      Width = 210
      Height = 21
      EditLabel.Width = 197
      EditLabel.Height = 13
      EditLabel.Caption = 'LIS'#26816#39564#21333#21807#19968#21495'(chk_con.unid)'
      TabOrder = 1
    end
    object BitBtn2: TBitBtn
      Left = 680
      Top = 112
      Width = 241
      Height = 25
      Caption = #33719#21462#26410#25191#34892#21270#39564#21307#22065#30340#30149#20154#21015#34920' '#8595
      TabOrder = 2
      OnClick = BitBtn2Click
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 257
    Width = 934
    Height = 210
    Align = alClient
    DataSource = DataSource1
    ReadOnly = True
    TabOrder = 2
    TitleFont.Charset = ANSI_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = #23435#20307
    TitleFont.Style = []
  end
  object UniStoredProc5: TUniStoredProc
    Connection = frmMain.UniConnection1
    Left = 56
    Top = 281
  end
  object DataSource1: TDataSource
    DataSet = UniStoredProc5
    Left = 88
    Top = 282
  end
end
