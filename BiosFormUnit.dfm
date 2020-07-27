object BiosForm: TBiosForm
  Left = 192
  Top = 127
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'CMOS De-Animator v3'
  ClientHeight = 382
  ClientWidth = 345
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 338
    Width = 345
    Height = 3
    Cursor = crArrow
    Align = alBottom
    Beveled = True
    ResizeStyle = rsNone
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 49
    Width = 345
    Height = 3
    Cursor = crArrow
    Align = alTop
    Beveled = True
    ResizeStyle = rsNone
  end
  object panel: TPanel
    Left = 0
    Top = 0
    Width = 345
    Height = 49
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 180
      Height = 13
      Caption = 'Create bootable medium wizard'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 341
    Width = 345
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Panel2: TPanel
      Left = 169
      Top = 0
      Width = 176
      Height = 41
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object Button1: TButton
        Left = 8
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Next >'
        TabOrder = 0
        OnClick = Button1Click
      end
      object Button2: TButton
        Left = 96
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Cancel'
        TabOrder = 1
        OnClick = Button2Click
      end
    end
  end
  inline Page1Frame: TPage1Frame
    Left = 0
    Top = 52
    Width = 345
    Height = 286
    Align = alClient
    TabOrder = 2
    inherited Label6: TLabel
      Caption = 
        'The bootable De-Animator can contain additional  features than t' +
        'his'
    end
  end
  inline Page2Frame: TPage2Frame
    Left = 0
    Top = 52
    Width = 345
    Height = 286
    Align = alClient
    TabOrder = 3
    Visible = False
    inherited dcb: TDriveComboBox
      AutoComplete = False
      AutoDropDown = True
      TextCase = tcUpperCase
      OnChange = Page2FramedcbChange
      OnClick = Page2FramedcbClick
      OnExit = Page2FramedcbExit
      OnStartDrag = Page2FramedcbStartDrag
    end
    inherited cb: TComboBox
      OnChange = Page2FrameComboBox1Change
      OnCloseUp = Page2FramecbCloseUp
      Items.Strings = (
        'Autodetect'
        'Custom...')
    end
  end
end
