unit uFunctions;

interface

procedure threadBuscarCliente(busca: string);
procedure buscarCliente(orderBy: string);
procedure verificarOrdenacaoCliente;
procedure threadBuscarProduto(busca: string);
procedure buscarProduto(orderBy: string);
procedure verificarOrdenacaoProduto;
procedure threadBuscarVenda;
procedure buscarVenda(orderBy: string);
procedure verificarOrdenacaoVenda;
procedure buscarCidade;
procedure fechaBuscaCidade;
procedure abreBuscaCidade;
procedure buscarEnderecoCliente;
procedure abrirDados(tabela: string; estado: Boolean);
procedure calculaSubTotalItem;
procedure calculaAcrescimoItem;
procedure calculaDescontoItem;
procedure calculaTotalItem;
procedure calculaSubTotalVenda;
procedure calculaTotalVenda;
procedure removeFormatacaoPrecoProduto;

var
  subTotalDaVenda, totalDaVenda, frete, totalDoItem, valDescontoItem,
    valAcrescimoItem, valUnitario, subTotalDoItem, desconto, acrescimo,
    descontoDoItem, acrescimoDoItem: Double;
  quantidadeDeProdutos: Integer;

implementation

uses
  System.Classes, System.SysUtils,
  uCadastrarCliente, uClientes, uDataModule, uFiltroCli, uPrincipal, uProdutos,
  uCadastrarProduto, uVendas, uCadastrarVenda, uVendaReport, uAdicionarItem, db;

procedure buscarCliente(orderBy: string);
begin
  abrirDados('cliente', false);
  dm.cdsClientes.IndexFieldNames := orderBy;
  abrirDados('cliente', true);
end;

procedure threadBuscarCliente(busca: string);
var
  t: TThread;
begin
  t := TThread.CreateAnonymousThread(
    procedure
    begin
      dm.cdsClientes.Filtered := false;
      dm.cdsClientes.FilterOptions := [foCaseInsensitive];
      dm.cdsClientes.Filter := 'nome LIKE ' + QuotedStr('%' + busca + '%');
      dm.cdsClientes.Filtered := true;

      TThread.Synchronize(nil,
        procedure
        begin
          frmClientes.dbgrid.DataSource := dm.dSourceClientes;
        end);
    end);
  t.FreeOnTerminate := true;
  t.Start;
end;

procedure verificarOrdenacaoCliente;
begin
  case frmClientes.cbOrdenarPor.ItemIndex of
    0:
      buscarCliente('id');
    1:
      buscarCliente('nome');
    2:
      buscarCliente('telefone');
    3:
      buscarCliente('email');
    4:
      buscarCliente('data_nascimento');
  end;
end;

procedure buscarProduto(orderBy: string);
begin
  dm.SQLConn.Close;
  dm.SQLConn.Open;
  abrirDados('produto', false);
  dm.cdsProdutos.IndexFieldNames := orderBy;
  abrirDados('produto', true);
end;

procedure threadBuscarProduto(busca: string);
var
  t: TThread;
begin
  t := TThread.CreateAnonymousThread(
    procedure
    begin
      dm.cdsProdutos.Filtered := false;
      dm.cdsProdutos.FilterOptions := [foCaseInsensitive];
      dm.cdsProdutos.Filter := 'nome LIKE ' + QuotedStr(busca + '%');
      dm.cdsProdutos.Filtered := true;

      TThread.Synchronize(nil,
        procedure
        begin
          frmProdutos.dbgrid.DataSource := dm.dSourceProdutos;
          frmAdicionarItem.dbgrid.DataSource := dm.dSourceProdutos;
        end);
    end);
  t.FreeOnTerminate := true;
  t.Start;
end;

procedure verificarOrdenacaoProduto;
begin
  case frmProdutos.cbOrdenarPor.ItemIndex of
    0:
      buscarProduto('id');
    1:
      buscarProduto('nome');
    2:
      buscarProduto('preco');
    3:
      buscarProduto('descricao');
    4:
      buscarProduto('quantidade_estoque');
  end;
end;

procedure buscarVenda(orderBy: string);
begin
  dm.SQLConn.Close;
  dm.SQLConn.Open;
  frmVendas.cdsVendas.Close;
  frmVendas.dSetVendas.Close;
  if orderBy = 'fk_cliente' then
  begin
    frmVendas.cdsVendas.CommandText :=
      'SELECT * FROM venda v JOIN cliente c ON ' +
      'c.id = v.fk_cliente ORDER BY c.nome ASC';
  end
  else
  begin
    frmVendas.cdsVendas.CommandText := 'SELECT * FROM venda ORDER BY '
      + orderBy;
  end;
  frmVendas.cdsVendas.Open;
  frmVendas.dSetVendas.Open;
end;

procedure threadBuscarVenda;
var
  t: TThread;
begin
  t := TThread.CreateAnonymousThread(
    procedure
    begin
      frmVendas.cdsVendas.Close;
      frmVendas.dSetVendas.Close;
      frmVendas.cdsVendas.CommandText := 'SELECT * FROM venda v JOIN cliente c '
        + ' ON v.fk_cliente = c.id WHERE c.nome LIKE "' +
        LowerCase(Trim(frmVendas.edtBuscar.Text)) + '%" ORDER BY c.id ASC;';
      frmVendas.cdsVendas.Open;
      frmVendas.dSetVendas.Open;

      TThread.Synchronize(nil,
        procedure
        begin
          frmVendas.DBGridVendas.DataSource := frmVendas.dSourceVendas;
        end);
    end);
  t.FreeOnTerminate := true;
  t.Start;
end;

procedure verificarOrdenacaoVenda;
begin
  case frmVendas.cbOrdenarPor.ItemIndex of
    0:
      buscarVenda('id');
    1:
      buscarVenda('fk_cliente');
    2:
      buscarVenda('total');
    3:
      buscarVenda('data');
  end;
end;

procedure buscarCidade;
var
  t: TThread;
begin
  t := TThread.CreateAnonymousThread(
    procedure
    begin
      abrirDados('cidade', false);
      dm.cdsCidades.CommandText := 'SELECT * FROM cidade c JOIN estado e ON ' +
        'c.fk_estado = e.id WHERE (e.uf = "' +
        UpperCase(Trim(frmCadastrarCliente.cboxEstados.Text)) +
        '") AND (c.nome LIKE "' + frmCadastrarCliente.edtCidade.Text +
        '%") ORDER BY c.nome DESC;';
      dm.cdsCidadesnome.Text;
      abrirDados('cidade', true);
      TThread.Synchronize(nil,
        procedure
        begin
          frmCadastrarCliente.gridCidades.DataSource := dm.dSourceCidades;
        end);
    end);
  t.FreeOnTerminate := true;
  t.Start;
end;

procedure buscarEnderecoCliente;
var
  t: TThread;
begin
  t := TThread.CreateAnonymousThread(
    procedure
    begin
      dm.queryEnderecoCliente.Close;
      dm.queryEnderecoCliente.SQL.Text :=
        'SELECT e.uf, c.nome, cli.bairro, cli.rua ' +
        'FROM cliente cli JOIN cidade c ON cli.fk_cidade = c.id JOIN estado e ON c.fk_estado = '
        + 'e.id WHERE cli.id = "' + dm.cdsClientesid.AsString + '"';
      dm.queryEnderecoCliente.Open;
      TThread.Synchronize(nil,
        procedure
        begin
          frmCadastrarCliente.cboxEstados.ItemIndex :=
            frmCadastrarCliente.cboxEstados.Items.IndexOf
            (dm.queryEnderecoCliente.Fields[0].AsString);
          frmCadastrarCliente.edtCidade.Text :=
            (dm.queryEnderecoCliente.Fields[1].AsString);
          frmCadastrarCliente.edtBairro.Text :=
            (dm.queryEnderecoCliente.Fields[2].AsString);
          frmCadastrarCliente.EdtRua.Text := (dm.queryEnderecoCliente.Fields[3]
            .AsString);
        end);
    end);
  t.FreeOnTerminate := true;
  t.Start;
end;

procedure fechaBuscaCidade;
begin
  frmCadastrarCliente.gridCidades.Visible := false;
  frmCadastrarCliente.btnCancelarCidade.Visible := false;
end;

procedure abreBuscaCidade;
begin
  frmCadastrarCliente.gridCidades.Visible := true;
  frmCadastrarCliente.btnCancelarCidade.Visible := true;
end;

procedure abrirDados(tabela: string; estado: Boolean);
begin

  if tabela = 'cliente' then
  begin
    if estado = true then
    begin
      dm.cdsClientes.Open;
      dm.dSetClientes.Open;
    end
    else
    begin
      dm.cdsClientes.Close;
      dm.dSetClientes.Close;
    end;
  end
  else if tabela = 'produto' then
  begin
    if estado = true then
    begin
      dm.cdsProdutos.Open;
      dm.dSetProdutos.Open;
    end
    else
    begin
      dm.cdsProdutos.Close;
      dm.dSetProdutos.Close;
    end;
  end
  else if tabela = 'estado' then
  begin
    if estado = true then
    begin
      dm.cdsEstados.Open;
      dm.dSetEstados.Open;
    end
    else
    begin
      dm.cdsEstados.Close;
      dm.dSetEstados.Close;
    end;
  end
  else if tabela = 'cidade' then
  begin
    if estado = true then
    begin
      dm.cdsCidades.Open;
      dm.dSetCidades.Open;
    end
    else
    begin
      dm.cdsCidades.Close;
      dm.dSetCidades.Close;
    end;
  end
  else if tabela = 'item' then
  begin
    if estado = true then
    begin
      dm.cdsItens.Open;
      dm.dSetItens.Open;
    end
    else
    begin
      dm.cdsItens.Close;
      dm.dSetItens.Close;
    end;
  end
  else if tabela = 'venda' then
  begin
    if estado = true then
    begin
      dm.cdsVendas.Open;
      dm.dSetVendas.Open;
    end
    else
    begin
      dm.cdsVendas.Close;
      dm.dSetVendas.Close;
    end;
  end;
end;

procedure calculaSubTotalItem;
begin
  quantidadeDeProdutos := StrToInt(frmAdicionarItem.edtQuantidade.Text);
  valUnitario := StrToFloat(frmAdicionarItem.edtValUnitario.Text);
  frmAdicionarItem.edtSubTotal.Text :=
    FloatToStr(quantidadeDeProdutos * valUnitario);
end;

procedure calculaAcrescimoItem;
begin
  acrescimoDoItem := StrToFloat(frmAdicionarItem.edtAcrescimo.Text) / 100;
  frmAdicionarItem.edtValAcrescimo.Text :=
    FloatToStr(acrescimoDoItem * StrToFloat(frmAdicionarItem.edtSubTotal.Text));
end;

procedure calculaDescontoItem;
begin
  descontoDoItem := StrToFloat(frmAdicionarItem.edtDesconto.Text) / 100;
  frmAdicionarItem.edtValDesconto.Text :=
    FloatToStr(descontoDoItem * StrToFloat(frmAdicionarItem.edtSubTotal.Text));
end;

procedure calculaTotalItem;
begin
  valAcrescimoItem := StrToFloat(frmAdicionarItem.edtValAcrescimo.Text);
  valDescontoItem := StrToFloat(frmAdicionarItem.edtValDesconto.Text);
  subTotalDoItem := StrToFloat(frmAdicionarItem.edtSubTotal.Text);
  frmAdicionarItem.edtValTotal.Text :=
    FloatToStr(valAcrescimoItem + subTotalDoItem - valDescontoItem);
end;

procedure calculaSubTotalVenda;
var
  novoValDoItem, diferenca: Double;
begin
  if frmCadastrarVenda.Tag = 4 then // adicionando algum item
  begin
    frmCadastrarVenda.edtSubtTotal.Text :=
      FloatToStr(StrToFloat(frmCadastrarVenda.edtSubtTotal.Text) +
      StrToFloat(frmAdicionarItem.edtValTotal.Text));
  end
  else if frmCadastrarVenda.Tag = 3 then // editando um item
  begin
    if frmCadastrarVenda.DBGridVendas.DataSource.DataSet.RecordCount = 0 then
      frmCadastrarVenda.edtSubtTotal.Text := '0'
    else
    begin
      novoValDoItem := dm.cdsItensvalor_total.AsFloat;
      diferenca := novoValDoItem - frmAdicionarItem.valAtualDoItem;

      if diferenca > 0 then
      begin
        frmCadastrarVenda.edtSubtTotal.Text :=
          FloatToStr(StrToFloat(frmCadastrarVenda.edtSubtTotal.Text) +
          diferenca);
      end
      else
      begin
        frmCadastrarVenda.edtSubtTotal.Text :=
          FloatToStr(StrToFloat(frmCadastrarVenda.edtSubtTotal.Text) +
          diferenca);
      end;
    end;
  end;
end;

procedure calculaTotalVenda;
var
  subTotal: Double;
begin
  desconto := StrToFloat(frmCadastrarVenda.edtDesconto.Text) / 100;
  acrescimo := StrToFloat(frmCadastrarVenda.edtAcrescimo.Text) / 100;
  frete := StrToFloat(frmCadastrarVenda.edtFrete.Text);
  subTotal := StrToFloat(frmCadastrarVenda.edtSubtTotal.Text);
  frmCadastrarVenda.edtTotalVenda.Text :=
    FloatToStr(subTotal + frete + (subTotal * acrescimo) -
    (subTotal * desconto));
end;

procedure removeFormatacaoPrecoProduto;
begin
  frmCadastrarProduto.dbEdtPreco.Text :=
    copy(frmCadastrarProduto.dbEdtPreco.Text, 4, 10);
  frmCadastrarProduto.dbEdtPreco.Text :=
    StringReplace(frmCadastrarProduto.dbEdtPreco.Text, '.', '', [rfReplaceAll]);
end;

end.
