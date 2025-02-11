unit uFrmSimulacao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlack,
  dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkroom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinOffice2019Colorful, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringtime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinTheBezier,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxLabel, cxSpinEdit, cxGroupBox, cxCheckBox, Vcl.StdCtrls, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, dxDateRanges, Data.DB, cxDBData, cxMemo, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.Menus, cxButtons;

type
  TFrmSimulacao = class(TForm)
    grpFiltros: TcxGroupBox;
    mskCodFilial: TcxMaskEdit;
    spnRuaInicial: TcxSpinEdit;
    spnRuaFinal: TcxSpinEdit;
    spnRuaAnterior: TcxSpinEdit;
    spnPercFinalizacao: TcxSpinEdit;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    mskRuasIgnorar: TcxMaskEdit;
    cxLabel10: TcxLabel;
    cxLabel11: TcxLabel;
    mskRuasLotadasPaleteiros: TcxMaskEdit;
    cxLabel12: TcxLabel;
    cxLabel15: TcxLabel;
    chkRuaSuperlotadaAntes: TcxCheckBox;
    chkBuscarArmazemTodo: TcxCheckBox;
    radPaleteiro: TRadioButton;
    radEmpilhador: TRadioButton;
    chkPalletBox: TcxCheckBox;
    cxLabel17: TcxLabel;
    cxLabel1: TcxLabel;
    cbbCriterios: TcxComboBox;
    btnSimular: TcxButton;
    btnExplicacaoRuasIgnorar: TcxButton;
    cxLabel13: TcxLabel;
    mskRuasLotadasOSs: TcxMaskEdit;
    cxLabel14: TcxLabel;
    cxLabel16: TcxLabel;
    btnExplicacaoRuasExcessoOS: TcxButton;
    cxLabel18: TcxLabel;
    mmAnalise: TcxMemo;
    procedure btnSimularClick(Sender: TObject);
    procedure btnExplicacaoRuasIgnorarClick(Sender: TObject);
    procedure btnExplicacaoRuasExcessoOSClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSimulacao: TFrmSimulacao;

implementation

{$R *.dfm}

uses uProximaOS, uQueryBuilder, UMensagens, uConvocacaoAtivaEnums, uFrmExplicacaoRuasIgnorar, uFrmExplicacaoRuasExcessoOS, UFRMDmdb,
  UVariaveiseFuncoes;

procedure TFrmSimulacao.btnExplicacaoRuasExcessoOSClick(Sender: TObject);
begin

  if not Assigned(FrmExplicacaoRuasExcessoOS) then
  begin

    Application.CreateForm(TFrmExplicacaoRuasExcessoOS, FrmExplicacaoRuasExcessoOS);
  end;

  FrmExplicacaoRuasExcessoOS.ShowModal;

end;

procedure TFrmSimulacao.btnExplicacaoRuasIgnorarClick(Sender: TObject);
begin

  if not Assigned(FrmExplicacaoRuasIgnorar) then
  begin

    Application.CreateForm(TFrmExplicacaoRuasIgnorar, FrmExplicacaoRuasIgnorar);
  end;

  FrmExplicacaoRuasIgnorar.ShowModal;

end;

procedure TFrmSimulacao.btnSimularClick(Sender: TObject);
var
  filtro: TFiltro;
  ruas: TStringList;
  I: Integer;
  criterio: double;
  qb: TQueryBuilder;
  pc: TProcessadorCriterio;
  separador_decimal: string;
  criterio_text: string;
  rua: double;
  sucesso: boolean;
  proxima_os: TProximaOS;
begin

  filtro := TFiltro.Create;
  ruas := TStringList.Create;
  ruas.Delimiter := ',';
  ruas.Duplicates := dupIgnore;

  if cbbCriterios.Text = '' then
  begin

    MsgAtencao('Selecione um critério');
    Exit;
  end;

  if mskCodFilial.Text = '' then
  begin

    MsgAtencao('Informe a filial');
    Exit;
  end;

  separador_decimal := FormatSettings.DecimalSeparator;
  criterio_text := StringReplace(cbbCriterios.Text, '.', separador_decimal, []);
  criterio := StrToFloat(criterio_text);

  filtro.Filial := mskCodFilial.Text;
  filtro.RuaInicial := spnRuaInicial.EditValue;
  filtro.RuaFinal := spnRuaFinal.EditValue;
  filtro.Senha := 1;
  filtro.RuaAnterior := spnRuaAnterior.EditValue;
  filtro.OndaAnterior := 1;
  filtro.DataOndaAnterior := Date;
  filtro.TipoOSAnterior := 0;
  filtro.DataSolicitacaoAnterior := Date;
  filtro.BuscarNoArmazemTodo := chkBuscarArmazemTodo.Checked;
  filtro.Matricula := 1;
  filtro.DataSolicitacao := Date;
  filtro.SenhaAnterior := 0;
  filtro.PercentualFinalizacaoSeparacao := spnPercFinalizacao.EditValue;
  filtro.TrabalharComPalletBox := chkPalletBox.Checked;
  filtro.RuaSuperLotadaAntes := chkRuaSuperlotadaAntes.Checked;

  filtro.TipoOperador := tpPaleteiro;

  if radEmpilhador.Checked then
  begin

    filtro.TipoOperador := tpEmpilhador;
  end;

  ruas.DelimitedText := mskRuasLotadasPaleteiros.Text;

  for I := 0 to ruas.Count - 1 do
  begin

    filtro.RuasIgnorar.Add(ruas[I]);
  end;

  ruas.DelimitedText := mskRuasLotadasOSs.Text;

  for I := 0 to ruas.Count - 1 do
  begin

    filtro.RuasSuperLotadas.Add(ruas[I]);
  end;

  ruas.DelimitedText := mskRuasIgnorar.Text;

  filtro.RangeRuasExcecao := ruas.Count > 0;

  for I := 0 to ruas.Count - 1 do
  begin

    if Trim(ruas[I]) = '' then
    begin

      Continue;
    end;

    rua := StrToFloat(ruas[I]);

    if (rua < filtro.RuaInicial) or (rua > filtro.RuaFinal) then
    begin

      filtro.RuasIgnorar.Add(ruas[I]);
    end;
  end;

  proxima_os := TProximaOS.Create(0, true);

  pc := TProcessadorCriterio.Create;
  sucesso := pc.executar(cbbCriterios.Text, filtro, proxima_os);

  mmAnalise.Text := proxima_os.AnalisesCriterios.Text;
end;

end.
