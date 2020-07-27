unit Page2FrameUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, ExtCtrls, ShellApi;

type
  TPage2Frame = class(TFrame)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    dcb: TDriveComboBox;
    Label10: TLabel;
    cb: TComboBox;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    procedure Label13Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}


procedure TPage2Frame.Label13Click(Sender: TObject);
begin

  ShellExecute(0, 'open', 'diskmgmt.msc', nil, nil, SW_SHOWNORMAL);

end;

end.
