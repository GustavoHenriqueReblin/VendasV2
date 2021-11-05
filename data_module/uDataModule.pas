unit uDataModule;

interface

uses
  System.SysUtils, System.Classes, Data.DBXMySQL, Data.DB, Data.SqlExpr,
  Data.FMTBcd, Datasnap.DBClient, Datasnap.Provider;

type
  Tdm = class(TDataModule)
    SQLConn: TSQLConnection;
    cdsClientes: TClientDataSet;
    dSetClientes: TSQLDataSet;
    dspClientes: TDataSetProvider;
    dSourceClientes: TDataSource;
    dSetProdutos: TSQLDataSet;
    dspProdutos: TDataSetProvider;
    dSourceProdutos: TDataSource;
    cdsCidades: TClientDataSet;
    dSetCidades: TSQLDataSet;
    dspCidades: TDataSetProvider;
    dSourceCidades: TDataSource;
    cdsEstados: TClientDataSet;
    dSetEstados: TSQLDataSet;
    dspEstados: TDataSetProvider;
    dSourceEstados: TDataSource;
    cdsCidadesid: TIntegerField;
    cdsCidadesnome: TStringField;
    cdsCidadesfk_estado: TIntegerField;
    cdsEstadosid: TIntegerField;
    cdsEstadosnome: TStringField;
    cdsEstadosuf: TStringField;
    cdsVendas: TClientDataSet;
    dSetVendas: TSQLDataSet;
    dspVendas: TDataSetProvider;
    dSourceVendas: TDataSource;
    dSetItens: TSQLDataSet;
    dpsItens: TDataSetProvider;
    dSourceItens: TDataSource;
    cdsVendasid: TIntegerField;
    cdsVendasfk_cliente: TIntegerField;
    cdsVendastotal: TFMTBCDField;
    cdsVendasdata: TStringField;
    cdsProdutos: TClientDataSet;
    cdsVendasCliente: TStringField;
    cdsItens: TClientDataSet;
    cdsProdutosid: TIntegerField;
    cdsProdutosnome: TStringField;
    cdsProdutospreco: TFMTBCDField;
    cdsProdutosdescricao: TStringField;
    cdsProdutosquantidade_estoque: TIntegerField;
    cdsItensid: TIntegerField;
    cdsItensfk_venda: TIntegerField;
    cdsItensfk_produto: TIntegerField;
    cdsItensnome: TStringField;
    cdsItenspreco: TFMTBCDField;
    cdsItensdescricao: TStringField;
    cdsItensquantidade: TIntegerField;
    cdsItensacrescimo: TIntegerField;
    cdsItensdesconto: TIntegerField;
    cdsItensvalor_total: TFloatField;
    cdsClientesid: TIntegerField;
    cdsClientesfk_cidade: TIntegerField;
    cdsClientesnome: TStringField;
    cdsClientescpf: TStringField;
    cdsClientestelefone: TStringField;
    cdsClientesemail: TStringField;
    cdsClientesdata_nascimento: TStringField;
    cdsClientesrua: TStringField;
    cdsClientesbairro: TStringField;
    queryEnderecoCliente: TSQLQuery;
    cdsCidadesuf: TStringField;
    cdsClientesnome_1: TStringField;
    cdsClientesfk_estado: TIntegerField;
    cdsClientesid_2: TIntegerField;
    cdsClientesuf: TStringField;
    cdsClientesnome_2: TStringField;
    cdsClientesid_1: TIntegerField;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dm: Tdm;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

end.
