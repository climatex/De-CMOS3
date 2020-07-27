program DeCMOS3;

uses
  Forms,
  MainFormUnit   in 'MainFormUnit.pas'    {MainForm},
  HWSettingsUnit in 'HWSettingsUnit.pas'  {HWSettings},
  HelpFormUnit   in 'HelpFormUnit.pas'    {HelpForm},
  BiosFormUnit   in 'BiosFormUnit.pas'    {BiosForm},
  Page1FrameUnit in 'Page1FrameUnit.pas'  {Page1Frame: TFrame},
  Page2FrameUnit in 'Page2FrameUnit.pas'  {Page2Frame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'CMOS De-Animator v3';
  Application.ShowMainForm := False;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(THWSettings, HWSettings);
  Application.CreateForm(THelpForm, HelpForm);
  Application.CreateForm(TBiosForm, BiosForm);
  Application.Run;
end.
