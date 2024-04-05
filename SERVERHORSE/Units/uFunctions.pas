unit uFunctions;

interface

uses SysUtils, FMX.TextLayout, FMX.ListView.Types, System.Types, FMX.Graphics,
     System.Classes, Soap.EncdDecd, Data.DB, System.NetEncoding;

type
    TFunctions = class
    private

    public
        class procedure LoadBitmapFromBlob(Bitmap: TBitmap; Blob: TBlobField);
        class function BitmapFromBase64(const base64: string): TBitmap;
        class function Base64FromBitmap(Bitmap: TBitmap): string;
        class function Base64FromFile(FileName: string): string;
        class function GerarNomeArq(extensao: string): string;
end;


implementation

// Converte uma string base64 em um Bitmap...
class function TFunctions.BitmapFromBase64(const base64: string): TBitmap;
var
        Input: TStringStream;
        Output: TBytesStream;
begin
        Input := TStringStream.Create(base64, TEncoding.ASCII);
        try
                Output := TBytesStream.Create;
                try
                        Soap.EncdDecd.DecodeStream(Input, Output);
                        Output.Position := 0;
                        Result := TBitmap.Create;
                        try
                                Result.LoadFromStream(Output);
                        except
                                Result.Free;
                                raise;
                        end;
                finally
                        Output.Free;
                end;
        finally
                Input.Free;
        end;
end;

// Converte um Bitmap em uma string no formato base64...
class function TFunctions.Base64FromBitmap(Bitmap: TBitmap): string;
var
  Input: TBytesStream;
  Output: TStringStream;
begin
        Input := TBytesStream.Create;
        try
                Bitmap.SaveToStream(Input);
                Input.Position := 0;
                Output := TStringStream.Create('', TEncoding.ASCII);

                try
                        Soap.EncdDecd.EncodeStream(Input, Output);
                        Result := Output.DataString;
                finally
                        Output.Free;
                end;

        finally
                Input.Free;
        end;
end;

class procedure TFunctions.LoadBitmapFromBlob(Bitmap: TBitmap; Blob: TBlobField);
var
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  try
    Blob.SaveToStream(ms);
    ms.Position := 0;
    Bitmap.LoadFromStream(ms);
  finally
    ms.Free;
  end;
end;

// Le um arquivo e retorna base 64...
class function TFunctions.Base64FromFile(FileName: string): string;
var
  inStream: TStream;
  outStream: TStringStream;
begin
    inStream := TFileStream.Create(FileName, fmOpenRead);

    try
        outStream := TStringStream.Create('', TEncoding.UTF8);

        try
            TNetEncoding.Base64.Encode(inStream, outStream);
            Result := outStream.DataString;
        finally
            outStream.Free;
        end;
  finally
    inStream.Free;
  end;
end;

// Gera um código de 15 caracteres...
class function TFunctions.GerarNomeArq(extensao: string): string;
begin
    Result := FormatDateTime('yymmddhhnnsszzz', Now) + '.' + extensao;
end;


end.
