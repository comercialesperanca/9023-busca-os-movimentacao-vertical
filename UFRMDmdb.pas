unit UFRMDmdb;

interface

uses
  SysUtils, Classes, DB, DBTables, DBClient;

type
  Tdmdb = class(TDataModule)
    qryCancelarSolicitacoesAbandonadas: TQuery;
    qryOSEmExecucao: TQuery;
    qryOSEmExecucaoNUMOS: TFloatField;
    qryOSEmExecucaoSENHA: TFloatField;
    qryCancelarSenha: TQuery;
    qryRegistrarRetorno: TQuery;
    qryCarregarSolicitacoes: TQuery;
    qryCarregarSolicitacoesSENHA: TFloatField;
    qryCarregarSolicitacoesMATRICULA: TFloatField;
    qryCarregarSolicitacoesRUARANGEINICIO: TFloatField;
    qryCarregarSolicitacoesRUARANGEFIM: TFloatField;
    qryDadosSenhaAnterior: TQuery;
    qryRuasExcessoFuncionariosEmp: TQuery;
    qryRuasExcessoFuncionariosEmpRUA: TFloatField;
    qryRuasExcecao: TQuery;
    qryRuasExcecaoRUA: TStringField;
    qryAbastecimentoSuperLotacao: TQuery;
    qryAbastecimentoSuperLotacaoNUMOS: TFloatField;
    qryAbastecimentoSuperLotacaoTOTALRUA: TFloatField;
    qryAbastecimentoSuperLotacaoCODENDERECO: TFloatField;
    qryDadosSenhaAnteriorFLAGSL: TStringField;
    qryDadosSenhaAnteriorRUA: TFloatField;
    qryAbastecimentoSuperLotacaoCODIGOUMA: TFloatField;
    qryAtenderSolicitacao: TQuery;
    qryAuxiliar: TQuery;
    qryDadosSenhaAnteriorNRONDA: TFloatField;
    qryRuasExcessoOS: TQuery;
    qryRuasExcessoOSRUA: TFloatField;
    qrySolicitacoesAbandonadas: TQuery;
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
    qryOSEmExecucaoCODENDERECO: TFloatField;
    qryOSEmExecucaoCODENDERECOORIG: TFloatField;
    qryOSEmExecucaoCODIGOUMA: TFloatField;
    qryOSEmExecucaoTIPOOS: TFloatField;
    qryOSEmExecucaoFLAGSL: TFloatField;
    cdsOSsAtribuidasTOTALOSRUA: TFloatField;
    cdsOSsAtribuidasTOTALFUNCRUA: TFloatField;
    cdsOSsAtribuidasRUA: TFloatField;
    qryTotalOSRuas: TQuery;
    qryTotalOSRuasRUA: TFloatField;
    qryTotalOSRuasTOTAL: TFloatField;
    qryTotalFuncRuas: TQuery;
    qryTotalFuncRuasRUA: TFloatField;
    qryTotalFuncRuasTOTAL: TFloatField;
    qryDadosSenhaAnteriorTIPOOS: TFloatField;
    qryDadosSenhaAnteriorDTSOLICITACAO: TDateTimeField;
    cdsOSsAtribuidasTIPOOSANTERIOR: TFloatField;
    cdsOSsAtribuidasDTSOLICITACAOANTERIOR: TDateTimeField;
    cdsOSsAtribuidasDTSOLICITACAO: TDateTimeField;
    cdsOSsAtribuidasRUAANTERIOR: TFloatField;
    cdsOSsAtribuidasTOTALOSRUAANTERIOR: TFloatField;
    cdsOSsAtribuidasTOTALFUNCRUAANTERIOR: TFloatField;
    qryCarregarSolicitacoesDTSOLICITACAO: TDateTimeField;
    cdsOSsAtribuidasSENHA: TFloatField;
    cdsOSsAtribuidasSENHAANTERIOR: TFloatField;
    qryDadosSenhaAnteriorSENHA: TFloatField;
    qryCarregarSolicitacoesTIPOOPERADOR: TFloatField;
    qryRuasExcessoFuncionariosPalet: TQuery;
    qryRuasExcessoFuncionariosPaletRUA: TFloatField;
    cdsOSsAtribuidasTIPOOPERADOR: TStringField;
    cdsOSsAtribuidasRUAINICIAL: TFloatField;
    cdsOSsAtribuidasRUAFINAL: TFloatField;
    cdsOSsAtribuidasRANGERUASEXCECAO: TStringField;
    cdsOSsAtribuidasANALISE: TMemoField;
    cdsOSsAtribuidasSEGUNDOSLOCALIZACAOOS: TFloatField;
    qryDadosSenhaAnteriorDTONDA: TDateTimeField;
    qryOSsMesmoEnderecoOrigem: TQuery;
    qryOSsMesmoEnderecoOrigemNUMOS: TFloatField;
    qryGravarBOFILAOSR: TQuery;
    qryClonarOS: TQuery;
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
