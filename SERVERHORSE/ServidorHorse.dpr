program ServidorHorse;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  DataModule.Global in 'DataModule\DataModule.Global.pas' {DmGlobal: TDataModule},
  uMD5 in 'Units\uMD5.pas',
  uFunctions in 'Units\uFunctions.pas',
  Controllers.CEP in 'Controller\Controllers.CEP.pas';

{$R *.res}

begin
  //ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
