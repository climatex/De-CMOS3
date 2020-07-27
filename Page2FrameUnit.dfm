object Page2Frame: TPage2Frame
  Left = 0
  Top = 0
  Width = 344
  Height = 287
  TabOrder = 0
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 310
    Height = 13
    Caption = 
      'Please select the drive you'#39'd like to install CMOS De-Animator t' +
      'o.'
  end
  object Label2: TLabel
    Left = 8
    Top = 32
    Width = 152
    Height = 13
    Caption = 'Then click on Install to proceed.'
  end
  object Label3: TLabel
    Left = 8
    Top = 72
    Width = 329
    Height = 13
    Caption = 
      'Alternatively, specify the drive where it is installed on, and t' +
      'hen click'
  end
  object Label4: TLabel
    Left = 8
    Top = 88
    Width = 311
    Height = 13
    Caption = 'on the Uninstall button to remove CMOS De-Animator boot code.'
  end
  object Label5: TLabel
    Left = 8
    Top = 128
    Width = 57
    Height = 13
    Caption = 'WARNING!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 72
    Top = 128
    Width = 40
    Height = 13
    Caption = 'Do NOT'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 116
    Top = 128
    Width = 195
    Height = 13
    Caption = 'specify your system'#39's bootable partition.'
  end
  object Label8: TLabel
    Left = 8
    Top = 144
    Width = 224
    Height = 13
    Caption = 'Doing so can render your machine unbootable.'
  end
  object Label9: TLabel
    Left = 8
    Top = 176
    Width = 58
    Height = 13
    Caption = 'Drive letter:'
  end
  object Label10: TLabel
    Left = 8
    Top = 208
    Width = 89
    Height = 13
    Caption = 'Disk formatted by:'
  end
  object Label11: TLabel
    Left = 8
    Top = 240
    Width = 326
    Height = 13
    Caption = 
      'After the installation is done, check whether your partition is ' +
      'active,'
  end
  object Label12: TLabel
    Left = 8
    Top = 256
    Width = 104
    Height = 13
    Caption = 'for example using the'
  end
  object Label13: TLabel
    Left = 116
    Top = 256
    Width = 84
    Height = 13
    Cursor = crHandPoint
    Caption = 'Disk Management'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = Label13Click
  end
  object Label14: TLabel
    Left = 204
    Top = 256
    Width = 40
    Height = 13
    Caption = 'console.'
  end
  object dcb: TDriveComboBox
    Left = 192
    Top = 176
    Width = 145
    Height = 19
    TabOrder = 0
  end
  object cb: TComboBox
    Left = 192
    Top = 206
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 1
    Text = 'Autodetect'
    Items.Strings = (
      'Autodetect'
      'Custom...'
      'MS-DOS/Windows 9x'
      'Windows NT, 2000, XP'
      'Windows Vista, 7, 8')
  end
end
