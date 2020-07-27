object HWSettings: THWSettings
  Left = 192
  Top = 117
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Hardware access'
  ClientHeight = 265
  ClientWidth = 234
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 217
    Height = 169
    Caption = 'Select mode:'
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 56
      Width = 148
      Height = 13
      Caption = 'For most versions of Windows.'
    end
    object Label2: TLabel
      Left = 16
      Top = 128
      Width = 173
      Height = 13
      Caption = '32bit access for Windows 95/NT 3.x'
    end
    object Standard: TRadioButton
      Left = 16
      Top = 32
      Width = 113
      Height = 17
      Caption = 'Default'
      Checked = True
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      TabStop = True
    end
    object Legacy: TRadioButton
      Left = 16
      Top = 104
      Width = 113
      Height = 17
      Caption = 'Legacy'
      TabOrder = 1
    end
  end
  object VerboseMode: TCheckBox
    Left = 56
    Top = 184
    Width = 129
    Height = 17
    Caption = 'Enable verbose mode'
    TabOrder = 1
  end
  object Button1: TButton
    Left = 88
    Top = 232
    Width = 65
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = Button1Click
  end
  object LegacyCMOS: TCheckBox
    Left = 56
    Top = 208
    Width = 105
    Height = 17
    Caption = '128-byte CMOS'
    TabOrder = 3
  end
end
