unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TFrmPrincipal = class(TForm)
    memo: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    btnliga: TSwitch;
    Image1: TImage;
    LBname: TLabel;
    verde: TBrushObject;
    Circle1: TCircle;
    procedure FormShow(Sender: TObject);
    procedure btnLigaClick(Sender: TObject);
    procedure IniciaServidor;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses Horse,
     Horse.Jhonson,
     Horse.CORS,
     Horse.Upload,
     Horse.BasicAuthentication,
     Horse.OctetStream,
     IdSSLOpenSSL,
     uMD5,
     Controllers.CEP, DataModule.Global;


procedure TFrmPrincipal.btnLigaClick(Sender: TObject);
begin

    if btnLiga.IsChecked then
    begin
     try
       IniciaServidor;
       Circle1.Visible := true;
     except  on E: Exception do
       memo.Lines.Add('Servidor N�o inciado.');
     end;
    end else
    begin
      THorse.StopListen;
      Circle1.Visible := false;
      memo.Lines.Add('Servidor Parado.');
    end;
end;


procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
    THorse.Use(Jhonson());
    THorse.Use(CORS);
    THorse.Use(OctetStream);
    THorse.Use(Upload);

   { THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
        Result := AUsername.Equals('zanelato') and APassword.Equals('123456');
    end));    }

end;

procedure TFrmPrincipal.IniciaServidor;
begin
   // Registrar as rotas...
    Controllers.cep.RegistrarRotas;
    THorse.Listen(9000);
    memo.Lines.Add('Servidor executando na porta: ' + THorse.Port.ToString);
end;

end.
