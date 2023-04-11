object frmMain: TfrmMain
  Left = 269
  Top = 127
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #26465#30721#25195#25551' - '#23545#25509#19975#36798'HIS'
  ClientHeight = 467
  ClientWidth = 954
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 954
    Height = 52
    Align = alTop
    TabOrder = 0
    object SpeedButton1: TSpeedButton
      Left = 923
      Top = 21
      Width = 23
      Height = 22
      Hint = #26597#30475#33713#22495#30003#35831#21333
      Caption = #65311
      ParentShowHint = False
      ShowHint = True
      OnClick = SpeedButton1Click
    end
    object Label2: TLabel
      Left = 6
      Top = 8
      Width = 104
      Height = 13
      Caption = #26816#39564#21307#22065#36215#22987#26085#26399
    end
    object LabeledEdit1: TLabeledEdit
      Left = 371
      Top = 24
      Width = 130
      Height = 21
      EditLabel.Width = 131
      EditLabel.Height = 13
      EditLabel.Caption = #25195#25551#25110#36755#20837#26465#30721'('#22238#36710')'
      TabOrder = 0
      OnKeyDown = LabeledEdit1KeyDown
    end
    object CheckBox1: TCheckBox
      Left = 725
      Top = 25
      Width = 195
      Height = 17
      TabStop = False
      Caption = #26080#38656#30830#35748','#25195#25551#21518#30452#25509#23548#20837'LIS'
      TabOrder = 1
      OnClick = CheckBox1Click
    end
    object RadioGroup1: TRadioGroup
      Left = 138
      Top = 15
      Width = 211
      Height = 32
      Columns = 4
      ItemIndex = 0
      Items.Strings = (
        #38376#35786
        #20303#38498
        #19981#29992
        #20307#26816)
      TabOrder = 2
    end
    object DateTimePicker1: TDateTimePicker
      Left = 6
      Top = 24
      Width = 105
      Height = 21
      Date = 45271.822518877310000000
      Time = 45271.822518877310000000
      TabOrder = 3
      TabStop = False
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 52
    Width = 954
    Height = 396
    Align = alClient
    Caption = #26465#30721#20449#24687
    TabOrder = 1
    object Panel3: TPanel
      Left = 2
      Top = 15
      Width = 950
      Height = 52
      Align = alTop
      TabOrder = 0
      object LabeledEdit2: TLabeledEdit
        Left = 209
        Top = 26
        Width = 60
        Height = 21
        TabStop = False
        Color = clMenu
        EditLabel.Width = 26
        EditLabel.Height = 13
        EditLabel.Caption = #22995#21517
        ReadOnly = True
        TabOrder = 0
      end
      object LabeledEdit3: TLabeledEdit
        Left = 276
        Top = 26
        Width = 35
        Height = 21
        TabStop = False
        Color = clMenu
        EditLabel.Width = 26
        EditLabel.Height = 13
        EditLabel.Caption = #24615#21035
        ReadOnly = True
        TabOrder = 1
      end
      object LabeledEdit4: TLabeledEdit
        Left = 326
        Top = 26
        Width = 35
        Height = 21
        TabStop = False
        Color = clMenu
        EditLabel.Width = 26
        EditLabel.Height = 13
        EditLabel.Caption = #24180#40836
        ReadOnly = True
        TabOrder = 2
      end
      object LabeledEdit7: TLabeledEdit
        Left = 6
        Top = 26
        Width = 160
        Height = 21
        TabStop = False
        Color = clMenu
        EditLabel.Width = 158
        EditLabel.Height = 13
        EditLabel.Caption = #26465#30721'('#21345#21495'/'#20303#38498#21495'/'#20307#26816#21495')'
        ReadOnly = True
        TabOrder = 3
      end
      object Edit2: TEdit
        Left = 361
        Top = 26
        Width = 35
        Height = 21
        TabStop = False
        Color = clMenu
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 4
      end
      object LabeledEdit5: TLabeledEdit
        Left = 401
        Top = 26
        Width = 52
        Height = 21
        TabStop = False
        Color = clMenu
        EditLabel.Width = 26
        EditLabel.Height = 13
        EditLabel.Caption = #21345#21495
        ReadOnly = True
        TabOrder = 5
      end
      object LabeledEdit6: TLabeledEdit
        Left = 463
        Top = 25
        Width = 55
        Height = 21
        TabStop = False
        Color = clMenu
        EditLabel.Width = 40
        EditLabel.Height = 13
        EditLabel.Caption = #30149#20154'ID'
        ReadOnly = True
        TabOrder = 6
      end
      object LabeledEdit9: TLabeledEdit
        Left = 529
        Top = 25
        Width = 60
        Height = 21
        TabStop = False
        Color = clMenu
        EditLabel.Width = 52
        EditLabel.Height = 13
        EditLabel.Caption = #30149#20154#31867#21035
        ReadOnly = True
        TabOrder = 7
      end
    end
    object Panel4: TPanel
      Left = 2
      Top = 361
      Width = 950
      Height = 33
      Align = alBottom
      TabOrder = 2
      object Label1: TLabel
        Left = 152
        Top = 3
        Width = 345
        Height = 13
        Caption = #27880#65306'1'#12289#20462#25913#30456#21516#24037#20316#32452#12289#30456#21516#26679#26412#31867#22411#31532#19968#26465#30340#32852#26426#21495#21363#21487
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlue
        Font.Height = -13
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
      end
      object BitBtn1: TBitBtn
        Left = 7
        Top = 4
        Width = 100
        Height = 25
        Caption = #23548#20837'LIS-F3'
        TabOrder = 0
        OnClick = BitBtn1Click
      end
    end
    object DBGrid1: TDBGrid
      Left = 2
      Top = 156
      Width = 950
      Height = 205
      TabStop = False
      Align = alClient
      DataSource = DataSource1
      PopupMenu = PopupMenu1
      TabOrder = 1
      TitleFont.Charset = ANSI_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = #23435#20307
      TitleFont.Style = []
    end
    object Memo1: TMemo
      Left = 2
      Top = 67
      Width = 950
      Height = 89
      Align = alTop
      Color = clMenu
      ReadOnly = True
      TabOrder = 3
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 448
    Width = 954
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Text = #25805#20316#20154#21592#24037#21495':'
        Width = 82
      end
      item
        Width = 100
      end
      item
        Text = #25805#20316#20154#21592#22995#21517':'
        Width = 82
      end
      item
        Width = 70
      end
      item
        Width = 50
      end>
  end
  object UniConnection1: TUniConnection
    Left = 686
    Top = 8
  end
  object ADOConnection1: TADOConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=Yklissa123;Persist Security Info=Tr' +
      'ue;User ID=sa;Initial Catalog=YkLis;Data Source=202.96.1.105'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 657
    Top = 8
  end
  object DataSource1: TDataSource
    DataSet = VirtualTable1
    Left = 40
    Top = 211
  end
  object VirtualTable1: TVirtualTable
    AfterOpen = VirtualTable1AfterOpen
    FieldDefs = <
      item
        Name = #22806#37096#31995#32479#21807#19968#32534#21495
        DataType = ftString
        Size = 20
      end
      item
        Name = #22806#37096#31995#32479#39033#30446#30003#35831#32534#21495
        DataType = ftString
        Size = 20
      end
      item
        Name = #30003#35831#31185#23460
        DataType = ftString
        Size = 50
      end
      item
        Name = #30003#35831#21307#29983
        DataType = ftString
        Size = 50
      end
      item
        Name = #30003#35831#26102#38388
        DataType = ftString
        Size = 20
      end
      item
        Name = 'HIS'#39033#30446#20195#30721
        DataType = ftString
        Size = 50
      end
      item
        Name = 'HIS'#39033#30446#21517#31216
        DataType = ftString
        Size = 100
      end
      item
        Name = 'LIS'#39033#30446#20195#30721
        DataType = ftString
        Size = 50
      end
      item
        Name = 'LIS'#39033#30446#21517#31216
        DataType = ftString
        Size = 100
      end
      item
        Name = #24037#20316#32452
        DataType = ftString
        Size = 50
      end
      item
        Name = #26679#26412#31867#22411
        DataType = ftString
        Size = 50
      end
      item
        Name = #32852#26426#21495
        DataType = ftString
        Size = 20
      end>
    Left = 72
    Top = 211
    Data = {
      03000C001000CDE2B2BFCFB5CDB3CEA8D2BBB1E0BAC501001400000000001400
      CDE2B2BFCFB5CDB3CFEEC4BFC9EAC7EBB1E0BAC501001400000000000800C9EA
      C7EBBFC6CAD201003200000000000800C9EAC7EBD2BDC9FA0100320000000000
      0800C9EAC7EBCAB1BCE401001400000000000B00484953CFEEC4BFB4FAC2EB01
      003200000000000B00484953CFEEC4BFC3FBB3C601006400000000000B004C49
      53CFEEC4BFB4FAC2EB01003200000000000B004C4953CFEEC4BFC3FBB3C60100
      6400000000000600B9A4D7F7D7E901003200000000000800D1F9B1BEC0E0D0CD
      01003200000000000600C1AABBFABAC50100140000000000000000000000}
  end
  object ActionList1: TActionList
    Left = 629
    Top = 8
    object Action1: TAction
      Caption = 'Action1'
      ShortCut = 114
      OnExecute = BitBtn1Click
    end
  end
  object DosMove1: TDosMove
    Active = True
    Left = 601
    Top = 8
  end
  object PopupMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 144
    Top = 211
    object N1: TMenuItem
      Caption = #29616#22312#19981#26816
      OnClick = N1Click
    end
  end
end
