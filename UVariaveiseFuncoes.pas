unit UVariaveiseFuncoes;

interface

Uses
  Graphics, IniFiles, Variants, SysUtils, Classes, StrUtils, DateUtils, Windows, Forms, uProximaOS, uConvocacaoAtivaEnums
  // , Clipbrd
    ;

type
  TProcessadorCriterio = class
  public
    function executar(codigo_criterio: string; filtro: TFiltro; proximaOS: TProximaOS): boolean;
  end;

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
  FrmInicial.memo.Lines.Add(FloatToStr(logs) + ') ' + DateTimeToStr(Now) + ': ' + aMensagem);
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

    aProximaOS.RegistrarAnaliseCriterios('Critério 5 não será avaliado pois é destinado apenas para operadores de empilhadeira');
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
    end
    else
    begin

      aProximaOS.RegistrarAnaliseCriterios('');
      aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
      aProximaOS.RegistrarAnaliseCriterios('Nenhuma OS encontrada');
    end;

    Close;
  end;
end;

function Criterio10_ProximaOSAbastecimento(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tempo: TDateTime;
  ruasIgnorar, ruasSuperLotadas: string;
  qb: TQueryBuilder;
begin

  ruasIgnorar := aFiltro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := aFiltro.ruasSuperLotadas.DelimitedText;

  // Critério 10

  Result := False;
  tempo := Now;

  // Somente para empilhadores
  if aFiltro.TipoOperador <> tpEmpilhador then
  begin

    aProximaOS.RegistrarAnaliseCriterios('Critério 10 não será avaliado pois é destinado apenas para operadores de empilhadeira');
    Exit;
  end;

  qb := TQueryBuilder.Create();

  with dmdb.qryAuxiliar do
  begin

    Close;
    SQL.Clear;
    SQL.Add(qb.GetQuery(10, aFiltro));

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
    end
    else
    begin

      aProximaOS.RegistrarAnaliseCriterios('');
      aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
      aProximaOS.RegistrarAnaliseCriterios('Nenhuma OS encontrada');
    end;

    Close;
  end;
end;

function Criterio6_ProximaOSAbastecimentoQualquerRua(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tempo: TDateTime;
  qb: TQueryBuilder;
begin

  // Item 6

  Result := False;
  tempo := Now;

  // Somente para empilhadores
  if aFiltro.TipoOperador <> tpEmpilhador then
  begin

    aProximaOS.RegistrarAnaliseCriterios('Critério 6 não será avaliado pois é destinado apenas para operadores de empilhadeira');
    Exit;
  end;

  if (aFiltro.ruasSuperLotadas.Count <= 0) then
  begin

    aProximaOS.RegistrarAnaliseCriterios('Critério 6 não será avaliado pois não há ruas super lotadas de OSs');
    Exit;
  end;

  qb := TQueryBuilder.Create();

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
    end
    else
    begin

      aProximaOS.RegistrarAnaliseCriterios('');
      aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
      aProximaOS.RegistrarAnaliseCriterios('Nenhuma OS encontrada');
    end;

    Close;

  end;
end;

function Criterio7_ProximaOSPendenciaAbastecimentoCorretivo(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tipo_os: integer;
  tempo: TDateTime;
  qb: TQueryBuilder;
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
    end
    else
    begin

      aProximaOS.RegistrarAnaliseCriterios('');
      aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
      aProximaOS.RegistrarAnaliseCriterios('Nenhuma OS encontrada');
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

      aProximaOS.RegistrarAnaliseCriterios('A rua encontrada (' + FloatToStr(rua_encontrada) + ') não está entre as ruas do filtro informado');

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
    end
    else
    begin

      aProximaOS.RegistrarAnaliseCriterios('');
      aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
      aProximaOS.RegistrarAnaliseCriterios('Nenhuma OS encontrada');
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

    aProximaOS.RegistrarAnaliseCriterios('Critério 6.5 não será avaliado pois trabalhar com pallet box não está habilitado');
    Exit;
  end;

  // Somente para paleteiros
  if aFiltro.TipoOperador <> tpPaleteiro then
  begin

    aProximaOS.RegistrarAnaliseCriterios('Critério 6.5 não será avaliado pois é destinado apenas para operadores de paleteira');
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
    end
    else
    begin

      aProximaOS.RegistrarAnaliseCriterios('');
      aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
      aProximaOS.RegistrarAnaliseCriterios('Nenhuma OS encontrada');
    end;

    Close();

  end;

end;

function Criterio8_2_ProximaOSAbastecimentoPreventivoSemOnda(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tempo: TDateTime;
  tipo_os: integer;
  rua_encontrada: double;
  qb: TQueryBuilder;
begin

  // Item 8.2
  Result := False;
  aProximaOS.RegistrarAnaliseCriterios('Critério 8.2 não será avaliado pois está desabilitado');
  Log('Critério 8.2 - Desabilitado temporariamente');
  Exit;
  tempo := Now;

  ODACSessionGlobal.StartTransaction();

  try
    begin

      qb := TQueryBuilder.Create;

      with dmdb.qryAuxiliar do
      begin
        Close;
        SQL.Clear;
        SQL.Add(qb.GetQuery(8.2, aFiltro));

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

          aProximaOS.RegistrarAnaliseCriterios('A rua encontrada (' + FloatToStr(rua_encontrada) + ') não está entre as ruas do filtro informado');

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
        end
        else
        begin

          aProximaOS.RegistrarAnaliseCriterios('');
          aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
          aProximaOS.RegistrarAnaliseCriterios('Nenhuma OS encontrada');
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
  qb: TQueryBuilder;
begin

  // Item 11

  Result := False;
  tempo := Now;

  qb := TQueryBuilder.Create;

  with dmdb.qryAuxiliar do
  begin
    Close;
    SQL.Clear;
    SQL.Add(qb.GetQuery(11, aFiltro));

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
    end
    else
    begin

      aProximaOS.RegistrarAnaliseCriterios('');
      aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
      aProximaOS.RegistrarAnaliseCriterios('Nenhuma OS encontrada');
    end;

    Close();

  end;

end;

function Criterio9_5_ProximaOSCorretivaBaseadaEmPedido(aFiltro: TFiltro; aProximaOS: TProximaOS): boolean;
var
  tempo: TDateTime;
  tipo_os: integer;
  rua_encontrada: double;
  qb: TQueryBuilder;
begin

  // Critério 9.5
  Result := False;

  aProximaOS.RegistrarAnaliseCriterios('Critério 9.5 não será avaliado pois está desabilitado');
  Log('O critério 9.5 foi desabilitado');
  Exit;

  tempo := Now;
  qb := TQueryBuilder.Create;

  with dmdb.qryAuxiliar do
  begin
    Close;
    SQL.Clear;
    SQL.Add(qb.GetQuery(9.5, aFiltro));

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

      aProximaOS.RegistrarAnaliseCriterios('A rua encontrada (' + FloatToStr(rua_encontrada) + ') não está entre as ruas do filtro informado');

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
    end
    else
    begin

      aProximaOS.RegistrarAnaliseCriterios('');
      aProximaOS.RegistrarAnaliseCriterios('--------------------------------------');
      aProximaOS.RegistrarAnaliseCriterios('Nenhuma OS encontrada');
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
  processador: TProcessadorCriterio;

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

        processador := TProcessadorCriterio.Create;

        // Com as ruas definidas pelo usuário

        // Item 5 - Se o funcionário estava em uma rua super lotada, vai continuar nela até a rua sair dessa situação
        Log('(Ordem 5) Analisando critério 5 - Senha: ' + FloatToStr(Senha));
        if (filtro.RuaSuperLotadaAntes) then
        begin
          if processador.executar('5', filtro, proxima_os) then
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
        if processador.executar('6', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 6: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 6.5 - Separação, processo conhecido como Pallet Box
        Log('(Ordem 7) Analisando critério 6.5 - Senha: ' + FloatToStr(Senha));
        if processador.executar('6.5', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 6.5: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 7 - OS de abastecimento corretivo mas com pendências
        Log('(Ordem 8) Analisando critério 7 - Senha: ' + FloatToStr(Senha));
        if processador.executar('7', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 7: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 7 - OS de abastecimento corretivo mas com pendências
        Log('(Ordem 9) Analisando critério 7.5 - Senha: ' + FloatToStr(Senha));
        if processador.executar('7.5', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 7.5: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 8 - Pesquisando OS normalmente, sem super lotação, priorizando onda e rua que ele estava antes
        Log('(Ordem 10) Analisando critério 8 - Senha: ' + FloatToStr(Senha));
        if processador.executar('8', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 8: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 7 - OS de abastecimento corretivo mas com pendências
        Log('(Ordem 11) Analisando critério 8.5 - Senha: ' + FloatToStr(Senha));
        if processador.executar('8.5', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 8.5: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 10 - Armazenamento comum
        Log('(Ordem 12) Analisando critério 10 - Senha: ' + FloatToStr(Senha));
        if processador.executar('10', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 10: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;


        // Item 9 - Daqui em diante, as mesmas pesquisas anteriores mas buscando o galpão todo

        Log('(Ordem 13) CRITÉRIO 9 - A pesquisa passa a ser no armazém todo');
        filtro.BuscarNoArmazemTodo := True;

        // Item 6 - Verificando ruas super lotadas mas priorizando as ruas com maior quantidade de OS pendentes (Armazém todo)
        Log('(Ordem 14) Analisando critério 6 (Armazém todo) - Senha: ' + FloatToStr(Senha));
        if processador.executar('6', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 6 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 7 - OS de abastecimento corretivo mas com pendências (Armazém todo)
        Log('(Ordem 15) Analisando critério 7 (Armazém todo) - Senha: ' + FloatToStr(Senha));
        if processador.executar('7', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 7 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        Log('(Ordem 16) Analisando critério 7.5 (Armazém todo) - Senha: ' + FloatToStr(Senha));
        if processador.executar('7.5', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 7.5 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 8 - Pesquisando OS normalmente, sem super lotação, priorizando onda e rua que ele estava antes (Armazém todo)
        Log('(Ordem 17) Analisando critério 8 (Armazém todo) - Senha: ' + FloatToStr(Senha));
        if processador.executar('8', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 8 (Armazém todo): OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Voltando a considerar apenas as ruas que o usuário informou

        Log('(Ordem 18) A pesquisa volta a ser pelo intervalo definido pelo separador');
        filtro.BuscarNoArmazemTodo := False;

        // Item 6.5 - Separação, processo conhecido como Pallet Box
        Log('(Ordem 19) Analisando critério 11 - Senha: ' + FloatToStr(Senha));
        if processador.executar('11', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 11: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        Log('(Ordem 20) CRITÉRIO 12 - A pesquisa volta a ser pelo armazém todo');
        filtro.BuscarNoArmazemTodo := True;

        Log('(Ordem 21) Analisando critério 6.5 - Senha: ' + FloatToStr(Senha));
        if processador.executar('6.5', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 6.5: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        Log('(Ordem 22) Analisando critério 8.5 - Senha: ' + FloatToStr(Senha));
        if processador.executar('8.5', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 8.5: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        Log('(Ordem 23) Analisando critério 10 - Senha: ' + FloatToStr(Senha));
        if processador.executar('10', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 10: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
            FloatToStr(Matricula));
          AtenderSolicitacao(filtro, proxima_os);
          dmdb.qryCarregarSolicitacoes.Next;
          continue;
        end;

        // Item 11 - Abastecimento preventivo
        Log('(Ordem 24) Analisando critério 11 - Senha: ' + FloatToStr(Senha));
        if processador.executar('11', filtro, proxima_os) then
        begin

          Log('CRITÉRIO 11: OS - ' + FloatToStr(proxima_os.NumeroOS) + ' RUA - ' + FloatToStr(proxima_os.Rua) + ' Funcionário - ' +
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

{ TProcessadorCriterio }

function TProcessadorCriterio.executar(codigo_criterio: string; filtro: TFiltro; proximaOS: TProximaOS): boolean;
begin

  Result := False;

  if codigo_criterio = '5' then
  begin

    Result := Criterio5_ProximaOSAbastecimentoNaRua(filtro, proximaOS);
    Exit;
  end;

  if codigo_criterio = '6' then
  begin

    Result := Criterio6_ProximaOSAbastecimentoQualquerRua(filtro, proximaOS);
    Exit;
  end;

  if codigo_criterio = '6.5' then
  begin

    Result := Criterio6_5_ProximaOSPalletBox(filtro, proximaOS);
    Exit;
  end;

  if codigo_criterio = '7' then
  begin

    Result := Criterio7_ProximaOSPendenciaAbastecimentoCorretivo(filtro, proximaOS);
    Exit;
  end;

  if codigo_criterio = '7.5' then
  begin

    Result := False;
    Exit;
  end;

  if codigo_criterio = '8' then
  begin

    Result := Criterio8_ProximaOSUltimaRua(filtro, proximaOS);
    Exit;
  end;

  if codigo_criterio = '8.2' then
  begin

    Result := Criterio8_2_ProximaOSAbastecimentoPreventivoSemOnda(filtro, proximaOS);
    Exit;
  end;

  if codigo_criterio = '8.5' then
  begin

    Result := False;
    Exit;
  end;


  if codigo_criterio = '9.5' then
  begin

    Result := Criterio9_5_ProximaOSCorretivaBaseadaEmPedido(filtro, proximaOS);
    Exit;
  end;

  if codigo_criterio = '10' then
  begin

    Result := Criterio10_ProximaOSAbastecimento(filtro, proximaOS);
    Exit;
  end;

  if codigo_criterio = '11' then
  begin

    Result := Criterio11_ProximaOSAbastecimentoPreventivo(filtro, proximaOS);
    Exit;
  end;

end;

end.
