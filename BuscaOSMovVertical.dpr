program BuscaOSMovVertical;

uses
  Forms,
  UVariaveiseFuncoes in 'UVariaveiseFuncoes.pas',
  UFRMDmdb in 'UFRMDmdb.pas' {dmdb: TDataModule},
  ULibrary in '..\LIBS\ULibrary.pas',
  UHistoricoAlteracoes in 'UHistoricoAlteracoes.pas',
  uFrmInicial in 'uFrmInicial.pas' {FrmInicial},
  uProximaOS in '..\LIBS\ConvocacaoAtiva\uProximaOS.pas',
  uConvocacaoAtivaEnums in '..\LIBS\ConvocacaoAtiva\uConvocacaoAtivaEnums.pas',
  uFrmAnalisesAtribuicao in 'uFrmAnalisesAtribuicao.pas' {frmAnalisesatribuicao};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tdmdb, dmdb);
  Application.CreateForm(TFrmInicial, FrmInicial);
  Application.CreateForm(TfrmAnalisesatribuicao, frmAnalisesatribuicao);
  abrirConexaoBDE();
  Application.Run;
end.
