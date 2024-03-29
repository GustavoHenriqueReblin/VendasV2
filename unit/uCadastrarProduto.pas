unit uCadastrarProduto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls;

type
  TfrmCadastrarProduto = class(TForm)
    Label1: TLabel;
    dbEdtNome: TDBEdit;
    Label2: TLabel;
    Label3: TLabel;
    dbEdtDescricao: TDBEdit;
    Label4: TLabel;
    dbEdtEstoque: TDBEdit;
    btnCadastrar: TButton;
    btnCancelar: TButton;
    dbEdtPreco: TDBEdit;
    procedure FormShow(Sender: TObject);
    procedure btnCadastrarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCadastrarProduto: TfrmCadastrarProduto;

implementation

{$R *.dfm}

uses uCadastrarCliente, uClientes, uDataModule, uFiltroCli, uFunctions,
  uPrincipal, uProdutos;

procedure TfrmCadastrarProduto.btnCadastrarClick(Sender: TObject);
begin
  removeFormatacaoPrecoProduto;
  if (dbEdtNome.Text = '') OR (Length(dbEdtNome.Text) < 5) OR
    (Length(dbEdtNome.Text) > 30) then
  begin
    ShowMessage('Nome inv�lido! ');
    dbEdtNome.SetFocus;
  end
  else if (dbEdtPreco.Text = '') OR (StrToFloat(dbEdtPreco.Text) < 0) OR
    (Length(dbEdtPreco.Text) < 0) OR (Length(dbEdtPreco.Text) > 10) then
  begin
    ShowMessage('Pre�o inv�lido! ');
    dbEdtPreco.SetFocus;
  end
  else if (dbEdtDescricao.Text = '') OR (Length(dbEdtDescricao.Text) < 5) OR
    (Length(dbEdtDescricao.Text) > 50) then
  begin
    ShowMessage('Descri��o inv�lida! ');
    dbEdtDescricao.SetFocus;
  end
  else if (dbEdtEstoque.Text = '') OR (StrToInt(dbEdtEstoque.Text) < 0) OR
    (Length(dbEdtEstoque.Text) < 0) OR (Length(dbEdtEstoque.Text) > 6) then
  begin
    ShowMessage('Quantidade inv�lida! ');
    dbEdtEstoque.SetFocus;
  end
  else
  begin
    if frmProdutos.Tag = 1 then
    begin
      dm.cdsProdutosid.Text := '0';

      try
        dm.cdsprodutospreco.asstring := dbEdtPreco.Text;
        dm.cdsProdutos.Post;
        dm.cdsProdutos.ApplyUpdates(0);
        Tag := 1;
        ShowMessage('Sucesso ao cadastrar o produto! ');
        frmCadastrarProduto.Close;

      except
        on E: Exception do
          ShowMessage('Erro ao cadastrar o produto! ' + E.ToString);
      end;
    end
    else if frmProdutos.Tag = 2 then
    begin
      try
        dm.cdsProdutos.Post;
        dm.cdsProdutos.ApplyUpdates(0);
        Tag := 2;
        ShowMessage('Sucesso ao editar o produto! ');
        frmCadastrarProduto.Close;
      except
        on E: Exception do
          ShowMessage('Erro ao editar o produto! ' + E.ToString);
      end;
    end;
  end;
end;

procedure TfrmCadastrarProduto.btnCancelarClick(Sender: TObject);
begin
  frmCadastrarProduto.Close;
end;

procedure TfrmCadastrarProduto.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (Tag <> 1) AND (Tag <> 2) then // close pelo usu�rio;
  begin
    if Application.MessageBox('Deseja realmente sair?', 'Aten��o',
      MB_YESNO + MB_ICONQUESTION) <> mrYes then
      Abort;
  end;
  frmProdutos.edtBuscar.Text := '';
  frmProdutos.cbOrdenarPor.ItemIndex := 1;
  abrirDados('produto', false);
  abrirDados('produto', true);
  dm.cdsProdutos.Filtered := false;
end;

procedure TfrmCadastrarProduto.FormShow(Sender: TObject);
begin
  if frmProdutos.Tag = 1 then // Tag = 1 -> cadastrar
  begin
    dm.cdsProdutos.Edit;
    dm.cdsProdutos.ClearFields;
  end
  else if frmProdutos.Tag = 2 then // Tag = 2 -> editar
  begin
    dm.cdsProdutos.Edit;
    btnCadastrar.Caption := 'Editar';
  end;
end;

end.
