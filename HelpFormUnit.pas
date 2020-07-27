unit HelpFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellApi;

type
  THelpForm = class(TForm)
    Image1: TImage;
    Label2: TLabel;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label8: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Label13Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HelpForm: THelpForm;

implementation

uses HWSettingsUnit, MainFormUnit;

{$R *.dfm}

procedure THelpForm.FormCreate(Sender: TObject);
begin

  if Screen.Fonts.IndexOf('Tahoma') = -1 then begin
    HelpForm.Label1.Font.Name := 'MS Sans Serif';
    HelpForm.Label3.Font.Name := 'MS Sans Serif';
    HelpForm.Label4.Font.Name := 'MS Sans Serif';
    HelpForm.Label5.Font.Name := 'MS Sans Serif';
    HelpForm.Label9.Font.Name := 'MS Sans Serif';
    HelpForm.Label10.Font.Name := 'MS Sans Serif';
    HelpForm.Label12.Font.Name := 'MS Sans Serif';
    HelpForm.Label8.Font.Name := 'MS Sans Serif';
    HelpForm.Label13.Font.Name := 'MS Sans Serif';
    HelpForm.Label14.Font.Name := 'MS Sans Serif';
    HelpForm.Label6.Font.Name := 'MS Sans Serif';
    HelpForm.Label11.Font.Name := 'MS Sans Serif';
    HelpForm.Label7.Font.Name := 'MS Sans Serif';
    HelpForm.Label15.Font.Name := 'MS Sans Serif';
  end;

end;

procedure THelpForm.Label13Click(Sender: TObject);
begin

  case CrappyOldOS of
    0: ShellExecute(Handle, 'open', 'http://boginjr.com/it/sw/dev/de-cmos3/', nil, nil, SW_SHOWNORMAL);
    1: WinExec('explorer.exe http://boginjr.com/it/sw/dev/de-cmos3/', SW_SHOW);
    2: ShowMessage('Is your machine really Internet-ready ? :)');
  end;

end;

end.
