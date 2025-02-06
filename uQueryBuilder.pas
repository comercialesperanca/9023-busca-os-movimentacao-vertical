unit uQueryBuilder;

interface

uses SysUtils, Classes, uProximaOS;

type
  TQueryBuilder = class
  private
    function GetQueryCriterio5(filtro: TFiltro): string;
  public
    function GetQuery(numero_criterio: integer; filtro: TFiltro): string;
  end;

implementation

{ TQueryBuilder }

function TQueryBuilder.GetQuery(numero_criterio: integer; filtro: TFiltro): string;
begin

  Result := '';

  if numero_criterio = 5 then
  begin

    Result := self.GetQueryCriterio5(filtro);
  end;

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

end.
