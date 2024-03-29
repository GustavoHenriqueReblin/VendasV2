unit uVendas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids,
  RpRave, RpBase, RpSystem, RpDefine, RpCon, RpConDS, RpRender, RpRenderPDF,
  Winapi.ShellAPI, Data.FMTBcd, Data.DB, Data.SqlExpr, Datasnap.DBClient,
  Datasnap.Provider;

type
  TfrmVendas = class(TForm)
    edtBuscar: TEdit;
    btnNova: TButton;
    btnImprimir: TButton;
    btnSair: TButton;
    Label2: TLabel;
    cbOrdenarPor: TComboBox;
    Label1: TLabel;
    DBGridVendas: TDBGrid;
    DBGridItens: TDBGrid;
    dSetVendas: TSQLDataSet;
    dspVendas: TDataSetProvider;
    cdsVendas: TClientDataSet;
    cdsVendasid: TIntegerField;
    cdsVendasfk_cliente: TIntegerField;
    cdsVendastotal: TFMTBCDField;
    cdsVendasdata: TStringField;
    dSourceVendas: TDataSource;
    dSourceItens: TDataSource;
    cdsItens: TClientDataSet;
    cdsItensid: TIntegerField;
    cdsItensfk_venda: TIntegerField;
    cdsItensfk_produto: TIntegerField;
    cdsItensnome: TStringField;
    cdsItenspreco: TFMTBCDField;
    cdsItensdescricao: TStringField;
    cdsItensquantidade: TIntegerField;
    dspItens: TDataSetProvider;
    dSetItens: TSQLDataSet;
    cdsVendasnome: TStringField;
    procedure edtBuscarChange(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure cbOrdenarPorSelect(Sender: TObject);
    procedure btnNovaClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVendas: TfrmVendas;

implementation

{$R *.dfm}

uses uCadastrarCliente, uCadastrarProduto, uClientes, uDataModule, uFiltroCli,
  uFunctions, uPrincipal, uProdutos, uVendaReport, uCadastrarVenda;

procedure TfrmVendas.btnImprimirClick(Sender: TObject);
var
  arquivo_pdf: string;
  id: Integer;
begin
  id := frmVendas.cdsVendasid.AsInteger;

  if frmVendaReport = nil then
    Application.CreateForm(TfrmVendaReport, frmVendaReport);

  if frmClientes = nil then
    Application.CreateForm(TfrmClientes, frmClientes);

  frmVendaReport.RvVendas.DataSet := cdsVendas;
  frmVendaReport.RvItens.DataSet := cdsItens;

  cdsVendas.Filtered := false;
  cdsVendas.FilterOptions := [foCaseInsensitive];
  cdsVendas.Filter := 'id = ' + IntToStr(id);
  cdsVendas.Filtered := True;

  frmVendaReport.rvsVendas.DefaultDest := rdFile;
  frmVendaReport.rvsVendas.DoNativeOutput := false;
  frmVendaReport.rvsVendas.RenderObject := frmVendaReport.rvRelVendasPDF;
  arquivo_pdf := ExtractFilePath(Application.ExeName) +
    'RELATORIO VENDA UNICA.pdf';
  frmVendaReport.rvsVendas.OutputFileName := arquivo_pdf;
  frmVendaReport.RvProject1.SetParam('titulo', 'Relatório da venda');
  frmVendaReport.RvProject1.Execute;
  ShellExecute(0, nil, Pchar(arquivo_pdf), nil,
    Pchar(ExtractFilePath(Application.ExeName) + 'docs\relatorios\'),
    SW_NORMAL);

  frmVendas.cdsVendas.Filtered := false;
  FreeAndNil(frmVendaReport);
  FreeAndNil(frmClientes);
end;

procedure TfrmVendas.btnNovaClick(Sender: TObject);
begin
  Application.CreateForm(TfrmCadastrarVenda, frmCadastrarVenda);
  try
    frmCadastrarVenda.ShowModal;
  finally
    FreeAndNil(frmCadastrarVenda);
  end;
end;

procedure TfrmVendas.btnSairClick(Sender: TObject);
begin
  frmVendas.Close;
end;

procedure TfrmVendas.cbOrdenarPorSelect(Sender: TObject);
begin
  verificarOrdenacaoVenda;
end;

procedure TfrmVendas.edtBuscarChange(Sender: TObject);
begin
  threadBuscarVenda;
  Sleep(60);
end;

procedure TfrmVendas.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  cdsVendas.Close;
  dSetVendas.Close;
  cdsItens.Close;
  dSetItens.Close;
end;

procedure TfrmVendas.FormShow(Sender: TObject);
begin
  cdsVendas.Open;
  dSetVendas.Open;
  cdsItens.Open;
  dSetItens.Open;
end;

end.
