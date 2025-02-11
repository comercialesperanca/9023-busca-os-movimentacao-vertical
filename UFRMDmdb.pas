unit UFRMDmdb;

interface

uses
  SysUtils, Classes, DB, Ora, OraSmart, MemDS, OraError, DBClient, DBAccess, OraCall, MidasLib;

type
  Tdmdb = class(TDataModule)
    qryCancelarSolicitacoesAbandonadas: TOraQuery;
    qryOSEmExecucao: TOraQuery;
    qryCancelarSenha: TOraQuery;
    qryRegistrarRetorno: TOraQuery;
    qryCarregarSolicitacoes: TOraQuery;
    qryDadosSenhaAnterior: TOraQuery;
    qryRuasExcessoFuncionariosEmp: TOraQuery;
    qryRuasExcecao: TOraQuery;
    qryAbastecimentoSuperLotacao: TOraQuery;
    qryAtenderSolicitacao: TOraQuery;
    qryAuxiliar: TOraQuery;
    qryRuasExcessoOS: TOraQuery;
    qrySolicitacoesAbandonadas: TOraQuery;
    cdsOSsAtribuidas: TClientDataSet;
    dsrOSsAtribuidas: TDataSource;
    cdsOSsAtribuidasDATA: TDateTimeField;
    cdsOSsAtribuidasMATRICULA: TFloatField;
    cdsOSsAtribuidasNUMOS: TFloatField;
    cdsOSsAtribuidasCODENDERECO: TFloatField;
    cdsOSsAtribuidasCODENDERECOORIG: TFloatField;
    cdsOSsAtribuidasCODIGOUMA: TFloatField;
    cdsOSsAtribuidasTIPOOS: TFloatField;
    cdsOSsAtribuidasCRITERIO: TFloatField;
    cdsOSsAtribuidasARMAZEMTODO: TFloatField;
    cdsOSsAtribuidasSUPERLOTADA: TFloatField;
    cdsOSsAtribuidasTOTALOSRUA: TFloatField;
    cdsOSsAtribuidasTOTALFUNCRUA: TFloatField;
    cdsOSsAtribuidasRUA: TFloatField;
    qryTotalOSRuas: TOraQuery;
    qryTotalFuncRuas: TOraQuery;
    cdsOSsAtribuidasTIPOOSANTERIOR: TFloatField;
    cdsOSsAtribuidasDTSOLICITACAOANTERIOR: TDateTimeField;
    cdsOSsAtribuidasDTSOLICITACAO: TDateTimeField;
    cdsOSsAtribuidasRUAANTERIOR: TFloatField;
    cdsOSsAtribuidasTOTALOSRUAANTERIOR: TFloatField;
    cdsOSsAtribuidasTOTALFUNCRUAANTERIOR: TFloatField;
    cdsOSsAtribuidasSENHA: TFloatField;
    cdsOSsAtribuidasSENHAANTERIOR: TFloatField;
    qryRuasExcessoFuncionariosPalet: TOraQuery;
    cdsOSsAtribuidasTIPOOPERADOR: TStringField;
    cdsOSsAtribuidasRUAINICIAL: TFloatField;
    cdsOSsAtribuidasRUAFINAL: TFloatField;
    cdsOSsAtribuidasRANGERUASEXCECAO: TStringField;
    cdsOSsAtribuidasANALISE: TMemoField;
    cdsOSsAtribuidasSEGUNDOSLOCALIZACAOOS: TFloatField;
    qryOSsMesmoEnderecoOrigem: TOraQuery;
    qryGravarBOFILAOSR: TOraQuery;
    qryClonarOS: TOraQuery;
    qryCarregarSolicitacoesSENHA: TFloatField;
    qryCarregarSolicitacoesMATRICULA: TIntegerField;
    qryCarregarSolicitacoesRUARANGEINICIO: TIntegerField;
    qryCarregarSolicitacoesRUARANGEFIM: TIntegerField;
    qryCarregarSolicitacoesDTSOLICITACAO: TDateTimeField;
    qryCarregarSolicitacoesTIPOOPERADOR: TFloatField;
    qryOSEmExecucaoNUMOS: TFloatField;
    qryOSEmExecucaoSENHA: TFloatField;
    qryOSEmExecucaoCODENDERECO: TFloatField;
    qryOSEmExecucaoCODENDERECOORIG: TFloatField;
    qryOSEmExecucaoCODIGOUMA: TFloatField;
    qryOSEmExecucaoTIPOOS: TFloatField;
    qryOSEmExecucaoFLAGSL: TFloatField;
    qryDadosSenhaAnteriorFLAGSL: TStringField;
    qryDadosSenhaAnteriorRUA: TFloatField;
    qryDadosSenhaAnteriorNRONDA: TFloatField;
    qryDadosSenhaAnteriorTIPOOS: TFloatField;
    qryDadosSenhaAnteriorDTSOLICITACAO: TDateTimeField;
    qryDadosSenhaAnteriorSENHA: TFloatField;
    qryDadosSenhaAnteriorDTONDA: TDateTimeField;
    qryRuasExcecaoRUA: TStringField;
    qryRuasExcessoOSRUA: TIntegerField;
    qryRuasExcessoFuncionariosEmpRUA: TIntegerField;
    qryRuasExcessoFuncionariosPaletRUA: TIntegerField;
    qryAbastecimentoSuperLotacaoNUMOS: TFloatField;
    qryAbastecimentoSuperLotacaoTOTALRUA: TFloatField;
    qryAbastecimentoSuperLotacaoCODENDERECO: TFloatField;
    qryTotalFuncRuasRUA: TIntegerField;
    qryTotalFuncRuasTOTAL: TFloatField;
    qryTotalOSRuasRUA: TIntegerField;
    qryTotalOSRuasTOTAL: TFloatField;
    qryOSsMesmoEnderecoOrigemNUMOS: TFloatField;
    qryConfiguracoes: TOraQuery;
    qryConfiguracoesCODIGO: TFloatField;
    qryConfiguracoesVALOR: TStringField;
    dsrAuxiliar: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmdb: Tdmdb;

implementation

{$R *.dfm}

end.
