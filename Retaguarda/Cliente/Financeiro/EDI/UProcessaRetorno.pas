{ *******************************************************************************
Title: T2Ti ERP
Description: Janela para tratamento dos arquivos de retorno

The MIT License

Copyright: Copyright (C) 2016 T2Ti.COM

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

@author Albert Eije (alberteije@gmail.com)
@version 2.0
******************************************************************************* }
unit UProcessaRetorno;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, Grids, DBGrids, StdCtrls, ExtCtrls, ActnList,
  RibbonSilverStyleActnCtrls, ActnMan, ToolWin, ActnCtrls, LabeledCtrls, ComCtrls,
  JvExDBGrids, JvDBGrid, JvDBUltimGrid, JvBaseEdits, Mask,
  JvExMask, JvToolEdit, Biblioteca, PessoaVO, ContaCaixaVO, ACBrBoleto, AdmParametroVO,
  SessaoUsuario, System.Actions, Controller, Vcl.Imaging.pngimage;

type
  TFProcessaRetorno = class(TForm)
    PanelCabecalho: TPanel;
    Bevel1: TBevel;
    Image1: TImage;
    Label2: TLabel;
    ActionToolBarPrincipal: TActionToolBar;
    ActionManagerLocal: TActionManager;
    ActionProcessarRetorno: TAction;
    PageControlItens: TPageControl;
    tsDados: TTabSheet;
    PanelDados: TPanel;
    Bevel2: TBevel;
    DSRetorno: TDataSource;
    CDSRetorno: TClientDataSet;
    Grid: TJvDBUltimGrid;
    CDSRetornoNOSSO_NUMERO: TStringField;
    CDSRetornoLOG: TStringField;
    ActionSair: TAction;
    procedure ActionProcessarRetornoExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActionSairExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FProcessaRetorno: TFProcessaRetorno;
  PessoaVO: TPessoaVO;
  ContaCaixaVO: TContaCaixaVO;
  AdmParametroVO: TAdmParametroVO;

implementation

uses
  UDataModule, ULookup, FinParcelaReceberController, FinParcelaReceberVO,
  FinParcelaRecebimentoVO, FinParcelaRecebimentoController, FinChequeRecebidoVO,
  AdmParametroController;
{$R *.dfm}

{$REGION 'Infra'}
procedure TFProcessaRetorno.FormShow(Sender: TObject);
var
  Filtro: String;
begin
  Grid.SetFocus;

  Filtro := 'ID_EMPRESA = ' + IntToStr(TSessaoUsuario.Instance.Empresa.Id);
  AdmParametroVO := TAdmParametroVO(TController.BuscarObjeto('AdmParametroController.TAdmParametroController', 'ConsultaObjeto', [Filtro], 'GET'));
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFProcessaRetorno.ActionProcessarRetornoExecute(Sender: TObject);
var
  I: integer;
  Titulo: TACBrTitulo;
  ParcelaReceber: TFinParcelaReceberVO;
  ParcelaRecebimento: TFinParcelaRecebimentoVO;
begin
  if not FDataModule.OpenDialog.Execute then
    Exit;

  try
    FDataModule.ACBrBoleto.Banco.TipoCobranca := cobBancoDoBrasil;
    FDataModule.ACBrBoleto.LayoutRemessa := c240;
    FDataModule.ACBrBoleto.LeCedenteRetorno := True;
    FDataModule.ACBrBoleto.DirArqRetorno := ExtractFileDir(FDataModule.OpenDialog.FileName);
    FDataModule.ACBrBoleto.NomeArqRetorno := ExtractFileName(FDataModule.OpenDialog.FileName);
    FDataModule.ACBrBoleto.LerRetorno;
    for I := 0 to FDataModule.ACBrBoleto.ListadeBoletos.Count - 1 do
    begin
      Titulo := FDataModule.ACBrBoleto.ListadeBoletos.Objects[i];

      //Verifica se o titulo encontra-se no banco de dados
      ParcelaReceber := TFinParcelaReceberVO(TController.BuscarObjeto('FinParcelaReceberController.TFinParcelaReceberController', 'ConsultaObjeto', ['BOLETO_NOSSO_NUMERO=' + QuotedStr(Titulo.NossoNumero)], 'GET'));

      if not Assigned(ParcelaReceber) then
      begin
        CDSRetorno.Append;
        CDSRetornoNOSSO_NUMERO.AsString := Titulo.NossoNumero;
        CDSRetornoLOG.AsString := 'Nosso N�mero n�o localizado no banco de dados.';
        CDSRetorno.Post;
      end
      else
      begin
        ParcelaReceber.IdFinStatusParcela := AdmParametroVO.FinParcelaQuitado;

        ParcelaRecebimento := TFinParcelaRecebimentoVO.Create;

        ParcelaRecebimento.IdFinTipoRecebimento := AdmParametroVO.FinTipoRecebimentoEdi;
        ParcelaRecebimento.IdFinParcelaReceber := ParcelaReceber.Id;
        ParcelaRecebimento.IdContaCaixa := ParcelaReceber.IdContaCaixa;
        ParcelaRecebimento.DataRecebimento := Titulo.DataBaixa;
        ParcelaRecebimento.TaxaMulta := Titulo.PercentualMulta;
        ParcelaRecebimento.ValorMulta := Titulo.ValorMoraJuros;
        ParcelaRecebimento.ValorDesconto := Titulo.ValorDesconto;
        ParcelaRecebimento.Historico := 'RECEBIDO VIA EDI BANCARIO - REFERENCIA: ' + Titulo.Referencia;
        ParcelaRecebimento.ValorRecebido := Titulo.ValorRecebido;

        CDSRetorno.Append;
        CDSRetornoNOSSO_NUMERO.AsString := Titulo.NossoNumero;
        CDSRetornoLOG.AsString := 'T�tulo processado com sucesso.';
        CDSRetorno.Post;

        TController.ExecutarMetodo('FinParcelaReceberController.TFinParcelaReceberController', 'Altera', [ParcelaReceber], 'POST', 'Boolean');
      end;
    end;
  finally
  end;
end;

procedure TFProcessaRetorno.ActionSairExecute(Sender: TObject);
begin
  Close;
end;
{$ENDREGION}

end.
