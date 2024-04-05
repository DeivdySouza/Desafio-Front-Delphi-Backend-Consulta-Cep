program ViaCEP;
uses
  Vcl.Forms,
  UPrincipal in 'UPrincipal.pas' {FrmPrincipal},
  Module.Dbfire in 'Module\Module.Dbfire.pas' {DataModule1: TDataModule},
  Controller.CepV in 'Controller\Controller.CepV.pas';

{$R *.res}
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.
