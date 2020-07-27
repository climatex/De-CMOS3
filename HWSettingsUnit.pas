unit HWSettingsUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  THWSettings = class(TForm)
    GroupBox1: TGroupBox;
    Standard: TRadioButton;
    Legacy: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    VerboseMode: TCheckBox;
    Button1: TButton;
    LegacyCMOS: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HWSettings: THWSettings;

implementation

uses MainFormUnit, HelpFormUnit;

{$R *.dfm}

procedure THWSettings.Button1Click(Sender: TObject);
begin

  if Legacy.Checked then UseLegacyDriver := True else UseLegacyDriver := False;
  if VerboseMode.Checked then Verbose := True else Verbose := False;
  if LegacyCMOS.Checked then CMOS128 := True else CMOS128 := False;

  if UseLegacyDriver then DriverType := 'hwinterface.sys'
  else if ( GetEnvironmentVariable('ProgramFiles(x86)') <> '' ) then DriverType := 'inpoutx64.sys'
  else DriverType := 'inpout32.sys';

  HWSettings.Close;

end;

procedure THWSettings.FormShow(Sender: TObject);
begin

  if UseLegacyDriver then begin
    Standard.Checked := False;
    Legacy.Checked := True;
  end else begin
    Standard.Checked := True;
    Legacy.Checked := False;
  end;

  if Verbose then
    VerboseMode.Checked := True
  else
    VerboseMode.Checked := False;

  if CMOS128 then
    LegacyCMOS.Checked := True
  else
    LegacyCMOS.Checked := False;

end;

procedure THWSettings.FormCreate(Sender: TObject);
begin

  if Screen.Fonts.IndexOf('Tahoma') = -1 then begin
    //No Tahoma
    HWSettings.GroupBox1.Font.Name := 'MS Sans Serif';
    HWSettings.Label1.Font.Name := 'MS Sans Serif';
    HWSettings.Label2.Font.Name := 'MS Sans Serif';
    HWSettings.Standard.Font.Name := 'MS Sans Serif';
    HWSettings.Legacy.Font.Name := 'MS Sans Serif';
    HWSettings.VerboseMode.Font.Name := 'MS Sans Serif';
    HWSettings.LegacyCMOS.Font.Name := 'MS Sans Serif';
    HWSettings.Button1.Font.Name := 'MS Sans Serif';
  end;

end;

end.
