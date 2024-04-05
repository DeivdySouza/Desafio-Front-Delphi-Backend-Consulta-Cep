unit DataModule.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, FireDAC.Phys.IBBase, Data.DB,
  FireDAC.Comp.Client, System.IniFiles, FireDAC.DApt, System.JSON,
  DataSet.Serialize, DataSet.Serialize.Config, uMD5, FMX.Graphics,
  SYstem.Variants, FireDAC.Phys.OracleDef, FireDAC.Phys.Oracle,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef, DBAccess, Uni, MemDS, UniProvider,
  PostgreSQLUniProvider,ufunctions,System.NetEncoding;

type
  TDmGlobal = class(TDataModule)
    Conn: TFDConnection;
    FDStoredProc1: TFDStoredProc;
    FDTransaction1: TFDTransaction;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    procedure DataModuleCreate(Sender: TObject);

  private

    { Private declarations }
  public

  end;

var
  DmGlobal: TDmGlobal;


implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmGlobal.DataModuleCreate(Sender: TObject);
begin
  //  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
  //  TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';

   Conn.Connected := true;
end;

end.
