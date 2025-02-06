unit UVariaveiseFuncoes;

interface

Uses
  Graphics, IniFiles, Variants, SysUtils, Classes, StrUtils, DateUtils, Windows, Forms, uProximaOS, uConvocacaoAtivaEnums
  // , Clipbrd
    ;

type
  TConfiguracoes = class
  public
    ruas_excecao_248: TStringList;
    qtd_os_rua_lotada_249: integer;
    qtd_limite_paleteiros_rua_251: integer;
    qtd_limite_empilhadores_rua_252: integer;
    minutos_os_reservada_262: integer;
    percentual_separacao_liberar_palletbox_263: integer;
    trabalha_com_palletbox_264: boolean;

    class function CarregarConfiguracoes(aFilial: string): TConfiguracoes;

    constructor Create();

  end;

procedure CancelarSolicitacoesAbandonadas(aFilial: string; aConfig: TConfiguracoes);
procedure AtenderSolicitacoes(aFilial: string; aConfig: TConfiguracoes; aRegistrarAnalise: boolean);
function SenhaEmExecucao(aMatricula: double; aTipoOperador: TTipoOperador): double;
procedure RegistrarRetorno(aSenhaAtual: double; aSenhaAnterior: double);
function RangeInformadoEDeExecao(aFilial: string; aRuaInicial, aRuaFinal: double; aConfig: TConfiguracoes): boolean;
procedure Log(aMensagem: string);
procedure ExibirAnalise();
function ExisteOSsMesmoEnderecoOrigemEDestino(aNumeroOS: double; aCodigoEnderecoOrigem, aCodigoEndereco: double; aTipoOS: double; aFilial: string;
  aForcarUsoDeOnda: boolean): boolean;
function GravarOSsAbastecimentoConsolidado(aSenha: double; aCodigoEnderecoOrigem, aCodigoEndereco: double; aTipoOS: double; aFilial: string;
  aForcarUsoDeOnda: boolean): boolean;

Var
  min, seg, fator, contador, contador2: integer;
  segundos: integer;
  segundos_padrao: integer;
  filial_padrao: string;
  processo_atual: string;
  logs: double;

implementation

uses UFRMDmdb, ULibrary, DB, DBAccess, Ora, OraSmart, MemDS, OraError, uFrmInicial,
  uFrmAnalisesAtribuicao, uQueryBuilder;

procedure Log(aMensagem: string);
begin

  if not FrmInicial.chkExibirMensagensLog.Checked then
  begin

    Exit;
  end;

  logs := logs + 1;
  processo_atual := aMensagem;
  // FrmInicial.memo.Lines.Add( IntToStr(FrmInicial.memo.Lines.Count + 1) + ') ' + DateTimeToStr(Now) + ': ' + aMensagem);
  FrmInicial.memo.Lines.Add(FloatToStr(logs) + ') ' + DateTimeToStr(Now) + ': ' + aMensagem);
  // Application.ProcessMessages;
end;

procedure CancelarSolicitacoesAbandonadas(aFilial: string; aConfig: TConfiguracoes);
var

  minutos_tolerancia: double;
begin

  Log('Cancelando solicitações abandonadas');

  minutos_tolerancia := (aConfig.minutos_os_reservada_262 * -1);

  dmdb.qrySolicitacoesAbandonadas.Close;
  dmdb.qrySolicitacoesAbandonadas.ParamByName('DTLIMITE').AsDateTime := IncMinute(Now, Trunc(minutos_tolerancia));
  dmdb.qrySolicitacoesAbandonadas.Open();

  if dmdb.qrySolicitacoesAbandonadas.RecordCount = 0 then
  begin

    Log('Nada para cancelar');
    dmdb.qrySolicitacoesAbandonadas.Close;
    Exit;
  end;

  try
    begin

      dmdb.qryCancelarSolicitacoesAbandonadas.Close;
      dmdb.qryCancelarSolicitacoesAbandonadas.ParamByName('DTLIMITE').AsDateTime := IncMinute(Now, Trunc(minutos_tolerancia));
      dmdb.qryCancelarSolicitacoesAbandonadas.ExecSQL;

      Log(IntToStr(dmdb.qryCancelarSolicitacoesAbandonadas.RowsAffected) + ' solictações canceladas');

      dmdb.qryCancelarSolicitacoesAbandonadas.Close;

    end;
  except
    on E: Exception do
    begin

      Log('Erro: ' + E.Message);
      Log('Processo: ' + processo_atual);
    end;
  end;

end;

procedure CriarSQLQueryMesmoEnderecoOS(aForcarUsoDeOnda: boolean);
begin

  with dmdb.qryOSsMesmoEnderecoOrigem do
  begin

    Close;
    SQL.Clear;
    SQL.Add(' SELECT   pcmovendpend.NUMOS                                                    ');
    SQL.Add(' FROM     pcmovendpend                                                          ');

    if aForcarUsoDeOnda then
    begin

      SQL.Add(' join bodefineondai ON bodefineondai.numtranswms = pcmovendpend.numtranswms ');
      // SQL.Add('     AND bodefineondai.numcar = pcmovendpend.numcar ');
    end;

    SQL.Add(' WHERE    pcmovendpend.posicao = ''P''                                          ');
    SQL.Add(' AND      pcmovendpend.codfilial = :CODFILIAL                                   ');
    SQL.Add(' AND      pcmovendpend.dtestorno IS NULL                                        ');
    SQL.Add(' AND      pcmovendpend.tipoos = :TIPOOS                                         ');
    SQL.Add(' AND      pcmovendpend.codfuncos IS NULL                                        ');
    SQL.Add(' AND      pcmovendpend.numos <> :NUMOS                                          ');
    SQL.Add(' AND      NOT EXISTS (                                                          ');
    SQL.Add('                 SELECT bofilaos.numos                                          ');
    SQL.Add('                 FROM   bofilaos                                                ');
    SQL.Add('                 WHERE  bofilaos.numos = pcmovendpend.numos                     ');
    SQL.Add('                 AND    bofilaos.status IN (''E'', ''R''))                      ');
    SQL.Add(' AND      NOT EXISTS (                                                          ');
    SQL.Add('                 SELECT bofilaosr.numos                                         ');
    SQL.Add('                 FROM   bofilaosr                                               ');
    SQL.Add('                 join   bofilaos ON bofilaosr.senha = bofilaos.senha            ');
    SQL.Add('                 WHERE  bofilaosr.numos = pcmovendpend.numos                    ');
    SQL.Add('                 AND    bofilaos.status IN (''E'', ''R''))                      ');
    SQL.Add('                                                                                ');
    SQL.Add(' AND      NOT EXISTS (                                                          ');
    SQL.Add('                 SELECT booscompendencia.numos                                  ');
    SQL.Add('                 FROM booscompendencia                                          ');
    SQL.Add('                 WHERE booscompendencia.numos = pcmovendpend.numos              ');
    SQL.Add('                 AND booscompendencia.dataliberacao is null                     ');
    SQL.Add('                 )                                                              ');
    SQL.Add('                                                                                ');
    SQL.Add(' AND      pcmovendpend.codenderecoorig = :CODENDERECOORIG                       ');
    SQL.Add(' AND      pcmovendpend.codendereco = :CODENDERECO                               ');
    SQL.Add(' AND      NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                    ');
  end;

end;

function ExisteOSsMesmoEnderecoOrigemEDestino(aNumeroOS: double; aCodigoEnderecoOrigem, aCodigoEndereco: double; aTipoOS: double; aFilial: string;
  aForcarUsoDeOnda: boolean): boolean;
begin
  {
    Retorna se existem outras OS's pendentes do mesmo tipo e endereço de origem da OS informada.
    A informação será usada para o processo conhecido como Abastecimento Consolidado
  }

  with dmdb.qryOSsMesmoEnderecoOrigem do
  begin

    CriarSQLQueryMesmoEnderecoOS(aForcarUsoDeOnda);

    ParamByName('CODFILIAL').AsString := aFilial;
    ParamByName('TIPOOS').AsFloat := aTipoOS;
    ParamByName('NUMOS').AsFloat := aNumeroOS;
    ParamByName('CODENDERECOORIG').AsFloat := aCodigoEnderecoOrigem;
    ParamByName('CODENDERECO').AsFloat := aCodigoEndereco;

    Open();

  end;


  // dmdb.qryOSsMesmoEnderecoOrigem.Close;
  // dmdb.qryOSsMesmoEnderecoOrigem.ParamByName('CODFILIAL').AsString := aFilial;
  // dmdb.qryOSsMesmoEnderecoOrigem.ParamByName('TIPOOS').AsFloat := aTipoOS;
  // dmdb.qryOSsMesmoEnderecoOrigem.ParamByName('NUMOS').AsFloat := aNumeroOS;
  // dmdb.qryOSsMesmoEnderecoOrigem.ParamByName('CODENDERECOORIG').AsFloat := aCodigoEnderecoOrigem;
  // dmdb.qryOSsMesmoEnderecoOrigem.ParamByName('CODENDERECO').AsFloat := aCodigoEndereco;
  // dmdb.qryOSsMesmoEnderecoOrigem.Open;

  Result := (dmdb.qryOSsMesmoEnderecoOrigem.RecordCount > 0);
end;

function GravarOSsAbastecimentoConsolidado(aSenha: double; aCodigoEnderecoOrigem, aCodigoEndereco: double; aTipoOS: double; aFilial: string;
  aForcarUsoDeOnda: boolean): boolean;
begin
  {
    Responsável por gravar dados na tabela BOFILAOSR, para permitir o processo
    conhecido como Abastecimento Consolidado
  }

  Result := False;


  // dmdb.qryOSsMesmoEnderecoOrigem.Close;

  CriarSQLQueryMesmoEnderecoOS(aForcarUsoDeOnda);

  dmdb.qryOSsMesmoEnderecoOrigem.ParamByName('CODFILIAL').AsString := aFilial;
  dmdb.qryOSsMesmoEnderecoOrigem.ParamByName('TIPOOS').AsFloat := aTipoOS;
  dmdb.qryOSsMesmoEnderecoOrigem.ParamByName('NUMOS').AsFloat := 0;
  dmdb.qryOSsMesmoEnderecoOrigem.ParamByName('CODENDERECOORIG').AsFloat := aCodigoEnderecoOrigem;
  dmdb.qryOSsMesmoEnderecoOrigem.ParamByName('CODENDERECO').AsFloat := aCodigoEndereco;

  dmdb.qryOSsMesmoEnderecoOrigem.Open;

  if dmdb.qryOSsMesmoEnderecoOrigem.RecordCount = 0 then
  begin

    Exit;
  end;

  dmdb.qryOSsMesmoEnderecoOrigem.First;

  while (not dmdb.qryOSsMesmoEnderecoOrigem.Eof) do
  begin

    dmdb.qryGravarBOFILAOSR.Close;
    dmdb.qryGravarBOFILAOSR.ParamByName('SENHA').AsFloat := aSenha;
    dmdb.qryGravarBOFILAOSR.ParamByName('NUMOS').AsFloat := dmdb.qryOSsMesmoEnderecoOrigemNUMOS.AsFloat;
    dmdb.qryGravarBOFILAOSR.ExecSQL;

    dmdb.qryOSsMesmoEnderecoOrigem.Next;
  end;

  Result := True;
end;

function RuasExcluidas(aFiltro: TFiltro; aConfig: TConfiguracoes): TStringList;
var
  ruas_excluidas: TStringList;
  maximo_funcionarios_na_rua: double;
  qry: TOraQuery;
begin
  {
    Retorna a lista de ruas que devem ser ignoradas na busca de OS
    1 - Obtém a lista de ruas que já estão com funcionários demais no range informado
    2 - Adiciona na lista as ruas de exceção caso o usuário não específique um range de exceção válido
  }

  ruas_excluidas := TStringList.Create;
  ruas_excluidas.Duplicates := dupIgnore;

  maximo_funcionarios_na_rua := 1000;

  qry := dmdb.qryRuasExcessoFuncionariosEmp;

  if (aFiltro.TipoOperador = tpPaleteiro) then
  begin

    qry := dmdb.qryRuasExcessoFuncionariosPalet;
    maximo_funcionarios_na_rua := aConfig.qtd_limite_paleteiros_rua_251;
  end;

  if (aFiltro.TipoOperador = tpEmpilhador) then
  begin

    maximo_funcionarios_na_rua := aConfig.qtd_limite_empilhadores_rua_252;
  end;

  /// Listando as ruas que já tem gente demais

  qry.Close;
  qry.ParamByName('MAXIMOPORRUA').AsFloat := maximo_funcionarios_na_rua;
  qry.ParamByName('MATRICULA').AsFloat := aFiltro.Matricula;
  qry.Open;

  if (qry.RecordCount > 0) then
  begin

    qry.First;

    while (not qry.Eof) do
    begin

      ruas_excluidas.Add(qry.FieldByName('RUA').AsString);
      qry.Next;
    end;
  end;

  qry.Close;

  /// Se não foi informado um range exclusivo de ruas de exceção, as ruas
  /// de exceção também vão para a lista de ruas para serem ignoradas

  if (not aFiltro.RangeRuasExcecao) then
  begin

    dmdb.qryRuasExcecao.Close;
    dmdb.qryRuasExcecao.ParamByName('CODFILIAL').AsString := aFiltro.Filial;
    dmdb.qryRuasExcecao.Open;

    if (dmdb.qryRuasExcecao.RecordCount > 0) then
    begin

      dmdb.qryRuasExcecao.First;

      while (not dmdb.qryRuasExcecao.Eof) do
      begin

        ruas_excluidas.Add(dmdb.qryRuasExcecaoRUA.AsString);
        dmdb.qryRuasExcecao.Next;
      end;
    end;

    dmdb.qryRuasExcecao.Close;
  end;

  // Existem casos que o usuário informou apenas uma parte do range
  // de exceção, não podemos permitir o range parametrizado inteiro
  // apenas da faixa que o usuário informou
  if aFiltro.RangeRuasExcecao then
  begin

    dmdb.qryRuasExcecao.Close;
    dmdb.qryRuasExcecao.ParamByName('CODFILIAL').AsString := aFiltro.Filial;
    dmdb.qryRuasExcecao.Open;

    if (dmdb.qryRuasExcecao.RecordCount > 0) then
    begin

      dmdb.qryRuasExcecao.First;

      while (not dmdb.qryRuasExcecao.Eof) do
      begin

        if (dmdb.qryRuasExcecaoRUA.AsFloat < aFiltro.RuaInicial) or (dmdb.qryRuasExcecaoRUA.AsFloat > aFiltro.RuaFinal) then
        begin

          ruas_excluidas.Add(dmdb.qryRuasExcecaoRUA.AsString);
        end;

        dmdb.qryRuasExcecao.Next;
      end;
    end;

    dmdb.qryRuasExcecao.Close;
  end;

  Result := ruas_excluidas;
end;

function Criterio5_ProximaOSAbastecimentoNaRua(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tempo: TDateTime;
  qb: TQueryBuilder;
begin

  // Critério 5

  Result := False;
  tempo := Now;

  // Somente para empilhadores
  if aFiltro.TipoOperador <> tpEmpilhador then
  begin

    Exit;
  end;

  qb := TQueryBuilder.Create;

  with dmdb.qryAuxiliar do
  begin

    Close;
    SQL.Clear;
    SQL.Add(qb.GetQuery(5, aFiltro));

    ParamByName('CODFILIAL').AsString := aFiltro.Filial;
    ParamByName('RUAINICIAL').AsFloat := aFiltro.RuaInicial;
    ParamByName('RUAFINAL').AsFloat := aFiltro.RuaFinal;
    ParamByName('RUA').AsFloat := aFiltro.RuaAnterior;

    Open;

    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
    aProximaOS.RegistrarAnaliseCriterios('Critério 5' + IfThen(aProximaOS.ArmazemTodo, ' - Armazém Todo', ''));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('Segundos para resposta da consulta: ' + IntToStr(SecondsBetween(tempo, Now)));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('CODFILIAL: ' + aFiltro.Filial);
    aProximaOS.RegistrarAnaliseCriterios('RUAINICIAL: ' + FloatToStr(aFiltro.RuaInicial));
    aProximaOS.RegistrarAnaliseCriterios('RUAFINAL: ' + FloatToStr(aFiltro.RuaFinal));
    aProximaOS.RegistrarAnaliseCriterios('RUA: ' + FloatToStr(aFiltro.RuaAnterior));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('SQL:');
    aProximaOS.RegistrarAnaliseCriterios(SQL.Text);

    if (dmdb.qryAuxiliar.RecordCount > 0) then
    begin

      aProximaOS.NumeroOS := FieldByName('NUMOS').AsFloat;
      aProximaOS.CodigoEndereco := FieldByName('CODENDERECO').AsFloat;
      aProximaOS.CodigoEnderecoOrigem := FieldByName('CODENDERECOORIG').AsFloat;
      aProximaOS.NumeroUMA := FieldByName('CODIGOUMA').AsFloat;
      aProximaOS.TipoOS := FieldByName('TIPOOS').AsFloat;
      aProximaOS.Rua := FieldByName('RUA').AsFloat;
      aProximaOS.TipoServico := 'SL';
      aProximaOS.CriterioUtilizado := 5;

      Result := True;
    end;

    Close;
  end;
end;

function Criterio10_ProximaOSAbastecimento(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tempo: TDateTime;
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := aFiltro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := aFiltro.ruasSuperLotadas.DelimitedText;

  // Critério 10

  Result := False;
  tempo := Now;

  // Somente para empilhadores
  if aFiltro.TipoOperador <> tpEmpilhador then
  begin

    Exit;
  end;

  with dmdb.qryAuxiliar do
  begin

    Close;
    SQL.Clear;
    SQL.Add(' select                                                                               ');
    SQL.Add('   numos,                                                                             ');
    SQL.Add('   rua,                                                                               ');
    SQL.Add('   codendereco,                                                                       ');
    SQL.Add('   codigouma,                                                                         ');
    SQL.Add('   codenderecoorig,                                                                   ');
    SQL.Add('   tipoos                                                                             ');
    SQL.Add(' from (                                                                               ');
    SQL.Add(' Select pcmovendpend.numos                                                            ');
    SQL.Add('        , nvl(pcest.qtestger -                                                        ');
    SQL.Add(' 			pcest.qtreserv -                                                               ');
    SQL.Add(' 			pcest.qtbloqueada -                                                            ');
    SQL.Add(' 			pcest.qtpendente,0) estoque                                                    ');
    SQL.Add('        , pcest.qtgirodia                                                             ');
    SQL.Add('        , pcmovendpend.data                                                           ');
    SQL.Add('        , count(pcmovendpend.numos) over (partition by pcendereco.rua ) as totalrua   ');
    SQL.Add('        , pcmovendpend.codendereco                                                    ');
    SQL.Add('        , pcmovendpend.codigouma                                                      ');
    SQL.Add('        , pcmovendpend.codenderecoorig                                                ');
    SQL.Add('        , pcendereco.rua                                                              ');
    SQL.Add('        , pcmovendpend.tipoos                                                         ');
    SQL.Add(' from pcmovendpend                                                                    ');
    SQL.Add(' join pcendereco on pcendereco.codendereco = pcmovendpend.codendereco                 ');
    SQL.Add(' join pcmovendpend mep97 on pcmovendpend.codigouma = mep97.codigouma                  ');
    SQL.Add('                             and mep97.tipoos = 97                                    ');
    SQL.Add('                             and mep97.numtranswms = pcmovendpend.numtranswms         ');
    SQL.Add('                             and mep97.dtfimos is not null                            ');
    SQL.Add(' join pcest on pcest.codfilial = pcmovendpend.codfilial                               ');
    SQL.Add('           and pcest.codprod = pcmovendpend.codprod                                   ');
    SQL.Add(' where pcmovendpend.data > sysdate - 30                                               ');
    SQL.Add('     and pcmovendpend.codfilial = :CODFILIAL                                          ');
    SQL.Add('     and pcmovendpend.posicao = ''P''                                                 ');
    SQL.Add('     and pcmovendpend.dtestorno is null                                               ');
    SQL.Add('     and pcmovendpend.tipoos = 98                                                     ');
    SQL.Add('     and pcmovendpend.codfuncos is null                                               ');
    SQL.Add('     and not exists (select bofilaos.numos                                            ');
    SQL.Add(' 					FROM bofilaos where bofilaos.numos = pcmovendpend.numos                    ');
    SQL.Add(' 					and bofilaos.status in (''E'',''R''))                               ');

    SQL.Add(' 		and not exists (select bofilaosR.numos                                ');
    SQL.Add(' 		                  FROM bofilaosR                                      ');
    SQL.Add(' 		                  join bofilaos                                       ');
    SQL.Add(' 		                    on bofilaosR.senha = bofilaos.senha               ');
    SQL.Add(' 		                  where bofilaosR.numos = pcmovendpend.numos          ');
    SQL.Add(' 		                  and bofilaos.status in (''E'',''R''))               ');

    SQL.Add(' and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                      ');
    SQL.Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                    ');

    if (aFiltro.ruasIgnorar.Count > 0) then
    begin

      SQL.Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
      SQL.Add(' and pcendereco.rua not in (' + aFiltro.ruasIgnorar.DelimitedText + ' )');
    end;

    SQL.Add(' and not exists (select pend.numos from booscompendencia pend ');
    SQL.Add('                 join pcmovendpend mep on mep.numos = pend.numos ');
    SQL.Add('                 where pend.dataliberacao is null ');
    SQL.Add('                 and mep.codprod = pcmovendpend.codprod ) ');

    SQL.Add(' order by pcmovendpend.data, estoque, pcest.qtgirodia desc )                          ');
    SQL.Add(' where rownum = 1                                                                     ');

    ParamByName('CODFILIAL').AsString := aFiltro.Filial;
    ParamByName('RUAINICIAL').AsFloat := aFiltro.RuaInicial;
    ParamByName('RUAFINAL').AsFloat := aFiltro.RuaFinal;

    Open;

    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
    aProximaOS.RegistrarAnaliseCriterios('Critério 10');
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('Segundos para resposta da consulta: ' + IntToStr(SecondsBetween(tempo, Now)));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('CODFILIAL: ' + aFiltro.Filial);
    aProximaOS.RegistrarAnaliseCriterios('RUAINICIAL: ' + FloatToStr(aFiltro.RuaInicial));
    aProximaOS.RegistrarAnaliseCriterios('RUAFINAL: ' + FloatToStr(aFiltro.RuaFinal));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('SQL:');
    aProximaOS.RegistrarAnaliseCriterios(SQL.Text);

    if (dmdb.qryAuxiliar.RecordCount > 0) then
    begin

      aProximaOS.NumeroOS := FieldByName('NUMOS').AsFloat;
      aProximaOS.CodigoEndereco := FieldByName('CODENDERECO').AsFloat;
      aProximaOS.CodigoEnderecoOrigem := FieldByName('CODENDERECOORIG').AsFloat;
      aProximaOS.NumeroUMA := FieldByName('CODIGOUMA').AsFloat;
      aProximaOS.TipoOS := FieldByName('TIPOOS').AsFloat;
      aProximaOS.Rua := FieldByName('RUA').AsFloat;
      aProximaOS.TipoServico := 'AC';
      aProximaOS.CriterioUtilizado := 10;

      Result := True;
    end;

    Close;
  end;
end;

function Criterio6_ProximaOSAbastecimentoQualquerRua(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tempo: TDateTime;
  qb : TQueryBuilder;
begin

  // Item 6

  Result := False;
  tempo := Now;

  // Somente para empilhadores
  if aFiltro.TipoOperador <> tpEmpilhador then
  begin

    Exit;
  end;

  if (aFiltro.ruasSuperLotadas.Count <= 0) then
  begin

    Exit;
  end;

  qb :=TQueryBuilder.Create();

  with dmdb.qryAuxiliar do
  begin

    Close;
    SQL.Clear;
    SQL.Add(qb.GetQuery(6, aFiltro));

    ParamByName('CODFILIAL').AsString := aFiltro.Filial;
    ParamByName('RUAINICIAL').AsFloat := aFiltro.RuaInicial;
    ParamByName('RUAFINAL').AsFloat := aFiltro.RuaFinal;
    ParamByName('RUAANTERIOR').AsFloat := aFiltro.RuaAnterior;

    Open;

    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
    aProximaOS.RegistrarAnaliseCriterios('Critério 6' + IfThen(aProximaOS.ArmazemTodo, ' - Armazém Todo', ''));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('CODFILIAL: ' + aFiltro.Filial);
    aProximaOS.RegistrarAnaliseCriterios('RUAINICIAL: ' + FloatToStr(aFiltro.RuaInicial));
    aProximaOS.RegistrarAnaliseCriterios('RUAFINAL: ' + FloatToStr(aFiltro.RuaFinal));
    aProximaOS.RegistrarAnaliseCriterios('RUAANTERIOR: ' + FloatToStr(aFiltro.RuaAnterior));
    aProximaOS.RegistrarAnaliseCriterios('Segundos para resposta da consulta: ' + IntToStr(SecondsBetween(tempo, Now)));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('SQL:');
    aProximaOS.RegistrarAnaliseCriterios(SQL.Text);

    if (dmdb.qryAuxiliar.RecordCount > 0) then
    begin

      aProximaOS.NumeroOS := FieldByName('NUMOS').AsFloat;
      aProximaOS.CodigoEndereco := FieldByName('CODENDERECO').AsFloat;
      aProximaOS.CodigoEnderecoOrigem := FieldByName('CODENDERECOORIG').AsFloat;
      aProximaOS.NumeroUMA := FieldByName('CODIGOUMA').AsFloat;
      aProximaOS.TipoOS := FieldByName('TIPOOS').AsFloat;
      aProximaOS.Rua := FieldByName('RUA').AsFloat;
      aProximaOS.TipoServico := 'SL';
      aProximaOS.CriterioUtilizado := 6;

      Result := True;
    end;

    Close;

  end;
end;

function Criterio7_ProximaOSPendenciaAbastecimentoCorretivo(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tipo_os: integer;
  tempo: TDateTime;
  qb : TQueryBuilder;
begin

  // Item 7

  Result := False;
  tempo := Now;

  qb := TQueryBuilder.Create;

  with dmdb.qryAuxiliar do
  begin

    Close;
    SQL.Clear;
    SQL.Add(qb.GetQuery(7, aFiltro));

    // Padrão tpEmpilhador
    tipo_os := 58;

    if aFiltro.TipoOperador = tpPaleteiro then
    begin

      tipo_os := 61;
    end;

    ParamByName('CODFILIAL').AsString := aFiltro.Filial;
    ParamByName('RUAINICIAL').AsFloat := aFiltro.RuaInicial;
    ParamByName('RUAFINAL').AsFloat := aFiltro.RuaFinal;
    ParamByName('TIPOOS').AsFloat := tipo_os;

    Open;

    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
    aProximaOS.RegistrarAnaliseCriterios('Critério 7' + IfThen(aProximaOS.ArmazemTodo, ' - Armazém Todo', ''));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('Segundos para resposta da consulta: ' + IntToStr(SecondsBetween(tempo, Now)));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('CODFILIAL: ' + aFiltro.Filial);
    aProximaOS.RegistrarAnaliseCriterios('RUAINICIAL: ' + FloatToStr(aFiltro.RuaInicial));
    aProximaOS.RegistrarAnaliseCriterios('RUAFINAL: ' + FloatToStr(aFiltro.RuaFinal));
    aProximaOS.RegistrarAnaliseCriterios('TIPOOS: ' + FloatToStr(tipo_os));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('SQL:');
    aProximaOS.RegistrarAnaliseCriterios(SQL.Text);

    if (dmdb.qryAuxiliar.RecordCount > 0) then
    begin

      aProximaOS.NumeroOS := FieldByName('NUMOS').AsFloat;
      aProximaOS.NumeroOnda := FieldByName('NUMONDA').AsFloat;
      aProximaOS.CodigoEndereco := FieldByName('CODENDERECO').AsFloat;
      aProximaOS.CodigoEnderecoOrigem := FieldByName('CODENDERECOORIG').AsFloat;
      aProximaOS.NumeroUMA := FieldByName('CODIGOUMA').AsFloat;
      aProximaOS.Rua := FieldByName('RUA').AsFloat;
      aProximaOS.TipoOS := FieldByName('TIPOOS').AsFloat;
      aProximaOS.TipoServico := 'SL';
      aProximaOS.CriterioUtilizado := 7;

      if (not FieldByName('DATAONDA').IsNull) and (FieldByName('DATAONDA').AsString <> '') then
      begin

        aProximaOS.DataOnda := FieldByName('DATAONDA').AsDateTime;
      end;

      // processando abastecimento consolidado
      if ExisteOSsMesmoEnderecoOrigemEDestino(aProximaOS.NumeroOS, aProximaOS.CodigoEnderecoOrigem, aProximaOS.CodigoEndereco, aProximaOS.TipoOS,
        aFiltro.Filial, False) then
      begin

        aProximaOS.NumeroOS := 0;
        aProximaOS.TipoServico := 'OC';

        if not GravarOSsAbastecimentoConsolidado(aFiltro.Senha, aProximaOS.CodigoEnderecoOrigem, aProximaOS.CodigoEndereco, aProximaOS.TipoOS,
          aFiltro.Filial, False) then
        begin

          Result := False;
          Exit;
        end;
      end;

      Result := True;
    end;

    Close;
  end;

end;

function Criterio8_ProximaOSUltimaRua(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tipo_os: integer;
  tempo: TDateTime;
  rua_encontrada: double;
  qb: TQueryBuilder;
begin


  // Item 8

  Result := False;
  tempo := Now;


  qb := TQueryBuilder.Create;

  with dmdb.qryAuxiliar do
  begin

    Close;
    SQL.Clear;
    SQL.Add(qb.GetQuery(8, aFiltro));

    // Padrão tpEmpilhador
    tipo_os := 58;

    if aFiltro.TipoOperador = tpPaleteiro then
    begin

      tipo_os := 61;
    end;

    ParamByName('CODFILIAL').AsString := aFiltro.Filial;
    ParamByName('RUAINICIAL').AsFloat := aFiltro.RuaInicial;
    ParamByName('RUAFINAL').AsFloat := aFiltro.RuaFinal;
    ParamByName('RUAANTERIOR').AsFloat := aFiltro.RuaAnterior;
    ParamByName('TIPOOS').AsFloat := tipo_os;

    Open();

    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
    aProximaOS.RegistrarAnaliseCriterios('Critério 8' + IfThen(aProximaOS.ArmazemTodo, ' - Armazém Todo', ''));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('Segundos para resposta da consulta: ' + IntToStr(SecondsBetween(tempo, Now)));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('CODFILIAL: ' + aFiltro.Filial);
    aProximaOS.RegistrarAnaliseCriterios('RUAINICIAL: ' + FloatToStr(aFiltro.RuaInicial));
    aProximaOS.RegistrarAnaliseCriterios('RUAFINAL: ' + FloatToStr(aFiltro.RuaFinal));
    aProximaOS.RegistrarAnaliseCriterios('RUAANTERIOR: ' + FloatToStr(aFiltro.RuaAnterior));
    aProximaOS.RegistrarAnaliseCriterios('ONDAANTERIOR: ' + FloatToStr(aFiltro.OndaAnterior));
    aProximaOS.RegistrarAnaliseCriterios('TIPOOS: ' + FloatToStr(tipo_os));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('SQL:');
    aProximaOS.RegistrarAnaliseCriterios(SQL.Text);

    rua_encontrada := FieldByName('RUA').AsFloat;

    if (not aFiltro.BuscarNoArmazemTodo) and ((rua_encontrada < aFiltro.RuaInicial) or (rua_encontrada > aFiltro.RuaFinal)) then
    begin

      Close();
      Result := False;
      Exit;
    end;

    if (dmdb.qryAuxiliar.RecordCount > 0) then
    begin

      aProximaOS.NumeroOS := FieldByName('NUMOS').AsFloat;
      aProximaOS.NumeroOnda := FieldByName('NUMONDA').AsFloat;
      aProximaOS.CodigoEndereco := FieldByName('CODENDERECO').AsFloat;
      aProximaOS.CodigoEnderecoOrigem := FieldByName('CODENDERECOORIG').AsFloat;
      aProximaOS.TipoServico := FieldByName('TIPOSERVICO').AsString;
      aProximaOS.Rua := FieldByName('RUA').AsFloat;
      aProximaOS.NumeroUMA := FieldByName('CODIGOUMA').AsFloat;
      aProximaOS.TipoOS := FieldByName('TIPOOS').AsFloat;
      aProximaOS.CriterioUtilizado := 8;

      if (not FieldByName('DATAONDA').IsNull) and (FieldByName('DATAONDA').AsString <> '') then
      begin

        aProximaOS.DataOnda := FieldByName('DATAONDA').AsDateTime;
      end;

      // processando abastecimento consolidado
      if ExisteOSsMesmoEnderecoOrigemEDestino(aProximaOS.NumeroOS, aProximaOS.CodigoEnderecoOrigem, aProximaOS.CodigoEndereco, aProximaOS.TipoOS,
        aFiltro.Filial, True) then
      begin

        aProximaOS.NumeroOS := 0;
        aProximaOS.TipoServico := 'OC';

        if not GravarOSsAbastecimentoConsolidado(aFiltro.Senha, aProximaOS.CodigoEnderecoOrigem, aProximaOS.CodigoEndereco, aProximaOS.TipoOS,
          aFiltro.Filial, True) then
        begin

          Result := False;
          Exit;
        end;
      end;

      Result := True;
    end;

    Close();

  end;

end;

function Criterio6_5_ProximaOSPalletBox(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tipo_os: integer;
  tempo: TDateTime;
  rua_encontrada: double;
  qb: TQueryBuilder;

begin
  // Item 6.5 (antigo 8.1)

  Result := False;
  tempo := Now;

  if not aFiltro.TrabalharComPalletBox then
  begin

    Exit;
  end;

  // Somente para paleteiros
  if aFiltro.TipoOperador <> tpPaleteiro then
  begin

    Exit;
  end;

  qb := TQueryBuilder.Create;

  with dmdb.qryAuxiliar do
  begin
    Close;
    SQL.Clear;
    SQL.Add(qb.GetQuery(6.5, aFiltro));

    // Padrão tpEmpilhador
    tipo_os := 23;

    if aFiltro.TipoOperador = tpPaleteiro then
    begin

      tipo_os := 17;
    end;

    ParamByName('CODFILIAL').AsString := aFiltro.Filial;
    ParamByName('RUAINICIAL').AsFloat := aFiltro.RuaInicial;
    ParamByName('RUAFINAL').AsFloat := aFiltro.RuaFinal;
    ParamByName('RUAANTERIOR').AsFloat := aFiltro.RuaAnterior;
    ParamByName('TIPOOS').AsFloat := tipo_os;
    ParamByName('PERCFINALIZACAO').AsFloat := aFiltro.PercentualFinalizacaoSeparacao;

    Open();

    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
    aProximaOS.RegistrarAnaliseCriterios('Critério 6.5' + IfThen(aProximaOS.ArmazemTodo, ' - Armazém Todo', ''));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('Segundos para resposta da consulta: ' + IntToStr(SecondsBetween(tempo, Now)));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('CODFILIAL: ' + aFiltro.Filial);
    aProximaOS.RegistrarAnaliseCriterios('RUAINICIAL: ' + FloatToStr(aFiltro.RuaInicial));
    aProximaOS.RegistrarAnaliseCriterios('RUAFINAL: ' + FloatToStr(aFiltro.RuaFinal));
    aProximaOS.RegistrarAnaliseCriterios('RUAANTERIOR: ' + FloatToStr(aFiltro.RuaAnterior));
    aProximaOS.RegistrarAnaliseCriterios('ONDAANTERIOR: ' + FloatToStr(aFiltro.OndaAnterior));
    aProximaOS.RegistrarAnaliseCriterios('TIPOOS: ' + FloatToStr(tipo_os));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('SQL:');
    aProximaOS.RegistrarAnaliseCriterios(SQL.Text);

    rua_encontrada := FieldByName('RUA').AsFloat;

    if (not aFiltro.BuscarNoArmazemTodo) and ((rua_encontrada < aFiltro.RuaInicial) or (rua_encontrada > aFiltro.RuaFinal)) then
    begin

      Close();
      Result := False;
      Exit;
    end;

    if (dmdb.qryAuxiliar.RecordCount > 0) then
    begin

      aProximaOS.NumeroOS := FieldByName('NUMOS').AsFloat;
      aProximaOS.NumeroOnda := FieldByName('NUMONDA').AsFloat;
      aProximaOS.CodigoEndereco := FieldByName('CODENDERECO').AsFloat;
      aProximaOS.CodigoEnderecoOrigem := FieldByName('CODENDERECOORIG').AsFloat;
      aProximaOS.TipoServico := 'PB';
      aProximaOS.Rua := FieldByName('RUA').AsFloat;
      aProximaOS.NumeroUMA := FieldByName('CODIGOUMA').AsFloat;
      aProximaOS.TipoOS := FieldByName('TIPOOS').AsFloat;
      aProximaOS.CriterioUtilizado := 6.5;

      if (not FieldByName('DATAONDA').IsNull) and (FieldByName('DATAONDA').AsString <> '') then
      begin

        aProximaOS.DataOnda := FieldByName('DATAONDA').AsDateTime;
      end;

      Result := True;
    end;

    Close();

  end;

end;

function Criterio8_2_ProximaOSAbastecimentoPreventivoSemOnda(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tempo: TDateTime;
  tipo_os: integer;
  rua_encontrada: double;
begin

  // Item 8.2
  Result := False;
  Log('Critério 8.2 - Desabilitado temporariamente');
  Exit;
  tempo := Now;

  ODACSessionGlobal.StartTransaction();

  try
    begin

      with dmdb.qryAuxiliar do
      begin
        Close;
        SQL.Clear;

        SQL.Add(' with sep_pendentes as                                                                                    ');
        SQL.Add(' (                                                                                                        ');
        SQL.Add('    select                                                                                                ');
        SQL.Add('     pcmovendpend.codendereco                                                                             ');
        SQL.Add('     , bodefineondai.data as dataonda                                                                     ');
        SQL.Add('     , bodefineondai.numonda                                                                              ');
        SQL.Add('     , bodefineondai.numordem                                                                             ');
        SQL.Add('   from pcmovendpend                                                                                      ');
        SQL.Add('   join bodefineondai  on bodefineondai.numtranswms = pcmovendpend.numtranswms                            ');
        SQL.Add('                       and bodefineondai.data >= pcmovendpend.data                                        ');
        SQL.Add('   where pcmovendpend.data >= trunc(sysdate - 10)                                                         ');
        SQL.Add('   and pcmovendpend.codfilial = :CODFILIAL                                                                ');
        SQL.Add('   and pcmovendpend.posicao = ''P''                                                                       ');
        SQL.Add('   and pcmovendpend.dtestorno is null                                                                     ');
        SQL.Add('   and pcmovendpend.codfuncos is null                                                                     ');
        SQL.Add('   and pcmovendpend.tipoos in (10, 22)                                                                    ');
        SQL.Add(' ),                                                                                                       ');
        SQL.Add(' fila_execucao as (                                                                                       ');
        SQL.Add('   select bofilaos.numos                                                                                  ');
        SQL.Add('   FROM bofilaos                                                                                          ');
        SQL.Add('   where bofilaos.status in (''E'',''R'')                                                                 ');
        SQL.Add('   and bofilaos.dtsolicitacao >= trunc(sysdate - 15)                                                      ');
        SQL.Add('                                                                                                          ');
        SQL.Add('   union all                                                                                              ');
        SQL.Add('                                                                                                          ');
        SQL.Add('   select bofilaosR.numos                                                                                 ');
        SQL.Add('   FROM bofilaosR                                                                                         ');
        SQL.Add('   join bofilaos on bofilaosR.senha = bofilaos.senha                                                      ');
        SQL.Add('   where  bofilaos.status in (''E'',''R'')                                                                ');
        SQL.Add('   and bofilaos.dtsolicitacao >= trunc(sysdate - 15)                                                      ');
        SQL.Add(' ),                                                                                                       ');
        SQL.Add('                                                                                                          ');
        SQL.Add(' pendencias as (                                                                                          ');
        SQL.Add('   select pend.numos                                                                                      ');
        SQL.Add('   from booscompendencia pend                                                                             ');
        SQL.Add('   where pend.datainclusao >= trunc(sysdate -  10)                                                        ');
        SQL.Add('   and pend.dataliberacao is null                                                                         ');
        SQL.Add(' )                                                                                                        ');
        SQL.Add('                                                                                                          ');
        SQL.Add('   select                                                                                                 ');
        SQL.Add('     mep.numos                                                                                            ');
        SQL.Add('     , pcendereco.rua                                                                                     ');
        SQL.Add('     , pcendereco.codendereco                                                                             ');
        SQL.Add('     , mep.codigouma                                                                                      ');
        SQL.Add('     , mep.codenderecoorig                                                                                ');
        SQL.Add('     , mep.tipoos                                                                                         ');
        SQL.Add('     , sep_pendentes.dataonda                                                                             ');
        SQL.Add('     , sep_pendentes.numonda                                                                              ');
        SQL.Add('     , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) ordem_rua_anterior                     ');
        SQL.Add('     , (case when pcendereco.rua between :RUAINICIAL and :RUAFINAL then 0 else mep.numos end) ordem_range ');
        SQL.Add('   from pcmovendpend mep                                                                                  ');
        SQL.Add('   left join pcwms on pcwms.numtranswms = mep.numtranswms                                                 ');
        SQL.Add('   join pcendereco on pcendereco.codendereco = mep.codendereco                                            ');
        SQL.Add('   join sep_pendentes on sep_pendentes.codendereco = mep.codendereco                                      ');

        if aFiltro.TipoOperador = tpPaleteiro then
        begin

          SQL.Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P      ');
          SQL.Add(' join pcmovendpend mep58 on mep58.data = mep.data               ');
          SQL.Add('  and mep58.codfilial = mep.codfilial                           ');
          SQL.Add('  and mep58.numtranswms = mep.numtranswms                       ');
          SQL.Add('  and mep58.codigouma = mep.codigouma                           ');
          SQL.Add('  and mep58.tipoos = 58                                         ');
          SQL.Add('  and mep58.posicao <> ''P''                                    ');
        end;

        SQL.Add('   where mep.data >= trunc(sysdate - 15)                                                                  ');
        SQL.Add('   and mep.codfilial = :CODFILIAL                                                                         ');
        SQL.Add('   and mep.posicao = ''P''                                                                                ');
        SQL.Add('   and mep.dtestorno is null                                                                              ');
        SQL.Add('   and mep.codfuncos is null                                                                              ');
        SQL.Add('   and mep.tipoos = :TIPOOS                                                                               ');
        SQL.Add('   and pcwms.numtranswms is NULL                                                                          ');
        SQL.Add('   AND NOT EXISTS (SELECT 1 FROM fila_execucao WHERE fila_execucao.NUMOS = mep.numos)                     ');
        SQL.Add('   AND NOT EXISTS (SELECT 1 FROM pendencias WHERE pendencias.NUMOS = mep.numos)                           ');
        SQL.Add('   and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                                                   ');
        SQL.Add('   AND NVL(mep.CODROTINA, 0) NOT IN (1709, 1721)                                                          ');
        SQL.Add('   and mep.codrotina = 1723                                                                               ');
        SQL.Add('   order by sep_pendentes.dataonda                                                                        ');
        SQL.Add('     , sep_pendentes.numonda                                                                              ');
        SQL.Add('     , ordem_rua_anterior                                                                                 ');
        SQL.Add('     , ordem_range                                                                                        ');
        SQL.Add('   FOR UPDATE SKIP LOCKED                                                                                 ');

        // Padrão tpEmpilhador
        tipo_os := 58;

        if aFiltro.TipoOperador = tpPaleteiro then
        begin

          tipo_os := 61;
        end;

        ParamByName('CODFILIAL').AsString := aFiltro.Filial;
        ParamByName('RUAINICIAL').AsFloat := aFiltro.RuaInicial;
        ParamByName('RUAFINAL').AsFloat := aFiltro.RuaFinal;
        ParamByName('RUAANTERIOR').AsFloat := aFiltro.RuaAnterior;
        ParamByName('TIPOOS').AsFloat := tipo_os;

        // Clipboard.AsText := SQL.Text;

        Open();

        aProximaOS.RegistrarAnaliseCriterios('');
        aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
        aProximaOS.RegistrarAnaliseCriterios('Critério 8.2' + IfThen(aProximaOS.ArmazemTodo, ' - Armazém Todo', ''));
        aProximaOS.RegistrarAnaliseCriterios('');
        aProximaOS.RegistrarAnaliseCriterios('Segundos para resposta da consulta: ' + IntToStr(SecondsBetween(tempo, Now)));
        aProximaOS.RegistrarAnaliseCriterios('');
        aProximaOS.RegistrarAnaliseCriterios('CODFILIAL: ' + aFiltro.Filial);
        aProximaOS.RegistrarAnaliseCriterios('RUAINICIAL: ' + FloatToStr(aFiltro.RuaInicial));
        aProximaOS.RegistrarAnaliseCriterios('RUAFINAL: ' + FloatToStr(aFiltro.RuaFinal));
        aProximaOS.RegistrarAnaliseCriterios('RUAANTERIOR: ' + FloatToStr(aFiltro.RuaAnterior));
        aProximaOS.RegistrarAnaliseCriterios('ONDAANTERIOR: ' + FloatToStr(aFiltro.OndaAnterior));
        aProximaOS.RegistrarAnaliseCriterios('TIPOOS: AP');
        aProximaOS.RegistrarAnaliseCriterios('');
        aProximaOS.RegistrarAnaliseCriterios('SQL:');
        aProximaOS.RegistrarAnaliseCriterios(SQL.Text);

        rua_encontrada := FieldByName('RUA').AsFloat;

        if (not aFiltro.BuscarNoArmazemTodo) and ((rua_encontrada < aFiltro.RuaInicial) or (rua_encontrada > aFiltro.RuaFinal)) then
        begin

          Close();
          ODACSessionGlobal.Rollback;
          Result := False;
          Exit;
        end;

        if (dmdb.qryAuxiliar.RecordCount > 0) then
        begin

          dmdb.qryAuxiliar.First;

          aProximaOS.NumeroOS := FieldByName('NUMOS').AsFloat;
          aProximaOS.NumeroOnda := FieldByName('NUMONDA').AsFloat;
          aProximaOS.CodigoEndereco := FieldByName('CODENDERECO').AsFloat;
          aProximaOS.CodigoEnderecoOrigem := FieldByName('CODENDERECOORIG').AsFloat;
          aProximaOS.TipoServico := 'AP';
          aProximaOS.Rua := FieldByName('RUA').AsFloat;
          aProximaOS.NumeroUMA := FieldByName('CODIGOUMA').AsFloat;
          aProximaOS.TipoOS := FieldByName('TIPOOS').AsFloat;
          aProximaOS.CriterioUtilizado := 8.2;

          if (not FieldByName('DATAONDA').IsNull) and (FieldByName('DATAONDA').AsString <> '') then
          begin

            aProximaOS.DataOnda := FieldByName('DATAONDA').AsDateTime;
          end;

          // processando abastecimento consolidado
          if ExisteOSsMesmoEnderecoOrigemEDestino(aProximaOS.NumeroOS, aProximaOS.CodigoEnderecoOrigem, aProximaOS.CodigoEndereco, aProximaOS.TipoOS,
            aFiltro.Filial, True) then
          begin

            aProximaOS.NumeroOS := 0;
            aProximaOS.TipoServico := 'OC';

            if not GravarOSsAbastecimentoConsolidado(aFiltro.Senha, aProximaOS.CodigoEnderecoOrigem, aProximaOS.CodigoEndereco, aProximaOS.TipoOS,
              aFiltro.Filial, True) then
            begin

              Result := False;
              ODACSessionGlobal.Rollback;
              Exit;
            end;
          end;

          Result := True;
        end;

        Close();
        ODACSessionGlobal.Commit;

      end;
    end;
  except
    on E: Exception do
    begin

      ODACSessionGlobal.Rollback;
    end;
  end;

end;

function Criterio11_ProximaOSAbastecimentoPreventivo(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tempo: TDateTime;
  tipo_os: integer;
begin

  // Item 11

  Result := False;
  tempo := Now;

  with dmdb.qryAuxiliar do
  begin
    Close;
    SQL.Clear;

    SQL.Add(' select                                                                                 ');
    SQL.Add('   numos,                                                                               ');
    SQL.Add('   nvl(rua, 0) as rua,                                                                  ');
    SQL.Add('   nvl(codendereco, 0) as codendereco,                                                  ');
    SQL.Add('   nvl(codenderecoorig, 0) as codenderecoorig,                                           ');
    SQL.Add('   nvl(codigouma, 0) as codigouma,                                                       ');
    SQL.Add('   nvl(tipoos, 0) as tipoos                                                             ');
    SQL.Add(' from (                                                                                 ');
    SQL.Add(' Select pcmovendpend.numos                                                              ');
    SQL.Add('        ,pcendereco.rua                                                                 ');
    SQL.Add('        , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) ordemrua          ');
    SQL.Add('        , pcmovendpend.codendereco                                                      ');
    SQL.Add('        , pcmovendpend.codenderecoorig                                                  ');
    SQL.Add('        , nvl(pcest.qtgirodia,0) as giro                                                ');
    SQL.Add('        , pcmovendpend.codigouma                                                        ');
    SQL.Add('        , pcmovendpend.tipoos                                                           ');
    SQL.Add(' from pcmovendpend                                                                      ');
    SQL.Add(' join pcendereco      on pcendereco.codendereco = pcmovendpend.codenderecoorig          ');
    SQL.Add(' left join bodefineondai   on bodefineondai.numtranswms = pcmovendpend.numtranswms      ');
    // SQL.Add('                         AND bodefineondai.numcar = pcmovendpend.numcar ');
    SQL.Add(' join pcest on pcest.codfilial = pcmovendpend.codfilial                                 ');
    SQL.Add('     and pcest.codprod = pcmovendpend.codprod                                           ');
    SQL.Add(' left join booscompendencia on booscompendencia.numos = pcmovendpend.numos            ');
    SQL.Add('     and booscompendencia.dataliberacao is null                                       ');

    if aFiltro.TipoOperador = tpPaleteiro then
    begin

      SQL.Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P');
      SQL.Add(' join pcmovendpend mep58 on mep58.data = pcmovendpend.data               ');
      SQL.Add('  and mep58.codfilial = pcmovendpend.codfilial                           ');
      SQL.Add('  and mep58.numtranswms = pcmovendpend.numtranswms                       ');
      SQL.Add('  and mep58.codigouma = pcmovendpend.codigouma                           ');
      SQL.Add('  and mep58.tipoos = 58                                                  ');
      SQL.Add('  and mep58.posicao <> ''P''                                             ');
    end;

    SQL.Add(' where pcmovendpend.data > sysdate - 30                                               ');
    SQL.Add('     and pcmovendpend.codfilial = :CODFILIAL                                          ');
    SQL.Add('     and pcmovendpend.posicao = ''P''                                                 ');
    SQL.Add('     and bodefineondai.numtranswms is null                                              ');
    SQL.Add('     and pcmovendpend.dtestorno is null                                                 ');
    SQL.Add('     and pcmovendpend.tipoos = :TIPOOS                                                  ');
    SQL.Add('     and pcmovendpend.codfuncos is null                                                 ');
    SQL.Add('     and not exists (select bofilaos.numos                                              ');
    SQL.Add('                              FROM bofilaos                                             ');
    SQL.Add('                               where bofilaos.numos = pcmovendpend.numos                ');
    SQL.Add('                               and bofilaos.status in (''E'',''R''))                    ');
    SQL.Add('                                                                                        ');

    SQL.Add(' 		and not exists (select bofilaosR.numos                                ');
    SQL.Add(' 		                  FROM bofilaosR                                      ');
    SQL.Add(' 		                  join bofilaos                                       ');
    SQL.Add(' 		                    on bofilaosR.senha = bofilaos.senha               ');
    SQL.Add(' 		                  where bofilaosR.numos = pcmovendpend.numos          ');
    SQL.Add(' 		                  and bofilaos.status in (''E'',''R''))               ');

    SQL.Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                    ');
    SQL.Add(' and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                                  ');
    SQL.Add(' and booscompendencia.numos is null ');

    if (aFiltro.ruasIgnorar.Count > 0) then
    begin

      SQL.Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
      SQL.Add(' and pcendereco.rua not in (' + aFiltro.ruasIgnorar.DelimitedText + ' )');
    end;

    SQL.Add(' order by ordemrua, giro desc                                                           ');
    SQL.Add(' ) where rownum = 1                                                                     ');

    // Padrão tpEmpilhador
    tipo_os := 58;

    if (aFiltro.TipoOperador = tpPaleteiro) then
    begin

      tipo_os := 61;
    end;

    ParamByName('CODFILIAL').AsString := aFiltro.Filial;
    ParamByName('RUAINICIAL').AsFloat := aFiltro.RuaInicial;
    ParamByName('RUAFINAL').AsFloat := aFiltro.RuaFinal;
    ParamByName('RUAANTERIOR').AsFloat := aFiltro.RuaAnterior;
    ParamByName('TIPOOS').AsFloat := tipo_os;
    Open();

    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
    aProximaOS.RegistrarAnaliseCriterios('Critério 11' + IfThen(aProximaOS.ArmazemTodo, ' - Armazém Todo', ''));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('Segundos para resposta da consulta: ' + IntToStr(SecondsBetween(tempo, Now)));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('CODFILIAL: ' + aFiltro.Filial);
    aProximaOS.RegistrarAnaliseCriterios('RUAINICIAL: ' + FloatToStr(aFiltro.RuaInicial));
    aProximaOS.RegistrarAnaliseCriterios('RUAFINAL: ' + FloatToStr(aFiltro.RuaFinal));
    aProximaOS.RegistrarAnaliseCriterios('RUAANTERIOR: ' + FloatToStr(aFiltro.RuaAnterior));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('SQL:');
    aProximaOS.RegistrarAnaliseCriterios(SQL.Text);

    if (dmdb.qryAuxiliar.RecordCount > 0) then
    begin

      aProximaOS.NumeroOS := FieldByName('NUMOS').AsFloat;
      aProximaOS.NumeroUMA := FieldByName('CODIGOUMA').AsFloat;
      aProximaOS.CodigoEndereco := FieldByName('CODENDERECO').AsFloat;
      aProximaOS.CodigoEnderecoOrigem := FieldByName('CODENDERECOORIG').AsFloat;
      aProximaOS.TipoOS := FieldByName('TIPOOS').AsFloat;
      aProximaOS.Rua := FieldByName('RUA').AsFloat;
      aProximaOS.TipoServico := 'PV';
      aProximaOS.CriterioUtilizado := 11;

      // processando abastecimento consolidado
      if ExisteOSsMesmoEnderecoOrigemEDestino(aProximaOS.NumeroOS, aProximaOS.CodigoEnderecoOrigem, aProximaOS.CodigoEndereco, aProximaOS.TipoOS,
        aFiltro.Filial, False) then
      begin

        aProximaOS.NumeroOS := 0;
        aProximaOS.TipoServico := 'OC';

        if not GravarOSsAbastecimentoConsolidado(aFiltro.Senha, aProximaOS.CodigoEnderecoOrigem, aProximaOS.CodigoEndereco, aProximaOS.TipoOS,
          aFiltro.Filial, False) then
        begin

          Result := False;
          Exit;
        end;
      end;

      Result := True;
    end;

    Close();

  end;

end;

function Criterio9_5_ProximaOSCorretivaBaseadaEmPedido(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tempo: TDateTime;
  tipo_os: integer;
  rua_encontrada: double;
begin

  // Critério 9.5
  Result := False;

  Log('O critério 9.5 foi desabilitado');
  Exit;

  tempo := Now;

  with dmdb.qryAuxiliar do
  begin
    Close;
    SQL.Clear;

    SQL.Add('select                                                                                                      ');
    SQL.Add('   numos,                                                                                                   ');
    SQL.Add('   rua,                                                                                                     ');
    SQL.Add('   codendereco,                                                                                             ');
    SQL.Add('   codigouma,                                                                                               ');
    SQL.Add('   codenderecoorig,                                                                                         ');
    SQL.Add('   tipoos,                                                                                                  ');
    SQL.Add('   0 as numonda                                                                                             ');
    SQL.Add(' from (                                                                                                     ');
    SQL.Add('                                                                                                            ');
    SQL.Add('   select                                                                                                   ');
    SQL.Add('     mep.numos                                                                                              ');
    SQL.Add('     , pcendereco.rua                                                                                       ');
    SQL.Add('     , pcendereco.codendereco                                                                               ');
    SQL.Add('     , mep.codigouma                                                                                        ');
    SQL.Add('     , mep.codenderecoorig                                                                                  ');
    SQL.Add('     , mep.tipoos                                                                                           ');
    SQL.Add('     , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) ordem_rua_anterior                       ');
    SQL.Add('     , (case when pcendereco.rua between :RUAINICIAL and :RUAFINAL then 0 else mep.numos end) ordem_range   ');
    SQL.Add('   from pcmovendpend mep                                                                                    ');
    SQL.Add('   left join pcwms on pcwms.numtranswms = mep.numtranswms                                                   ');
    SQL.Add('   join pcendereco on pcendereco.codendereco = mep.codendereco                                              ');

    if aFiltro.TipoOperador = tpPaleteiro then
    begin

      SQL.Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P      ');
      SQL.Add(' join pcmovendpend mep58 on mep58.data = mep.data               ');
      SQL.Add('  and mep58.codfilial = mep.codfilial                           ');
      SQL.Add('  and mep58.numtranswms = mep.numtranswms                       ');
      SQL.Add('  and mep58.codigouma = mep.codigouma                           ');
      SQL.Add('  and mep58.tipoos = 58                                         ');
      SQL.Add('  and mep58.posicao <> ''P''                                    ');
    end;

    SQL.Add('                                                                                                            ');
    SQL.Add('                                                                                                            ');
    SQL.Add('   where mep.data >= trunc(sysdate - 30)                                                                    ');
    SQL.Add('   and mep.codfilial = :CODFILIAL                                                                           ');
    SQL.Add('   and mep.posicao = ''P''                                                                                  ');
    SQL.Add('   and mep.dtestorno is null                                                                                ');
    SQL.Add('   and mep.codfuncos is null                                                                                ');
    SQL.Add('   and mep.tipoos = :TIPOOS                                                                                 ');
    SQL.Add('   and pcwms.numtranswms is null                                                                            ');
    SQL.Add('   and not exists (select bofilaos.numos                                                                    ');
    SQL.Add('         FROM bofilaos where bofilaos.numos = mep.numos                                                     ');
    SQL.Add('         and bofilaos.status in (''E'',''R''))                                                              ');
    SQL.Add('                                                                                                            ');
    SQL.Add('   and not exists (select bofilaosR.numos                                                                   ');
    SQL.Add('                     FROM bofilaosR                                                                         ');
    SQL.Add('                     join bofilaos                                                                          ');
    SQL.Add('                       on bofilaosR.senha = bofilaos.senha                                                  ');
    SQL.Add('                     where bofilaosR.numos = mep.numos                                                      ');
    SQL.Add('                     and bofilaos.status in (''E'',''R''))                                                  ');
    SQL.Add('   and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                                                     ');
    SQL.Add('                                                                                                            ');
    SQL.Add('                                                                                                            ');
    SQL.Add(' and not exists (select pend.numos from booscompendencia pend                                               ');
    SQL.Add('                 join pcmovendpend on pcmovendpend.numos = pend.numos                                       ');
    SQL.Add('                 where pend.dataliberacao is null                                                           ');
    SQL.Add('                 and pcmovendpend.codprod = mep.codprod )                                                   ');
    SQL.Add('                                                                                                            ');
    SQL.Add('  and mep.codrotina = 1752                                                                                  ');
    SQL.Add('   group by mep.numos                                                                                       ');
    SQL.Add('     , pcendereco.rua                                                                                       ');
    SQL.Add('     , pcendereco.codendereco                                                                               ');
    SQL.Add('     , mep.codigouma                                                                                        ');
    SQL.Add('     , mep.codenderecoorig                                                                                  ');
    SQL.Add('     , mep.tipoos                                                                                           ');
    SQL.Add('                                                                                                            ');
    SQL.Add('   order by ordem_rua_anterior                                                                              ');
    SQL.Add('     , ordem_range                                                                                          ');
    SQL.Add(' ) where rownum = 1                                                                                         ');

    // Padrão tpEmpilhador
    tipo_os := 58;

    if aFiltro.TipoOperador = tpPaleteiro then
    begin

      tipo_os := 61;
    end;

    ParamByName('CODFILIAL').AsString := aFiltro.Filial;
    ParamByName('RUAINICIAL').AsFloat := aFiltro.RuaInicial;
    ParamByName('RUAFINAL').AsFloat := aFiltro.RuaFinal;
    ParamByName('RUAANTERIOR').AsFloat := aFiltro.RuaAnterior;
    ParamByName('TIPOOS').AsFloat := tipo_os;

    Open();

    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
    aProximaOS.RegistrarAnaliseCriterios('Critério 9.5' + IfThen(aProximaOS.ArmazemTodo, ' - Armazém Todo', ''));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('Segundos para resposta da consulta: ' + IntToStr(SecondsBetween(tempo, Now)));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('CODFILIAL: ' + aFiltro.Filial);
    aProximaOS.RegistrarAnaliseCriterios('RUAINICIAL: ' + FloatToStr(aFiltro.RuaInicial));
    aProximaOS.RegistrarAnaliseCriterios('RUAFINAL: ' + FloatToStr(aFiltro.RuaFinal));
    aProximaOS.RegistrarAnaliseCriterios('RUAANTERIOR: ' + FloatToStr(aFiltro.RuaAnterior));
    aProximaOS.RegistrarAnaliseCriterios('ONDAANTERIOR: ' + FloatToStr(aFiltro.OndaAnterior));
    aProximaOS.RegistrarAnaliseCriterios('');
    aProximaOS.RegistrarAnaliseCriterios('SQL:');
    aProximaOS.RegistrarAnaliseCriterios(SQL.Text);

    rua_encontrada := FieldByName('RUA').AsFloat;

    if (not aFiltro.BuscarNoArmazemTodo) and ((rua_encontrada < aFiltro.RuaInicial) or (rua_encontrada > aFiltro.RuaFinal)) then
    begin

      Close();
      Result := False;
      Exit;
    end;

    if (dmdb.qryAuxiliar.RecordCount > 0) then
    begin

      aProximaOS.NumeroOS := FieldByName('NUMOS').AsFloat;
      aProximaOS.NumeroOnda := FieldByName('NUMONDA').AsFloat;
      aProximaOS.CodigoEndereco := FieldByName('CODENDERECO').AsFloat;
      aProximaOS.CodigoEnderecoOrigem := FieldByName('CODENDERECOORIG').AsFloat;
      aProximaOS.TipoServico := 'PP';
      aProximaOS.Rua := FieldByName('RUA').AsFloat;
      aProximaOS.NumeroUMA := FieldByName('CODIGOUMA').AsFloat;
      aProximaOS.TipoOS := FieldByName('TIPOOS').AsFloat;
      aProximaOS.CriterioUtilizado := 9.5;

      // if (not FieldByName('DATAONDA').IsNull) and (FieldByName('DATAONDA').AsString <> '') then
      // begin
      //
      // aProximaOS.DataOnda := FieldByName('DATAONDA').AsDateTime;
      // end;

      // processando abastecimento consolidado
      if ExisteOSsMesmoEnderecoOrigemEDestino(aProximaOS.NumeroOS, aProximaOS.CodigoEnderecoOrigem, aProximaOS.CodigoEndereco, aProximaOS.TipoOS,
        aFiltro.Filial, False) then
      begin

        aProximaOS.NumeroOS := 0;
        aProximaOS.TipoServico := 'OC';

        if not GravarOSsAbastecimentoConsolidado(aFiltro.Senha, aProximaOS.CodigoEnderecoOrigem, aProximaOS.CodigoEndereco, aProximaOS.TipoOS,
          aFiltro.Filial, False) then
        begin

          Result := False;
          Exit;
        end;
      end;

      Result := True;
    end;

    Close();

  end;

end;

procedure ClonarOS(aNumeroOS: double; aNovoTipoOS: double; aAntigoTipoOS: double; aFilial: string);
begin

  dmdb.qryClonarOS.Close;
  dmdb.qryClonarOS.ParamByName('NUMOS').AsFloat := aNumeroOS;
  dmdb.qryClonarOS.ParamByName('NOVOTIPO').AsFloat := aNovoTipoOS;
  dmdb.qryClonarOS.ParamByName('ANTIGOTIPO').AsFloat := aAntigoTipoOS;
  dmdb.qryClonarOS.ParamByName('CODFILIAL').AsString := aFilial;
  dmdb.qryClonarOS.ExecSQL;
end;

procedure AtenderSolicitacao(aFiltro: TFiltro; aProximaOS: TProximaOS);
begin

  aProximaOS.SuperLotada := False;

  // if (dmdb.qryRuasExcessoOS.State = dsBrowse)
  // and (dmdb.qryRuasExcessoOS.RecordCount > 0)
  // and (dmdb.qryRuasExcessoOS.Locate('RUA', aProximaOS.Rua, []))
  // then
  // begin
  //
  // aProximaOS.SuperLotada := True;
  // end;

  if aFiltro.ruasSuperLotadas.IndexOf(FloatToStr(aProximaOS.Rua)) > -1 then
  begin

    aProximaOS.SuperLotada := True;
  end;

  with dmdb.qryAtenderSolicitacao do
  begin

    Close;
    ParamByName('NUMOS').AsFloat := aProximaOS.NumeroOS;
    ParamByName('CODIGOUMA').AsFloat := aProximaOS.NumeroUMA;
    ParamByName('CODENDERECO').AsFloat := aProximaOS.CodigoEndereco;
    ParamByName('CODENDERECOORIG').AsFloat := aProximaOS.CodigoEnderecoOrigem;

    if aProximaOS.SuperLotada then
    begin

      ParamByName('FLAGSL').AsFloat := 1;
    end
    else
    begin

      ParamByName('FLAGSL').AsFloat := 0;
    end;

    ParamByName('TIPOSERVICO').AsString := aProximaOS.TipoServico;
    ParamByName('SENHA').AsFloat := aProximaOS.Senha;

    if aProximaOS.DataOnda > 0 then
    begin

      ParamByName('DTONDA').AsDate := aProximaOS.DataOnda;
    end
    else
    begin

      ParamByName('DTONDA').AsString := '';
    end;

    ParamByName('NRONDA').AsFloat := aProximaOS.NumeroOnda;
    ParamByName('TIPOOS').AsFloat := aProximaOS.TipoOS;
    ParamByName('CRITERIO').AsFloat := aProximaOS.CriterioUtilizado;
    ParamByName('ARMAZEMTODO').AsString := IfThen(aFiltro.BuscarNoArmazemTodo, 'S', 'N');

    ExecSQL;
  end;

  // if (dmdb.cdsOSsAtribuidas.State <> dsBrowse) then
  // begin
  //
  //
  // end;

  dmdb.cdsOSsAtribuidas.Insert;
  dmdb.cdsOSsAtribuidasSENHA.AsFloat := aFiltro.Senha;
  dmdb.cdsOSsAtribuidasSENHAANTERIOR.AsFloat := aFiltro.SenhaAnterior;
  dmdb.cdsOSsAtribuidasDATA.AsDateTime := Now;
  dmdb.cdsOSsAtribuidasDTSOLICITACAO.AsDateTime := aFiltro.DataSolicitacao;
  dmdb.cdsOSsAtribuidasMATRICULA.AsFloat := aFiltro.Matricula;
  dmdb.cdsOSsAtribuidasNUMOS.AsFloat := aProximaOS.NumeroOS;
  dmdb.cdsOSsAtribuidasCODENDERECO.AsFloat := aProximaOS.CodigoEndereco;
  dmdb.cdsOSsAtribuidasCODENDERECOORIG.AsFloat := aProximaOS.CodigoEnderecoOrigem;
  dmdb.cdsOSsAtribuidasCODIGOUMA.AsFloat := aProximaOS.NumeroUMA;
  dmdb.cdsOSsAtribuidasTIPOOS.AsFloat := aProximaOS.TipoOS;
  dmdb.cdsOSsAtribuidasCRITERIO.AsFloat := aProximaOS.CriterioUtilizado;
  dmdb.cdsOSsAtribuidasRUA.AsFloat := aProximaOS.Rua;
  dmdb.cdsOSsAtribuidasTIPOOSANTERIOR.AsFloat := aFiltro.TipoOSAnterior;
  dmdb.cdsOSsAtribuidasRUAANTERIOR.AsFloat := aFiltro.RuaAnterior;
  dmdb.cdsOSsAtribuidasRUAINICIAL.AsFloat := aFiltro.RuaInicialOriginal;
  dmdb.cdsOSsAtribuidasRUAFINAL.AsFloat := aFiltro.RuaFinalOriginal;

  if aFiltro.DataSolicitacaoAnterior > 0 then
  begin

    dmdb.cdsOSsAtribuidasDTSOLICITACAOANTERIOR.AsDateTime := aFiltro.DataSolicitacaoAnterior;
  end;

  dmdb.cdsOSsAtribuidasARMAZEMTODO.AsFloat := 0;
  dmdb.cdsOSsAtribuidasSUPERLOTADA.AsFloat := 0;
  dmdb.cdsOSsAtribuidasTOTALOSRUA.AsFloat := 0;
  dmdb.cdsOSsAtribuidasTOTALFUNCRUA.AsFloat := 0;
  dmdb.cdsOSsAtribuidasTOTALOSRUAANTERIOR.AsFloat := 0;
  dmdb.cdsOSsAtribuidasTOTALFUNCRUAANTERIOR.AsFloat := 0;

  if aFiltro.BuscarNoArmazemTodo then
  begin

    dmdb.cdsOSsAtribuidasARMAZEMTODO.AsFloat := 1;
  end;

  if aProximaOS.SuperLotada then
  begin

    dmdb.cdsOSsAtribuidasSUPERLOTADA.AsFloat := 1;
  end;

  if (dmdb.qryTotalOSRuas.State = dsBrowse) and (dmdb.qryTotalOSRuas.RecordCount > 0) and (dmdb.qryTotalOSRuas.Locate('RUA', aProximaOS.Rua, [])) then
  begin

    dmdb.cdsOSsAtribuidasTOTALOSRUA.AsFloat := dmdb.qryTotalOSRuasTOTAL.AsFloat;
  end;

  if (dmdb.qryTotalFuncRuas.State = dsBrowse) and (dmdb.qryTotalFuncRuas.RecordCount > 0) and (dmdb.qryTotalFuncRuas.Locate('RUA', aProximaOS.Rua, []))
  then
  begin

    dmdb.cdsOSsAtribuidasTOTALFUNCRUA.AsFloat := dmdb.qryTotalFuncRuasTOTAL.AsFloat;
  end;

  if (dmdb.qryTotalOSRuas.State = dsBrowse) and (dmdb.qryTotalOSRuas.RecordCount > 0) and (dmdb.qryTotalOSRuas.Locate('RUA', aFiltro.RuaAnterior, []))
  then
  begin

    dmdb.cdsOSsAtribuidasTOTALOSRUAANTERIOR.AsFloat := dmdb.qryTotalOSRuasTOTAL.AsFloat;
  end;

  if (dmdb.qryTotalFuncRuas.State = dsBrowse) and (dmdb.qryTotalFuncRuas.RecordCount > 0) and
    (dmdb.qryTotalFuncRuas.Locate('RUA', aFiltro.RuaAnterior, [])) then
  begin

    dmdb.cdsOSsAtribuidasTOTALFUNCRUAANTERIOR.AsFloat := dmdb.qryTotalFuncRuasTOTAL.AsFloat;
  end;

  // Padrão tpEmpilhador
  dmdb.cdsOSsAtribuidasTIPOOPERADOR.AsString := 'E';

  if aFiltro.TipoOperador = tpPaleteiro then
  begin

    dmdb.cdsOSsAtribuidasTIPOOPERADOR.AsString := 'P';
  end;

  dmdb.cdsOSsAtribuidasRANGERUASEXCECAO.AsString := IfThen(aFiltro.RangeRuasExcecao, 'S', 'N');
  dmdb.cdsOSsAtribuidasANALISE.AsString := Trim(aProximaOS.AnalisesCriterios.Text);
  dmdb.cdsOSsAtribuidasSEGUNDOSLOCALIZACAOOS.AsFloat := aProximaOS.SegundosTotalBusca();

  dmdb.cdsOSsAtribuidas.Post;


  // if aProximaOS.TipoOS = 17 then
  // begin
  //
  // ClonarOS(aProximaOS.NumeroOS, 23, aProximaOS.TipoOS, aFiltro.Filial);
  // end;

end;

function CarregarRuasSuperLotadas(aFilial: String; AQuantidadeRuaSuperLotada: double): TStringList;
var
  ruas_superlotadas: TStringList;

begin

  ruas_superlotadas := TStringList.Create;

  Log('Carregando ruas super lotadas');
  dmdb.qryRuasExcessoOS.Close;
  dmdb.qryRuasExcessoOS.ParamByName('CODFILIAL').AsString := aFilial;
  dmdb.qryRuasExcessoOS.ParamByName('MAXIMOPORRUA').AsFloat := AQuantidadeRuaSuperLotada;
  dmdb.qryRuasExcessoOS.Open;

  if (dmdb.qryRuasExcessoOS.RecordCount > 0) then
  begin

    dmdb.qryRuasExcessoOS.First;

    while (not dmdb.qryRuasExcessoOS.Eof) do
    begin

      ruas_superlotadas.Add(dmdb.qryRuasExcessoOSRUA.AsString);
      dmdb.qryRuasExcessoOS.Next;
    end;
  end;

  dmdb.qryRuasExcessoOS.Close;

  Result := ruas_superlotadas;
end;

procedure CarregarTotaisOSPorRua(aFilial: string);
begin

  dmdb.qryTotalOSRuas.Close;
  dmdb.qryTotalOSRuas.ParamByName('CODFILIAL').AsString := aFilial;
  dmdb.qryTotalOSRuas.Open;
end;

procedure CarregarTotaisFuncionariosPorRua(aFilial: string);
begin

  dmdb.qryTotalFuncRuas.Close;
  dmdb.qryTotalFuncRuas.ParamByName('CODFILIAL').AsString := aFilial;
  dmdb.qryTotalFuncRuas.Open;
end;

procedure AtenderSolicitacoes(aFilial: string; aConfig: TConfiguracoes; aRegistrarAnalise: boolean);
var
  Senha: double;
  senha_anterior: double;
  Matricula: double;
  config_str: string;
  qtd_os_para_superlotada: double;
  filtro: TFiltro;
  proxima_os: TProximaOS;
  ruas_superlotadas: TStringList;
  percentual_separacao_finalizada: double;
  trabalhar_com_pallet_box: boolean;
  tipo_operador: TTipoOperador;

begin

  /// Verificando se há solicitações pendentes

  Log('Pesquisando solicitações');

  dmdb.qryCarregarSolicitacoes.Close;
  dmdb.qryCarregarSolicitacoes.Open;

  if dmdb.qryCarregarSolicitacoes.RecordCount = 0 then
  begin

    Log('Sem solicitações pendentes');
    dmdb.qryCarregarSolicitacoes.Close;
    Exit;
  end;

  try
    begin

      /// Obtendo a configuração que define a quantidade de OS pendentes
      /// pode definir uma rua como super lotada.

      qtd_os_para_superlotada := aConfig.qtd_os_rua_lotada_249;
      percentual_separacao_finalizada := aConfig.percentual_separacao_liberar_palletbox_263;
      trabalhar_com_pallet_box := aConfig.trabalha_com_palletbox_264;

      // PercentualFinalizacaoSeparacao

      /// Percorrendo todas as solicitações pendentes

      Log(IntToStr(dmdb.qryCarregarSolicitacoes.RecordCount) + ' solicitações encontradas');
      dmdb.qryCarregarSolicitacoes.First;

      filtro := TFiltro.Create;

      while (not dmdb.qryCarregarSolicitacoes.Eof) do
      begin

        Application.ProcessMessages;

        /// Carregando os totais de OS e funcionáios por rua
        /// a informação será usada pelo log da rotina
        CarregarTotaisOSPorRua(aFilial);
        CarregarTotaisFuncionariosPorRua(aFilial);

        /// Carregando as ruas que estão com excesso de OS dos tipos 58 e 98
        ruas_superlotadas := CarregarRuasSuperLotadas(aFilial, qtd_os_para_superlotada);

        /// Verificando se o funcionário já tem algo em andamento

        tipo_operador := TTipoOperador(Trunc(dmdb.qryCarregarSolicitacoesTIPOOPERADOR.AsFloat));
        Matricula := dmdb.qryCarregarSolicitacoesMATRICULA.AsFloat;
        Senha := dmdb.qryCarregarSolicitacoesSENHA.AsFloat;
        senha_anterior := SenhaEmExecucao(Matricula, tipo_operador);

        if (senha_anterior > 0) then
        begin

          /// Registrando o retorno do funcionário
          Log('Registrando retorno do funcionário: ' + FloatToStr(Matricula));
          RegistrarRetorno(Senha, senha_anterior);

          dmdb.cdsOSsAtribuidas.Insert;
          dmdb.cdsOSsAtribuidasDATA.AsDateTime := Now;
          dmdb.cdsOSsAtribuidasMATRICULA.AsFloat := Matricula;
          dmdb.cdsOSsAtribuidasNUMOS.AsFloat := dmdb.qryOSEmExecucaoNUMOS.AsFloat;
          dmdb.cdsOSsAtribuidasCODENDERECO.AsFloat := dmdb.qryOSEmExecucaoCODENDERECO.AsFloat;
          dmdb.cdsOSsAtribuidasCODENDERECOORIG.AsFloat := dmdb.qryOSEmExecucaoCODENDERECOORIG.AsFloat;
          dmdb.cdsOSsAtribuidasCODIGOUMA.AsFloat := dmdb.qryOSEmExecucaoCODIGOUMA.AsFloat;
          dmdb.cdsOSsAtribuidasTIPOOS.AsFloat := dmdb.qryOSEmExecucaoTIPOOS.AsFloat;
          dmdb.cdsOSsAtribuidasCRITERIO.AsFloat := 3;
          dmdb.cdsOSsAtribuidasARMAZEMTODO.AsFloat := 0;
          dmdb.cdsOSsAtribuidasSUPERLOTADA.AsFloat := 0;

          if dmdb.qryOSEmExecucaoFLAGSL.AsFloat > 0 then
          begin

            dmdb.cdsOSsAtribuidasSUPERLOTADA.AsFloat := 1;
          end;

          dmdb.cdsOSsAtribuidas.Post;

          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        /// O filtro contém as informações necessárias para pesquisa das OS

        filtro.Senha := dmdb.qryCarregarSolicitacoesSENHA.AsFloat;
        filtro.RuaInicial := dmdb.qryCarregarSolicitacoesRUARANGEINICIO.AsFloat;
        filtro.RuaFinal := dmdb.qryCarregarSolicitacoesRUARANGEFIM.AsFloat;
        filtro.BuscarNoArmazemTodo := False;
        filtro.Filial := aFilial;
        filtro.RuaAnterior := -1;
        filtro.OndaAnterior := -1;
        filtro.DataOndaAnterior := IncDay(Date, -30);
        filtro.RuaSuperLotadaAntes := False;
        filtro.TipoOperador := TTipoOperador(Trunc(dmdb.qryCarregarSolicitacoesTIPOOPERADOR.AsFloat));
        filtro.RangeRuasExcecao := RangeInformadoEDeExecao(aFilial, filtro.RuaInicial, filtro.RuaFinal, aConfig);
        filtro.ruasIgnorar := RuasExcluidas(filtro, aConfig);
        filtro.ruasSuperLotadas := ruas_superlotadas;
        filtro.Matricula := Matricula;
        filtro.DataSolicitacao := dmdb.qryCarregarSolicitacoesDTSOLICITACAO.AsDateTime;
        filtro.PercentualFinalizacaoSeparacao := percentual_separacao_finalizada;
        filtro.TrabalharComPalletBox := trabalhar_com_pallet_box;

        Log('Obtendo dados da tarefa anterior do funcionário: ' + FloatToStr(Matricula));
        dmdb.qryDadosSenhaAnterior.Close;
        dmdb.qryDadosSenhaAnterior.ParamByName('MATRICULA').AsFloat := Matricula;
        dmdb.qryDadosSenhaAnterior.ParamByName('SENHA').AsFloat := Senha;
        dmdb.qryDadosSenhaAnterior.Open;

        if (dmdb.qryDadosSenhaAnterior.RecordCount > 0) then
        begin

          filtro.SenhaAnterior := dmdb.qryDadosSenhaAnteriorSENHA.AsFloat;
          filtro.RuaSuperLotadaAntes := (dmdb.qryDadosSenhaAnteriorFLAGSL.AsString = 'S');
          filtro.RuaAnterior := dmdb.qryDadosSenhaAnteriorRUA.AsFloat;
          filtro.OndaAnterior := dmdb.qryDadosSenhaAnteriorNRONDA.AsFloat;
          filtro.DataSolicitacaoAnterior := dmdb.qryDadosSenhaAnteriorDTSOLICITACAO.AsDateTime;
          filtro.TipoOSAnterior := dmdb.qryDadosSenhaAnteriorTIPOOS.AsFloat;
          filtro.DataOndaAnterior := dmdb.qryDadosSenhaAnteriorDTONDA.AsDateTime;

          if filtro.RuaSuperLotadaAntes then
          begin

            filtro.ruasSuperLotadas.Add(FloatToStr(filtro.RuaAnterior));
          end;
        end;

        dmdb.qryDadosSenhaAnterior.Close;

        proxima_os := TProximaOS.Create(Senha, aRegistrarAnalise);

        // Com as ruas definidas pelo usuário

        // Item 5 - Se o funcionário estava em uma rua super lotada, vai continuar nela até a rua sair dessa situação
        Log('(Ordem 5) Analisando critério 5 - Senha: ' + FloatToStr(Senha));
        if (filtro.RuaSuperLotadaAntes) then
        begin
          if Criterio5_ProximaOSAbastecimentoNaRua(filtro, proxima_os) then
          begin

            Log('CRITÉRIO 5: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
              FloatToStr(Matricula));
            AtenderSolicitacao(filtro, proxima_os);
            dmdb.qryCarregarSolicitacoes.Next;
            continue;
          end;
        end;

        // Item 6 - Verificando ruas super lotadas mas priorizando as ruas com maior quantidade de OS pendentes
        Log('(Ordem 6) Analisando critério 6 - Senha: ' + FloatToStr(Senha));
        if Criterio6_ProximaOSAbastecimentoQualquerRua(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 6: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 6.5 - Separação, processo conhecido como Pallet Box
        Log('(Ordem 7) Analisando critério 6.5 - Senha: ' + FloatToStr(Senha));
        if Criterio6_5_ProximaOSPalletBox(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 6.5: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 7 - OS de abastecimento corretivo mas com pendências
        Log('(Ordem 8) Analisando critério 7 - Senha: ' + FloatToStr(Senha));
        if Criterio7_ProximaOSPendenciaAbastecimentoCorretivo(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 7: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 8 - Pesquisando OS normalmente, sem super lotação, priorizando onda e rua que ele estava antes
        Log('(Ordem 9) Analisando critério 8 - Senha: ' + FloatToStr(Senha));
        if Criterio8_ProximaOSUltimaRua(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 8: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 10 - Armazenamento comum
        Log('(Ordem 10) Analisando critério 10 - Senha: ' + FloatToStr(Senha));
        if Criterio10_ProximaOSAbastecimento(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 10: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 8.1 - Separação, processo conhecido como Pallet Box
        // Log('Analisando critério 8.1 - Senha: ' + FloatToStr(senha));
        // if ProximaOSPalletBox(filtro, proxima_os) then
        // begin
        //
        // Log('CRITÉRIO 8.1: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua)  +  ' Funcionário - ' + FloatToStr(matricula));
        // AtenderSolicitacao(filtro, proxima_os);
        // dmdb.qryCarregarSolicitacoes.Next;
        // Continue;
        // end;

        // Item 8.2 - Abastecimento preventivo sem onda
        Log('(Ordem 11) Analisando critério 8.2 - Senha: ' + FloatToStr(Senha));
        if Criterio8_2_ProximaOSAbastecimentoPreventivoSemOnda(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 8.2: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 9 - Daqui em diante, as mesmas pesquisas anteriores mas buscando o galpão todo

        Log('(Ordem 12) CRITÉRIO 10 - A pesquisa passa a ser no armazém todo');
        filtro.BuscarNoArmazemTodo := True;

        // Item 5 - Se o funcionário estava em uma rua super lotada, vai continuar nela até a rua sair dessa situação (Armazém todo)
        Log('(Ordem 13) Analisando critério 5 (Armazém todo) - Senha: ' + FloatToStr(Senha));
        if filtro.RuaSuperLotadaAntes then
        begin
          if Criterio5_ProximaOSAbastecimentoNaRua(filtro, proxima_os) then
          begin

            Log('CRITÉRIO 5 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
              FloatToStr(Matricula));
            AtenderSolicitacao(filtro, proxima_os);
            dmdb.qryCarregarSolicitacoes.Next;
            continue;
          end;
        end;

        // Item 6 - Verificando ruas super lotadas mas priorizando as ruas com maior quantidade de OS pendentes (Armazém todo)
        Log('(Ordem 14) Analisando critério 6 (Armazém todo) - Senha: ' + FloatToStr(Senha));
        if Criterio6_ProximaOSAbastecimentoQualquerRua(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 6 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 6.5 - Separação, processo conhecido como Pallet Box
        Log('(Ordem 15) Analisando critério 6.5 - Senha: ' + FloatToStr(Senha));
        if Criterio6_5_ProximaOSPalletBox(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 6.5 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 7 - OS de abastecimento corretivo mas com pendências (Armazém todo)
        Log('(Ordem 16) Analisando critério 7 (Armazém todo) - Senha: ' + FloatToStr(Senha));
        if Criterio7_ProximaOSPendenciaAbastecimentoCorretivo(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 7 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 8 - Pesquisando OS normalmente, sem super lotação, priorizando onda e rua que ele estava antes (Armazém todo)
        Log('(Ordem 17) Analisando critério 8 (Armazém todo) - Senha: ' + FloatToStr(Senha));
        if Criterio8_ProximaOSUltimaRua(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 8 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 8.1 - Separação, processo conhecido como Pallet Box (Armazém todo)
        // Log('Analisando critério 8.1 (Armazém todo) - Senha: ' + FloatToStr(senha));
        // if ProximaOSPalletBox(filtro, proxima_os) then
        // begin
        //
        // Log('CRITÉRIO 8.1 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua)  +  ' Funcionário - ' + FloatToStr(matricula));
        // AtenderSolicitacao(filtro, proxima_os);
        // dmdb.qryCarregarSolicitacoes.Next;
        // Continue;
        // end;

        // Item 8.2 - Abastecimento preventivo sem onda (Armazém todo)
        Log('(Ordem 18) Analisando critério 8.2 (Armazém todo) - Senha: ' + FloatToStr(Senha));
        if Criterio8_2_ProximaOSAbastecimentoPreventivoSemOnda(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 8.2 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;


        // Voltando a considerar apenas as ruas que o usuário informou

        Log('(Ordem 19) A pesquisa volta a ser pelo intervalo definido pelo separador');
        filtro.BuscarNoArmazemTodo := False;

        // Item 9.5 - O.S. preventiva baseadas em pedidos
        Log('(Ordem 20) Analisando critério 9.5 - Senha: ' + FloatToStr(Senha));
        if Criterio9_5_ProximaOSCorretivaBaseadaEmPedido(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 9.5: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

//        // Item 10 - Armazenamento comum
//        Log('(Ordem 19) Analisando critério 10 - Senha: ' + FloatToStr(Senha));
//        if ProximaOSAbastecimento(filtro, proxima_os) then
//        begin
//
//          Log('CRITÉRIO 10: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
//            FloatToStr(Matricula));
//          AtenderSolicitacao(filtro, proxima_os);
//          dmdb.qryCarregarSolicitacoes.Next;
//          continue;
//        end;

        // Item 11 - Abastecimento preventivo
        Log('(Ordem 21) Analisando critério 11 - Senha: ' + FloatToStr(Senha));
        if Criterio11_ProximaOSAbastecimentoPreventivo(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 11: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;


        // Item 12 - Mesmas coisas mas com galpão inteiro
         Log('(Ordem 22) CRITÉRIO 12: A pesquisa passa a ser no armazém todo novamente');
        filtro.BuscarNoArmazemTodo := True;

        // Item 9.5 - O.S. preventiva baseadas em pedidos (Armazém todo)
        Log('(Ordem 23) Analisando critério 9.5 (Armazém todo) - Senha: ' + FloatToStr(Senha));
        if Criterio9_5_ProximaOSCorretivaBaseadaEmPedido(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 9.5 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 10 - Armazenamento comum (Armazém todo)
        Log('(Ordem 24) Analisando critério 10 (Armazém todo) - Senha: ' + FloatToStr(Senha));
        if Criterio10_ProximaOSAbastecimento(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 10 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 11 - Abastecimento preventivo (Armazém todo)
        Log('(Ordem 25) Analisando critério 11 (Armazém todo) - Senha: ' + FloatToStr(Senha));
        if Criterio11_ProximaOSAbastecimentoPreventivo(filtro, proxima_os) then
        begin

          Log('CRITÉRIO 11 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        filtro.BuscarNoArmazemTodo := False;

        Log('SOLICITAÇÃO NÃO ATENDIDA: SENHA - ' + FloatToStr(proxima_os.Senha) + ' Funcionário - ' + FloatToStr(Matricula));
        dmdb.qryCarregarSolicitacoes.Next;
      end;

      dmdb.qryCarregarSolicitacoes.Close;

      dmdb.qryTotalOSRuas.Close;
      dmdb.qryTotalFuncRuas.Close;

      FreeAndNil(filtro);

    end;
  except
    on E: Exception do
    begin
      Log('Erro: ' + E.Message);
      Log('Processo atual: ' + processo_atual);
    end;
  end;

end;

function SenhaEmExecucao(aMatricula: double; aTipoOperador: TTipoOperador): double;
var
  Senha: double;
begin
  {
    Retorna o número da OS e senha que está em execução pelo usuário
  }

  Senha := 0;

  dmdb.qryOSEmExecucao.Close;
  dmdb.qryOSEmExecucao.ParamByName('MATRICULA').AsFloat := aMatricula;
  dmdb.qryOSEmExecucao.ParamByName('TIPOOPERADOR').AsString := IfThen(aTipoOperador = tpEmpilhador, 'E', 'P');
  dmdb.qryOSEmExecucao.Open;

  if (dmdb.qryOSEmExecucao.RecordCount > 0) then
  begin

    Senha := dmdb.qryOSEmExecucaoSENHA.AsFloat;
  end;

  dmdb.qryOSEmExecucao.Close;
  Result := Senha;
end;

procedure RegistrarRetorno(aSenhaAtual: double; aSenhaAnterior: double);
begin
  {
    Registra o retorno de um funcionário no atendimento de uma OS
  }

  with dmdb do
  begin

    qryCancelarSenha.Close;
    qryCancelarSenha.ParamByName('SENHA').AsFloat := aSenhaAnterior;
    qryCancelarSenha.ExecSQL;

    qryRegistrarRetorno.Close;
    qryRegistrarRetorno.ParamByName('SENHAANTERIOR').AsFloat := aSenhaAnterior;
    qryRegistrarRetorno.ParamByName('SENHAATUAL').AsFloat := aSenhaAtual;
    qryRegistrarRetorno.ExecSQL;
  end;

end;

function RangeInformadoEDeExecao(aFilial: string; aRuaInicial, aRuaFinal: double; aConfig: TConfiguracoes): boolean;
var
  // lista_ruas_excecao: TStringList;
  I: double;
  range_excecao: boolean;
begin
  /// Retorna se o range de ruas informado é composto apenas
  /// por ruas que pertencem a configuração de ruas de exceção
  ///

  range_excecao := True;
  I := aRuaInicial;

  while I <= aRuaFinal do
  begin

    if aConfig.ruas_excecao_248.IndexOf(FloatToStr(I)) < 0 then
    begin

      range_excecao := False;
      break;
    end;

    I := I + 1;
  end;

  Result := range_excecao;

end;

procedure ExibirAnalise();
begin

  if (dmdb.cdsOSsAtribuidas.State <> dsBrowse) or (dmdb.cdsOSsAtribuidas.RecordCount = 0) then
  begin

    Exit;
  end;

  if not Assigned(frmAnalisesatribuicao) then
  begin

    Application.CreateForm(TfrmAnalisesatribuicao, frmAnalisesatribuicao);
  end;

  frmAnalisesatribuicao.ShowModal();
end;

{ TConfiguracoes }

class function TConfiguracoes.CarregarConfiguracoes(aFilial: string): TConfiguracoes;
var
  config: TConfiguracoes;
  config_str: string;
  config_float: double;
begin

  config := TConfiguracoes.Create;
  Result := config;

  with dmdb do
  begin

    qryConfiguracoes.Close;
    qryConfiguracoes.ParamByName('CODFILIAL').AsString := aFilial;
    qryConfiguracoes.Open;

    qryConfiguracoes.First;

    while (not qryConfiguracoes.Eof) do
    begin

      if qryConfiguracoesCODIGO.AsFloat = 248 then
      begin

        config.ruas_excecao_248.Delimiter := ',';
        config.ruas_excecao_248.DelimitedText := StringReplace(qryConfiguracoesVALOR.AsString, ' ', '', [rfReplaceAll]);
      end;

      if qryConfiguracoesCODIGO.AsFloat = 249 then
      begin

        config_str := qryConfiguracoesVALOR.AsString;

        if TryStrToFloat(config_str, config_float) then
        begin

          config.qtd_os_rua_lotada_249 := Trunc(config_float);
        end;

      end;

      if qryConfiguracoesCODIGO.AsFloat = 251 then
      begin

        config_str := qryConfiguracoesVALOR.AsString;

        if TryStrToFloat(config_str, config_float) then
        begin

          config.qtd_limite_paleteiros_rua_251 := Trunc(config_float);
        end;

      end;

      if qryConfiguracoesCODIGO.AsFloat = 252 then
      begin

        config_str := qryConfiguracoesVALOR.AsString;

        if TryStrToFloat(config_str, config_float) then
        begin

          config.qtd_limite_empilhadores_rua_252 := Trunc(config_float);
        end;

      end;

      if qryConfiguracoesCODIGO.AsFloat = 262 then
      begin

        config_str := qryConfiguracoesVALOR.AsString;

        if TryStrToFloat(config_str, config_float) then
        begin

          config.minutos_os_reservada_262 := Trunc(config_float);
        end;

      end;

      if qryConfiguracoesCODIGO.AsFloat = 263 then
      begin

        config_str := qryConfiguracoesVALOR.AsString;

        if TryStrToFloat(config_str, config_float) then
        begin

          config.percentual_separacao_liberar_palletbox_263 := Trunc(config_float);
        end;

      end;

      if qryConfiguracoesCODIGO.AsFloat = 264 then
      begin

        config_str := qryConfiguracoesVALOR.AsString;
        config.trabalha_com_palletbox_264 := config_str = 'S';
      end;

      qryConfiguracoes.Next;
    end;

    qryConfiguracoes.Close;

  end;

end;

constructor TConfiguracoes.Create;
begin

  ruas_excecao_248 := TStringList.Create;
  qtd_os_rua_lotada_249 := 0;
  qtd_limite_paleteiros_rua_251 := 0;
  qtd_limite_empilhadores_rua_252 := 0;
  minutos_os_reservada_262 := 0;
  percentual_separacao_liberar_palletbox_263 := 100;
  trabalha_com_palletbox_264 := False;

end;

end.
