{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Or�ameto Financeiro de Caixa

The MIT License

Copyright: Copyright (C) 2015 T2Ti.COM

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

The author may be contacted at:
t2ti.com@gmail.com</p>

@author Albert Eije
@version 2.0
******************************************************************************* }
unit UOrcamentoFinanceiroCaixa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, DB, DBClient, Menus, StdCtrls, ExtCtrls, Buttons, Grids,
  DBGrids, JvExDBGrids, JvDBGrid, JvDBUltimGrid, ComCtrls, OrcamentoFluxoCaixaVO,
  OrcamentoFluxoCaixaController, Tipos, Atributos, Constantes, LabeledCtrls, JvToolEdit,
  Mask, JvExMask, JvBaseEdits, Math, StrUtils, ActnList, Generics.Collections,
  RibbonSilverStyleActnCtrls, ActnMan, ToolWin, ActnCtrls, DateUtils,
  System.Actions, Controller;

type
  [TFormDescription(TConstantes.MODULO_ORCAMENTO, 'Or�amento Financeiro de Caixa')]

  TFOrcamentoFinanceiroCaixa = class(TFTelaCadastro)
    PanelParcelas: TPanel;
    PanelMestre: TPanel;
    EditIdOrcamentoPeriodo: TLabeledCalcEdit;
    EditOrcamentoPeriodo: TLabeledEdit;
    EditNome: TLabeledEdit;
    EditDataBase: TLabeledDateEdit;
    EditNumeroPeriodos: TLabeledCalcEdit;
    EditDataInicial: TLabeledDateEdit;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridOrcamentoDetalhe: TJvDBUltimGrid;
    ActionToolBarEdits: TActionToolBar;
    ActionManager: TActionManager;
    ActionGerarOrcamentoFinanceiroCaixa: TAction;
    ActionPegarRealizado: TAction;
    ActionCalcularVariacao: TAction;
    DSOrcamentoDetalhe: TDataSource;
    MemoDescricao: TLabeledMemo;
    CDSOrcamentoDetalhe: TClientDataSet;
    EditOrcamentoPeriodoCodigo: TLabeledEdit;
    CDSOrcamentoDetalheID: TIntegerField;
    CDSOrcamentoDetalheID_NATUREZA_FINANCEIRA: TIntegerField;
    CDSOrcamentoDetalheID_ORCAMENTO_FLUXO_CAIXA: TIntegerField;
    CDSOrcamentoDetalheNATUREZA_FINANCEIRACLASSIFICACAO: TStringField;
    CDSOrcamentoDetalheNATUREZA_FINANCEIRADESCRICAO: TStringField;
    CDSOrcamentoDetalhePERIODO: TStringField;
    CDSOrcamentoDetalheVALOR_ORCADO: TFMTBCDField;
    CDSOrcamentoDetalheVALOR_REALIZADO: TFMTBCDField;
    CDSOrcamentoDetalheTAXA_VARIACAO: TFMTBCDField;
    CDSOrcamentoDetalheVALOR_VARIACAO: TFMTBCDField;
    CDSOrcamentoDetalhePERSISTE: TStringField;
    EditIdContaCaixa: TLabeledEdit;
    EditContaCaixa: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridOrcamentoDetalheKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionGerarOrcamentoFinanceiroCaixaExecute(Sender: TObject);
    procedure ActionPegarRealizadoExecute(Sender: TObject);
    procedure ActionCalcularVariacaoExecute(Sender: TObject);
    procedure CDSOrcamentoDetalheAfterEdit(DataSet: TDataSet);
    procedure CDSOrcamentoDetalheAfterPost(DataSet: TDataSet);
    procedure EditIdOrcamentoPeriodoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;

    procedure ConfigurarLayoutTela;
  end;

var
  FOrcamentoFinanceiroCaixa: TFOrcamentoFinanceiroCaixa;

implementation

uses ULookup, Biblioteca, UDataModule, OrcamentoFluxoCaixaDetalheController,
  OrcamentoFluxoCaixaDetalheVO, NaturezaFinanceiraController, NaturezaFinanceiraVO,
  ViewFinTotalRecebimentosDiaController, ViewFinTotalPagamentosDiaController,
  ViewFinTotalRecebimentosDiaVO, ViewFinTotalPagamentosDiaVO,
  PlanoNaturezaFinanceiraVO, PlanoNaturezaFinanceiraController,
  OrcamentoFluxoCaixaPeriodoVO, OrcamentoFluxoCaixaPeriodoController;
{$R *.dfm}

{$REGION 'Infra'}
procedure TFOrcamentoFinanceiroCaixa.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TOrcamentoFluxoCaixaVO;
  ObjetoController := TOrcamentoFluxoCaixaController.Create;

  inherited;
end;

procedure TFOrcamentoFinanceiroCaixa.LimparCampos;
begin
  inherited;
  CDSOrcamentoDetalhe.EmptyDataSet;
end;

procedure TFOrcamentoFinanceiroCaixa.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;

  if StatusTela = stNavegandoEdits then
  begin
    PanelMestre.Enabled := False;
    PanelItens.Enabled := True;
    ActionGerarOrcamentoFinanceiroCaixa.Enabled := False;
    ActionPegarRealizado.Enabled := False;
    ActionCalcularVariacao.Enabled := False;
  end
  else
  begin
    PanelMestre.Enabled := True;
    PanelItens.Enabled := True;
    ActionGerarOrcamentoFinanceiroCaixa.Enabled := True;
    ActionPegarRealizado.Enabled := True;
    ActionCalcularVariacao.Enabled := True
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFOrcamentoFinanceiroCaixa.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditIdOrcamentoPeriodo.SetFocus;
  end;
end;

function TFOrcamentoFinanceiroCaixa.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditIdOrcamentoPeriodo.SetFocus;
  end;
end;

function TFOrcamentoFinanceiroCaixa.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      TController.ExecutarMetodo('OrcamentoFluxoCaixaController.TOrcamentoFluxoCaixaController', 'Exclui', [IdRegistroSelecionado], 'DELETE', 'Boolean');
      Result := TController.RetornoBoolean;
    except
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;

  if Result then
    TController.ExecutarMetodo('OrcamentoFluxoCaixaController.TOrcamentoFluxoCaixaController', 'Consulta', [Trim(Filtro), Pagina.ToString, False], 'GET', 'Lista');
end;

function TFOrcamentoFinanceiroCaixa.DoSalvar: Boolean;
var
  OrcamentoDetalhe: TOrcamentoFluxoCaixaDetalheVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TOrcamentoFluxoCaixaVO.Create;

      TOrcamentoFluxoCaixaVO(ObjetoVO).IdOrcFluxoCaixaPeriodo := EditIdOrcamentoPeriodo.AsInteger;
      TOrcamentoFluxoCaixaVO(ObjetoVO).OrcamentoPeriodoNome := EditOrcamentoPeriodo.Text;
      TOrcamentoFluxoCaixaVO(ObjetoVO).OrcamentoPeriodoCodigo := EditOrcamentoPeriodoCodigo.Text;
      TOrcamentoFluxoCaixaVO(ObjetoVO).Nome := EditNome.Text;
      TOrcamentoFluxoCaixaVO(ObjetoVO).Descricao := MemoDescricao.Text;
      TOrcamentoFluxoCaixaVO(ObjetoVO).DataInicial := EditDataInicial.Date;
      TOrcamentoFluxoCaixaVO(ObjetoVO).NumeroPeriodos := EditNumeroPeriodos.AsInteger;
      TOrcamentoFluxoCaixaVO(ObjetoVO).DataBase := EditDataBase.Date;

      if StatusTela = stEditando then
        TOrcamentoFluxoCaixaVO(ObjetoVO).Id := IdRegistroSelecionado;

      // Detalhes do or�amento
      TOrcamentoFluxoCaixaVO(ObjetoVO).ListaOrcamentoDetalheVO := TObjectList<TOrcamentoFluxoCaixaDetalheVO>.Create;
      CDSOrcamentoDetalhe.DisableControls;
      CDSOrcamentoDetalhe.First;
      while not CDSOrcamentoDetalhe.Eof do
      begin
        if (CDSOrcamentoDetalhePERSISTE.AsString = 'S') or (CDSOrcamentoDetalheID.AsInteger = 0) then
        begin
          OrcamentoDetalhe := TOrcamentoFluxoCaixaDetalheVO.Create;
          OrcamentoDetalhe.Id := CDSOrcamentoDetalheID.AsInteger;
          OrcamentoDetalhe.IdNaturezaFinanceira := CDSOrcamentoDetalheID_NATUREZA_FINANCEIRA.AsInteger;
          OrcamentoDetalhe.IdOrcamentoFluxoCaixa := CDSOrcamentoDetalheID_ORCAMENTO_FLUXO_CAIXA.AsInteger;
          OrcamentoDetalhe.Periodo := CDSOrcamentoDetalhePERIODO.AsString;
          OrcamentoDetalhe.ValorOrcado := CDSOrcamentoDetalheVALOR_ORCADO.AsExtended;
          OrcamentoDetalhe.ValorRealizado := CDSOrcamentoDetalheVALOR_REALIZADO.AsExtended;
          OrcamentoDetalhe.TaxaVariacao := CDSOrcamentoDetalheTAXA_VARIACAO.AsExtended;
          OrcamentoDetalhe.ValorVariacao := CDSOrcamentoDetalheVALOR_VARIACAO.AsExtended;
          TOrcamentoFluxoCaixaVO(ObjetoVO).ListaOrcamentoDetalheVO.Add(OrcamentoDetalhe);
        end;
        CDSOrcamentoDetalhe.Next;
      end;
      CDSOrcamentoDetalhe.EnableControls;

      /// EXERCICIO: IMPLEMENTE DE ACORDO COM O C�DIGO ABAIXO ENSINADO NOS MODULOS DE INFRA
      // TController.PreencherObjectListFromCDS<TOrcamentoDetalheVO>(TOrcamentoFluxoCaixaVO(ObjetoVO).ListaOrcamentoDetalheVO, CDSOrcamentoDetalhe);

      if StatusTela = stInserindo then
      begin
        TController.ExecutarMetodo('OrcamentoFluxoCaixaController.TOrcamentoFluxoCaixaController', 'Insere', [TOrcamentoFluxoCaixaVO(ObjetoVO)], 'PUT', 'Lista');
      end
      else if StatusTela = stEditando then
      begin
        if TOrcamentoFluxoCaixaVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TController.ExecutarMetodo('OrcamentoFluxoCaixaController.TOrcamentoFluxoCaixaController', 'Altera', [TOrcamentoFluxoCaixaVO(ObjetoVO)], 'POST', 'Boolean');
        end
        else
          Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      end;
    except
      Result := False;
    end;
  end;

end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFOrcamentoFinanceiroCaixa.EditIdOrcamentoPeriodoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdOrcamentoPeriodo.Value <> 0 then
      Filtro := 'ID = ' + EditIdOrcamentoPeriodo.Text
    else
      Filtro := 'ID=0';

    try
      EditIdOrcamentoPeriodo.Clear;
      EditOrcamentoPeriodo.Clear;
      if not PopulaCamposTransientes(Filtro, TOrcamentoFluxoCaixaPeriodoVO, TOrcamentoFluxoCaixaPeriodoController) then
        PopulaCamposTransientesLookup(TOrcamentoFluxoCaixaPeriodoVO, TOrcamentoFluxoCaixaPeriodoController);
      if CDSTransiente.RecordCount > 0 then
      begin
        EditIdOrcamentoPeriodo.Text := CDSTransiente.FieldByName('ID').AsString;
        EditOrcamentoPeriodo.Text := CDSTransiente.FieldByName('NOME').AsString;
        EditOrcamentoPeriodoCodigo.Text := CDSTransiente.FieldByName('PERIODO').AsString;
      end
      else
      begin
        Exit;
        EditNome.SetFocus;
      end;
    finally
      CDSTransiente.Close;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFOrcamentoFinanceiroCaixa.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFOrcamentoFinanceiroCaixa.GridParaEdits;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    ObjetoVO := TOrcamentoFluxoCaixaVO(TController.BuscarObjeto('OrcamentoFluxoCaixaController.TOrcamentoFluxoCaixaController', 'ConsultaObjeto', ['ID=' + IdRegistroSelecionado.ToString], 'GET'));
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdOrcamentoPeriodo.AsInteger := TOrcamentoFluxoCaixaVO(ObjetoVO).IdOrcFluxoCaixaPeriodo;
    EditOrcamentoPeriodo.Text := TOrcamentoFluxoCaixaVO(ObjetoVO).OrcamentoPeriodoNome;
    EditOrcamentoPeriodoCodigo.Text := TOrcamentoFluxoCaixaVO(ObjetoVO).OrcamentoPeriodoCodigo;
    EditIdContaCaixa.Text := IntToStr(TOrcamentoFluxoCaixaVO(ObjetoVO).OrcamentoPeriodoVO.ContaCaixaVO.Id);
    EditContaCaixa.Text := TOrcamentoFluxoCaixaVO(ObjetoVO).OrcamentoPeriodoVO.ContaCaixaVO.Nome;
    EditNome.Text := TOrcamentoFluxoCaixaVO(ObjetoVO).Nome;
    MemoDescricao.Text := TOrcamentoFluxoCaixaVO(ObjetoVO).Descricao;
    EditDataInicial.Date := TOrcamentoFluxoCaixaVO(ObjetoVO).DataInicial;
    EditNumeroPeriodos.AsInteger := TOrcamentoFluxoCaixaVO(ObjetoVO).NumeroPeriodos;
    EditDataBase.Date := TOrcamentoFluxoCaixaVO(ObjetoVO).DataBase;

    // Detalhes do or�amento
    TController.TratarRetorno<TOrcamentoFluxoCaixaDetalheVO>(TOrcamentoFluxoCaixaVO(ObjetoVO).ListaOrcamentoDetalheVO, True, True, CDSOrcamentoDetalhe);

    // Limpa as listas para comparar posteriormente se houve inclus�es/altera��es e subir apenas o necess�rio para o servidor
    TOrcamentoFluxoCaixaVO(ObjetoVO).ListaOrcamentoDetalheVO.Clear;

    // Serializa o objeto para consultar posteriormente se houve altera��es
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
  ConfigurarLayoutTela;
end;

procedure TFOrcamentoFinanceiroCaixa.GridOrcamentoDetalheKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If Key = VK_RETURN then
    GridOrcamentoDetalhe.SelectedIndex := GridOrcamentoDetalhe.SelectedIndex + 1;
end;

procedure TFOrcamentoFinanceiroCaixa.CDSOrcamentoDetalheAfterEdit(DataSet: TDataSet);
begin
  CDSOrcamentoDetalhePERSISTE.AsString := 'S';
end;

procedure TFOrcamentoFinanceiroCaixa.CDSOrcamentoDetalheAfterPost(DataSet: TDataSet);
begin
  if CDSOrcamentoDetalheNATUREZA_FINANCEIRACLASSIFICACAO.AsString = '' then
    CDSOrcamentoDetalhe.Delete;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFOrcamentoFinanceiroCaixa.ActionGerarOrcamentoFinanceiroCaixaExecute(Sender: TObject);
var
  NaturezaFinanceira: TNaturezaFinanceiraVO;
  i, ContadorPeriodo: Integer;
begin

  /// EXERCICIO: SE J� EXISTIREM DADOS NO BANCO E VOC� CLICAR NO BOT�O "GERAR OR�AMENTO" O QUE VAI OCORRER? FA�A V�RIOS TESTES E CORRIJA O QUE FOR PRECISO

  CDSOrcamentoDetalhe.EmptyDataSet;
  try
    PopulaCamposTransientesLookup(TPlanoNaturezaFinanceiraVO, TPlanoNaturezaFinanceiraController);
    if CDSTransiente.RecordCount > 0 then
    begin
      ConsultaGenerica('ID_PLANO_NATUREZA_FINANCEIRA = ' + QuotedStr(IntToStr(CDSTransiente.FieldByName('ID').AsInteger)), TNaturezaFinanceiraVO, TNaturezaFinanceiraController);

      ContadorPeriodo := 0;

      // 01=Di�rio | 02=Semanal | 03=Mensal | 04=Bimestral | 05=Trimestral | 06=Semestral | 07=Anual
      for i := 1 to EditNumeroPeriodos.AsInteger do
      begin

        CDSConsultaGenerica.First;
        while not CDSConsultaGenerica.Eof do
        begin
          CDSOrcamentoDetalhe.Append;
          CDSOrcamentoDetalheID_NATUREZA_FINANCEIRA.AsInteger := CDSConsultaGenerica.FieldByName('ID').AsInteger;
          CDSOrcamentoDetalheNATUREZA_FINANCEIRACLASSIFICACAO.AsString := CDSConsultaGenerica.FieldByName('CLASSIFICACAO').AsString;
          CDSOrcamentoDetalheNATUREZA_FINANCEIRADESCRICAO.AsString := CDSConsultaGenerica.FieldByName('DESCRICAO').AsString;
          CDSOrcamentoDetalheVALOR_ORCADO.AsExtended := 0;
          CDSOrcamentoDetalheVALOR_REALIZADO.AsExtended := 0;
          CDSOrcamentoDetalheTAXA_VARIACAO.AsExtended := 0;
          CDSOrcamentoDetalheVALOR_VARIACAO.AsExtended := 0;
          CDSOrcamentoDetalhe.FieldByName('PERSISTE').AsString := 'S';

          case StrToInt(EditOrcamentoPeriodoCodigo.Text) of
            1: // di�rio
              CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString := DateToStr(EditDataInicial.Date + ContadorPeriodo);
            2: // semanal
              CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString := DateToStr(IncWeek(EditDataInicial.Date, ContadorPeriodo));
            3: // mensal
              CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString := Copy(DateToStr(IncMonth(EditDataInicial.Date, ContadorPeriodo)), 4, 7);
            4: // bimestral
              CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString := Copy(DateToStr(IncMonth(EditDataInicial.Date, ContadorPeriodo * 2)), 4, 7);
            5: // trimestral
              CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString := Copy(DateToStr(IncMonth(EditDataInicial.Date, ContadorPeriodo * 3)), 4, 7);
            6: // semestral
              CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString := Copy(DateToStr(IncMonth(EditDataInicial.Date, ContadorPeriodo * 6)), 4, 7);
            7: // anual
              CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString := Copy(DateToStr(IncYear(EditDataInicial.Date, ContadorPeriodo)), 7, 4);
          end;
          CDSOrcamentoDetalhe.Post;
          CDSConsultaGenerica.Next;
        end;
        Inc(ContadorPeriodo);
      end;
      CDSConsultaGenerica.Close;
      GridOrcamentoDetalhe.SetFocus;
    end;
  finally
    CDSTransiente.Close;
  end;
end;

procedure TFOrcamentoFinanceiroCaixa.ActionPegarRealizadoExecute(Sender: TObject);
var
  FiltroRecebimento, FiltroPagamento: String;
  DataInicio, DataFim: TDateTime;
  RealizadoPagar, RealizadoReceber: Extended;
begin
  try
    CDSOrcamentoDetalhe.DisableControls;
    CDSOrcamentoDetalhe.First;
    while not CDSOrcamentoDetalhe.Eof do
    begin
      RealizadoPagar := 0;
      RealizadoReceber := 0;

      /// EXERCICIO: O FILTRO N�O EST� LEVANDO EM CONSIDERA��O A NATUREZA FINANCEIRA. CORRIJA ISSO.
      /// EXERCICIO: OBSERVE SE A DATA QUE EST� SENDO MONTADA NO FILTRO EST� DE ACORDO COM O DESEJADO PARA ENCONTRAR OS DADOS PRETENDIDOS

      //Define o filtro
      if EditOrcamentoPeriodoCodigo.Text = '01' then //Di�rio
      begin
        DataInicio := StrToDate(Copy(CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString, 1, 2) +  Copy(EditDataBase.Text, 3, 8));
        FiltroRecebimento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and DATA_RECEBIMENTO='+QuotedStr(DataParaTexto(DataInicio));
        FiltroPagamento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and DATA_PAGAMENTO='+QuotedStr(DataParaTexto(DataInicio));
      end
      else if EditOrcamentoPeriodoCodigo.Text = '02' then //Semanal
      begin
        DataInicio := StrToDate(CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString);
        DataFim := StrToDate(CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString) + 6;
        FiltroRecebimento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and (DATA_RECEBIMENTO between '+QuotedStr(DataParaTexto(DataInicio)) + ' and ' + QuotedStr(DataParaTexto(DataFim)) + ')';
        FiltroPagamento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and (DATA_PAGAMENTO between '+QuotedStr(DataParaTexto(DataInicio)) + ' and ' + QuotedStr(DataParaTexto(DataFim)) + ')';
      end
      else if EditOrcamentoPeriodoCodigo.Text = '03' then //Mensal
      begin
        DataInicio := StrToDate('01/'+CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString);
        DataFim := StrToDate('01/'+CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString) + 30;
        FiltroRecebimento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and (DATA_RECEBIMENTO between '+QuotedStr(DataParaTexto(DataInicio)) + ' and ' + QuotedStr(DataParaTexto(DataFim)) + ')';
        FiltroPagamento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and (DATA_PAGAMENTO between '+QuotedStr(DataParaTexto(DataInicio)) + ' and ' + QuotedStr(DataParaTexto(DataFim)) + ')';
      end
      else if EditOrcamentoPeriodoCodigo.Text = '04' then //Bimestral
      begin
        DataInicio := StrToDate('01/'+CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString);
        DataFim := StrToDate('01/'+CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString) + 60;
        FiltroRecebimento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and (DATA_RECEBIMENTO between '+QuotedStr(DataParaTexto(DataInicio)) + ' and ' + QuotedStr(DataParaTexto(DataFim)) + ')';
        FiltroPagamento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and (DATA_PAGAMENTO between '+QuotedStr(DataParaTexto(DataInicio)) + ' and ' + QuotedStr(DataParaTexto(DataFim)) + ')';
      end
      else if EditOrcamentoPeriodoCodigo.Text = '05' then //Trimestral
      begin
        DataInicio := StrToDate('01/'+CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString);
        DataFim := StrToDate('01/'+CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString) + 90;
        FiltroRecebimento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and (DATA_RECEBIMENTO between '+QuotedStr(DataParaTexto(DataInicio)) + ' and ' + QuotedStr(DataParaTexto(DataFim)) + ')';
        FiltroPagamento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and (DATA_PAGAMENTO between '+QuotedStr(DataParaTexto(DataInicio)) + ' and ' + QuotedStr(DataParaTexto(DataFim)) + ')';
      end
      else if EditOrcamentoPeriodoCodigo.Text = '06' then //Semestral
      begin
        DataInicio := StrToDate('01/'+CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString);
        DataFim := StrToDate('01/'+CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString) + 180;
        FiltroRecebimento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and (DATA_RECEBIMENTO between '+QuotedStr(DataParaTexto(DataInicio)) + ' and ' + QuotedStr(DataParaTexto(DataFim)) + ')';
        FiltroPagamento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and (DATA_PAGAMENTO between '+QuotedStr(DataParaTexto(DataInicio)) + ' and ' + QuotedStr(DataParaTexto(DataFim)) + ')';
      end
      else if EditOrcamentoPeriodoCodigo.Text = '07' then //Anual
      begin
        DataInicio := StrToDate('01/01/'+CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString);
        DataFim := StrToDate('31/12/'+CDSOrcamentoDetalhe.FieldByName('PERIODO').AsString);
        FiltroRecebimento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and (DATA_RECEBIMENTO between '+QuotedStr(DataParaTexto(DataInicio)) + ' and ' + QuotedStr(DataParaTexto(DataFim)) + ')';
        FiltroPagamento := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and (DATA_PAGAMENTO between '+QuotedStr(DataParaTexto(DataInicio)) + ' and ' + QuotedStr(DataParaTexto(DataFim)) + ')';
      end;

      //Realiza a consulta e pega os valores recebidos
      ConsultaGenerica(FiltroRecebimento, TViewFinTotalRecebimentosDiaVO, TViewFinTotalRecebimentosDiaController);
      CDSConsultaGenerica.First;
      while not CDSConsultaGenerica.Eof do
      begin
        RealizadoReceber := RealizadoReceber + CDSConsultaGenerica.FieldByName('TOTAL').AsExtended;
        CDSConsultaGenerica.Next;
      end;
      CDSConsultaGenerica.Close;

      //Realiza a consulta e pega os valores pagos
      ConsultaGenerica(FiltroPagamento, TViewFinTotalPagamentosDiaVO, TViewFinTotalPagamentosDiaController);
      CDSConsultaGenerica.First;
      while not CDSConsultaGenerica.Eof do
      begin
        RealizadoPagar := RealizadoPagar + CDSConsultaGenerica.FieldByName('TOTAL').AsExtended;
        CDSConsultaGenerica.Next;
      end;
      CDSConsultaGenerica.Close;

      //Grava os valores
      CDSOrcamentoDetalhe.Edit;
      CDSOrcamentoDetalhe.FieldByName('VALOR_REALIZADO').AsExtended := RealizadoPagar + RealizadoReceber;
      CDSOrcamentoDetalhe.Post;

      CDSOrcamentoDetalhe.Next;
    end;
    CDSOrcamentoDetalhe.First;
    CDSOrcamentoDetalhe.EnableControls;

    GridOrcamentoDetalhe.SetFocus;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro na consulta do realizado. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

procedure TFOrcamentoFinanceiroCaixa.ActionCalcularVariacaoExecute(Sender: TObject);
begin
  try
    CDSOrcamentoDetalhe.DisableControls;
    CDSOrcamentoDetalhe.First;
    while not CDSOrcamentoDetalhe.Eof do
    begin
      if (CDSOrcamentoDetalhe.FieldByName('VALOR_REALIZADO').AsExtended <> 0) and (CDSOrcamentoDetalhe.FieldByName('VALOR_ORCADO').AsExtended <> 0) then
      begin
        CDSOrcamentoDetalhe.Edit;
        CDSOrcamentoDetalhe.FieldByName('VALOR_VARIACAO').AsExtended := CDSOrcamentoDetalhe.FieldByName('VALOR_REALIZADO').AsExtended - CDSOrcamentoDetalhe.FieldByName('VALOR_ORCADO').AsExtended;
        CDSOrcamentoDetalhe.FieldByName('TAXA_VARIACAO').AsExtended := RoundTo(CDSOrcamentoDetalhe.FieldByName('VALOR_VARIACAO').AsExtended / CDSOrcamentoDetalhe.FieldByName('VALOR_ORCADO').AsExtended * 100, -2);
        CDSOrcamentoDetalhe.Post;
      end;
      CDSOrcamentoDetalhe.Next;
    end;
    CDSOrcamentoDetalhe.First;
    CDSOrcamentoDetalhe.EnableControls;
    GridOrcamentoDetalhe.SetFocus;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro ao calcular a varia��o. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;
{$ENDREGION}

end.
