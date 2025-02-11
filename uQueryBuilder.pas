unit uQueryBuilder;

interface

uses SysUtils, Classes, uProximaOS;

type
  TQueryBuilder = class
  private

    sList: TStringList;

    procedure Add(text: string);

    function GetQueryCriterio5(filtro: TFiltro): string;
    function GetQueryCriterio6(filtro: TFiltro): string;
    function GetQueryCriterio6_5(filtro: TFiltro): string;
    function GetQueryCriterio7(filtro: TFiltro): string;
    function GetQueryCriterio8(filtro: TFiltro): string;
    function GetQueryCriterio8_2(filtro: TFiltro): string;
    function GetQueryCriterio9_5(filtro: TFiltro): string;
    function GetQueryCriterio10(filtro: TFiltro): string;
    function GetQueryCriterio11(filtro: TFiltro): string;



  public
    function GetQuery(numero_criterio: double; filtro: TFiltro): string;

    constructor Create();
  end;

implementation

{ TQueryBuilder }

uses uConvocacaoAtivaEnums;

procedure TQueryBuilder.Add(text: string);
begin

  sList.Add(TrimRight(text));

end;

constructor TQueryBuilder.Create;
begin

  sList := TStringList.Create;

end;

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

   if numero_criterio = 11 then
  begin

    Result := self.GetQueryCriterio11(filtro);
  end;

end;

function TQueryBuilder.GetQueryCriterio10(filtro: TFiltro): string;
var
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sList := TStringList.Create();

  Add(' select                                                                               ');
  Add('   numos,                                                                             ');
  Add('   rua,                                                                               ');
  Add('   codendereco,                                                                       ');
  Add('   codigouma,                                                                         ');
  Add('   codenderecoorig,                                                                   ');
  Add('   tipoos                                                                             ');
  Add(' from (                                                                               ');
  Add(' Select pcmovendpend.numos                                                            ');
  Add('        , nvl(pcest.qtestger -                                                        ');
  Add(' 			pcest.qtreserv -                                                               ');
  Add(' 			pcest.qtbloqueada -                                                            ');
  Add(' 			pcest.qtpendente,0) estoque                                                    ');
  Add('        , pcest.qtgirodia                                                             ');
  Add('        , pcmovendpend.data                                                           ');
  Add('        , count(pcmovendpend.numos) over (partition by pcendereco.rua ) as totalrua   ');
  Add('        , pcmovendpend.codendereco                                                    ');
  Add('        , pcmovendpend.codigouma                                                      ');
  Add('        , pcmovendpend.codenderecoorig                                                ');
  Add('        , pcendereco.rua                                                              ');
  Add('        , pcmovendpend.tipoos                                                         ');
  Add(' from pcmovendpend                                                                    ');
  Add(' join pcendereco on pcendereco.codendereco = pcmovendpend.codendereco                 ');
  Add(' join pcmovendpend mep97 on pcmovendpend.codigouma = mep97.codigouma                  ');
  Add('                             and mep97.tipoos = 97                                    ');
  Add('                             and mep97.numtranswms = pcmovendpend.numtranswms         ');
  Add('                             and mep97.dtfimos is not null                            ');
  Add(' join pcest on pcest.codfilial = pcmovendpend.codfilial                               ');
  Add('           and pcest.codprod = pcmovendpend.codprod                                   ');
  Add(' where pcmovendpend.data > sysdate - 30                                               ');
  Add('     and pcmovendpend.codfilial = :CODFILIAL                                          ');
  Add('     and pcmovendpend.posicao = ''P''                                                 ');
  Add('     and pcmovendpend.dtestorno is null                                               ');
  Add('     and pcmovendpend.tipoos = 98                                                     ');
  Add('     and pcmovendpend.codfuncos is null                                               ');
  Add('     and not exists (select bofilaos.numos                                            ');
  Add(' 					FROM bofilaos where bofilaos.numos = pcmovendpend.numos                    ');
  Add(' 					and bofilaos.status in (''E'',''R''))                               ');

  Add(' 		and not exists (select bofilaosR.numos                                ');
  Add(' 		                  FROM bofilaosR                                      ');
  Add(' 		                  join bofilaos                                       ');
  Add(' 		                    on bofilaosR.senha = bofilaos.senha               ');
  Add(' 		                  where bofilaosR.numos = pcmovendpend.numos          ');
  Add(' 		                  and bofilaos.status in (''E'',''R''))               ');

  Add(' and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                      ');
  Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                    ');

  if (filtro.ruasIgnorar.Count > 0) then
  begin

    Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
    Add(' and pcendereco.rua not in (' + filtro.ruasIgnorar.DelimitedText + ' )');
  end;

  Add(' and not exists (select pend.numos from booscompendencia pend ');
  Add('                 join pcmovendpend mep on mep.numos = pend.numos ');
  Add('                 where pend.dataliberacao is null ');
  Add('                 and mep.codprod = pcmovendpend.codprod ) ');

  Add(' order by pcmovendpend.data, estoque, pcest.qtgirodia desc )                          ');
  Add(' where rownum = 1                                                                     ');

  Result := sList.Text;

end;

function TQueryBuilder.GetQueryCriterio11(filtro: TFiltro): string;
begin


  sList := TStringList.Create();

  Add(' select                                                                                 ');
  Add('   numos,                                                                               ');
  Add('   nvl(rua, 0) as rua,                                                                  ');
  Add('   nvl(codendereco, 0) as codendereco,                                                  ');
  Add('   nvl(codenderecoorig, 0) as codenderecoorig,                                           ');
  Add('   nvl(codigouma, 0) as codigouma,                                                       ');
  Add('   nvl(tipoos, 0) as tipoos                                                             ');
  Add(' from (                                                                                 ');
  Add(' Select pcmovendpend.numos                                                              ');
  Add('        ,pcendereco.rua                                                                 ');
  Add('        , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) ordemrua          ');
  Add('        , pcmovendpend.codendereco                                                      ');
  Add('        , pcmovendpend.codenderecoorig                                                  ');
  Add('        , nvl(pcest.qtgirodia,0) as giro                                                ');
  Add('        , pcmovendpend.codigouma                                                        ');
  Add('        , pcmovendpend.tipoos                                                           ');
  Add(' from pcmovendpend                                                                      ');
  Add(' join pcendereco      on pcendereco.codendereco = pcmovendpend.codendereco              ');
  Add(' left join bodefineondai   on bodefineondai.numtranswms = pcmovendpend.numtranswms      ');
  Add(' join pcest on pcest.codfilial = pcmovendpend.codfilial                                 ');
  Add('     and pcest.codprod = pcmovendpend.codprod                                           ');
  Add(' left join booscompendencia on booscompendencia.numos = pcmovendpend.numos            ');
  Add('     and booscompendencia.dataliberacao is null                                       ');

  if filtro.TipoOperador = tpPaleteiro then
  begin

    Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P');
    Add(' join pcmovendpend mep58 on mep58.data = pcmovendpend.data               ');
    Add('  and mep58.codfilial = pcmovendpend.codfilial                           ');
    Add('  and mep58.numtranswms = pcmovendpend.numtranswms                       ');
    Add('  and mep58.codigouma = pcmovendpend.codigouma                           ');
    Add('  and mep58.tipoos = 58                                                  ');
    Add('  and mep58.posicao <> ''P''                                             ');
  end;

  Add(' where pcmovendpend.data > sysdate - 30                                               ');
  Add('     and pcmovendpend.codfilial = :CODFILIAL                                          ');
  Add('     and pcmovendpend.posicao = ''P''                                                 ');
  Add('     and bodefineondai.numtranswms is null                                              ');
  Add('     and pcmovendpend.dtestorno is null                                                 ');
  Add('     and pcmovendpend.tipoos = :TIPOOS                                                  ');
  Add('     and pcmovendpend.codfuncos is null                                                 ');
  Add('     and not exists (select bofilaos.numos                                              ');
  Add('                              FROM bofilaos                                             ');
  Add('                               where bofilaos.numos = pcmovendpend.numos                ');
  Add('                               and bofilaos.status in (''E'',''R''))                    ');
  Add('                                                                                        ');

  Add(' 		and not exists (select bofilaosR.numos                                ');
  Add(' 		                  FROM bofilaosR                                      ');
  Add(' 		                  join bofilaos                                       ');
  Add(' 		                    on bofilaosR.senha = bofilaos.senha               ');
  Add(' 		                  where bofilaosR.numos = pcmovendpend.numos          ');
  Add(' 		                  and bofilaos.status in (''E'',''R''))               ');

  Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                    ');
  Add(' and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                                  ');
  Add(' and booscompendencia.numos is null ');

  if (filtro.ruasIgnorar.Count > 0) then
  begin

    Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
    Add(' and pcendereco.rua not in (' + filtro.ruasIgnorar.DelimitedText + ' )');
  end;

  Add(' order by ordemrua, giro desc                                                           ');
  Add(' ) where rownum = 1                                                                     ');

  Result := sList.Text;

end;

function TQueryBuilder.GetQueryCriterio5(filtro: TFiltro): string;
var
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sList := TStringList.Create();

  Add(' select                                                                               ');
  Add('   numos,                                                                             ');
  Add('   rua,                                                                               ');
  Add('   codendereco,                                                                       ');
  Add('   codigouma,                                                                         ');
  Add('   codenderecoorig,                                                                   ');
  Add('   tipoos                                                                             ');
  Add(' from (                                                                               ');
  Add(' Select pcmovendpend.numos                                                            ');
  Add('        , nvl(pcest.qtestger -                                                        ');
  Add(' 			pcest.qtreserv -                                                               ');
  Add(' 			pcest.qtbloqueada -                                                            ');
  Add(' 			pcest.qtpendente,0) estoque                                                    ');
  Add('        , pcest.qtgirodia                                                             ');
  Add('        , pcmovendpend.data                                                           ');
  Add('        , count(pcmovendpend.numos) over (partition by pcendereco.rua ) as totalrua   ');
  Add('        , pcmovendpend.codendereco                                                    ');
  Add('        , pcmovendpend.codigouma                                                      ');
  Add('        , pcmovendpend.codenderecoorig                                                ');
  Add('        , pcendereco.rua                                                              ');
  Add('        , pcmovendpend.tipoos                                                         ');
  Add(' from pcmovendpend                                                                    ');
  Add(' join pcendereco on pcendereco.codendereco = pcmovendpend.codendereco                 ');
  Add(' join pcmovendpend mep97 on pcmovendpend.codigouma = mep97.codigouma                  ');
  Add('                             and mep97.tipoos = 97                                    ');
  Add('                             and mep97.numtranswms = pcmovendpend.numtranswms         ');
  Add('                             and mep97.dtfimos is not null                            ');
  Add(' join pcest on pcest.codfilial = pcmovendpend.codfilial                               ');
  Add('           and pcest.codprod = pcmovendpend.codprod                                   ');
  Add(' where pcmovendpend.data > sysdate - 30                                               ');
  Add('     and pcmovendpend.codfilial = :CODFILIAL                                          ');
  Add('     and pcmovendpend.posicao = ''P''                                                 ');
  Add('     and pcmovendpend.dtestorno is null                                               ');
  Add('     and pcmovendpend.tipoos = 98                                                     ');
  Add('     and pcendereco.rua = :RUA                                                        ');
  Add('     and pcmovendpend.codfuncos is null                                               ');
  Add('     and not exists (select bofilaos.numos                                            ');
  Add(' 					FROM bofilaos where bofilaos.numos = pcmovendpend.numos                    ');
  Add(' 					and bofilaos.status in (''E'',''R''))                                      ');
  Add(' 		and not exists (select bofilaosR.numos                                           ');
  Add(' 		                  FROM bofilaosR                                                 ');
  Add(' 		                  join bofilaos                                                  ');
  Add(' 		                    on bofilaosR.senha = bofilaos.senha                          ');
  Add(' 		                  where bofilaosR.numos = pcmovendpend.numos                     ');
  Add(' 		                  and bofilaos.status in (''E'',''R''))                          ');
  Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                               ');
  Add(' and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                                 ');

  if (not filtro.RuaSuperLotadaAntes) then
  begin

    if (filtro.ruasIgnorar.Count > 0) then
    begin

      Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
      Add(' and pcendereco.rua not in (' + ruasIgnorar + ' )');
    end;

    if (filtro.ruasSuperLotadas.Count > 0) then
    begin

      Add(' -- Ruas superlotadas de OS ');
      Add(' and pcendereco.rua in (' + ruasSuperLotadas + ' )');
    end;
  end;

  Add(' and pcmovendpend.numos not in (select                              ');
  Add('                                   pend.numos                       ');
  Add('                              from booscompendencia pend            ');
  Add('                              where                                 ');
  Add('                                   pend.dataliberacao is null       ');
  Add('                             )                                      ');

  Add(' order by pcmovendpend.data, estoque, pcest.qtgirodia desc )        ');
  Add(' where rownum = 1                                                   ');

  Result := sList.Text;
end;

function TQueryBuilder.GetQueryCriterio6(filtro: TFiltro): string;
var
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sList := TStringList.Create();

  Add(' select                                                                              ');
  Add('   numos,                                                                            ');
  Add('   codendereco,                                                                      ');
  Add('   codigouma,                                                                        ');
  Add('   rua,                                                                              ');
  Add('   codenderecoorig,                                                                  ');
  Add('   tipoos                                                                            ');
  Add(' from (                                                                              ');
  Add(' Select pcmovendpend.numos                                                           ');
  Add('        , pcmovendpend.data                                                          ');
  Add('        , count(pcmovendpend.numos) over (partition by pcendereco.rua ) as totalrua  ');
  Add('        , pcmovendpend.codendereco                                                   ');
  Add('        , pcmovendpend.codigouma                                                     ');
  Add('        , pcendereco.rua                                                             ');
  Add('        , pcmovendpend.codenderecoorig                                               ');
  Add('        , pcmovendpend.tipoos                                                        ');
  Add('        , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) as ordem1      ');
  Add(' from pcmovendpend                                                                   ');
  Add(' join pcendereco on pcendereco.codendereco = pcmovendpend.codendereco                ');
  Add(' join pcmovendpend mep97 on pcmovendpend.codigouma = mep97.codigouma                 ');
  Add('                             and mep97.tipoos = 97                                   ');
  Add('                             and mep97.numtranswms = pcmovendpend.numtranswms        ');
  Add('                             and mep97.dtfimos is not null                           ');
  Add('                                                                                     ');
  Add(' where pcmovendpend.data > sysdate - 30                                               ');
  Add('     and pcmovendpend.codfilial = :CODFILIAL                                          ');
  Add('     and pcmovendpend.posicao = ''P''                                                 ');
  Add('     and pcmovendpend.dtestorno is null                                              ');
  Add('     and pcmovendpend.tipoos = 98                                                    ');
  Add('     and pcmovendpend.codfuncos is null                                              ');
  Add('     and not exists (select bofilaos.numos                                           ');
  Add(' 			FROM bofilaos where bofilaos.numos = pcmovendpend.numos                       ');
  Add(' 			and bofilaos.status in (''E'',''R''))                                         ');

  Add(' 		and not exists (select bofilaosR.numos                                ');
  Add(' 		                  FROM bofilaosR                                      ');
  Add(' 		                  join bofilaos                                       ');
  Add(' 		                    on bofilaosR.senha = bofilaos.senha               ');
  Add(' 		                  where bofilaosR.numos = pcmovendpend.numos          ');
  Add(' 		                  and bofilaos.status in (''E'',''R''))               ');

  Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                    ');
  Add(' and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                      ');

  if (filtro.ruasIgnorar.Count > 0) then
  begin

    Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
    Add(' and pcendereco.rua not in (' + filtro.ruasIgnorar.DelimitedText + ' )');
  end;

  if (filtro.ruasSuperLotadas.Count > 0) then
  begin

    Add(' -- Ruas superlotadas de OS ');
    Add(' and pcendereco.rua in (' + filtro.ruasSuperLotadas.DelimitedText + ' )');
  end;

  Add(' and not exists (select pend.numos from booscompendencia pend ');
  Add('                 join pcmovendpend mep on mep.numos = pend.numos ');
  Add('                 where pend.dataliberacao is null ');
  Add('                 and mep.codprod = pcmovendpend.codprod ) ');

  Add(' order by ordem1, totalrua desc, pcendereco.rua                                      ');
  Add(' ) where rownum = 1                                                                  ');

  Result := sList.Text;

end;

function TQueryBuilder.GetQueryCriterio6_5(filtro: TFiltro): string;
var
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sList := TStringList.Create();

  Add('  select                                                                                                                                    ');
  Add('    numos,                                                                                                                                  ');
  Add('    dataonda,                                                                                                                               ');
  Add('    nvl(numonda, 0) as numonda,                                                                                                             ');
  Add('    nvl(numordem,  0) as numordem,                                                                                                          ');
  Add('    nvl(rua, 0) as numrua,                                                                                                                  ');
  Add('    tiposervico,                                                                                                                            ');
  Add('    nvl(codendereco, 0) as codendereco,                                                                                                     ');
  Add('    nvl(codenderecoorig, 0) as codenderecoorig,                                                                                             ');
  Add('    nvl(rua, 0) as rua,                                                                                                                     ');
  Add('    nvl(codigouma, 0) as codigouma,                                                                                                         ');
  Add('    nvl(tipoos, 0) as tipoos                                                                                                                ');
  Add('   from (                                                                                                                                   ');
  Add('                                                                                                                                            ');
  Add(' with carreg_pend as (                                                                                                                      ');
  Add('   select mep.numcar, min(mep.data) as data                                                                                                 ');
  Add('   from pcmovendpend mep                                                                                                                    ');
  Add('   where mep.data > trunc(sysdate - 10)                                                                                                     ');
  Add('       and mep.codfilial = :CODFILIAL                                                                                                       ');
  Add('       and mep.dtestorno is null                                                                                                            ');
  Add('       and mep.posicao = ''P''                                                                                                              ');
  Add('   group by mep.numcar                                                                                                                      ');
  Add(' ),                                                                                                                                         ');
  Add(' carreg_detalhes as (                                                                                                                       ');
  Add(' select                                                                                                                                     ');
  Add('   mep.numcar                                                                                                                               ');
  Add('   , (case when mep.tipoos in (10, 22) then mep.numos else null end ) as os_normal                                                          ');
  Add('   , (case when mep.tipoos in (10, 22) and mep.dtfimseparacao is not null then mep.numos else null end ) as os_normal_finalizadas           ');
  Add('   , (case when mep.tipoos in (17, 23) then mep.numos else null end ) as os_pallet_box                                                      ');
  Add('   , (case when mep.posicao = ''P'' then mep.numos else null end ) as os_pendentes                                                          ');
  Add(' from carreg_pend                                                                                                                           ');
  Add(' join pcmovendpend mep on mep.numcar = carreg_pend.numcar                                                                                   ');
  Add('     where mep.data > trunc(sysdate - 10)                                                                                                   ');
  Add('     and mep.codfilial = :CODFILIAL                                                                                                         ');
  Add('     and mep.tipoos in (10, 22, 17, 23)                                                                                                     ');
  Add('     and mep.dtestorno is null                                                                                                              ');
  Add('     ),                                                                                                                                     ');
  Add(' carregamentos as (                                                                                                                         ');
  Add(' select                                                                                                                                     ');
  Add('   carreg_detalhes.numcar                                                                                                                   ');
  Add('   , count(distinct carreg_detalhes.os_normal) as quantidade                                                                                ');
  Add('   , count(distinct carreg_detalhes.os_normal_finalizadas) as finalizadas                                                                   ');
  Add(' from carreg_detalhes                                                                                                                       ');
  Add(' group by carreg_detalhes.numcar                                                                                                            ');
  Add(' order by numcar)                                                                                                                           ');
  Add('                                                                                                                                            ');
  Add('  Select pcmovendpend.numos                                                                                                                 ');
  Add('           ,bodefineondai.data as dataonda                                                                                                  ');
  Add('           ,bodefineondai.numonda                                                                                                           ');
  Add('           ,bodefineondai.numordem                                                                                                          ');
  Add('           ,pcendereco.rua                                                                                                                  ');
  Add('           , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) ordem_rua_anterior                                                 ');
  Add('           , (case when pcendereco.rua between :RUAINICIAL and :RUAFINAL then 0 else pcmovendpend.numos end) ordem_range                    ');
  Add('           , (case when pcendereco.rua = :RUAANTERIOR then ''MR'' else ''TR'' end) tiposervico                                              ');
  Add('           , pcmovendpend.codendereco                                                                                                       ');
  Add('           , pcmovendpend.codenderecoorig                                                                                                   ');
  Add('           , pcmovendpend.codigouma                                                                                                         ');
  Add('           , pcmovendpend.tipoos                                                                                                            ');
  Add('    from pcmovendpend                                                                                                                       ');
  Add('    join pcendereco      on pcendereco.codendereco = pcmovendpend.codendereco                                                               ');
  Add('    left join bodefineondai   on bodefineondai.numtranswms = pcmovendpend.numtranswms                                                       ');
  Add('    left join carregamentos on carregamentos.numcar = pcmovendpend.numcar                                                                   ');
  Add('    left join booscompendencia on booscompendencia.numos = pcmovendpend.numos                                                               ');
  Add('        and booscompendencia.dataliberacao is null                                                                                          ');

  if filtro.TipoOperador = tpPaleteiro then
  begin

    Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P      ');
    Add(' join pcmovendpend mep23 on mep23.data = pcmovendpend.data               ');
    Add('  and mep23.codfilial = pcmovendpend.codfilial                           ');
    Add('  and mep23.numtranswms = pcmovendpend.numtranswms                       ');
    Add('  and mep23.codigouma = pcmovendpend.codigouma                           ');
    Add('  and mep23.tipoos = 23                                                  ');
    Add('  and mep23.dtfimseparacao is not null                                   ');
  end;

  Add('  where pcmovendpend.data > sysdate - 30                                                                                                    ');
  Add('      and pcmovendpend.codfilial = :CODFILIAL                                                                                               ');
  Add('      and pcmovendpend.posicao = ''P''                                                                                                      ');
  Add('      and pcmovendpend.dtestorno is null                                                                                                    ');
  Add('      and pcmovendpend.tipoos = :TIPOOS                                                                                                     ');
  Add('      and pcmovendpend.codfuncos is null                                                                                                    ');
  Add('       AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                    ');
  Add('       and not exists (select bofilaos.numos                                                                                                ');
  Add('                               FROM bofilaos                                                                                                ');
  Add('                                where bofilaos.numos = pcmovendpend.numos                                                                   ');
  Add('                                and bofilaos.status in (''E'',''R''))                                                                       ');
  Add('  		and not exists (select bofilaosR.numos                                                                                               ');
  Add('  		                  FROM bofilaosR                                                                                                     ');
  Add('  		                  join bofilaos                                                                                                      ');
  Add('  		                    on bofilaosR.senha = bofilaos.senha                                                                              ');
  Add('  		                  where bofilaosR.numos = pcmovendpend.numos                                                                         ');
  Add('  		                  and bofilaos.status in (''E'',''R''))                                                                              ');
  Add('   and booscompendencia.numos is null                                                                                                       ');
  Add('   and ( (carregamentos.numcar is null) or (carregamentos.quantidade = carregamentos.finalizadas) or                                        ');
  Add('        (nvl(carregamentos.finalizadas,0) > 0                                                                                               ');
  Add('          and                                                                                                                               ');
  Add('         ((nvl(carregamentos.finalizadas,0) * 100) / carregamentos.quantidade) >= :PERCFINALIZACAO                                          ');
  Add('        ))                                                                                                                                  ');

  if (filtro.ruasIgnorar.Count > 0) then
  begin

    Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
    Add(' and pcendereco.rua not in (' + filtro.ruasIgnorar.DelimitedText + ' )');
  end;

  Add('    order by dataonda, numonda, ordem_range, ordem_rua_anterior, pcendereco.rua, pcmovendpend.numos                                         ');
  Add(' ) where rownum = 1                                                                                                                         ');

  Result := sList.Text;

end;

function TQueryBuilder.GetQueryCriterio7(filtro: TFiltro): string;
var
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sList := TStringList.Create();

  Add(' -- Essa consulta tem uma camada a mais apenas para melhorar performance da consulta nas OS do tipo 61 ');

  Add(' select                                                                                      ');
  Add('   numos                                                                                     ');
  Add('   , dataonda                                                                                ');
  Add('   , nvl(numonda, 0) as numonda                                                              ');
  Add('   , nvl(numordem, 0) as numordem                                                            ');
  Add('   , nvl(rua, 0) as rua                                                                      ');
  Add('   , nvl(codendereco, 0) as codendereco                                                      ');
  Add('   , nvl(codenderecoorig, 0) as codenderecoorig                                              ');
  Add('   , nvl(codigouma, 0) as codigouma                                                          ');
  Add('   , nvl(tipoos, 0) as tipoos                                                                ');
  Add(' from (                                                                                      ');
  Add('                                                                                             ');
  Add(' Select pcmovendpend.numos                                                                   ');
  Add('        ,bodefineondai.data as dataonda                                                      ');
  Add('        ,bodefineondai.numonda                                                               ');
  Add('        ,bodefineondai.numordem                                                              ');
  Add('        ,pcendereco.rua                                                                      ');
  Add('        ,pcmovendpend.codendereco                                                            ');
  Add('        ,pcmovendpend.codenderecoorig                                                        ');
  Add('        , count(pcmovendpend.numos) over (partition by pcendereco.rua) as totalrua           ');
  Add('        , pcmovendpend.codigouma                                                             ');
  Add('        , pcmovendpend.tipoos                                                                ');

  Add(' from pcmovendpend                                                                           ');
  Add(' join pcendereco      on pcendereco.codendereco = pcmovendpend.codendereco                   ');
  Add(' left join bopendenciaconf on bopendenciaconf.numos = pcmovendpend.numos                     ');
  Add(' left join bodefineondai   on bodefineondai.numtranswms = pcmovendpend.numtranswms           ');
  Add(' left join booscompendencia on booscompendencia.numos = pcmovendpend.numos                   ');
  Add('     and booscompendencia.dataliberacao is null                                              ');

  if filtro.TipoOperador = tpPaleteiro then
  begin

    Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P      ');
    Add(' join pcmovendpend mep58 on mep58.data = pcmovendpend.data               ');
    Add('  and mep58.codfilial = pcmovendpend.codfilial                           ');
    Add('  and mep58.numtranswms = pcmovendpend.numtranswms                       ');
    Add('  and mep58.codigouma = pcmovendpend.codigouma                           ');
    Add('  and mep58.tipoos = 58                                                  ');
    Add('  and mep58.posicao <> ''P''                                             ');
  end;

  Add(' where pcmovendpend.data > sysdate - 30                                                      ');
  Add('     and pcmovendpend.codfilial = :CODFILIAL                                                 ');
  Add('     and pcmovendpend.posicao = ''P''                                                        ');
  Add('     and pcmovendpend.dtestorno is null                                                      ');
  Add('     and pcmovendpend.tipoos = :TIPOOS                                                       ');
  Add('     and pcmovendpend.codfuncos is null                                                      ');
  Add('     and not exists (select bofilaos.numos                                                   ');
  Add('                              FROM bofilaos                                                  ');
  Add('                               where bofilaos.numos = pcmovendpend.numos                     ');
  Add('                               and bofilaos.status in (''E'',''R''))                   ');

  Add(' 		and not exists (select bofilaosR.numos                                ');
  Add(' 		                  FROM bofilaosR                                      ');
  Add(' 		                  join bofilaos                                       ');
  Add(' 		                    on bofilaosR.senha = bofilaos.senha               ');
  Add(' 		                  where bofilaosR.numos = pcmovendpend.numos          ');
  Add(' 		                  and bofilaos.status in (''E'',''R''))               ');

  Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)                    ');
  Add(' and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                      ');
  Add(' and booscompendencia.numos is null ');

  if (filtro.ruasIgnorar.Count > 0) then
  begin

    Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
    Add(' and pcendereco.rua not in (' + filtro.ruasIgnorar.DelimitedText + ' )');
  end;

  Add('     and ( bopendenciaconf.numos is not null                      ');
  Add('     or                                                           ');
  Add('     exists ( select boetiquetas.codprod                          ');
  Add('             from boetiquetas                                     ');
  Add('             where boetiquetas.codprod = pcmovendpend.codprod     ');
  Add('             and  boetiquetas.pendente = ''S'' ))                 ');

  Add(' order by dataonda, numonda, numordem                                                        ');
  Add(' ) where rownum = 1                                                                          ');

  Result := sList.Text;

end;

function TQueryBuilder.GetQueryCriterio8(filtro: TFiltro): string;
var
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sList := TStringList.Create();

  Add(' select                                                                                              ');
  Add('  numos,                                                                                             ');
  Add('  dataonda,                                                                                          ');
  Add('  nvl(numonda, 0) as numonda,                                                                         ');
  Add('  nvl(numordem,  0) as numordem,                                                                      ');
  Add('  nvl(rua, 0) as numrua,                                                                              ');
  Add('  tiposervico,                                                                                       ');
  Add('  nvl(codendereco, 0) as codendereco,                                                                 ');
  Add('  nvl(codenderecoorig, 0) as codenderecoorig,                                                         ');
  Add('  nvl(rua, 0) as rua,                                                                                 ');
  Add('  nvl(codigouma, 0) as codigouma,                                                                     ');
  Add('  nvl(tipoos, 0) as tipoos                                                                           ');
  Add(' from (                                                                                              ');
  Add(' Select pcmovendpend.numos                                                                           ');
  Add('        ,bodefineondai.data as dataonda                                                              ');
  Add('        ,bodefineondai.numonda                                                                       ');
  Add('        ,bodefineondai.numordem                                                                      ');
  Add('        ,pcendereco.rua                                                                              ');
  Add('        , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) ordem_rua_anterior                         ');
  Add('        , (case when pcendereco.rua between :RUAINICIAL and :RUAFINAL then 0 else pcmovendpend.numos end) ordem_range ');
  Add('        , (case when pcendereco.rua = :RUAANTERIOR then ''MR'' else ''TR'' end) tiposervico          ');
  Add('        , pcmovendpend.codendereco                                                                   ');
  Add('        , pcmovendpend.codenderecoorig                                                               ');
  Add('        , pcmovendpend.codigouma                                                                     ');
  Add('        , pcmovendpend.tipoos                                                                        ');
  Add(' from pcmovendpend                                                                                   ');
  Add(' join pcendereco      on pcendereco.codendereco = pcmovendpend.codendereco                           ');
  Add(' join bodefineondai   on bodefineondai.numtranswms = pcmovendpend.numtranswms                        ');
  Add(' left join booscompendencia on booscompendencia.numos = pcmovendpend.numos            ');
  Add('     and booscompendencia.dataliberacao is null                                       ');

  if filtro.TipoOperador = tpPaleteiro then
  begin

    Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P      ');
    Add(' join pcmovendpend mep58 on mep58.data = pcmovendpend.data               ');
    Add('  and mep58.codfilial = pcmovendpend.codfilial                           ');
    Add('  and mep58.numtranswms = pcmovendpend.numtranswms                       ');
    Add('  and mep58.codigouma = pcmovendpend.codigouma                           ');
    Add('  and mep58.tipoos = 58                                                  ');
    Add('  and mep58.posicao <> ''P''                                             ');
  end;

  Add(' where pcmovendpend.data > sysdate - 30                                               ');
  Add('     and pcmovendpend.codfilial = :CODFILIAL                                          ');
  Add('     and pcmovendpend.posicao = ''P''                                                 ');
  Add('     and pcmovendpend.dtestorno is null                                                              ');
  Add('     and pcmovendpend.tipoos = :TIPOOS                                                               ');
  Add('     and pcmovendpend.codfuncos is null                                                              ');
  Add('     and not exists (select bofilaos.numos                                                           ');
  Add('                              FROM bofilaos                                                          ');
  Add('                               where bofilaos.numos = pcmovendpend.numos                             ');
  Add('                               and bofilaos.status in (''E'',''R''))                           ');

  Add(' 		and not exists (select bofilaosR.numos                                ');
  Add(' 		                  FROM bofilaosR                                      ');
  Add(' 		                  join bofilaos                                       ');
  Add(' 		                    on bofilaosR.senha = bofilaos.senha               ');
  Add(' 		                  where bofilaosR.numos = pcmovendpend.numos          ');
  Add(' 		                  and bofilaos.status in (''E'',''R''))               ');

  Add(' AND NVL(pcmovendpend.CODROTINA, 0) NOT IN (1709, 1721)  ');
  Add(' and booscompendencia.numos is null ');

  if (filtro.ruasIgnorar.Count > 0) then
  begin

    Add(' -- Ruas que serão ignoradas por estarem com excesso de funcionários e do range de exceção caso a exceção não tenha sido informada explicitamente');
    Add(' and pcendereco.rua not in (' + filtro.ruasIgnorar.DelimitedText + ' )');
  end;

  // Add(' order by dataonda, numonda, ordem1, ordem2, pcmovendpend.numos ');
  Add(' order by dataonda, numonda, ordem_range, ordem_rua_anterior, pcendereco.rua, pcmovendpend.numos ');

  Add(') where rownum = 1  ');

  Result := sList.Text;

end;

function TQueryBuilder.GetQueryCriterio8_2(filtro: TFiltro): string;
var
  ruasIgnorar, ruasSuperLotadas: string;
begin

  ruasIgnorar := filtro.ruasIgnorar.DelimitedText;
  ruasSuperLotadas := filtro.ruasSuperLotadas.DelimitedText;

  sList := TStringList.Create();

  Add(' with sep_pendentes as                                                                                    ');
  Add(' (                                                                                                        ');
  Add('    select                                                                                                ');
  Add('     pcmovendpend.codendereco                                                                             ');
  Add('     , bodefineondai.data as dataonda                                                                     ');
  Add('     , bodefineondai.numonda                                                                              ');
  Add('     , bodefineondai.numordem                                                                             ');
  Add('   from pcmovendpend                                                                                      ');
  Add('   join bodefineondai  on bodefineondai.numtranswms = pcmovendpend.numtranswms                            ');
  Add('                       and bodefineondai.data >= pcmovendpend.data                                        ');
  Add('   where pcmovendpend.data >= trunc(sysdate - 10)                                                         ');
  Add('   and pcmovendpend.codfilial = :CODFILIAL                                                                ');
  Add('   and pcmovendpend.posicao = ''P''                                                                       ');
  Add('   and pcmovendpend.dtestorno is null                                                                     ');
  Add('   and pcmovendpend.codfuncos is null                                                                     ');
  Add('   and pcmovendpend.tipoos in (10, 22)                                                                    ');
  Add(' ),                                                                                                       ');
  Add(' fila_execucao as (                                                                                       ');
  Add('   select bofilaos.numos                                                                                  ');
  Add('   FROM bofilaos                                                                                          ');
  Add('   where bofilaos.status in (''E'',''R'')                                                                 ');
  Add('   and bofilaos.dtsolicitacao >= trunc(sysdate - 15)                                                      ');
  Add('                                                                                                          ');
  Add('   union all                                                                                              ');
  Add('                                                                                                          ');
  Add('   select bofilaosR.numos                                                                                 ');
  Add('   FROM bofilaosR                                                                                         ');
  Add('   join bofilaos on bofilaosR.senha = bofilaos.senha                                                      ');
  Add('   where  bofilaos.status in (''E'',''R'')                                                                ');
  Add('   and bofilaos.dtsolicitacao >= trunc(sysdate - 15)                                                      ');
  Add(' ),                                                                                                       ');
  Add('                                                                                                          ');
  Add(' pendencias as (                                                                                          ');
  Add('   select pend.numos                                                                                      ');
  Add('   from booscompendencia pend                                                                             ');
  Add('   where pend.datainclusao >= trunc(sysdate -  10)                                                        ');
  Add('   and pend.dataliberacao is null                                                                         ');
  Add(' )                                                                                                        ');
  Add('                                                                                                          ');
  Add('   select                                                                                                 ');
  Add('     mep.numos                                                                                            ');
  Add('     , pcendereco.rua                                                                                     ');
  Add('     , pcendereco.codendereco                                                                             ');
  Add('     , mep.codigouma                                                                                      ');
  Add('     , mep.codenderecoorig                                                                                ');
  Add('     , mep.tipoos                                                                                         ');
  Add('     , sep_pendentes.dataonda                                                                             ');
  Add('     , sep_pendentes.numonda                                                                              ');
  Add('     , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) ordem_rua_anterior                     ');
  Add('     , (case when pcendereco.rua between :RUAINICIAL and :RUAFINAL then 0 else mep.numos end) ordem_range ');
  Add('   from pcmovendpend mep                                                                                  ');
  Add('   left join pcwms on pcwms.numtranswms = mep.numtranswms                                                 ');
  Add('   join pcendereco on pcendereco.codendereco = mep.codendereco                                            ');
  Add('   join sep_pendentes on sep_pendentes.codendereco = mep.codendereco                                      ');

  if filtro.TipoOperador = tpPaleteiro then
  begin

    Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P      ');
    Add(' join pcmovendpend mep58 on mep58.data = mep.data               ');
    Add('  and mep58.codfilial = mep.codfilial                           ');
    Add('  and mep58.numtranswms = mep.numtranswms                       ');
    Add('  and mep58.codigouma = mep.codigouma                           ');
    Add('  and mep58.tipoos = 58                                         ');
    Add('  and mep58.posicao <> ''P''                                    ');
  end;

  Add('   where mep.data >= trunc(sysdate - 15)                                                                  ');
  Add('   and mep.codfilial = :CODFILIAL                                                                         ');
  Add('   and mep.posicao = ''P''                                                                                ');
  Add('   and mep.dtestorno is null                                                                              ');
  Add('   and mep.codfuncos is null                                                                              ');
  Add('   and mep.tipoos = :TIPOOS                                                                               ');
  Add('   and pcwms.numtranswms is NULL                                                                          ');
  Add('   AND NOT EXISTS (SELECT 1 FROM fila_execucao WHERE fila_execucao.NUMOS = mep.numos)                     ');
  Add('   AND NOT EXISTS (SELECT 1 FROM pendencias WHERE pendencias.NUMOS = mep.numos)                           ');
  Add('   and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                                                   ');
  Add('   AND NVL(mep.CODROTINA, 0) NOT IN (1709, 1721)                                                          ');
  Add('   and mep.codrotina = 1723                                                                               ');
  Add('   order by sep_pendentes.dataonda                                                                        ');
  Add('     , sep_pendentes.numonda                                                                              ');
  Add('     , ordem_rua_anterior                                                                                 ');
  Add('     , ordem_range                                                                                        ');
  Add('   FOR UPDATE SKIP LOCKED                                                                                 ');

  Result := sList.Text;

end;

function TQueryBuilder.GetQueryCriterio9_5(filtro: TFiltro): string;
begin

  sList := TStringList.Create();

  Add('select                                                                                                      ');
  Add('   numos,                                                                                                   ');
  Add('   rua,                                                                                                     ');
  Add('   codendereco,                                                                                             ');
  Add('   codigouma,                                                                                               ');
  Add('   codenderecoorig,                                                                                         ');
  Add('   tipoos,                                                                                                  ');
  Add('   0 as numonda                                                                                             ');
  Add(' from (                                                                                                     ');
  Add('                                                                                                            ');
  Add('   select                                                                                                   ');
  Add('     mep.numos                                                                                              ');
  Add('     , pcendereco.rua                                                                                       ');
  Add('     , pcendereco.codendereco                                                                               ');
  Add('     , mep.codigouma                                                                                        ');
  Add('     , mep.codenderecoorig                                                                                  ');
  Add('     , mep.tipoos                                                                                           ');
  Add('     , (case when pcendereco.rua = :RUAANTERIOR then 0 else 1 end) ordem_rua_anterior                       ');
  Add('     , (case when pcendereco.rua between :RUAINICIAL and :RUAFINAL then 0 else mep.numos end) ordem_range   ');
  Add('   from pcmovendpend mep                                                                                    ');
  Add('   left join pcwms on pcwms.numtranswms = mep.numtranswms                                                   ');
  Add('   join pcendereco on pcendereco.codendereco = mep.codendereco                                              ');

  if filtro.TipoOperador = tpPaleteiro then
  begin

    Add(' -- Trecho adicionado apenas quando BOFILAOS.TIPOOPERADOR igual a P      ');
    Add(' join pcmovendpend mep58 on mep58.data = mep.data               ');
    Add('  and mep58.codfilial = mep.codfilial                           ');
    Add('  and mep58.numtranswms = mep.numtranswms                       ');
    Add('  and mep58.codigouma = mep.codigouma                           ');
    Add('  and mep58.tipoos = 58                                         ');
    Add('  and mep58.posicao <> ''P''                                    ');
  end;

  Add('                                                                                                            ');
  Add('                                                                                                            ');
  Add('   where mep.data >= trunc(sysdate - 30)                                                                    ');
  Add('   and mep.codfilial = :CODFILIAL                                                                           ');
  Add('   and mep.posicao = ''P''                                                                                  ');
  Add('   and mep.dtestorno is null                                                                                ');
  Add('   and mep.codfuncos is null                                                                                ');
  Add('   and mep.tipoos = :TIPOOS                                                                                 ');
  Add('   and pcwms.numtranswms is null                                                                            ');
  Add('   and not exists (select bofilaos.numos                                                                    ');
  Add('         FROM bofilaos where bofilaos.numos = mep.numos                                                     ');
  Add('         and bofilaos.status in (''E'',''R''))                                                              ');
  Add('                                                                                                            ');
  Add('   and not exists (select bofilaosR.numos                                                                   ');
  Add('                     FROM bofilaosR                                                                         ');
  Add('                     join bofilaos                                                                          ');
  Add('                       on bofilaosR.senha = bofilaos.senha                                                  ');
  Add('                     where bofilaosR.numos = mep.numos                                                      ');
  Add('                     and bofilaos.status in (''E'',''R''))                                                  ');
  Add('   and pcendereco.rua between :RUAINICIAL AND :RUAFINAL                                                     ');
  Add('                                                                                                            ');
  Add('                                                                                                            ');
  Add(' and not exists (select pend.numos from booscompendencia pend                                               ');
  Add('                 join pcmovendpend on pcmovendpend.numos = pend.numos                                       ');
  Add('                 where pend.dataliberacao is null                                                           ');
  Add('                 and pcmovendpend.codprod = mep.codprod )                                                   ');
  Add('                                                                                                            ');
  Add('  and mep.codrotina = 1752                                                                                  ');
  Add('   group by mep.numos                                                                                       ');
  Add('     , pcendereco.rua                                                                                       ');
  Add('     , pcendereco.codendereco                                                                               ');
  Add('     , mep.codigouma                                                                                        ');
  Add('     , mep.codenderecoorig                                                                                  ');
  Add('     , mep.tipoos                                                                                           ');
  Add('                                                                                                            ');
  Add('   order by ordem_rua_anterior                                                                              ');
  Add('     , ordem_range                                                                                          ');
  Add(' ) where rownum = 1                                                                                         ');

  Result := sList.Text;

end;

end.
