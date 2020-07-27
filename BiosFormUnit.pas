unit BiosFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, FileCtrl, Page1FrameUnit, Page2FrameUnit;

type
  TBiosForm = class(TForm)
    panel: TPanel;
    Label1: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    Page1Frame: TPage1Frame;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Page2Frame: TPage2Frame;
    procedure WMDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Page2FrameComboBox1Change(Sender: TObject);
    procedure Page2FramecbCloseUp(Sender: TObject);
    procedure Page2FramedcbExit(Sender: TObject);
    procedure Page2FramedcbClick(Sender: TObject);
    procedure Page2FramedcbChange(Sender: TObject);
    procedure Page2FramedcbStartDrag(Sender: TObject;
      var DragObject: TDragObject);
  private
    { Private declarations }
  public
    procedure PrintPage1;
    procedure PrintPage2;
    procedure InstallBootCode;
    procedure UninstallBootCode;
  end;

var
  BiosForm: TBiosForm;
  DoUninstall: Boolean  = False;
  ExcFile: String;

implementation

{$R *.dfm}

function GetFileSize(Path: String): Integer;
var
  f: file of byte;
begin

  Result := -1;

  try
    AssignFile(f, Path);
    Reset(f);
    Result := FileSize(f);
  except end;

    Close(f);

end;

procedure TBiosForm.PrintPage1;
begin

  Button1.Caption := 'Next >';
  Button2.Caption := 'Cancel';

  Page1Frame.Visible := True;
  Page2Frame.Visible := False;

end;


procedure TBiosForm.PrintPage2;
begin

  Button1.Caption := 'Install';
  Button2.Caption := 'Uninstall';

  Page1Frame.Visible := False;
  Page2Frame.Visible := True;

end;

procedure TBiosForm.Button1Click(Sender: TObject);
begin

  if (Button1.Caption = 'Next >') then begin

    PrintPage2;

  end else begin

    if (Page2Frame.dcb.ItemIndex = -1) then begin

      Application.MessageBox('Select a drive first.', 'Information', MB_ICONINFORMATION + MB_OK);
      Exit;
    end;
    InstallBootCode;

  end;

end;

procedure TBiosForm.Button2Click(Sender: TObject);
begin

  if (Button2.Caption = 'Cancel') then begin

    BiosForm.Close;

  end else begin

     if (Page2Frame.dcb.ItemIndex = -1) then begin

      Application.MessageBox('Select a drive first.', 'Information', MB_ICONINFORMATION + MB_OK);
      Exit;
    end;

    UninstallBootCode;

  end;

end;

procedure TBiosForm.InstallBootCode;
var
  DrvPath: String;
  APPStream: TResourceStream;
begin

  DrvPath := Page2Frame.dcb.Drive + ':\';
  if Application.MessageBox(PAnsiChar('Install CMOS De-Animator to ' + DrvPath + ' ?'),
    'Question', MB_ICONQUESTION + MB_YESNO ) = IDNO then Exit;

  APPStream := nil;

  try
    APPStream := TResourceStream.Create(hInstance, 'BootCode', RT_RCDATA);
    if (Page2Frame.cb.ItemIndex = 1) then APPStream.SaveToFile(DrvPath + ExcFile) else begin

      SetFileAttributes(PAnsiChar(DrvPath + 'io.sys'), FILE_ATTRIBUTE_NORMAL);
      DeleteFile(DrvPath + 'io.sys');
      APPStream.SaveToFile(DrvPath + 'io.sys');
      SetFileAttributes(PAnsiChar(DrvPath + 'io.sys'), FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_ARCHIVE or FILE_ATTRIBUTE_SYSTEM);

      SetFileAttributes(PAnsiChar(DrvPath + 'msdos.sys'), FILE_ATTRIBUTE_NORMAL);
      DeleteFile(DrvPath + 'msdos.sys');
      APPStream.SaveToFile(DrvPath + 'msdos.sys');
      SetFileAttributes(PAnsiChar(DrvPath + 'msdos.sys'), FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_ARCHIVE or FILE_ATTRIBUTE_SYSTEM);

      SetFileAttributes(PAnsiChar(DrvPath + 'ntldr'), FILE_ATTRIBUTE_NORMAL);
      DeleteFile(DrvPath + 'ntldr');
      APPStream.SaveToFile(DrvPath + 'ntldr');
      SetFileAttributes(PAnsiChar(DrvPath + 'ntldr'), FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_ARCHIVE or FILE_ATTRIBUTE_SYSTEM);

      SetFileAttributes(PAnsiChar(DrvPath + 'bootmgr'), FILE_ATTRIBUTE_NORMAL);
      DeleteFile(DrvPath + 'bootmgr');
      APPStream.SaveToFile(DrvPath + 'bootmgr');
      SetFileAttributes(PAnsiChar(DrvPath + 'bootmgr'), FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_ARCHIVE or FILE_ATTRIBUTE_SYSTEM);

    end;
  except
    Application.MessageBox('Cannot write to disk!', 'Error', MB_ICONSTOP + MB_OK);
    APPStream.Free;
    BiosForm.Close;
    Exit;
  end;

  APPStream.Free;
  Application.MessageBox('CMOS De-Animator boot code has been successfully installed.',
    'Information', MB_ICONINFORMATION + MB_OK);
  BiosForm.Close;

end;

procedure TBiosForm.UninstallBootCode;
var
  DrvPath, Exec: String;
begin

  DrvPath := Page2Frame.dcb.Drive + ':\';

  if ( Page2Frame.cb.ItemIndex = 0 ) then begin

    Exec := DrvPath + 'IO.SYS';
    SetFileAttributes(PAnsichar(Exec), FILE_ATTRIBUTE_NORMAL);
    if ( (not FileExists(Exec)) or (GetFileSize(Exec) <> 4096) ) then begin
      Exec := DrvPath + 'MSDOS.SYS';
      SetFileAttributes(PAnsichar(Exec), FILE_ATTRIBUTE_NORMAL);
      if ( (not FileExists(Exec)) or (GetFileSize(Exec) <> 4096) ) then begin
        Exec := DrvPath + 'NTLDR';
        SetFileAttributes(PAnsichar(Exec), FILE_ATTRIBUTE_NORMAL);
        if ( (not FileExists(Exec)) or (GetFileSize(Exec) <> 4096) ) then begin
          Exec := DrvPath + 'BOOTMGR';
          SetFileAttributes(PAnsichar(Exec), FILE_ATTRIBUTE_NORMAL);
          if ( (not FileExists(Exec)) or (GetFileSize(Exec) <> 4096) ) then begin
            Application.MessageBox('CMOS De-Animator boot code not present on disk.', 'Warning',
              MB_ICONWARNING + MB_OK);
            Exit;
          end;
        end;
      end;
    end;

  try

      SetFileAttributes(PAnsiChar(DrvPath + 'io.sys'), FILE_ATTRIBUTE_NORMAL);
      DeleteFile(DrvPath + 'io.sys');

      SetFileAttributes(PAnsiChar(DrvPath + 'msdos.sys'), FILE_ATTRIBUTE_NORMAL);
      DeleteFile(DrvPath + 'msdos.sys');

      SetFileAttributes(PAnsiChar(DrvPath + 'ntldr'), FILE_ATTRIBUTE_NORMAL);
      DeleteFile(DrvPath + 'ntldr');

      SetFileAttributes(PAnsiChar(DrvPath + 'bootmgr'), FILE_ATTRIBUTE_NORMAL);
      DeleteFile(DrvPath + 'bootmgr');
    
  except
    Application.MessageBox('Cannot write to disk!', 'Error', MB_ICONSTOP + MB_OK);
    BiosForm.Close;
    Exit;
  end;

  Application.MessageBox('CMOS De-Animator boot code has been uninstalled.', 'Information',
              MB_ICONINFORMATION + MB_OK);
  BiosForm.Close;
  Exit;

  end else begin

    Exec := DrvPath + ExcFile;
    SetFileAttributes(PAnsichar(Exec), FILE_ATTRIBUTE_NORMAL);
    if ( (not FileExists(Exec)) or (GetFileSize(Exec) <> 4096) ) then begin
      Application.MessageBox('CMOS De-Animator boot code not present on disk.', 'Warning',
        MB_ICONWARNING + MB_OK);
      Exit;
    end else begin
      DeleteFile(Exec);
      Application.MessageBox('CMOS De-Animator boot code has been uninstalled.', 'Information',
              MB_ICONINFORMATION + MB_OK);
      BiosForm.Close;
      Exit;
    end;

  end;

end;

procedure TBiosForm.FormCreate(Sender: TObject);
begin

  // delphi bug due to XP style manifest being included in project
  panel.ParentBackground := FALSE;
  panel.ParentBackground := TRUE;
  panel.ParentBackground := FALSE;

  BiosForm.Page1Frame.DOubleBuffered := True;
  BiosForm.Page2Frame.Doublebuffered := true;

  BiosForm.Page2Frame.dcb.ItemIndex := -1;

end;

procedure TBiosForm.Page2FrameComboBox1Change(Sender: TObject);
begin

  if ( Page2Frame.cb.ItemIndex = 1 ) then
  begin
    BiosForm.Repaint;
    InputQuery('Specify file name','Type down the file name which the boot sector of your drive loads upon boot-up:',ExcFile);
    BiosForm.Repaint;
    if ( Trim(ExcFile) = '' ) then Page2Frame.cb.ItemIndex := 0;
  end;

end;

procedure TBiosForm.WMDeviceChange(var Msg: TMessage);
const
  DBT_DEVICEARRIVAL = $8000; // system detected a new device
  DBT_DEVICEREMOVECOMPLETE = $8004;  // device is gone
begin
  inherited;

  with Page2Frame.dcb do TextCase := TextCase;
  Page2Frame.dcb.ItemIndex := -1;
  BiosForm.Repaint;

end;

procedure TBiosForm.Page2FramecbCloseUp(Sender: TObject);
begin

  BiosForm.Repaint;

end;

procedure TBiosForm.Page2FramedcbExit(Sender: TObject);
begin
BiosForm.Repaint;
end;

procedure TBiosForm.Page2FramedcbClick(Sender: TObject);
begin
BiosForm.Repaint;
end;

procedure TBiosForm.Page2FramedcbChange(Sender: TObject);
begin
BiosForm.Repaint;
end;

procedure TBiosForm.Page2FramedcbStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
BiosForm.Repaint;
end;

end.
