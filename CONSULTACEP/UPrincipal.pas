unit UPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.Graphics, System.Types, System.UITypes, System.Classes, System.Variants,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.JSON, System.Threading, Controller.cepv,
  Vcl.ExtCtrls, Vcl.Mask, Vcl.Imaging.pngimage, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Imaging.jpeg;

type
  TRetornoCEPArray = array of TRetornoCEP;
  TFrmPrincipal = class(TForm)
    imgLogoViaCEP: TImage;
    pnlTop: TPanel;
    btnConsultar: TButton;
    memResultado: TMemo;
    edCEP: TLabeledEdit;
    tmrConsultaAutomatica: TTimer;
    procedure btnConsultarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrConsultaAutomaticaTimer(Sender: TObject);
  private
    FResultadosCache: TRetornoCEPArray;
    procedure ExibirDados(const RetornoCEP: TRetornoCEP);
    procedure ExibirErro(const ErrorMessage: string);
    function SomenteNumeros(const pValor: string): string;
    procedure ConsultarFaixaDeCEPs(const FaixaInicial, FaixaFinal: string);
    procedure AgendarConsultaAutomatica;
    procedure ExecutarConsultaAutomatica;
    procedure ApagarCEPsAntigosDoCache;
    function GetCep(const CEP: string): Boolean;
    procedure InsertCep(const CEP: string; const UF, Cidade, Bairro, Logradouro: string);
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  Module.Dbfire;

{$R *.dfm}

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  tmrConsultaAutomatica.Interval := 60000; // 1 minuto
  AgendarConsultaAutomatica;
end;

procedure TFrmPrincipal.btnConsultarClick(Sender: TObject);
var
  lCEP: string;

begin
  lCEP := SomenteNumeros(edCEP.Text);

  if Length(lCEP) <> 9 then
  begin
    ShowMessage('CEP inv�lido.');
    Exit;
  end;



    if GetCEP(lCEP) then
    begin
      ShowMessage('CEP encontrado no banco de dados.');
      Exit;
    end;


  TTask.Run(
    procedure
    var
      ConsultaCEP: TConsultaCEP;
      RetornoCEP: TRetornoCEP;
    begin
      try
        ConsultaCEP := TConsultaCEP.Create(lCEP);
        try
          RetornoCEP := ConsultaCEP.Consultar;
          TThread.Queue(nil,
            procedure
            begin
              ExibirDados(RetornoCEP);

              InsertCEP(RetornoCEP.CEP, RetornoCEP.UF, RetornoCEP.Cidade, RetornoCEP.Bairro, RetornoCEP.Logradouro);
            end);
        finally
          ConsultaCEP.Free;
        end;
      except
        on E: Exception do
        begin

              ExibirErro('Este CEP n�o existe na Base de Dados. ');

        end;
      end;
    end);
end;

procedure TFrmPrincipal.ExibirDados(const RetornoCEP: TRetornoCEP);
begin
  memResultado.Lines.Add('-------------------------------');
  memResultado.Lines.Add('CEP: ' + RetornoCEP.CEP);
  memResultado.Lines.Add('UF: ' + RetornoCEP.UF);
  memResultado.Lines.Add('Bairro: ' + RetornoCEP.Bairro);
  memResultado.Lines.Add('Cidade: ' + RetornoCEP.Cidade);
  memResultado.Lines.Add('Logradouro: ' + RetornoCEP.Logradouro);
  memResultado.Lines.Add('-------------------------------');
end;

procedure TFrmPrincipal.ExibirErro(const ErrorMessage: string);
begin
  ShowMessage(ErrorMessage);
end;

function TFrmPrincipal.SomenteNumeros(const pValor: string): string;
var
  lI: Integer;
begin
  Result := '';

  for lI := 1 to Length(pValor) do
  begin
    if (pValor[lI] in ['0'..'9']) or (pValor[lI] = '-') then
      Result := Result + pValor[lI];
  end;
end;

procedure TFrmPrincipal.ConsultarFaixaDeCEPs(const FaixaInicial, FaixaFinal: string);
var
  CEPInicial, CEPFinal: Integer;
  CEPAtual: Integer;
  CEP: string;
  ConsultaCEP: TConsultaCEP;
  RetornoCEP: TRetornoCEP;
  ResultadosCache: TRetornoCEPArray;
begin
  try

    CEPInicial := StrToInt(FaixaInicial.Replace('-', ''));
    CEPFinal := StrToInt(FaixaFinal.Replace('-', ''));


    SetLength(ResultadosCache, 0);


    for CEPAtual := CEPInicial to CEPFinal do
    begin

      CEP := Format('%5s-%3s', [Copy(IntToStr(CEPAtual), 1, 5), Copy(IntToStr(CEPAtual), 6, 3)]);


      try
        ConsultaCEP := TConsultaCEP.Create(CEP);
        try
          RetornoCEP := ConsultaCEP.Consultar;


          SetLength(ResultadosCache, Length(ResultadosCache) + 1);
          ResultadosCache[High(ResultadosCache)] := RetornoCEP;
          TThread.Queue(nil,
            procedure
            begin
              ExibirDados(RetornoCEP);
            end);
        finally
          ConsultaCEP.Free;
        end;
      except
        on E: Exception do
        begin
         memResultado.Lines.Add('Erro ao consultar CEP ' + CEP + ': ' + E.Message);
        end;
      end;
    end;

    memResultado.Lines.Add('Consulta de faixa de CEPs conclu�da.');
  except
    on E: Exception do
    begin
      memResultado.Lines.Add('Erro ao consultar CEP ' + CEP + ': ' + E.Message);
    end;
  end;
end;

procedure TFrmPrincipal.ApagarCEPsAntigosDoCache;
var
  I: Integer;
begin

  if Length(FResultadosCache) > 100 then
  begin

    for I := 0 to Length(FResultadosCache) - 101 do
    begin
      FResultadosCache[I] := nil;
    end;

    SetLength(FResultadosCache, 100);
  end;
end;

procedure TFrmPrincipal.AgendarConsultaAutomatica;
begin
  tmrConsultaAutomatica.Enabled := True;
end;

procedure TFrmPrincipal.ExecutarConsultaAutomatica;
var
  FaixaInicial, FaixaFinal: string;
begin
  FaixaInicial := '88000-000';
  FaixaFinal := '88000-002';

  ConsultarFaixaDeCEPs(FaixaInicial, FaixaFinal);
end;

procedure TFrmPrincipal.tmrConsultaAutomaticaTimer(Sender: TObject);
begin
  tmrConsultaAutomatica.Enabled := False;
  try
    ExecutarConsultaAutomatica;
    ApagarCEPsAntigosDoCache;
  finally
    tmrConsultaAutomatica.Enabled := True;
  end;
end;
function TFrmPrincipal.GetCep(const CEP: string): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := DataModule1.Conn;
    Query.SQL.Text := 'SELECT * FROM CEPs WHERE cep = :cep';
    Query.ParamByName('cep').AsString := CEP;
    Query.Open;
    Result := not Query.IsEmpty;
  finally
    Query.Free;
  end;
end;

procedure TFrmPrincipal.InsertCep(const CEP: string; const UF, Cidade, Bairro, Logradouro: string);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := DataModule1.Conn;
    Query.SQL.Text := 'INSERT INTO CEPs (cep, uf, cidade, bairro, logradouro) VALUES (:cep, :uf, :cidade, :bairro, :logradouro)';
    Query.ParamByName('cep').AsString := CEP;
    Query.ParamByName('uf').AsString := UF;
    Query.ParamByName('cidade').AsString := Cidade;
    Query.ParamByName('bairro').AsString := Bairro;
    Query.ParamByName('logradouro').AsString := Logradouro;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;
end.
