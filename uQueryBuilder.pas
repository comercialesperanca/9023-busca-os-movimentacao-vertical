unit uQueryBuilder;

interface

uses SysUtils, Classes, uProximaOS;

type
  TQueryBuilder = class
  private
    function GetQueryCriterio5(filtro: TFiltro): string;
    function GetQueryCriterio6(filtro: TFiltro): string;
    function GetQueryCriterio6_5(filtro: TFiltro): string;
    function GetQueryCriterio7(filtro: TFiltro): string;
    function GetQueryCriterio8(filtro: TFiltro): string;
    function GetQueryCriterio8_2(filtro: TFiltro): string;
    function GetQueryCriterio9_5(filtro: TFiltro): string;
    function GetQueryCriterio10(filtro: TFiltro): string;

  public
    function GetQuery(numero_criterio: double; filtro: TFiltro): string;
  end;

implementation

{ TQueryBuilder }

uses uConvocacaoAtivaEnums;

function TQueryBuilder.GetQuery(numero_criterio: double; filtro: TFiltro): string;
begin

  Result := '';

  if numero_criterio = 5 then
  begin

    Result := self.GetQueryCriterio5(filtro);
  end;

  if numero_criterio = 6 then
  begin

    Result := self.GetQueryCriterio6(filtro);
  end;

  if numero_criterio = 6.5 then
  begin

    Result := self.GetQueryCriterio6_5(filtro);
  end;

  if numero_criterio = 7 then
  begin

    Result := self.GetQueryCriterio7(filtro);
  end;

  if numero_criterio = 8 then
  begin

    Result := self.GetQueryCriterio8(filtro);
  end;

  if numero_criterio = 8.2 then
  begin

    Result := self.GetQueryCriterio8_2(filtro);
  end;

  if numero_criterio = 9.5 then
  begin

    Result := self.GetQueryCriterio9_5(filtro);
  end;

  if numero_criterio = 10 then
  begin

    Result := self.GetQueryCriterio10(filtro);
  end;

end;

function TQueryBuilder.GetQueryCriterio10(filtro: TFiltro): string;
var
  sql: TStringList;
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sql := TStringList.Create();

  sql.Add(' select                                                                               ');
  sql.Add('   numos,                                                                             ');
  sql.Add('   rua,                                                                               ');
  sql.Add('   codendereco,                                                                       ');
  sql.Add('   codigouma,                                                                         ');
  sql.Add('   codenderecoorig,                                                                   ');
  sql.Add('   tipoos                                                                             ');
  sql.Add(' from (                                                                               ');
  sql.Add(' Select pcmovendpend.numos                                                            ');
  sql.Add('        , nvl(pcest.qtestger -                                                        ');
  sql.Add(' 			pcest.qtreserv -                                                               ');
  sql.Add(' 			pcest.qtbloqueada -                                                            ');
  sql.Add(' 			pcest.qtpendente,0) estoque                                                    ');
  sql.Add('        , pcest.qtgirodia                                                             ');
  sql.Add('        , pcmovendpend.data                                                           ');
  sql.Add('        , count(pcmovendpend.numos) over (partition by pcendereco.rua ) as totalrua   ');
  sql.Add('        , pcmovendpend.codendereco                                                    ');
  sql.Add('        , pcmovendpend.codigouma                                                      ');
  sql.Add('        , pcmovendpend.codenderecoorig                                                ');
  sql.Add('        , pcendereco.rua                                                              ');
  sql.Add('        , pcmovendpend.tipoos                                                         ');
  sql.Add(' from pcmovendpend                                                                    ');
  sql.Add(' join pcendereco on pcendereco.codendereco = pcmovendpend.codendereco                 ');
  sql.Add(' join pcmovendpend mep97 on pcmovendpend.codigouma = mep97.codigouma                  ');
  sql.Add('                             and mep97.tipoos = 97                                    ');
  sql.Add('                             and mep97.numtranswms = pcmovendpend.numtranswms         ');
  sql.Add('                             and mep97.dtfimos is not null                            ');
  sql.Add(' join pcest on pcest.codfilial = pcmovendpend.codfilial                               ');
  sql.Add('           and pcest.codprod = pcmovendpend.codprod                                   ');
  sql.Add(' where pcmovendpend.data > sysdate - 30                                               ');
  sql.Add('     and pcmovendpend.codfilial = :CODFILIAL                                          ');
  sql.Add('     and pcmovendpend.posicao = ''P''                                                 ');
  sql.Add('     and pcmovendpend.dtestorno is null                                               ');
  sql.Add('     and pcmovendpend.tipoos = 98                                                     ');
  sql.Add('     and pcmovendpend.codfuncos is null                                               ');
  sql.Add('     and not exists (select bofilaos.numos                                            ');
  sql.Add(' 					FROM bofilaos where bofilaos.numos = pcmovendpend.numos                    ');
  sql.Add(' 					and bofilaos.status in (''E'',''R''))                               ');

  sql.Add(' 		and not exists (select bofilaosR.numos                                ');
  sql.Add(' 		                  FROM bofilaosR                                      ');
  sql.Add(' 		                  join bofilaos                                       ');
  sql.Add(' 		                    on bofilaosR.senha = bofilaos.senha               ');
  sql.Add(' 		                  where bofilaosR.numos = pcmovendpend.numos          ');
  sql.Add(' 		                  and bofilaos.status in (''E'',''R''))               ');

  sql.Add(' and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                      ');
  sql.Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                    ');

  if (filtro.ruasIgnorar.Count > 0) then
  begin

    sql.Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
    sql.Add(' and pcendereco.rua not in (' + filtro.ruasIgnorar.DelimitedText + ' )');
  end;

  sql.Add(' and not exists (select pend.numos from booscompendencia pend ');
  sql.Add('                 join pcmovendpend mep on mep.numos = pend.numos ');
  sql.Add('                 where pend.dataliberacao is null ');
  sql.Add('                 and mep.codprod = pcmovendpend.codprod ) ');

  sql.Add(' order by pcmovendpend.data, estoque, pcest.qtgirodia desc )                          ');
  sql.Add(' where rownum = 1                                                                     ');

  Result := sql.Text;

end;

function TQueryBuilder.GetQueryCriterio5(filtro: TFiltro): string;
var
  sql: TStringList;
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sql := TStringList.Create();

  sql.Add(' select                                                                               ');
  sql.Add('   numos,                                                                             ');
  sql.Add('   rua,                                                                               ');
  sql.Add('   codendereco,                                                                       ');
  sql.Add('   codigouma,                                                                         ');
  sql.Add('   codenderecoorig,                                                                   ');
  sql.Add('   tipoos                                                                             ');
  sql.Add(' from (                                                                               ');
  sql.Add(' Select pcmovendpend.numos                                                            ');
  sql.Add('        , nvl(pcest.qtestger -                                                        ');
  sql.Add(' 			pcest.qtreserv -                                                               ');
  sql.Add(' 			pcest.qtbloqueada -                                                            ');
  sql.Add(' 			pcest.qtpendente,0) estoque                                                    ');
  sql.Add('        , pcest.qtgirodia                                                             ');
  sql.Add('        , pcmovendpend.data                                                           ');
  sql.Add('        , count(pcmovendpend.numos) over (partition by pcendereco.rua ) as totalrua   ');
  sql.Add('        , pcmovendpend.codendereco                                                    ');
  sql.Add('        , pcmovendpend.codigouma                                                      ');
  sql.Add('        , pcmovendpend.codenderecoorig                                                ');
  sql.Add('        , pcendereco.rua                                                              ');
  sql.Add('        , pcmovendpend.tipoos                                                         ');
  sql.Add(' from pcmovendpend                                                                    ');
  sql.Add(' join pcendereco on pcendereco.codendereco = pcmovendpend.codendereco                 ');
  sql.Add(' join pcmovendpend mep97 on pcmovendpend.codigouma = mep97.codigouma                  ');
  sql.Add('                             and mep97.tipoos = 97                                    ');
  sql.Add('                             and mep97.numtranswms = pcmovendpend.numtranswms         ');
  sql.Add('                             and mep97.dtfimos is not null                            ');
  sql.Add(' join pcest on pcest.codfilial = pcmovendpend.codfilial                               ');
  sql.Add('           and pcest.codprod = pcmovendpend.codprod                                   ');
  sql.Add(' where pcmovendpend.data > sysdate - 30                                               ');
  sql.Add('     and pcmovendpend.codfilial = :CODFILIAL                                          ');
  sql.Add('     and pcmovendpend.posicao = ''P''                                                 ');
  sql.Add('     and pcmovendpend.dtestorno is null                                               ');
  sql.Add('     and pcmovendpend.tipoos = 98                                                     ');
  sql.Add('     and pcendereco.rua = :RUA                                                        ');
  sql.Add('     and pcmovendpend.codfuncos is null                                               ');
  sql.Add('     and not exists (select bofilaos.numos                                            ');
  sql.Add(' 					FROM bofilaos where bofilaos.numos = pcmovendpend.numos                    ');
  sql.Add(' 					and bofilaos.status in (''E'',''R''))                                      ');
  sql.Add(' 		and not exists (select bofilaosR.numos                                           ');
  sql.Add(' 		                  FROM bofilaosR                                                 ');
  sql.Add(' 		                  join bofilaos                                                  ');
  sql.Add(' 		                    on bofilaosR.senha = bofilaos.senha                          ');
  sql.Add(' 		                  where bofilaosR.numos = pcmovendpend.numos                     ');
  sql.Add(' 		                  and bofilaos.status in (''E'',''R''))                          ');
  sql.Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                               ');
  sql.Add(' and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                                 ');

  if (not filtro.RuaSuperLotadaAntes) then
  begin

    if (filtro.ruasIgnorar.Count > 0) then
    begin

      sql.Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
      sql.Add(' and pcendereco.rua not in (' + ruasIgnorar + ' )');
    end;

    if (filtro.ruasSuperLotadas.Count > 0) then
    begin

      sql.Add(' -- Ruas superlotadas de OS ');
      sql.Add(' and pcendereco.rua in (' + ruasSuperLotadas + ' )');
    end;
  end;

  sql.Add(' and pcmovendpend.numos not in (select                              ');
  sql.Add('                                   pend.numos                       ');
  sql.Add('                              from booscompendencia pend            ');
  sql.Add('                              where                                 ');
  sql.Add('                                   pend.dataliberacao is null       ');
  sql.Add('                             )                                      ');

  sql.Add(' order by pcmovendpend.data, estoque, pcest.qtgirodia desc )        ');
  sql.Add(' where rownum = 1                                                   ');

  Result := sql.Text;
end;

function TQueryBuilder.GetQueryCriterio6(filtro: TFiltro): string;
var
  sql: TStringList;
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sql := TStringList.Create();

  sql.Add(' select                                                                              ');
  sql.Add('   numos,                                                                            ');
  sql.Add('   codendereco,                                                                      ');
  sql.Add('   codigouma,                                                                        ');
  sql.Add('   rua,                                                                              ');
  sql.Add('   codenderecoorig,                                                                  ');
  sql.Add('   tipoos                                                                            ');
  sql.Add(' from (                                                                              ');
  sql.Add(' Select pcmovendpend.numos                                                           ');
  sql.Add('        , pcmovendpend.data                                                          ');
  sql.Add('        , count(pcmovendpend.numos) over (partition by pcendereco.rua ) as totalrua  ');
  sql.Add('        , pcmovendpend.codendereco                                                   ');
  sql.Add('        , pcmovendpend.codigouma                                                     ');
  sql.Add('        , pcendereco.rua                                                             ');
  sql.Add('        , pcmovendpend.codenderecoorig                                               ');
  sql.Add('        , pcmovendpend.tipoos                                                        ');
  sql.Add('        , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) as ordem1      ');
  sql.Add(' from pcmovendpend                                                                   ');
  sql.Add(' join pcendereco on pcendereco.codendereco = pcmovendpend.codendereco                ');
  sql.Add(' join pcmovendpend mep97 on pcmovendpend.codigouma = mep97.codigouma                 ');
  sql.Add('                             and mep97.tipoos = 97                                   ');
  sql.Add('                             and mep97.numtranswms = pcmovendpend.numtranswms        ');
  sql.Add('                             and mep97.dtfimos is not null                           ');
  sql.Add('                                                                                     ');
  sql.Add(' where pcmovendpend.data > sysdate - 30                                               ');
  sql.Add('     and pcmovendpend.codfilial = :CODFILIAL                                          ');
  sql.Add('     and pcmovendpend.posicao = ''P''                                                 ');
  sql.Add('     and pcmovendpend.dtestorno is null                                              ');
  sql.Add('     and pcmovendpend.tipoos = 98                                                    ');
  sql.Add('     and pcmovendpend.codfuncos is null                                              ');
  sql.Add('     and not exists (select bofilaos.numos                                           ');
  sql.Add(' 			FROM bofilaos where bofilaos.numos = pcmovendpend.numos                       ');
  sql.Add(' 			and bofilaos.status in (''E'',''R''))                                         ');

  sql.Add(' 		and not exists (select bofilaosR.numos                                ');
  sql.Add(' 		                  FROM bofilaosR                                      ');
  sql.Add(' 		                  join bofilaos                                       ');
  sql.Add(' 		                    on bofilaosR.senha = bofilaos.senha               ');
  sql.Add(' 		                  where bofilaosR.numos = pcmovendpend.numos          ');
  sql.Add(' 		                  and bofilaos.status in (''E'',''R''))               ');

  sql.Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                    ');
  sql.Add(' and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                      ');

  if (filtro.ruasIgnorar.Count > 0) then
  begin

    sql.Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
    sql.Add(' and pcendereco.rua not in (' + filtro.ruasIgnorar.DelimitedText + ' )');
  end;

  if (filtro.ruasSuperLotadas.Count > 0) then
  begin

    sql.Add(' -- Ruas superlotadas de OS ');
    sql.Add(' and pcendereco.rua in (' + filtro.ruasSuperLotadas.DelimitedText + ' )');
  end;

  sql.Add(' and not exists (select pend.numos from booscompendencia pend ');
  sql.Add('                 join pcmovendpend mep on mep.numos = pend.numos ');
  sql.Add('                 where pend.dataliberacao is null ');
  sql.Add('                 and mep.codprod = pcmovendpend.codprod ) ');

  sql.Add(' order by ordem1, totalrua desc, pcendereco.rua                                      ');
  sql.Add(' ) where rownum = 1                                                                  ');

  Result := sql.Text;

end;

function TQueryBuilder.GetQueryCriterio6_5(filtro: TFiltro): string;
var
  sql: TStringList;
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sql := TStringList.Create();

  sql.Add('  select                                                                                                                                    ');
  sql.Add('    numos,                                                                                                                                  ');
  sql.Add('    dataonda,                                                                                                                               ');
  sql.Add('    nvl(numonda, 0) as numonda,                                                                                                             ');
  sql.Add('    nvl(numordem,  0) as numordem,                                                                                                          ');
  sql.Add('    nvl(rua, 0) as numrua,                                                                                                                  ');
  sql.Add('    tiposervico,                                                                                                                            ');
  sql.Add('    nvl(codendereco, 0) as codendereco,                                                                                                     ');
  sql.Add('    nvl(codenderecoorig, 0) as codenderecoorig,                                                                                             ');
  sql.Add('    nvl(rua, 0) as rua,                                                                                                                     ');
  sql.Add('    nvl(codigouma, 0) as codigouma,                                                                                                         ');
  sql.Add('    nvl(tipoos, 0) as tipoos                                                                                                                ');
  sql.Add('   from (                                                                                                                                   ');
  sql.Add('                                                                                                                                            ');
  sql.Add(' with carreg_pend as (                                                                                                                      ');
  sql.Add('   select mep.numcar, min(mep.data) as data                                                                                                 ');
  sql.Add('   from pcmovendpend mep                                                                                                                    ');
  sql.Add('   where mep.data > trunc(sysdate - 10)                                                                                                     ');
  sql.Add('       and mep.codfilial = :CODFILIAL                                                                                                       ');
  sql.Add('       and mep.dtestorno is null                                                                                                            ');
  sql.Add('       and mep.posicao = ''P''                                                                                                              ');
  sql.Add('   group by mep.numcar                                                                                                                      ');
  sql.Add(' ),                                                                                                                                         ');
  sql.Add(' carreg_detalhes as (                                                                                                                       ');
  sql.Add(' select                                                                                                                                     ');
  sql.Add('   mep.numcar                                                                                                                               ');
  sql.Add('   , (case when mep.tipoos in (10, 22) then mep.numos else null end ) as os_normal                                                          ');
  sql.Add('   , (case when mep.tipoos in (10, 22) and mep.dtfimseparacao is not null then mep.numos else null end ) as os_normal_finalizadas           ');
  sql.Add('   , (case when mep.tipoos in (17, 23) then mep.numos else null end ) as os_pallet_box                                                      ');
  sql.Add('   , (case when mep.posicao = ''P'' then mep.numos else null end ) as os_pendentes                                                          ');
  sql.Add(' from carreg_pend                                                                                                                           ');
  sql.Add(' join pcmovendpend mep on mep.numcar = carreg_pend.numcar                                                                                   ');
  sql.Add('     where mep.data > trunc(sysdate - 10)                                                                                                   ');
  sql.Add('     and mep.codfilial = :CODFILIAL                                                                                                         ');
  sql.Add('     and mep.tipoos in (10, 22, 17, 23)                                                                                                     ');
  sql.Add('     and mep.dtestorno is null                                                                                                              ');
  sql.Add('     ),                                                                                                                                     ');
  sql.Add(' carregamentos as (                                                                                                                         ');
  sql.Add(' select                                                                                                                                     ');
  sql.Add('   carreg_detalhes.numcar                                                                                                                   ');
  sql.Add('   , count(distinct carreg_detalhes.os_normal) as quantidade                                                                                ');
  sql.Add('   , count(distinct carreg_detalhes.os_normal_finalizadas) as finalizadas                                                                   ');
  sql.Add(' from carreg_detalhes                                                                                                                       ');
  sql.Add(' group by carreg_detalhes.numcar                                                                                                            ');
  sql.Add(' order by numcar)                                                                                                                           ');
  sql.Add('                                                                                                                                            ');
  sql.Add('  Select pcmovendpend.numos                                                                                                                 ');
  sql.Add('           ,bodefineondai.data as dataonda                                                                                                  ');
  sql.Add('           ,bodefineondai.numonda                                                                                                           ');
  sql.Add('           ,bodefineondai.numordem                                                                                                          ');
  sql.Add('           ,pcendereco.rua                                                                                                                  ');
  sql.Add('           , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) ordem_rua_anterior                                                 ');
  sql.Add('           , (case when pcendereco.rua between :RUAINICIAL and :RUAFINAL then 0 else pcmovendpend.numos end) ordem_range                    ');
  sql.Add('           , (case when pcendereco.rua = :RUAANTERIOR then ''MR'' else ''TR'' end) tiposervico                                              ');
  sql.Add('           , pcmovendpend.codendereco                                                                                                       ');
  sql.Add('           , pcmovendpend.codenderecoorig                                                                                                   ');
  sql.Add('           , pcmovendpend.codigouma                                                                                                         ');
  sql.Add('           , pcmovendpend.tipoos                                                                                                            ');
  sql.Add('    from pcmovendpend                                                                                                                       ');
  sql.Add('    join pcendereco      on pcendereco.codendereco = pcmovendpend.codendereco                                                               ');
  sql.Add('    left join bodefineondai   on bodefineondai.numtranswms = pcmovendpend.numtranswms                                                       ');
  sql.Add('    left join carregamentos on carregamentos.numcar = pcmovendpend.numcar                                                                   ');
  sql.Add('    left join booscompendencia on booscompendencia.numos = pcmovendpend.numos                                                               ');
  sql.Add('        and booscompendencia.dataliberacao is null                                                                                          ');

  if filtro.TipoOperador = tpPaleteiro then
  begin

    sql.Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P      ');
    sql.Add(' join pcmovendpend mep23 on mep23.data = pcmovendpend.data               ');
    sql.Add('  and mep23.codfilial = pcmovendpend.codfilial                           ');
    sql.Add('  and mep23.numtranswms = pcmovendpend.numtranswms                       ');
    sql.Add('  and mep23.codigouma = pcmovendpend.codigouma                           ');
    sql.Add('  and mep23.tipoos = 23                                                  ');
    sql.Add('  and mep23.dtfimseparacao is not null                                   ');
  end;

  sql.Add('  where pcmovendpend.data > sysdate - 30                                                                                                    ');
  sql.Add('      and pcmovendpend.codfilial = :CODFILIAL                                                                                               ');
  sql.Add('      and pcmovendpend.posicao = ''P''                                                                                                      ');
  sql.Add('      and pcmovendpend.dtestorno is null                                                                                                    ');
  sql.Add('      and pcmovendpend.tipoos = :TIPOOS                                                                                                     ');
  sql.Add('      and pcmovendpend.codfuncos is null                                                                                                    ');
  sql.Add('       AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                    ');
  sql.Add('       and not exists (select bofilaos.numos                                                                                                ');
  sql.Add('                               FROM bofilaos                                                                                                ');
  sql.Add('                                where bofilaos.numos = pcmovendpend.numos                                                                   ');
  sql.Add('                                and bofilaos.status in (''E'',''R''))                                                                       ');
  sql.Add('  		and not exists (select bofilaosR.numos                                                                                               ');
  sql.Add('  		                  FROM bofilaosR                                                                                                     ');
  sql.Add('  		                  join bofilaos                                                                                                      ');
  sql.Add('  		                    on bofilaosR.senha = bofilaos.senha                                                                              ');
  sql.Add('  		                  where bofilaosR.numos = pcmovendpend.numos                                                                         ');
  sql.Add('  		                  and bofilaos.status in (''E'',''R''))                                                                              ');
  sql.Add('   and booscompendencia.numos is null                                                                                                       ');
  sql.Add('   and ( (carregamentos.numcar is null) or (carregamentos.quantidade = carregamentos.finalizadas) or                                        ');
  sql.Add('        (nvl(carregamentos.finalizadas,0) > 0                                                                                               ');
  sql.Add('          and                                                                                                                               ');
  sql.Add('         ((nvl(carregamentos.finalizadas,0) * 100) / carregamentos.quantidade) >= :PERCFINALIZACAO                                          ');
  sql.Add('        ))                                                                                                                                  ');

  if (filtro.ruasIgnorar.Count > 0) then
  begin

    sql.Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
    sql.Add(' and pcendereco.rua not in (' + filtro.ruasIgnorar.DelimitedText + ' )');
  end;

  sql.Add('    order by dataonda, numonda, ordem_range, ordem_rua_anterior, pcendereco.rua, pcmovendpend.numos                                         ');
  sql.Add(' ) where rownum = 1                                                                                                                         ');

  Result := sql.Text;

end;

function TQueryBuilder.GetQueryCriterio7(filtro: TFiltro): string;
var
  sql: TStringList;
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sql := TStringList.Create();

  sql.Add(' -- Essa consulta tem uma camada a mais apenas para melhorar performance da consulta nas OS do tipo 61 ');

  sql.Add(' select                                                                                      ');
  sql.Add('   numos                                                                                     ');
  sql.Add('   , dataonda                                                                                ');
  sql.Add('   , nvl(numonda, 0) as numonda                                                              ');
  sql.Add('   , nvl(numordem, 0) as numordem                                                            ');
  sql.Add('   , nvl(rua, 0) as rua                                                                      ');
  sql.Add('   , nvl(codendereco, 0) as codendereco                                                      ');
  sql.Add('   , nvl(codenderecoorig, 0) as codenderecoorig                                              ');
  sql.Add('   , nvl(codigouma, 0) as codigouma                                                          ');
  sql.Add('   , nvl(tipoos, 0) as tipoos                                                                ');
  sql.Add(' from (                                                                                      ');
  sql.Add('                                                                                             ');
  sql.Add(' Select pcmovendpend.numos                                                                   ');
  sql.Add('        ,bodefineondai.data as dataonda                                                      ');
  sql.Add('        ,bodefineondai.numonda                                                               ');
  sql.Add('        ,bodefineondai.numordem                                                              ');
  sql.Add('        ,pcendereco.rua                                                                      ');
  sql.Add('        ,pcmovendpend.codendereco                                                            ');
  sql.Add('        ,pcmovendpend.codenderecoorig                                                        ');
  sql.Add('        , count(pcmovendpend.numos) over (partition by pcendereco.rua) as totalrua           ');
  sql.Add('        , pcmovendpend.codigouma                                                             ');
  sql.Add('        , pcmovendpend.tipoos                                                                ');

  sql.Add(' from pcmovendpend                                                                           ');
  sql.Add(' join pcendereco      on pcendereco.codendereco = pcmovendpend.codenderecoorig               ');
  sql.Add(' left join bopendenciaconf on bopendenciaconf.numos = pcmovendpend.numos                     ');
  sql.Add(' left join bodefineondai   on bodefineondai.numtranswms = pcmovendpend.numtranswms           ');
  sql.Add(' left join booscompendencia on booscompendencia.numos = pcmovendpend.numos                   ');
  sql.Add('     and booscompendencia.dataliberacao is null                                              ');

  if filtro.TipoOperador = tpPaleteiro then
  begin

    sql.Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P      ');
    sql.Add(' join pcmovendpend mep58 on mep58.data = pcmovendpend.data               ');
    sql.Add('  and mep58.codfilial = pcmovendpend.codfilial                           ');
    sql.Add('  and mep58.numtranswms = pcmovendpend.numtranswms                       ');
    sql.Add('  and mep58.codigouma = pcmovendpend.codigouma                           ');
    sql.Add('  and mep58.tipoos = 58                                                  ');
    sql.Add('  and mep58.posicao <> ''P''                                             ');
  end;

  sql.Add(' where pcmovendpend.data > sysdate - 30                                                      ');
  sql.Add('     and pcmovendpend.codfilial = :CODFILIAL                                                 ');
  sql.Add('     and pcmovendpend.posicao = ''P''                                                        ');
  sql.Add('     and pcmovendpend.dtestorno is null                                                      ');
  sql.Add('     and pcmovendpend.tipoos = :TIPOOS                                                       ');
  sql.Add('     and pcmovendpend.codfuncos is null                                                      ');
  sql.Add('     and not exists (select bofilaos.numos                                                   ');
  sql.Add('                              FROM bofilaos                                                  ');
  sql.Add('                               where bofilaos.numos = pcmovendpend.numos                     ');
  sql.Add('                               and bofilaos.status in (''E'',''R''))                   ');

  sql.Add(' 		and not exists (select bofilaosR.numos                                ');
  sql.Add(' 		                  FROM bofilaosR                                      ');
  sql.Add(' 		                  join bofilaos                                       ');
  sql.Add(' 		                    on bofilaosR.senha = bofilaos.senha               ');
  sql.Add(' 		                  where bofilaosR.numos = pcmovendpend.numos          ');
  sql.Add(' 		                  and bofilaos.status in (''E'',''R''))               ');

  sql.Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                    ');
  sql.Add(' and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                      ');
  sql.Add(' and booscompendencia.numos is null ');

  if (filtro.ruasIgnorar.Count > 0) then
  begin

    sql.Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
    sql.Add(' and pcendereco.rua not in (' + filtro.ruasIgnorar.DelimitedText + ' )');
  end;

  sql.Add('     and ( bopendenciaconf.numos is not null                      ');
  sql.Add('     or                                                           ');
  sql.Add('     exists ( select boetiquetas.codprod                          ');
  sql.Add('             from boetiquetas                                     ');
  sql.Add('             where boetiquetas.codprod = pcmovendpend.codprod     ');
  sql.Add('             and  boetiquetas.pendente = ''S'' ))                 ');

  sql.Add(' order by dataonda, numonda, numordem                                                        ');
  sql.Add(' ) where rownum = 1                                                                          ');

  Result := sql.Text;

end;

function TQueryBuilder.GetQueryCriterio8(filtro: TFiltro): string;
var
  sql: TStringList;
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sql := TStringList.Create();

  sql.Add(' select                                                                                              ');
  sql.Add('  numos,                                                                                             ');
  sql.Add('  dataonda,                                                                                          ');
  sql.Add('  nvl(numonda, 0) as numonda,                                                                         ');
  sql.Add('  nvl(numordem,  0) as numordem,                                                                      ');
  sql.Add('  nvl(rua, 0) as numrua,                                                                              ');
  sql.Add('  tiposervico,                                                                                       ');
  sql.Add('  nvl(codendereco, 0) as codendereco,                                                                 ');
  sql.Add('  nvl(codenderecoorig, 0) as codenderecoorig,                                                         ');
  sql.Add('  nvl(rua, 0) as rua,                                                                                 ');
  sql.Add('  nvl(codigouma, 0) as codigouma,                                                                     ');
  sql.Add('  nvl(tipoos, 0) as tipoos                                                                           ');
  sql.Add(' from (                                                                                              ');
  sql.Add(' Select pcmovendpend.numos                                                                           ');
  sql.Add('        ,bodefineondai.data as dataonda                                                              ');
  sql.Add('        ,bodefineondai.numonda                                                                       ');
  sql.Add('        ,bodefineondai.numordem                                                                      ');
  sql.Add('        ,pcendereco.rua                                                                              ');
  sql.Add('        , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) ordem_rua_anterior                         ');
  sql.Add('        , (case when pcendereco.rua between :RUAINICIAL and :RUAFINAL then 0 else pcmovendpend.numos end) ordem_range ');
  sql.Add('        , (case when pcendereco.rua = :RUAANTERIOR then ''MR'' else ''TR'' end) tiposervico          ');
  sql.Add('        , pcmovendpend.codendereco                                                                   ');
  sql.Add('        , pcmovendpend.codenderecoorig                                                               ');
  sql.Add('        , pcmovendpend.codigouma                                                                     ');
  sql.Add('        , pcmovendpend.tipoos                                                                        ');
  sql.Add(' from pcmovendpend                                                                                   ');
  sql.Add(' join pcendereco      on pcendereco.codendereco = pcmovendpend.codenderecoorig                       ');
  sql.Add(' join bodefineondai   on bodefineondai.numtranswms = pcmovendpend.numtranswms                        ');
  sql.Add(' left join booscompendencia on booscompendencia.numos = pcmovendpend.numos            ');
  sql.Add('     and booscompendencia.dataliberacao is null                                       ');

  if filtro.TipoOperador = tpPaleteiro then
  begin

    sql.Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P      ');
    sql.Add(' join pcmovendpend mep58 on mep58.data = pcmovendpend.data               ');
    sql.Add('  and mep58.codfilial = pcmovendpend.codfilial                           ');
    sql.Add('  and mep58.numtranswms = pcmovendpend.numtranswms                       ');
    sql.Add('  and mep58.codigouma = pcmovendpend.codigouma                           ');
    sql.Add('  and mep58.tipoos = 58                                                  ');
    sql.Add('  and mep58.posicao <> ''P''                                             ');
  end;

  sql.Add(' where pcmovendpend.data > sysdate - 30                                               ');
  sql.Add('     and pcmovendpend.codfilial = :CODFILIAL                                          ');
  sql.Add('     and pcmovendpend.posicao = ''P''                                                 ');
  sql.Add('     and pcmovendpend.dtestorno is null                                                              ');
  sql.Add('     and pcmovendpend.tipoos = :TIPOOS                                                               ');
  sql.Add('     and pcmovendpend.codfuncos is null                                                              ');
  sql.Add('     and not exists (select bofilaos.numos                                                           ');
  sql.Add('                              FROM bofilaos                                                          ');
  sql.Add('                               where bofilaos.numos = pcmovendpend.numos                             ');
  sql.Add('                               and bofilaos.status in (''E'',''R''))                           ');

  sql.Add(' 		and not exists (select bofilaosR.numos                                ');
  sql.Add(' 		                  FROM bofilaosR                                      ');
  sql.Add(' 		                  join bofilaos                                       ');
  sql.Add(' 		                    on bofilaosR.senha = bofilaos.senha               ');
  sql.Add(' 		                  where bofilaosR.numos = pcmovendpend.numos          ');
  sql.Add(' 		                  and bofilaos.status in (''E'',''R''))               ');

  sql.Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)  ');
  sql.Add(' and booscompendencia.numos is null ');

  if (filtro.ruasIgnorar.Count > 0) then
  begin

    sql.Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
    sql.Add(' and pcendereco.rua not in (' + filtro.ruasIgnorar.DelimitedText + ' )');
  end;

  // SQL.Add(' order by dataonda, numonda, ordem1, ordem2, pcmovendpend.numos ');
  sql.Add(' order by dataonda, numonda, ordem_range, ordem_rua_anterior, pcendereco.rua, pcmovendpend.numos ');

  sql.Add(') where rownum = 1  ');

  Result := sql.Text;

end;

function TQueryBuilder.GetQueryCriterio8_2(filtro: TFiltro): string;
var
  sql: TStringList;
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sql := TStringList.Create();

  sql.Add(' with sep_pendentes as                                                                                    ');
  sql.Add(' (                                                                                                        ');
  sql.Add('    select                                                                                                ');
  sql.Add('     pcmovendpend.codendereco                                                                             ');
  sql.Add('     , bodefineondai.data as dataonda                                                                     ');
  sql.Add('     , bodefineondai.numonda                                                                              ');
  sql.Add('     , bodefineondai.numordem                                                                             ');
  sql.Add('   from pcmovendpend                                                                                      ');
  sql.Add('   join bodefineondai  on bodefineondai.numtranswms = pcmovendpend.numtranswms                            ');
  sql.Add('                       and bodefineondai.data >= pcmovendpend.data                                        ');
  sql.Add('   where pcmovendpend.data >= trunc(sysdate - 10)                                                         ');
  sql.Add('   and pcmovendpend.codfilial = :CODFILIAL                                                                ');
  sql.Add('   and pcmovendpend.posicao = ''P''                                                                       ');
  sql.Add('   and pcmovendpend.dtestorno is null                                                                     ');
  sql.Add('   and pcmovendpend.codfuncos is null                                                                     ');
  sql.Add('   and pcmovendpend.tipoos in (10, 22)                                                                    ');
  sql.Add(' ),                                                                                                       ');
  sql.Add(' fila_execucao as (                                                                                       ');
  sql.Add('   select bofilaos.numos                                                                                  ');
  sql.Add('   FROM bofilaos                                                                                          ');
  sql.Add('   where bofilaos.status in (''E'',''R'')                                                                 ');
  sql.Add('   and bofilaos.dtsolicitacao >= trunc(sysdate - 15)                                                      ');
  sql.Add('                                                                                                          ');
  sql.Add('   union all                                                                                              ');
  sql.Add('                                                                                                          ');
  sql.Add('   select bofilaosR.numos                                                                                 ');
  sql.Add('   FROM bofilaosR                                                                                         ');
  sql.Add('   join bofilaos on bofilaosR.senha = bofilaos.senha                                                      ');
  sql.Add('   where  bofilaos.status in (''E'',''R'')                                                                ');
  sql.Add('   and bofilaos.dtsolicitacao >= trunc(sysdate - 15)                                                      ');
  sql.Add(' ),                                                                                                       ');
  sql.Add('                                                                                                          ');
  sql.Add(' pendencias as (                                                                                          ');
  sql.Add('   select pend.numos                                                                                      ');
  sql.Add('   from booscompendencia pend                                                                             ');
  sql.Add('   where pend.datainclusao >= trunc(sysdate -  10)                                                        ');
  sql.Add('   and pend.dataliberacao is null                                                                         ');
  sql.Add(' )                                                                                                        ');
  sql.Add('                                                                                                          ');
  sql.Add('   select                                                                                                 ');
  sql.Add('     mep.numos                                                                                            ');
  sql.Add('     , pcendereco.rua                                                                                     ');
  sql.Add('     , pcendereco.codendereco                                                                             ');
  sql.Add('     , mep.codigouma                                                                                      ');
  sql.Add('     , mep.codenderecoorig                                                                                ');
  sql.Add('     , mep.tipoos                                                                                         ');
  sql.Add('     , sep_pendentes.dataonda                                                                             ');
  sql.Add('     , sep_pendentes.numonda                                                                              ');
  sql.Add('     , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) ordem_rua_anterior                     ');
  sql.Add('     , (case when pcendereco.rua between :RUAINICIAL and :RUAFINAL then 0 else mep.numos end) ordem_range ');
  sql.Add('   from pcmovendpend mep                                                                                  ');
  sql.Add('   left join pcwms on pcwms.numtranswms = mep.numtranswms                                                 ');
  sql.Add('   join pcendereco on pcendereco.codendereco = mep.codendereco                                            ');
  sql.Add('   join sep_pendentes on sep_pendentes.codendereco = mep.codendereco                                      ');

  if filtro.TipoOperador = tpPaleteiro then
  begin

    sql.Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P      ');
    sql.Add(' join pcmovendpend mep58 on mep58.data = mep.data               ');
    sql.Add('  and mep58.codfilial = mep.codfilial                           ');
    sql.Add('  and mep58.numtranswms = mep.numtranswms                       ');
    sql.Add('  and mep58.codigouma = mep.codigouma                           ');
    sql.Add('  and mep58.tipoos = 58                                         ');
    sql.Add('  and mep58.posicao <> ''P''                                    ');
  end;

  sql.Add('   where mep.data >= trunc(sysdate - 15)                                                                  ');
  sql.Add('   and mep.codfilial = :CODFILIAL                                                                         ');
  sql.Add('   and mep.posicao = ''P''                                                                                ');
  sql.Add('   and mep.dtestorno is null                                                                              ');
  sql.Add('   and mep.codfuncos is null                                                                              ');
  sql.Add('   and mep.tipoos = :TIPOOS                                                                               ');
  sql.Add('   and pcwms.numtranswms is NULL                                                                          ');
  sql.Add('   AND NOT EXISTS (SELECT 1 FROM fila_execucao WHERE fila_execucao.NUMOS = mep.numos)                     ');
  sql.Add('   AND NOT EXISTS (SELECT 1 FROM pendencias WHERE pendencias.NUMOS = mep.numos)                           ');
  sql.Add('   and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                                                   ');
  sql.Add('   AND NVL(mep.CODROTINA, 0) NOT IN (1709, 1721)                                                          ');
  sql.Add('   and mep.codrotina = 1723                                                                               ');
  sql.Add('   order by sep_pendentes.dataonda                                                                        ');
  sql.Add('     , sep_pendentes.numonda                                                                              ');
  sql.Add('     , ordem_rua_anterior                                                                                 ');
  sql.Add('     , ordem_range                                                                                        ');
  sql.Add('   FOR UPDATE SKIP LOCKED                                                                                 ');

  Result := sql.Text;

end;

function TQueryBuilder.GetQueryCriterio9_5(filtro: TFiltro): string;
var
  sql: TStringList;
begin

  sql := TStringList.Create();

  sql.Add('select                                                                                                      ');
  sql.Add('   numos,                                                                                                   ');
  sql.Add('   rua,                                                                                                     ');
  sql.Add('   codendereco,                                                                                             ');
  sql.Add('   codigouma,                                                                                               ');
  sql.Add('   codenderecoorig,                                                                                         ');
  sql.Add('   tipoos,                                                                                                  ');
  sql.Add('   0 as numonda                                                                                             ');
  sql.Add(' from (                                                                                                     ');
  sql.Add('                                                                                                            ');
  sql.Add('   select                                                                                                   ');
  sql.Add('     mep.numos                                                                                              ');
  sql.Add('     , pcendereco.rua                                                                                       ');
  sql.Add('     , pcendereco.codendereco                                                                               ');
  sql.Add('     , mep.codigouma                                                                                        ');
  sql.Add('     , mep.codenderecoorig                                                                                  ');
  sql.Add('     , mep.tipoos                                                                                           ');
  sql.Add('     , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) ordem_rua_anterior                       ');
  sql.Add('     , (case when pcendereco.rua between :RUAINICIAL and :RUAFINAL then 0 else mep.numos end) ordem_range   ');
  sql.Add('   from pcmovendpend mep                                                                                    ');
  sql.Add('   left join pcwms on pcwms.numtranswms = mep.numtranswms                                                   ');
  sql.Add('   join pcendereco on pcendereco.codendereco = mep.codendereco                                              ');

  if filtro.TipoOperador = tpPaleteiro then
  begin

    sql.Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P      ');
    sql.Add(' join pcmovendpend mep58 on mep58.data = mep.data               ');
    sql.Add('  and mep58.codfilial = mep.codfilial                           ');
    sql.Add('  and mep58.numtranswms = mep.numtranswms                       ');
    sql.Add('  and mep58.codigouma = mep.codigouma                           ');
    sql.Add('  and mep58.tipoos = 58                                         ');
    sql.Add('  and mep58.posicao <> ''P''                                    ');
  end;

  sql.Add('                                                                                                            ');
  sql.Add('                                                                                                            ');
  sql.Add('   where mep.data >= trunc(sysdate - 30)                                                                    ');
  sql.Add('   and mep.codfilial = :CODFILIAL                                                                           ');
  sql.Add('   and mep.posicao = ''P''                                                                                  ');
  sql.Add('   and mep.dtestorno is null                                                                                ');
  sql.Add('   and mep.codfuncos is null                                                                                ');
  sql.Add('   and mep.tipoos = :TIPOOS                                                                                 ');
  sql.Add('   and pcwms.numtranswms is null                                                                            ');
  sql.Add('   and not exists (select bofilaos.numos                                                                    ');
  sql.Add('         FROM bofilaos where bofilaos.numos = mep.numos                                                     ');
  sql.Add('         and bofilaos.status in (''E'',''R''))                                                              ');
  sql.Add('                                                                                                            ');
  sql.Add('   and not exists (select bofilaosR.numos                                                                   ');
  sql.Add('                     FROM bofilaosR                                                                         ');
  sql.Add('                     join bofilaos                                                                          ');
  sql.Add('                       on bofilaosR.senha = bofilaos.senha                                                  ');
  sql.Add('                     where bofilaosR.numos = mep.numos                                                      ');
  sql.Add('                     and bofilaos.status in (''E'',''R''))                                                  ');
  sql.Add('   and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                                                     ');
  sql.Add('                                                                                                            ');
  sql.Add('                                                                                                            ');
  sql.Add(' and not exists (select pend.numos from booscompendencia pend                                               ');
  sql.Add('                 join pcmovendpend on pcmovendpend.numos = pend.numos                                       ');
  sql.Add('                 where pend.dataliberacao is null                                                           ');
  sql.Add('                 and pcmovendpend.codprod = mep.codprod )                                                   ');
  sql.Add('                                                                                                            ');
  sql.Add('  and mep.codrotina = 1752                                                                                  ');
  sql.Add('   group by mep.numos                                                                                       ');
  sql.Add('     , pcendereco.rua                                                                                       ');
  sql.Add('     , pcendereco.codendereco                                                                               ');
  sql.Add('     , mep.codigouma                                                                                        ');
  sql.Add('     , mep.codenderecoorig                                                                                  ');
  sql.Add('     , mep.tipoos                                                                                           ');
  sql.Add('                                                                                                            ');
  sql.Add('   order by ordem_rua_anterior                                                                              ');
  sql.Add('     , ordem_range                                                                                          ');
  sql.Add(' ) where rownum = 1                                                                                         ');

  Result := sql.Text;

end;

end.
