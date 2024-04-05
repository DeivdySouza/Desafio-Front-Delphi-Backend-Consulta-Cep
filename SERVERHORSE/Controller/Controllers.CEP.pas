unit Controllers.CEP;

interface
uses Horse,
     Horse.Jhonson,
     Horse.CORS,
     Horse.Upload,
     System.SysUtils,
     DataModule.Global,
     System.JSON,
     Controllers.Auth,
     Horse.JWT,
     System.Classes,
     ufunctions,
     System.Types,
     System.UITypes,
     System.Variants,
      FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
      FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
      FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
      FireDAC.Comp.Client;

procedure RegistrarRotas;
procedure buscacep(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation
procedure RegistrarRotas;
begin
     tHorse.Get('/cep/:cep',buscacep)
end;
procedure buscacep(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    CEP: string;
    CepData: TJSONObject;
    fbQuery: TFDQuery;
  begin
    CEP := Req.Params['cep'];

    fbQuery := TFDQuery.Create(nil);
    DmGlobal := TDmGlobal.Create(Nil);
    fbQuery.Connection :=  DmGlobal.Conn;


    fbQuery.Close;
    fbQuery.SQL.Text := 'SELECT * FROM Ceps WHERE cep = :cep';
    fbQuery.ParamByName('cep').AsString := CEP;
    fbQuery.Open;

    if not fbQuery.IsEmpty then
    begin
      CepData := TJSONObject.Create;
      CepData.AddPair('cep', fbQuery.FieldByName('cep').AsString);
      CepData.AddPair('uf', fbQuery.FieldByName('uf').AsString);
      CepData.AddPair('bairro', fbQuery.FieldByName('bairro').AsString);
      CepData.AddPair('cidade', fbQuery.FieldByName('cidade').AsString);
      CepData.AddPair('logradouro', fbQuery.FieldByName('logradouro').AsString);

      Res.Send(CepData);
    end
    else
    begin
      Res.Send('Cep não Encontrado').Status(404);
    end;
     FreeAndNil(fbQuery) ;
     FreeAndNil(DmGlobal) ;
  end;
end.
