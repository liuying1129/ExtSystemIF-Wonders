program ExtSystemIFWondersReport;

uses
  Forms,
  UfrmMain in 'UfrmMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.ShowMainForm:=false;
  Application.Run;
end.
