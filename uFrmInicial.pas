unit uFrmInicial;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Menus,
  cxButtons, ExtCtrls, cxControls, cxContainer, cxEdit, cxTextEdit, cxMemo,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, DB, cxDBData,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel,
  cxClasses, cxGridCustomView, cxGrid, DBAccess, Ora, OraSmart, MemDS, OraError, cxPC, cxCheckBox, dxSkinsCore, dxSkinBlack, dxSkinBlue,
  dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkroom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinOffice2019Colorful, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringtime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinTheBezier,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, dxBarBuiltInMenu, cxNavigator, dxDateRanges, UVariaveiseFuncoes, DateUtils;

type
  TFrmInicial = class(TForm)
    btnIniciar: TcxButton;
    btnParar: TcxButton;
    timer: TTimer;
    memo: TcxMemo;
    btnLimparLog: TcxButton;
    pgcPrincipal: TcxPageControl;
    tabRobo: TcxTabSheet;
    tabOSAtribuidas: TcxTabSheet;
    grdOSAtrbuidasDBTableView1: TcxGridDBTableView;
    grdOSAtrbuidasLevel1: TcxGridLevel;
    grdOSAtrbuidas: TcxGrid;
    grdOSAtrbuidasDBTableView1DATA: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1MATRICULA: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1NUMOS: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1CODENDERECO: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1CODIGOUMA: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1CODENDERECOORIG: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1TIPOOS: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1CRITERIO: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1ARMAZEMTODO: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1SUPERLOTADA: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1TOTALOSRUA: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1TOTALFUNCRUA: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1RUA: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1SENHA: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1DTSOLICITACAO: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1TIPOOSANTERIOR: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1SENHAANTERIOR: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1RUAANTERIOR: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1DTSOLICITACAOANTERIOR: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1TOTALOSRUAANTERIOR: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1TOTALFUNCRUAANTERIOR: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1TIPOOPERADOR: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1RUAINICIAL: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1RUAFINAL: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1RANGERUASEXCECAO: TcxGridDBColumn;
    grdOSAtrbuidasDBTableView1SEGUNDOSLOCALIZACAOOS: TcxGridDBColumn;
    cxLookAndFeelController1: TcxLookAndFeelController;
    chkExibirMensagensLog: TcxCheckBox;
    chkRegistrarLogs: TcxCheckBox;
    btnSimulacao: TcxButton;
    procedure grdOSAtrbuidasDBTableView1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnLimparLogClick(Sender: TObject);
    procedure btnPararClick(Sender: TObject);
    procedure btnIniciarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure timerTimer(Sender: TObject);
    procedure executarProcessamento();
    procedure btnSimulacaoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmInicial: TFrmInicial;
  HABILITADO: boolean;
  CONFIG: TConfiguracoes;
  EXECUTANDO: boolean;
  SEGUNDOS_PARA_CANCELAMENTO: integer;
  TEMPO_PADRAO_CANCELAMENTO: integer;
  QTD_INTEGRACOES_MESMA_CONEXAO: integer;
  CONFIGURACAO_OBTIDA: boolean;
  NECESSARIO_RECONECTAR_DB: boolean;
  ULT_CHECAGEM_CANCELAMENTO: TDateTime;

implementation

uses ULibrary, UFRMDmdb, uFrmSimulacao, UMensagens;

{$R *.dfm}

procedure TFrmInicial.btnIniciarClick(Sender: TObject);
begin

  HABILITADO := true;
  btnParar.Enabled := true;
  btnIniciar.Enabled := False;
  TEMPO_PADRAO_CANCELAMENTO := 10;
  SEGUNDOS_PARA_CANCELAMENTO := 10;
  logs := 0;
  QTD_INTEGRACOES_MESMA_CONEXAO := 0;
  chkExibirMensagensLog.Enabled := False;
  chkRegistrarLogs.Enabled := False;
  CONFIGURACAO_OBTIDA := False;
end;

procedure TFrmInicial.btnLimparLogClick(Sender: TObject);
begin

  memo.Lines.Clear;
end;

procedure TFrmInicial.btnPararClick(Sender: TObject);
begin

  HABILITADO := False;
  btnParar.Enabled := False;
  btnIniciar.Enabled := true;
  chkExibirMensagensLog.Enabled := true;
  chkRegistrarLogs.Enabled := true;
end;

procedure TFrmInicial.btnSimulacaoClick(Sender: TObject);
begin

  if not Assigned(FrmSimulacao) then
  begin

    Application.CreateForm(TFrmSimulacao, FrmSimulacao);
  end;

  FrmSimulacao.ShowModal;

end;

procedure TFrmInicial.executarProcessamento;
var
  minutos_ult_checagem_cancelamento: integer;
  I: integer;
begin

  if (HABILITADO) and (not EXECUTANDO) then
  begin

    Application.ProcessMessages;

    QTD_INTEGRACOES_MESMA_CONEXAO := QTD_INTEGRACOES_MESMA_CONEXAO + 1;

    // Refazendo a conexão a cada 10 minutos
    // Como cada loop é a cada segundo, então 600 segundos são 10 minutos
    // como há o tempo de validações e etc, esse tempo de 10 minutos é aproximado
    if (NECESSARIO_RECONECTAR_DB) or (QTD_INTEGRACOES_MESMA_CONEXAO >= 600) then
    begin

      ODACSessionGlobal.Connected := False;
      ODACSessionGlobal.Close;

      try
        begin

          abrirConexaoODAC();
          AtribuiSessionDmd(dmdb, ODACSessionGlobal);

          NECESSARIO_RECONECTAR_DB := False;
        end;
      except
        on E: Exception do
        begin

          memo.Lines.Add(DateTimeToStr(Now()) + ': Erro ao conectar ao banco de dados: ' + E.Message);
          EXECUTANDO := False;
          NECESSARIO_RECONECTAR_DB := true;
          Exit;
        end;
      end;

      QTD_INTEGRACOES_MESMA_CONEXAO := 0;
      CONFIGURACAO_OBTIDA := False;
    end;

    EXECUTANDO := true;

    if not CONFIGURACAO_OBTIDA then
    begin

      CONFIG := TConfiguracoes.CarregarConfiguracoes('2');
      CONFIGURACAO_OBTIDA := true;
    end;

    try
      begin

        processo_atual := '';

        minutos_ult_checagem_cancelamento := MinutesBetween(Now, ULT_CHECAGEM_CANCELAMENTO);

        if minutos_ult_checagem_cancelamento >= CONFIG.minutos_os_reservada_262 then
        begin

          CancelarSolicitacoesAbandonadas('2', CONFIG);
          ULT_CHECAGEM_CANCELAMENTO := Now;
        end;

        AtenderSolicitacoes('2', CONFIG, chkRegistrarLogs.Checked);

      end;
    except
      on E: Exception do
      begin

        memo.Lines.Add(DateTimeToStr(Now()) + ': Erro ' + E.Message + ' >> Processo do erro: ' + processo_atual);

        EXECUTANDO := False;
        NECESSARIO_RECONECTAR_DB := true;
        Exit;
      end;
    end;

    EXECUTANDO := False;
  end;

  if memo.Lines.Count >= 1000 then
  begin

    logs := 0;
    memo.Lines.Clear;
  end;

  if dmdb.cdsOSsAtribuidas.RecordCount >= 1000 then
  begin

    dmdb.cdsOSsAtribuidas.EmptyDataSet;
  end;

  SEGUNDOS_PARA_CANCELAMENTO := SEGUNDOS_PARA_CANCELAMENTO + 1;

end;

procedure TFrmInicial.FormCreate(Sender: TObject);
begin

  HABILITADO := False;
  dmdb.cdsOSsAtribuidas.CreateDataSet;
end;

procedure TFrmInicial.FormShow(Sender: TObject);
var
  dia, mes, ano: word;
  data_limite: TDateTime;
begin

//  dia := 21;
//  mes := 3;
//  ano := 2025;
//
//  data_limite := EncodeDateTime(ano, mes, dia, 0, 0, 0, 0);
//
//  if Date > data_limite then
//  begin
//
//    MsgAtencao('Versão de homologação expirada no dia 21/03/2025'  + #13 + 'A rotina será encerrada');
//    Close;
//  end
//  else
//  begin
//
//    MsgInformacao('Versão de homologação válida até 21/03/2025');
//  end;

  CONFIGURACAO_OBTIDA := False;
  NECESSARIO_RECONECTAR_DB := False;
  pgcPrincipal.ActivePage := tabRobo;
  Self.Caption := ParamStr(5) + ' - Busca O.S. movimentação - versão: ' + Retorna_Versao();
  Application.Title := ParamStr(5) + ' - Busca O.S. movimentação';

  ULT_CHECAGEM_CANCELAMENTO := IncDay(Now, -1);
end;

procedure TFrmInicial.grdOSAtrbuidasDBTableView1DblClick(Sender: TObject);
begin

  ExibirAnalise();
end;

procedure TFrmInicial.timerTimer(Sender: TObject);
begin

  try
    begin

      executarProcessamento();
    end;
  except
    on E: Exception do
    begin
      memo.Lines.Add(DateTimeToStr(Now()) + ': Erro ' + E.Message + ' >> Processo do erro: ' + processo_atual);

      EXECUTANDO := False;
      NECESSARIO_RECONECTAR_DB := true;
      Exit;

    end;
  end;

end;

end.
