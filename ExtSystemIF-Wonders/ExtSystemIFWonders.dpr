program ExtSystemIFWonders;

uses
  Forms,
  UfrmMain in 'UfrmMain.pas' {frmMain},
  superobject in 'superobject.pas',
  UfrmRequestInfo in 'UfrmRequestInfo.pas' {frmRequestInfo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
