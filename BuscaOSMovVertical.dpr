program BuscaOSMovVertical;

uses
  Forms,
  UVariaveiseFuncoes in 'UVariaveiseFuncoes.pas',
  UFRMDmdb in 'UFRMDmdb.pas' {dmdb: TDataModule},
  UHistoricoAlteracoes in 'UHistoricoAlteracoes.pas',
  uFrmInicial in 'uFrmInicial.pas' {FrmInicial},
  uProximaOS in '..\LIBS\ConvocacaoAtiva\uProximaOS.pas',
  uConvocacaoAtivaEnums in '..\LIBS\ConvocacaoAtiva\uConvocacaoAtivaEnums.pas',
  uFrmAnalisesAtribuicao in 'uFrmAnalisesAtribuicao.pas' {frmAnalisesatribuicao},
  ULibrary in '..\LIBSODAC\ULibrary.pas',
  uQueryBuilder in 'uQueryBuilder.pas',
  uFrmSimulacao in 'uFrmSimulacao.pas' {FrmSimulacao},
  UMensagens in '..\LIBS\UMensagens.pas',
  uFrmExplicacaoRuasIgnorar in 'uFrmExplicacaoRuasIgnorar.pas' {FrmExplicacaoRuasIgnorar},
  uFrmExplicacaoRuasExcessoOS in 'uFrmExplicacaoRuasExcessoOS.pas' {FrmExplicacaoRuasExcessoOS};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tdmdb, dmdb);
  Application.CreateForm(TFrmInicial, FrmInicial);
  Application.CreateForm(TfrmAnalisesatribuicao, frmAnalisesatribuicao);
  abrirConexaoODAC();
  AtribuiSessionDmd(dmdb, ODACSessionGlobal);
  Application.Run;

end.
