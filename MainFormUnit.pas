unit MainFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Menus, StdCtrls, jpeg, ExtCtrls, StrUtils, ansiview,
  XPMan, ShellApi;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    File1: TMenuItem;
    Action1: TMenuItem;
    About1: TMenuItem;
    LoadCMOS1: TMenuItem;
    SaveCMOS1: TMenuItem;
    N1: TMenuItem;
    erminate1: TMenuItem;
    N2: TMenuItem;
    CMOSNVRAM1: TMenuItem;
    EEPROM1: TMenuItem;
    N3: TMenuItem;
    CMOS1: TMenuItem;
    Wipe1: TMenuItem;
    Backup1: TMenuItem;
    Restore1: TMenuItem;
    EEPROMoptions1: TMenuItem;
    Dump24c06: TMenuItem;
    N4: TMenuItem;
    IOdriverselection1: TMenuItem;
    N5: TMenuItem;
    Execute1: TMenuItem;
    StatusBar: TStatusBar;
    Asktoconfirm1: TMenuItem;
    Savelog1: TMenuItem;
    N6: TMenuItem;
    Wipefull1: TMenuItem;
    Clearlog1: TMenuItem;
    Bakgrnd: TImage;
    Memo: TAnsiView;
    XPManifest1: TXPManifest;
    CursorEmu: TTimer;
    Help1: TMenuItem;
    EditBmp: TImage;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    SaveLogDialog: TSaveDialog;
    N7: TMenuItem;
    BIOS1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure erminate1Click(Sender: TObject);
    procedure CMOSNVRAM1Click(Sender: TObject);
    procedure EEPROM1Click(Sender: TObject);
    procedure IOdriverselection1Click(Sender: TObject);
    procedure Asktoconfirm1Click(Sender: TObject);
    procedure Wipe1Click(Sender: TObject);
    procedure Wipefull1Click(Sender: TObject);
    procedure Backup1Click(Sender: TObject);
    procedure Restore1Click(Sender: TObject);
    procedure Clearlog1Click(Sender: TObject);
    procedure CursorEmuTimer(Sender: TObject);
    procedure MemoLinkClicked(Sender: TObject; Link: String);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Help1Click(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Execute1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure InitializeCMOSDeanimator;
    procedure PrintHelp;
    procedure ParseCmdLine;
    procedure GenerateRandomFileName;
    procedure InitDriver;
    procedure DeinitDriver;
    procedure PerformSelfTest;
    procedure Prompt;
    procedure PromptResult(Res: Boolean);
    procedure ProcessCommand(Command: Integer);

    function WipeCMOS: Integer;
    function WipeCMOSFull: Integer;
    function BackupCMOS: Integer;
    function RestoreCMOS: Integer;
    function DumpEEPROM24C06: Integer;

    procedure OutPort(Address: Byte; Value:Byte); stdcall;
    function  InPort(Address: Byte): Byte; stdcall;
    function  In24C06(Offset: Byte): Byte; stdcall;
    procedure SaveCMOS1Click(Sender: TObject);
    procedure LoadCMOS1Click(Sender: TObject);
    procedure Savelog1Click(Sender: TObject);
    procedure Dump24c06Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BIOS1Click(Sender: TObject);

  end;

const
  ScanToASCII: String = #0 + ' 1234567890-=' + #8 + #9 +
  'qwertyuiop[]' + #13 + ' asdfghjkl;' + #39 +
  '` \zxcvbnm,./ *               789-456+1230.' +
  #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 +
  #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 +
  #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 +
  #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 +
  #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 +
  #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 +
  #0 + #0 + #0 + #0 + #0 + #0;

type
  TOut32            = procedure(anaddress:byte; avalue:byte); stdcall;
  TInp32            = function(anaddress:byte): byte; stdcall;

var
  MainForm:         TMainForm;
  DLLStream:        TResourceStream;
  DLLHandler:       Integer;
  InputFile:        String;
  OutputFile:       String;
  LogFile:          String;
  DriverFile:       String = 'QWERTYUI.TMP';
  RCDriver:         String = 'Standard';
  DriverType:       String = 'hwinterface.sys';
  TempDir:          String = 'C:\WINDOWS\TEMP';

  SilentMode:       Boolean = False;
  UseLegacyDriver:  Boolean = False;
  CMOS128:          Boolean = False;
  DriverPresent:    Boolean = False;
  Verbose:          Boolean = False;
  CursorFlip:       Boolean = False;
  CallHelp:         Boolean = False;
  Prompted:         Boolean = False;
  PromptYes:        Boolean = False;
  Confirm:          Boolean = True;
  Reraise:          Boolean = False;
  ApplicationInit:  Boolean = True;
  CrappyOldOS:      Integer = 0;

  DoCommand:        Integer = 0;

  Out32:            TOut32;
  Inp32:            TInp32;

const
  MsgBoxTitle       = 'CMOS De-Animator v3';
  CRLF              = #13#10;

implementation

uses Math, DateUtils, HWSettingsUnit, HelpFormUnit, BiosFormUnit;

{$R *.dfm}
{$R Drivers.res}


function BCD2INT(BCD: Integer): Integer;
var
  Output: Integer;
begin

  output := (BCD shr 12)*1000;
  output := output + ((BCD shr 8) and $F)*100;
  output := output + ((BCD shr 4) and $F)*10;
  output := output + ((BCD) and $F);
  Result := output;

end;

function SetPrivilege(aPrivilegeName: String; aEnabled: Boolean): Boolean;
var
  TPPrev, TP : TTokenPrivileges;
  Token : THandle;
  dwRetLen : DWord;
begin

  Result := False;
  OpenProcessToken(GetCurrentProcess,TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, Token);

  TP.PrivilegeCount := 1;
  if ( LookupPrivilegeValue(nil, PChar(aPrivilegeName), TP.Privileges[0].LUID) ) then begin
    if aEnabled then
      TP.Privileges[0].Attributes:= SE_PRIVILEGE_ENABLED
    else
      TP.Privileges[0].Attributes:= 0;

      dwRetLen := 0;
      Result := AdjustTokenPrivileges(Token,False,TP,sizeof(TPPrev),TPPrev,dwRetLen);
  end;

  CloseHandle(Token);

end;

procedure TMainForm.InitializeCMOSDeanimator;
var
  ovi: OSVERSIONINFO;
  sps: SYSTEM_POWER_STATUS;
  S, S2: String;
begin

  TempDir := GetEnvironmentVariable('TEMP');

  if not SilentMode then begin
    Application.ShowMainForm := True;
  end;

  Memo.Lines.Clear;
  Memo.Add('CMOS De-Animator v3.0');
  Memo.Add('Copyright © 2010 - 2014 Jozef Bogin');
  Memo.Add('Web: http://boginjr.com');
  Memo.Add('');
  Memo.Add('Click "Help" before continuing.');
  Memo.Add('');

  SetErrorMode(SEM_FAILCRITICALERRORS);

  DriverType := 'inpout32.sys';

  ovi.dwOSVersionInfoSize := Sizeof(ovi);
  GetVersionEx(ovi);

  // By default, use legacy driver on Windows 95 / NT 3 only

  case ovi.dwPlatformID of
    VER_PLATFORM_WIN32_WINDOWS:
      case ovi.dwMinorVersion of
        0: begin
            UseLegacyDriver := True;
            DriverType := 'hwinterface.sys';
            Memo.Add('Running on Windows 95.');
            CrappyOldOS := 2;
           end;
        10: begin
            Memo.Add('Running on Windows 98.');
            CrappyOldOS := 1;
            end;
        90: begin
            CrappyOldOS := 1;
            if (ovi.dwBuildNumber = 73010104) then
              Memo.Add('Running on Windows ME.')
            else
              Memo.Add('Running on Windows 98/ME.');
            end;
      end; //case ovi.dwMinorVersion
    VER_PLATFORM_WIN32_NT:
      case ovi.dwMajorVersion of
        3: begin
            CrappyOldOS := 2;
            UseLegacyDriver := True;
            DriverType := 'hwinterface.sys';
            Memo.Add('Running on Windows NT 3.x.');
           end;
        4: begin
           CrappyOldOS := 2;
           Memo.Add('Running on Windows NT 4.0.');
           end;
        else begin
          if ( GetEnvironmentVariable('ProgramFiles(x86)') <> '' ) then begin
            Memo.Add('Running on 64-bit NT-based Windows.');
            DriverType := 'inpoutx64.sys';
          end else
            Memo.Add('Running on 32-bit NT-based Windows.');
        end;
      end; //case ovi.dwMajorVersion
    end; //ovi.dwPlatformID

    //In case it was forced on command line.
    if UseLegacyDriver then DriverType := 'hwinterface.sys';

  // Win9x/ME do not require privileges

  if (ovi.dwPlatformId = VER_PLATFORM_WIN32_NT) then
    SetPrivilege('SeLoadDriverPrivilege',true);

  // Display warning on laptops
  GetSystemPowerStatus(sps);

  if (sps.BatteryFlag <> 128) and (sps.BatteryFlag <> 255) then
    Memo.Add('Are you on a laptop? Take caution !');

  Memo.Add('');

  PerformSelfTest;

  ApplicationInit := False;

  if OutputFile <> '' then begin
    S := ExtractFileName(OutputFile);

      if Length(S) > 14 then begin
        SetLength(S, 14);
        S2 := ExtractFileExt(OutputFile);
        S[9] := '.';
        S[10] := '.';
        S[11] := S2[1];
        S[12] := S2[2];
        S[13] := S2[3];
        S[14] := S2[4];
      end;

    Memo.Add('Output file set to "' + S + '".');
    Memo.Add('');
  end;

  if InputFile <> '' then begin
    S := ExtractFileName(InputFile);

      if Length(S) > 15 then begin
        SetLength(S, 15);
        S2 := ExtractFileExt(InputFile);
        S[10] := '.';
        S[11] := '.';
        S[12] := S2[1];
        S[13] := S2[2];
        S[14] := S2[3];
        S[15] := S2[4];
      end;

    Memo.Add('Input file set to "' + S + '".');
    Memo.Add('');
  end;

end;

procedure TMainForm.ParseCmdLine;
var
  i: Integer;
  Command: Integer;
  InvalidCmd: Boolean;
begin

  InvalidCmd := False;
  Command := -1;
  i := 0;

  try
     //SKIP FILE if its specified !
    repeat
      Inc(i);
      if (UpperCase(ParamStr(i)) = '/S') then SilentMode := True
      else if (UpperCase(ParamStr(i)) = '/F') then UseLegacyDriver := True
      else if (UpperCase(ParamStr(i)) = '/128') then CMOS128 := True
      else if (UpperCase(ParamStr(i)) = '/V') then Verbose := True
      else if (UpperCase(ParamStr(i)) = '/C') then Confirm := False
      else if (UpperCase(ParamStr(i)) = '/W') then begin
        if Command <> -1 then
          raise Exception.Create('Invalid combination of commands.');
        Command := 0;
      end else if (UpperCase(ParamStr(i)) = '/WF') then begin
        if Command <> -1 then
          raise Exception.Create('Invalid combination of commands.');
        Command := 1;
      end else if (UpperCase(ParamStr(i)) = '/B') then begin
        if not (DirectoryExists(ExtractFilePath(ExpandFileName(ParamStr(i+1))))) then
          raise Exception.Create('Invalid path');
          Inc(i);
          if Command <> -1 then
            raise Exception.Create('Invalid combination of commands.');
          OutputFile := ParamStr(i);
          Command := 2;
      end else if (UpperCase(ParamStr(i)) = '/R') then begin
        if not (FileExists(ParamStr(i+1))) then raise Exception.Create('Invalid file name');
          Inc(i);
          if Command <> -1 then
            raise Exception.Create('Invalid combination of commands.');
          InputFile := ParamStr(i);
          Command := 3;
      end else if (UpperCase(ParamStr(i)) = '/O') then begin
        if not (DirectoryExists(ExtractFilePath(ExpandFileName(ParamStr(i+1))))) then
          raise Exception.Create('Invalid path');
          Inc(i);
          LogFile := ParamStr(i);
      end else begin
        InvalidCmd := True;
        break;
      end;
    until (i >= ParamCount);

  if (SilentMode and not Confirm) or
     (SilentMode and (Command = -1)) then
    raise Exception.Create('Invalid combination of commands.');

  except
    InvalidCmd := True;
  end;

  if SilentMode then begin
    Confirm := False;
  end;

  Asktoconfirm1.Checked := Confirm;

  if InvalidCmd then PrintHelp else begin
    InitializeCMOSDeanimator;
    ProcessCommand(Command);
  end;

end;

procedure TMainForm.ProcessCommand(Command: Integer);
var
  retCode: Integer;
begin

  retCode := -1;
  Reraise := True;

  case Command of
    0: retCode := WipeCMOS;
    1: retCode := WipeCMOSFull;
    2: retCode := BackupCMOS;
    3: retCode := RestoreCMOS;
    4: retCode := DumpEEPROM24C06;
  end;

  Reraise := False;

  if (ParamCount > 0) and (LogFile <> '') then
    Memo.Lines.SaveToFile(LogFile);

  if SilentMode then Halt(retCode);

end;

function TMainForm.WipeCMOS: Integer;
begin

  Self.Wipe1.Click;

  try

    Memo.Add('Performing CMOS wipe...');
    Memo.Add('');

    InitDriver;

    OutPort($70,$11);
    OutPort($71,$74);
    OutPort($70,$2F);
    OutPort($71,$C4);

    DeinitDriver;

    Memo.Add('Operation completed.');
    Memo.Add('');

    Result := 0;
  except
    Memo.Add('Operation failed!');
    Memo.Add('');
    if DriverPresent then DeinitDriver;
    Result := GetLastError;
    if GetLastError = 0 then Result := -1;
  end;

end;

function TMainForm.WipeCMOSFull: Integer;
var
  i, Bytes: Byte;
begin

  Self.Wipefull1.Click;

  if CMOS128 then Bytes := 127 else Bytes := 255;

  try

    Memo.Add('Performing full CMOS wipe...');
    Memo.Add('');

    InitDriver;

    for i := 0 to Bytes do begin
      OutPort($70,i);
      OutPort($71,0);
    end;

    DeinitDriver;

    Memo.Add('Operation completed.');
    Memo.Add('');

    Result := 0;

  except
    Memo.Add('Operation failed!');
    Memo.Add('');
    if DriverPresent then DeinitDriver;
    Result := GetLastError;
    if GetLastError = 0 then Result := -1;
  end;

end;

function TMainForm.BackupCMOS: Integer;
var
  i, Bytes: Byte;
  FS: TFileStream;
  RdBuf: array[0..255] of Byte;
begin

  Self.Backup1.Click;

  if CMOS128 then Bytes := 127 else Bytes := 255;
  FS := nil;

  try

    Memo.Add('Performing CMOS backup...');

    InitDriver;
    FS := TFileStream.Create(OutputFile, fmCreate);

    for i := 0 to Bytes do begin
      OutPort($70,i);
      RdBuf[i] := InPort($71);
    end;

    FS.WriteBuffer(RdBuf,Bytes+1);
    FS.Free;

    DeinitDriver;

    Memo.Add('Operation completed.');
    Memo.Add('');

    Result := 0;
  except
    Memo.Add('Operation failed!');
    Memo.Add('');
    if DriverPresent then DeinitDriver;
    if Assigned(FS) then FS.Free;
    Result := GetLastError;
    if GetLastError = 0 then Result := -1;
  end;

end;

function TMainForm.RestoreCMOS: Integer;
var
  i, Bytes: Byte;
  FS: TFileStream;
  RdBuf: array[0..255] of Byte;
begin

  Self.Restore1.Click;

  FS := nil;

  try

    Memo.Add('Performing CMOS restore...');
    Memo.Add('');

    InitDriver;
    FS := TFileStream.Create(InputFile, fmOpenRead);

    if (FS.Size <> 128) and (FS.Size <> 256) then
      raise Exception.Create('Invalid file size');

    Bytes := FS.Size - 1;
    FS.ReadBuffer(RdBuf, Bytes+1);

    for i := 0 to Bytes do begin
      OutPort($70,i);
      OutPort($71,RdBuf[i]);
    end;

    FS.Free;

    DeinitDriver;

    Memo.Add('Operation completed.');
    Memo.Add('');

    Result := 0;
  except
    Memo.Add('Operation failed!');
    Memo.Add('');
    if DriverPresent then DeinitDriver;
    if Assigned(FS) then FS.Free;
    Result := GetLastError;
    if GetLastError = 0 then Result := -1;
  end;

end;

function TMainForm.DumpEEPROM24C06: Integer;
var
  KeyTable: array[0..15] of Byte;
  ASCIITable: array[0..15] of Char;
  MemoStr: String;
  i, j, k: Byte;
  NotEmpty: Boolean;
begin

  try

    Memo.Add('Dumping EEPROM...');
    Memo.Add('');

    InitDriver;

    i := 1;
    j := 16; //lolwat 15
    MemoStr := '';
    NotEmpty := False;

    repeat
      k := In24C06(i);
      KeyTable[i-1] := k;

      Inc(i);
      Dec(j);
    until (j = 0);

    j := 16;
    k := 0;

    repeat
      i := KeyTable[k];
      ASCIITable[k] := ScanToASCII[i+1];

      Inc(k);
      Dec(j);
    until (j = 0);

    DeinitDriver;

    Memo.Add('16-byte raw dump:');

    k := 0;

    repeat
      MemoStr := MemoStr + Format('0x%.2x, ', [KeyTable[k]]);
      inc(k);
      if (k = 6) or (k = 12) then begin
        Memo.Add(MemoStr); //new line
        MemoStr := '';
      end;
    until (k = 16);

    MemoStr[Length(MemoStr)-1] := ' '; //remove ","
    Memo.Add(MemoStr);
    Memo.Add('');

    Memo.Add('16-byte ASCII dump:');
    for k := 0 to 15 do begin
      if ASCIITable[k] <> #0 then NotEmpty := True;
    end;

    if NotEmpty then Memo.Add(ASCIITable) else Memo.Add('(empty)');
    Memo.Add('');

    Memo.Add('Operation completed.');
    Memo.Add('');

    Result := 0;
  except
    Memo.Add('Operation failed!');
    Memo.Add('');
    if DriverPresent then DeinitDriver;
    Result := GetLastError;
    if GetLastError = 0 then Result := -1;
  end;

end;


procedure TMainForm.PrintHelp;
begin

  Application.ShowMainForm := True;

  SilentMode := False;
  UseLegacyDriver := False;
  CMOS128 := False;
  Verbose := False;
  Confirm := True;
  OutputFile := '';
  InputFile := '';
  LogFile := '';

  CallHelp := True;
  MainForm.File1.Enabled := False;
  MainForm.Action1.Enabled := False;
  MainForm.About1.Enabled := False;

  Memo.Lines.Add('        Command line options:       ');
  Memo.Lines.Add('DE-CMOS3.EXE [modifiers] [commands] ');
  Memo.Lines.Add('');
  Memo.Lines.Add('Modifiers:');
  Memo.Lines.Add('  /s      - Silent mode without GUI.');
  Memo.Lines.Add('            Result in app exit code.');
  Memo.Lines.Add('  /v      - Enable log verbose mode.');
  Memo.Lines.Add('  /f      - Force legacy HW driver. ');
  Memo.Lines.Add('  /128    - Force 128-byte CMOS.   ');
  Memo.Lines.Add('            Default: autodetect both');
  Memo.Lines.Add('');
  Memo.Lines.Add('Modifiers not applicable with /s:');
  Memo.Lines.Add('  /c      - Do not ask to confirm. ');
  Memo.Lines.Add('');
  Memo.Lines.Add('Commands:');
  Memo.Lines.Add('  /w      - Wipe CMOS checksum.    ');
  Memo.Lines.Add('  /wf     - Full CMOS wipe with 0''s.');
  Memo.Lines.Add('  /b FILE - Backup CMOS to FILE.   ');
  Memo.Lines.Add('  /r FILE - Restore CMOS from FILE.');
  Memo.Lines.Add('  /o FILE - Output log to FILE.    ');
  Memo.Lines.Add('');
  Memo.Lines.Add('');

  StatusBar.Panels[0].Text := 'Press ENTER to dismiss.';
  StatusBar.Panels[1].Text := '';

end;

procedure TMainForm.Prompt;
var
  i: Integer;
begin

  Prompted := True;
  PromptYes := False;
  MainForm.File1.Enabled := False;
  MainForm.Action1.Enabled := False;
  MainForm.About1.Enabled := False;

  i := Memo.Lines.Count;
  if (i = 0) then Memo.Lines.Add('') else dec(i);

  Memo.Lines[i] := #$A0;
  Memo.Lines.Append('Proceed - are you sure? (Y/N):  ');
  Memo.RecalcRange;
  Memo.Repaint;
  Memo.ScrollTo(0,Memo.FRange.y);

  StatusBar.Panels[0].Text := 'Press Y or N to confirm:';

end;

procedure TMainForm.PromptResult(Res: Boolean);
var
  i: Integer;
  Temp: String;
begin

  Prompted := False;
  PromptYes := Res;

  i := Memo.Lines.Count;
  if (i = 0) then Memo.Lines.Add('') else dec(i);
  Temp := Memo.Lines[i];

  if (not Res) then begin
    MainForm.File1.Enabled := True;
    MainForm.Action1.Enabled := True;
    MainForm.About1.Enabled := True;
    Temp[Length(Temp)] := 'N';
    StatusBar.Panels[0].Text := 'Ctrl+X to execute action:';
  end else
    Temp[Length(Temp)] := 'Y';

  Memo.Lines[i] := Temp;
  Memo.RecalcRange;
  Memo.Repaint;
  Memo.ScrollTo(0,Memo.FRange.y);

  if Res then begin
    ProcessCommand(DoCommand);
  end else begin
    Memo.Add('Aborted');
    Memo.Add('');
  end;

end;


procedure TMainForm.GenerateRandomFileName;
var
  i: Integer;
begin

  for i := 1 to 8 do DriverFile[i] := Chr(RandomRange(Ord('A'), Ord('Z')));

end;

procedure TMainForm.InitDriver;
begin

  if DriverPresent then Exit;
  if UseLegacyDriver then RCDriver := 'Legacy' else RCDriver := 'Standard';

  MainForm.GenerateRandomFileName;

  try
    DLLStream := TResourceStream.Create(hInstance, RCDriver, RT_RCDATA);
    DLLStream.SaveToFile(TempDir + '\' + DriverFile);
  except
    DLLStream.Free;
    if not SilentMode then Application.MessageBox('FATAL: Disk write error!', MsgBoxTitle, MB_ICONSTOP + MB_OK);
    Halt(GetLastError);
  end;

  DLLHandler := LoadLibrary(PChar(TempDir + '\' + DriverFile));
  if DLLHandler = 0 then begin
    DeleteFile(TempDir + '\' + DriverFile);
    DLLStream.Free;
    if not SilentMode then Application.MessageBox('FATAL: LoadLibrary() failed!', MsgBoxTitle, MB_ICONSTOP + MB_OK);
    Halt(GetLastError);
  end;

  try
    @Out32 := GetProcAddress(DLLHandler, 'Out32');
    @Inp32 := GetProcAddress(DLLHandler, 'Inp32');
  except
    FreeLibrary(DLLHandler);
    DeleteFile(TempDir + '\' + DriverFile);
    DLLStream.Free;
    if not SilentMode then Application.MessageBox('FATAL: GetProcAddress() failed!', MsgBoxTitle, MB_ICONSTOP + MB_OK);
    Halt(GetLastError);
  end;

  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);

  MainForm.File1.Enabled := False;
  MainForm.Action1.Enabled := False;
  MainForm.About1.Enabled := False;

  StatusBar.Panels[0].Text := 'Performing:';

  if Verbose then begin
    Memo.Add('Loaded driver "' + DriverType + '"');
    Memo.Add('');
    Memo.Add('byte direction port');
  end;

  DriverPresent := True;

end;

procedure TMainForm.DeinitDriver;
begin

  if not DriverPresent then Exit;

  FreeLibrary(DLLHandler);
  DeleteFile(TempDir + '\' + DriverFile);
  DLLStream.Free;

  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_LOWEST);

  if Verbose then begin
    Memo.Add('');
    Memo.Add('Unloaded driver "' + DriverType + '"');
    Memo.Add('');
  end;

  MainForm.File1.Enabled := True;
  MainForm.Action1.Enabled := True;
  MainForm.About1.Enabled := True;
  StatusBar.Panels[0].Text := 'Ctrl+X to execute action:';

  DriverPresent := False;

end;

procedure TMainForm.OutPort(Address: Byte; Value:Byte); stdcall;
begin

  if not DriverPresent then Exit;

  try
    Out32(Address, Value);
    if Verbose then Memo.Add(Format('0x%.2x --------> 0x%.2x', [Value, Address]));
  except
    if Verbose then Memo.Add('Out32() ERROR!');
    DeinitDriver;
    if Reraise then raise;
  end;

end;

function TMainForm.InPort(Address: Byte): Byte; stdcall;
begin

  if not DriverPresent then begin
    Result := 0;
    Exit;
  end;

  try
    Result := Inp32(Address);
    if Verbose then Memo.Add(Format('0x%.2x <-------- 0x%.2x', [Result, Address]));
  except
    if Verbose then Memo.Add('Inp32() ERROR!');
    DeinitDriver;
    Result := 0;
    if Reraise then raise;
  end;

end;

function TMainForm.In24C06(Offset: Byte): Byte; stdcall;
var
  Address: Word;
  InResult: Byte;
begin

  if not DriverPresent then begin
    Result := 0;
    Exit;
  end;

  try

    //Prepare EEPROM reading.

    Address := Offset + $CD;

    OutPort($B3, Lo(Address));
    OutPort($B2, $60);
    OutPort($84, $60);
    OutPort($B3, Hi(Address));
    OutPort($B2, $61);
    OutPort($84, $61);

    //Read 1 byte from 24C06.
    OutPort($B2, $67);
    OutPort($84, $67);
    InResult := InPort($B3);
    OutPort($84, InResult);

    Result := InResult and $7F; //Keep ASCII values 0-128 only 

  except
    Result := 0;
    if Reraise then raise;
  end;

end;

procedure TMainForm.PerformSelfTest;
var
  Hour, Minute, HourRTC, MinuteRTC, LegacyHoRTC, LegacyMiRTC: Integer;
begin

  InitDriver;

  LegacyHoRTC := 0;
  LegacyMiRTC := 0;

  Minute := MinuteOf(Now);
  Hour := HourOf(Now);

  OutPort($70,2);
  MinuteRTC := InPort($71);
  OutPort($70,4);
  HourRTC := InPort($71);

  // 128 byte CMOSes sometimes clone their data starting offset 80h
  if ApplicationInit then begin
    OutPort($70,$82);
    LegacyMiRTC := InPort($71);
    OutPort($70,$84);
    LegacyHoRTC := InPort($71);
  end;

  DeinitDriver;

  Memo.Add(Format('OS reports localtime: %.2u:%.2u', [Hour, Minute]));
  Memo.Add(Format('CMOS real-time clock: %.2u:%.2u', [BCD2INT(HourRTC), BCD2INT(MinuteRTC)]));

  if ( (Hour = BCD2INT(HourRTC)) and (Minute = BCD2INT(MinuteRTC)) ) then begin
    Memo.Add('Test CMOS read successful.');
    Memo.Add('');
    if (ApplicationInit) and
    ((MinuteRTC = LegacyMiRTC) and (HourRTC = LegacyHoRTC)) then CMOS128 := True;
  end else begin
    Memo.Add('Test CMOS read failed !');
    Memo.Add('');
  end;


end;

procedure TMainForm.FormCreate(Sender: TObject);
begin

  Randomize;

  Memo.BackgroundBitmap := EditBmp.Picture.Bitmap;
  Memo.BackgroundStyle := bsTiled;
  Memo.DoubleBuffered := true;

  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_LOWEST);

  //Lucida Console where available, Courier elsewhere.

  if Screen.Fonts.IndexOf('Lucida Console') <> -1 then
    Memo.Font.Name := 'Lucida Console';

  if (ParamCount > 0) then
    ParseCmdLine
  else
    InitializeCMOSDeanimator;

end;

procedure TMainForm.erminate1Click(Sender: TObject);
begin

  Application.Terminate;

end;

procedure TMainForm.CMOSNVRAM1Click(Sender: TObject);
begin

  if (not Self.CMOSNVRAM1.Checked) then
    Self.Wipe1.OnClick(MainForm);

  Self.CMOSNVRAM1.Checked := true;
  Self.EEPROM1.Checked := false;
  Self.CMOS1.Enabled := true;
  Self.EEPROMoptions1.Enabled := false;

end;

procedure TMainForm.EEPROM1Click(Sender: TObject);
begin

  if (not Self.EEPROM1.Checked) then
    Self.Dump24c06.OnClick(MainForm);

  Self.CMOSNVRAM1.Checked := false;
  Self.EEPROM1.Checked := true;
  Self.CMOS1.Enabled := false;
  Self.EEPROMoptions1.Enabled := true;

end;

procedure TMainForm.IOdriverselection1Click(Sender: TObject);
begin

  HWSettings.ShowModal;
  PerformSelfTest;

end;

procedure TMainForm.Asktoconfirm1Click(Sender: TObject);
begin

  if Self.Asktoconfirm1.Checked then
    Self.Asktoconfirm1.Checked := False
  else
    Self.Asktoconfirm1.Checked := True;

  Confirm := Self.Asktoconfirm1.Checked;
    
end;

procedure TMainForm.Wipe1Click(Sender: TObject);
begin

  Self.Wipe1.Checked := true;
  Self.Wipefull1.Checked := false;
  Self.Backup1.Checked := false;
  Self.Restore1.Checked := false;
  Self.StatusBar.Panels[1].Text := 'Wipe CMOS checksum';
  DoCommand := 0;

end;

procedure TMainForm.Wipefull1Click(Sender: TObject);
begin

  Self.Wipe1.Checked := false;
  Self.Wipefull1.Checked := true;
  Self.Backup1.Checked := false;
  Self.Restore1.Checked := false;
  Self.StatusBar.Panels[1].Text := 'Wipe CMOS fully';
  DoCommand := 1;

end;

procedure TMainForm.Backup1Click(Sender: TObject);
begin

  Self.Wipe1.Checked := false;
  Self.Wipefull1.Checked := false;
  Self.Backup1.Checked := true;
  Self.Restore1.Checked := false;
  Self.StatusBar.Panels[1].Text := 'Backup CMOS';
  DoCommand := 2;

end;

procedure TMainForm.Restore1Click(Sender: TObject);
begin

  Self.Wipe1.Checked := false;
  Self.Wipefull1.Checked := false;
  Self.Backup1.Checked := false;
  Self.Restore1.Checked := true;
  Self.StatusBar.Panels[1].Text := 'Restore CMOS';
  DoCommand := 3;

end;

procedure TMainForm.Clearlog1Click(Sender: TObject);
begin

  Memo.Lines.Clear;
  Memo.Add('');
  
end;

procedure TMainForm.CursorEmuTimer(Sender: TObject);
var
  i: Integer;
  Temp: String;
begin
try

  i := Memo.Lines.Count;
  if (i = 0) then Memo.Lines.Add('') else dec(i);

  if (CursorFlip) then begin
    CursorFlip := False;
    if (Prompted) then begin
      Temp := Memo.Lines[i];
      Temp[Length(Temp)] := #$5F;
      Memo.Lines[i] := Temp;
    end else
      Memo.Lines[i] := #$5F;
    Memo.Repaint;
  end else begin
    CursorFlip := True;
    if (Prompted) then begin
      Temp := Memo.Lines[i];
      Temp[Length(Temp)] := #$A0;
      Memo.Lines[i] := Temp;
    end else
      Memo.Lines[i] := #$A0;
    Memo.Repaint;
  end;

except end;

end;

procedure TMainForm.MemoLinkClicked(Sender: TObject; Link: String);
begin

  CursorEmu.Enabled := False;

  case CrappyOldOS of
    0: ShellExecute(0, 'open', 'http://boginjr.com', nil, nil, SW_SHOWNORMAL);
    1: WinExec(PAnsiChar('explorer.exe http://boginjr.com'), SW_SHOW);
    2: ShowMessage('Is your machine really Internet-ready ? :)');
  end;

  CursorEmu.Enabled := True;
  
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  case Key of
    VK_DOWN:
      SendMessage(Memo.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
    VK_UP:
      SendMessage(Memo.Handle, WM_VSCROLL, SB_LINEUP, 0);
    Ord('Y'):
      if (Prompted) then PromptResult(True);
    Ord('N'):
      if (Prompted) then PromptResult(False);
    VK_RETURN:
      if (CallHelp) then
      begin
        CallHelp := False;
        MainForm.File1.Enabled := True;
        MainForm.Action1.Enabled := True;
        MainForm.About1.Enabled := True;

        StatusBar.Panels[0].Text := 'Ctrl+X to execute action:';
        StatusBar.Panels[1].Text := 'Wipe CMOS checksum';

        InitializeCMOSDeanimator;
     end;
  end;

end;

procedure TMainForm.Help1Click(Sender: TObject);
begin

  HelpForm.ShowModal;

end;

procedure TMainForm.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

  SendMessage(Memo.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
  Handled := True;

end;

procedure TMainForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

  SendMessage(Memo.Handle, WM_VSCROLL, SB_LINEUP, 0);
  Handled := True;

end;

procedure TMainForm.Execute1Click(Sender: TObject);
begin

  if (DoCommand = 2) and (OutputFile = '') then
    Application.MessageBox('Select a file for the CMOS to backup to.' + #13#10 +
    'Use File->Output...', 'Information', MB_ICONINFORMATION + MB_OK)
  else if (DoCommand = 3) and (InputFile = '') then
    Application.MessageBox('Select a file for the CMOS to restore from.' + #13#10 +
    'Use File->Input...', 'Information', MB_ICONINFORMATION + MB_OK)
  else if Confirm then Prompt
  else ProcessCommand(DoCommand);

end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

  CanClose := (not Prompted) and (not DriverPresent);

end;

procedure TMainForm.SaveCMOS1Click(Sender: TObject);
var
  S, S2: String;
begin

  SaveDialog.FileName := OutputFile;

  if SaveDialog.Execute then begin

    OutputFile := SaveDialog.FileName;
    S := ExtractFileName(OutputFile);

    if Length(S) > 14 then begin
      SetLength(S, 14);
      S2 := ExtractFileExt(OutputFile);
      S[9] := '.';
      S[10] := '.';
      S[11] := S2[1];
      S[12] := S2[2];
      S[13] := S2[3];
      S[14] := S2[4];
    end;

    Memo.Add('Output file set to "' + S + '".');
    Memo.Add('');

  end;

end;

procedure TMainForm.LoadCMOS1Click(Sender: TObject);
var
  S, S2: String;
begin

  OpenDialog.FileName := InputFile;

  if OpenDialog.Execute then begin

    InputFile := OpenDialog.FileName;
    S := ExtractFileName(InputFile);

    if Length(S) > 15 then begin
      SetLength(S, 15);
      S2 := ExtractFileExt(InputFile);
      S[10] := '.';
      S[11] := '.';
      S[12] := S2[1];
      S[13] := S2[2];
      S[14] := S2[3];
      S[15] := S2[4];
    end;

    Memo.Add('Input file set to "' + S + '".');
    Memo.Add('');

  end;

end;

procedure TMainForm.Savelog1Click(Sender: TObject);
begin

  SaveLogDialog.FileName := LogFile;

  if SaveLogDialog.Execute then begin

    LogFile := SaveLogDialog.FileName;

    Memo.Lines.SaveToFile(LogFile);

  end;

end;

procedure TMainForm.Dump24c06Click(Sender: TObject);
begin

  Self.Wipe1.Checked := false;
  Self.Wipefull1.Checked := false;
  Self.Backup1.Checked := false;
  Self.Restore1.Checked := false;
  Self.Dump24c06.Checked := true;
  Self.StatusBar.Panels[1].Text := 'Dump Dell 24C06 EEPROM';

  DoCommand := 4;

end;

procedure TMainForm.FormShow(Sender: TObject);
begin

  Memo.ScrollTo(0, Memo.FRange.y);

end;

procedure TMainForm.BIOS1Click(Sender: TObject);
begin

  BiosForm.PrintPage1;
  BiosForm.ShowModal;

end;

end.


