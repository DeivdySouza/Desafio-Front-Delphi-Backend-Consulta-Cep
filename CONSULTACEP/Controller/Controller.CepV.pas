unit Controller.CepV;
interface

uses
  System.SysUtils, System.Classes, System.JSON, IdHTTP, IdException, IdTCPConnection, IdTCPClient;

type
  TRetornoCEP = class
  private
    FCEP: string;
    FUF: string;
    FBairro: string;
    FCidade: string;
    FLogradouro: string;
  public
    property CEP: string read FCEP write FCEP;
    property UF: string read FUF write FUF;
    property Bairro: string read FBairro write FBairro;
    property Cidade: string read FCidade write FCidade;
    property Logradouro: string read FLogradouro write FLogradouro;
  end;

  TConsultaCEP = class
  private
    FCEP: string;
    FHTTPClient: TIdHTTP;
    function GetJSONResponse(const URL: string): TJSONObject;
  public
    constructor Create(const CEP: string);
    destructor Destroy; override;
    function Consultar: TRetornoCEP;
  end;

implementation

{ TConsultaCEP }

constructor TConsultaCEP.Create(const CEP: string);
begin
  FCEP := CEP;
  FHTTPClient := TIdHTTP.Create(nil);

  FHTTPClient.ReadTimeout := 5000;
end;

destructor TConsultaCEP.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TConsultaCEP.GetJSONResponse(const URL: string): TJSONObject;
var
  ResponseContent: TStringStream;
begin
  ResponseContent := TStringStream.Create('', TEncoding.UTF8);
  try
    try
      FHTTPClient.Get(URL, ResponseContent);
      ResponseContent.Position := 0;
      Result := TJSONObject.ParseJSONValue(ResponseContent.DataString) as TJSONObject;
    except
      on E: EIdHTTPProtocolException do
        raise Exception.Create('Erro na requisição HTTP: ' + E.Message);
      on E: EIdConnClosedGracefully do
        raise Exception.Create('Conexão encerrada pelo servidor: ' + E.Message);
      on E: EIdException do
        raise Exception.Create('Erro de conexão: ' + E.Message);
      on E: Exception do
        raise Exception.Create('Erro ao consultar o CEP: ' + E.Message);
    end;
  finally
    ResponseContent.Free;
  end;
end;

function TConsultaCEP.Consultar: TRetornoCEP;
const
  BaseURL = 'http://localhost:9000/cep/';
var
  URL: string;
  JSONData: TJSONObject;
begin
  URL := BaseURL + FCEP;
  JSONData := GetJSONResponse(URL);

  Result := TRetornoCEP.Create;
  try
    Result.CEP := JSONData.GetValue('cep').Value;
    Result.UF := JSONData.GetValue('uf').Value;
    Result.Bairro := JSONData.GetValue('bairro').Value;
    Result.Cidade := JSONData.GetValue('cidade').Value;
    Result.Logradouro := JSONData.GetValue('logradouro').Value;
  except
    Result.Free;
    raise;
  end;
end;

end.
