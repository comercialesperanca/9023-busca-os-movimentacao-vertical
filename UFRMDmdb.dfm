object dmdb: Tdmdb
  OldCreateOrder = False
  Height = 812
  Width = 668
  object qryCancelarSolicitacoesAbandonadas: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'UPDATE BOFILAOS SET'
      'STATUS = '#39'C'#39
      'WHERE dtatribuida IS NULL'
      'AND DTSOLICITACAO <= :DTLIMITE'
      'and status in ('#39'A'#39', '#39'R'#39')')
    Left = 88
    Top = 80
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'DTLIMITE'
        ParamType = ptUnknown
      end>
  end
  object qryOSEmExecucao: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      
        'select nvl(numos, 0) as numos, senha, nvl(codendereco,0) as code' +
        'ndereco,  nvl(codenderecoorig, 0) as codenderecoorig, nvl(codigo' +
        'uma,0) as codigouma,  nvl(tipoos, 0) as tipoos, nvl(flagsl, 0) a' +
        's flagsl'
      'from bofilaos'
      'where matricula = :MATRICULA'
      'and status = '#39'E'#39
      'and tipooperador = :TIPOOPERADOR'
      'and tipoos in (58, 61, 98, 17)')
    Left = 88
    Top = 144
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'MATRICULA'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'TIPOOPERADOR'
        ParamType = ptUnknown
      end>
    object qryOSEmExecucaoNUMOS: TFloatField
      FieldName = 'NUMOS'
    end
    object qryOSEmExecucaoSENHA: TFloatField
      FieldName = 'SENHA'
    end
    object qryOSEmExecucaoCODENDERECO: TFloatField
      FieldName = 'CODENDERECO'
    end
    object qryOSEmExecucaoCODENDERECOORIG: TFloatField
      FieldName = 'CODENDERECOORIG'
    end
    object qryOSEmExecucaoCODIGOUMA: TFloatField
      FieldName = 'CODIGOUMA'
    end
    object qryOSEmExecucaoTIPOOS: TFloatField
      FieldName = 'TIPOOS'
    end
    object qryOSEmExecucaoFLAGSL: TFloatField
      FieldName = 'FLAGSL'
    end
  end
  object qryCancelarSenha: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'update bofilaos set'
      'status = '#39'C'#39
      'where senha = :SENHA')
    Left = 263
    Top = 24
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'SENHA'
        ParamType = ptUnknown
      end>
  end
  object qryRegistrarRetorno: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'UPDATE bofilaos '
      'SET    ( ruarangeinicio, ruarangefim, status, numos, '
      '         codigouma, tipoos, dtatendimento, codenderecoorig, '
      '         codendereco, flagsl, dtonda, nronda, '
      
        '         tiposervico, dtreserva, criterio, armazemtodo ) = (SELE' +
        'CT ruarangeinicio,'
      '                                            ruarangefim, '
      '                                            '#39'R'#39', '
      '                                            numos, '
      '                                            codigouma, '
      '                                            tipoos, '
      '                                            SYSDATE, '
      '                                            codenderecoorig, '
      '                                            codendereco, '
      '                                            flagsl, '
      '                                            dtonda, '
      '                                            nronda, '
      '                                            '#39'RT'#39', '
      '                                            dtreserva,'
      '                                            3,'
      
        '                                            NVL(armazemtodo, '#39'N'#39 +
        ')'
      '                                     FROM   bofilaos '
      
        '                                     WHERE  senha = :SENHAANTERI' +
        'OR) '
      'WHERE  senha = :SENHAATUAL ')
    Left = 399
    Top = 24
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'SENHAANTERIOR'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'SENHAATUAL'
        ParamType = ptUnknown
      end>
  end
  object qryCarregarSolicitacoes: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'SELECT'
      '  senha, '
      '  matricula, '
      '  ruarangeinicio, '
      '  ruarangefim,'
      ' dtsolicitacao,'
      
        ' (case when nvl(tipooperador, '#39'E'#39') = '#39'E'#39' then 0 else 1 end) tipo' +
        'operador'
      'FROM bofilaos'
      'where status = '#39'A'#39
      'order by senha')
    Left = 263
    Top = 80
    object qryCarregarSolicitacoesSENHA: TFloatField
      FieldName = 'SENHA'
      Origin = 'BDECONNECTION.BOFILAOS.SENHA'
    end
    object qryCarregarSolicitacoesMATRICULA: TFloatField
      FieldName = 'MATRICULA'
      Origin = 'BDECONNECTION.BOFILAOS.MATRICULA'
    end
    object qryCarregarSolicitacoesRUARANGEINICIO: TFloatField
      FieldName = 'RUARANGEINICIO'
      Origin = 'BDECONNECTION.BOFILAOS.RUARANGEINICIO'
    end
    object qryCarregarSolicitacoesRUARANGEFIM: TFloatField
      FieldName = 'RUARANGEFIM'
      Origin = 'BDECONNECTION.BOFILAOS.RUARANGEFIM'
    end
    object qryCarregarSolicitacoesDTSOLICITACAO: TDateTimeField
      FieldName = 'DTSOLICITACAO'
    end
    object qryCarregarSolicitacoesTIPOOPERADOR: TFloatField
      FieldName = 'TIPOOPERADOR'
    end
  end
  object qryDadosSenhaAnterior: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'select '
      
        '   (case when nvl(flagsl, 0) = 0 then '#39'N'#39' else '#39'S'#39' end) as flags' +
        'l   '
      '  , nvl(pcendereco.rua, 0) as rua'
      '  , nvl(bofilaos.nronda, 0) as nronda'
      '  , nvl(bofilaos.tipoos, 0) as tipoos'
      '  , bofilaos.dtsolicitacao'
      '  , senha'
      '  , bofilaos.dtonda'
      'from bofilaos'
      
        'left join pcendereco on pcendereco.codendereco = bofilaos.codend' +
        'ereco'
      'where senha = ( select max(senha) '
      '                  from bofilaos '
      '                  where matricula = :MATRICULA '
      '                  and senha < :SENHA '
      '                  and dtfinalizado is not null '
      '                  and status = '#39'F'#39' )')
    Left = 263
    Top = 144
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'MATRICULA'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'SENHA'
        ParamType = ptUnknown
      end>
    object qryDadosSenhaAnteriorFLAGSL: TStringField
      FieldName = 'FLAGSL'
      Size = 1
    end
    object qryDadosSenhaAnteriorRUA: TFloatField
      FieldName = 'RUA'
    end
    object qryDadosSenhaAnteriorNRONDA: TFloatField
      FieldName = 'NRONDA'
    end
    object qryDadosSenhaAnteriorTIPOOS: TFloatField
      FieldName = 'TIPOOS'
    end
    object qryDadosSenhaAnteriorDTSOLICITACAO: TDateTimeField
      FieldName = 'DTSOLICITACAO'
    end
    object qryDadosSenhaAnteriorSENHA: TFloatField
      FieldName = 'SENHA'
    end
    object qryDadosSenhaAnteriorDTONDA: TDateTimeField
      FieldName = 'DTONDA'
    end
  end
  object qryRuasExcessoFuncionariosEmp: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'select pcendereco.rua'
      'from bofilaos'
      
        'join pcendereco on (pcendereco.codendereco = bofilaos.codenderec' +
        'oorig and bofilaos.tipoos = 61) '
      
        '                  or (pcendereco.codendereco = bofilaos.codender' +
        'eco and bofilaos.tipoos = 98)'
      'where bofilaos.status in ('#39'E'#39','#39'R'#39')'
      'and bofilaos.tipoos in (98, 61)'
      'and bofilaos.tipooperador = '#39'E'#39
      'and bofilaos.matricula <> :MATRICULA'
      'group by pcendereco.rua'
      'having count(bofilaos.codenderecoorig) >= :MAXIMOPORRUA')
    Left = 559
    Top = 24
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'MATRICULA'
        ParamType = ptUnknown
      end
      item
        DataType = ftString
        Name = 'MAXIMOPORRUA'
        ParamType = ptUnknown
        Value = '10'
      end>
    object qryRuasExcessoFuncionariosEmpRUA: TFloatField
      FieldName = 'RUA'
    end
  end
  object qryRuasExcecao: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      
        '(SELECT DISTINCT TRIM(REGEXP_SUBSTR(VALOR, '#39'[^,]+'#39', 1, LEVEL)) R' +
        'UA'
      
        ' FROM (SELECT VALOR FROM BOCONFIGdetalhe WHERE CODIGO = 248 AND ' +
        'FILIAL = :CODFILIAL) T'
      'CONNECT BY INSTR(VALOR, '#39','#39', 1, LEVEL - 1) > 0)')
    Left = 399
    Top = 80
    ParamData = <
      item
        DataType = ftString
        Name = 'CODFILIAL'
        ParamType = ptUnknown
        Value = '2'
      end>
    object qryRuasExcecaoRUA: TStringField
      FieldName = 'RUA'
      Size = 100
    end
  end
  object qryAbastecimentoSuperLotacao: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'select '
      '  numos,'
      '  totalrua,'
      '  codendereco'
      'from ('
      'Select pcmovendpend.numos'
      
        '       , nvl(pcest.qtestger - pcest.qtreserv - pcest.qtbloqueada' +
        ' - pcest.qtpendente,0) estoque'
      '       , pcest.qtgirodia'
      '       , pcmovendpend.data'
      
        '       , count(pcmovendpend.numos) over (partition by pcendereco' +
        '.rua ) as totalrua       '
      '       , pcmovendpend.codendereco'
      'from pcmovendpend'
      
        'join pcendereco on pcendereco.codendereco = pcmovendpend.codende' +
        'reco'
      
        'join pcmovendpend mep97 on pcmovendpend.codigouma = mep97.codigo' +
        'uma'
      '                            and mep97.tipoos = 97'
      
        '                            and mep97.numtranswms = pcmovendpend' +
        '.numtranswms'
      '                            and mep97.dtfimos is not null    '
      'join pcest on pcest.codfilial = pcmovendpend.codfilial '
      
        '          and pcest.codprod = pcmovendpend.codprod              ' +
        '              '
      
        'left join booscompendencia on booscompendencia.numos = pcmovendp' +
        'end.numos'
      'where pcmovendpend.posicao = '#39'P'#39
      '    and pcmovendpend.codfilial = :CODFILIAL'
      '    and pcmovendpend.dtestorno is null'
      '    and pcmovendpend.tipoos = 98'
      '    and pcendereco.rua = :RUA'
      '    and pcmovendpend.codfuncos is null'
      
        '    and not exists (select bofilaos.numos FROM bofilaos where bo' +
        'filaos.numos = pcmovendpend.numos and bofilaos.status in ('#39'E'#39','#39'R' +
        #39'))'
      '    and booscompendencia.dataliberacao is null'
      'order by pcmovendpend.data, estoque, pcest.qtgirodia desc )'
      'where rownum = 1')
    Left = 559
    Top = 144
    ParamData = <
      item
        DataType = ftString
        Name = 'CODFILIAL'
        ParamType = ptUnknown
        Value = '2'
      end
      item
        DataType = ftString
        Name = 'RUA'
        ParamType = ptUnknown
        Value = '1'
      end>
    object qryAbastecimentoSuperLotacaoNUMOS: TFloatField
      FieldName = 'NUMOS'
    end
    object qryAbastecimentoSuperLotacaoTOTALRUA: TFloatField
      FieldName = 'TOTALRUA'
    end
    object qryAbastecimentoSuperLotacaoCODENDERECO: TFloatField
      FieldName = 'CODENDERECO'
    end
    object qryAbastecimentoSuperLotacaoCODIGOUMA: TFloatField
      FieldName = 'CODIGOUMA'
    end
  end
  object qryAtenderSolicitacao: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'UPDATE bofilaos SET'
      '  STATUS = '#39'R'#39','
      '  NUMOS = :NUMOS,'
      '  CODIGOUMA = :CODIGOUMA,'
      '  DTATENDIMENTO = SYSDATE,'
      '  CODENDERECO = :CODENDERECO,'
      '  CODENDERECOORIG = :CODENDERECOORIG,'
      '  FLAGSL = :FLAGSL,'
      '  TIPOSERVICO = :TIPOSERVICO,'
      '  DTRESERVA = SYSDATE,'
      '  DTONDA = :DTONDA,'
      '  NRONDA = :NRONDA,'
      '  TIPOOS = :TIPOOS,'
      '  CRITERIO = :CRITERIO,'
      '  ARMAZEMTODO = :ARMAZEMTODO'
      'WHERE SENHA = :SENHA')
    Left = 96
    Top = 328
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'NUMOS'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'CODIGOUMA'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'CODENDERECO'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'CODENDERECOORIG'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'FLAGSL'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'TIPOSERVICO'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'DTONDA'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'NRONDA'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'TIPOOS'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'CRITERIO'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'ARMAZEMTODO'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'SENHA'
        ParamType = ptUnknown
      end>
  end
  object qryAuxiliar: TQuery
    DatabaseName = 'BDEConnection'
    Left = 88
    Top = 232
  end
  object qryRuasExcessoOS: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'SELECT'
      '  pcendereco.rua  '
      'FROM PCMOVENDPEND'
      
        'join pcendereco on pcendereco.codendereco = PCMOVENDPEND.codende' +
        'reco and PCMOVENDPEND.tipoos = 98'
      
        'join pcmovendpend mep97 on pcmovendpend.codigouma = mep97.codigo' +
        'uma          '
      
        '                            and mep97.tipoos = 97               ' +
        '             '
      
        '                            and mep97.numtranswms = pcmovendpend' +
        '.numtranswms '
      '                            and mep97.dtfimos is not null'
      ''
      
        'WHERE pcmovendpend.posicao = '#39'P'#39'                                ' +
        '                '
      
        '    and pcmovendpend.codfilial = :CODFILIAL                     ' +
        '                   '
      
        '    and pcmovendpend.dtestorno is null                          ' +
        '                   '
      '    and pcmovendpend.tipoos = 98'
      'group by pcendereco.rua '
      'having count(distinct PCMOVENDPEND.NUMOS) >= :MAXIMOPORRUA'
      'order by pcendereco.rua')
    Left = 399
    Top = 152
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'CODFILIAL'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'MAXIMOPORRUA'
        ParamType = ptUnknown
      end>
    object qryRuasExcessoOSRUA: TFloatField
      FieldName = 'RUA'
    end
  end
  object qrySolicitacoesAbandonadas: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'SELECT SENHA FROM BOFILAOS'
      'WHERE dtatribuida IS NULL'
      'AND DTSOLICITACAO <= :DTLIMITE'
      'AND STATUS in ('#39'A'#39', '#39'R'#39')')
    Left = 88
    Top = 24
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'DTLIMITE'
        ParamType = ptUnknown
      end>
  end
  object cdsOSsAtribuidas: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 399
    Top = 232
    object cdsOSsAtribuidasSENHA: TFloatField
      FieldName = 'SENHA'
    end
    object cdsOSsAtribuidasDATA: TDateTimeField
      DisplayLabel = 'DT. ATRIBUI'#199#195'O'
      FieldName = 'DATA'
    end
    object cdsOSsAtribuidasDTSOLICITACAO: TDateTimeField
      DisplayLabel = 'DT. SOLICITA'#199#195'O'
      FieldName = 'DTSOLICITACAO'
    end
    object cdsOSsAtribuidasMATRICULA: TFloatField
      DisplayLabel = 'MATR'#205'CULA'
      FieldName = 'MATRICULA'
    end
    object cdsOSsAtribuidasNUMOS: TFloatField
      DisplayLabel = 'N'#218'M. O.S.'
      FieldName = 'NUMOS'
    end
    object cdsOSsAtribuidasCODENDERECO: TFloatField
      DisplayLabel = 'C'#211'D. ENDERE'#199'O'
      FieldName = 'CODENDERECO'
    end
    object cdsOSsAtribuidasCODIGOUMA: TFloatField
      DisplayLabel = 'C'#211'DIGO U.M.A.'
      FieldName = 'CODIGOUMA'
    end
    object cdsOSsAtribuidasCODENDERECOORIG: TFloatField
      DisplayLabel = 'C'#211'D. ENDERE'#199'O ORIGEM'
      FieldName = 'CODENDERECOORIG'
    end
    object cdsOSsAtribuidasTIPOOS: TFloatField
      DisplayLabel = 'TIPO O.S.'
      FieldName = 'TIPOOS'
    end
    object cdsOSsAtribuidasCRITERIO: TFloatField
      DisplayLabel = 'C'#211'D. CRIT'#201'RIO'
      FieldName = 'CRITERIO'
    end
    object cdsOSsAtribuidasARMAZEMTODO: TFloatField
      DisplayLabel = 'ARMAZ'#201'M TODO'
      FieldName = 'ARMAZEMTODO'
    end
    object cdsOSsAtribuidasSUPERLOTADA: TFloatField
      DisplayLabel = 'SUPER LOTADA'
      FieldName = 'SUPERLOTADA'
    end
    object cdsOSsAtribuidasTOTALOSRUA: TFloatField
      DisplayLabel = 'QTD O.S. NA RUA'
      FieldName = 'TOTALOSRUA'
    end
    object cdsOSsAtribuidasTOTALFUNCRUA: TFloatField
      DisplayLabel = 'QTD. FUNC. NA RUA'
      FieldName = 'TOTALFUNCRUA'
    end
    object cdsOSsAtribuidasRUA: TFloatField
      FieldName = 'RUA'
    end
    object cdsOSsAtribuidasTIPOOSANTERIOR: TFloatField
      DisplayLabel = 'TIPO O.S. ANTERIOR'
      FieldName = 'TIPOOSANTERIOR'
    end
    object cdsOSsAtribuidasSENHAANTERIOR: TFloatField
      DisplayLabel = 'SENHA ANTERIOR'
      FieldName = 'SENHAANTERIOR'
    end
    object cdsOSsAtribuidasRUAANTERIOR: TFloatField
      DisplayLabel = 'RUA ANTERIOR'
      FieldName = 'RUAANTERIOR'
    end
    object cdsOSsAtribuidasDTSOLICITACAOANTERIOR: TDateTimeField
      DisplayLabel = 'DT. SOLICITA'#199#195'O ANTERIOR'
      FieldName = 'DTSOLICITACAOANTERIOR'
    end
    object cdsOSsAtribuidasTOTALOSRUAANTERIOR: TFloatField
      DisplayLabel = 'TOTAL OS RUA ANTERIOR (NESTE MOMENTO)'
      FieldName = 'TOTALOSRUAANTERIOR'
    end
    object cdsOSsAtribuidasTOTALFUNCRUAANTERIOR: TFloatField
      DisplayLabel = 'TOTAL FUNC. RUA ANTERIOR (NESTE MOMENTO)'
      FieldName = 'TOTALFUNCRUAANTERIOR'
    end
    object cdsOSsAtribuidasTIPOOPERADOR: TStringField
      DisplayLabel = 'TIPO OPERADOR'
      FieldName = 'TIPOOPERADOR'
      Size = 1
    end
    object cdsOSsAtribuidasRUAINICIAL: TFloatField
      DisplayLabel = 'RUA INICIAL SOLICITADA'
      FieldName = 'RUAINICIAL'
    end
    object cdsOSsAtribuidasRUAFINAL: TFloatField
      DisplayLabel = 'RUA FINAL SOLICITADA'
      FieldName = 'RUAFINAL'
    end
    object cdsOSsAtribuidasRANGERUASEXCECAO: TStringField
      DisplayLabel = 'RANGE DE RUAS DE EXCE'#199#195'O'
      FieldName = 'RANGERUASEXCECAO'
      Size = 1
    end
    object cdsOSsAtribuidasANALISE: TMemoField
      DisplayLabel = 'AN'#193'LISES'
      FieldName = 'ANALISE'
      BlobType = ftMemo
      Size = 5000
    end
    object cdsOSsAtribuidasSEGUNDOSLOCALIZACAOOS: TFloatField
      DisplayLabel = 'SEGUNDOS PARA LOCALIZA'#199#195'O DA O.S.'
      FieldName = 'SEGUNDOSLOCALIZACAOOS'
    end
  end
  object dsrOSsAtribuidas: TDataSource
    DataSet = cdsOSsAtribuidas
    Left = 399
    Top = 288
  end
  object qryTotalOSRuas: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'SELECT '
      '  pcendereco.rua  '
      '  , count(pcmovendpend.numos) as total'
      'FROM PCMOVENDPEND'
      
        'join pcendereco on (pcendereco.codendereco = PCMOVENDPEND.codend' +
        'erecoorig and PCMOVENDPEND.tipoos = 61) '
      
        '                  or (pcendereco.codendereco = PCMOVENDPEND.code' +
        'ndereco and PCMOVENDPEND.tipoos = 98) '
      
        'WHERE pcmovendpend.posicao = '#39'P'#39'                                ' +
        '                '
      
        '    and pcmovendpend.codfilial = :CODFILIAL                     ' +
        '                   '
      
        '    and pcmovendpend.dtestorno is null                          ' +
        '                   '
      '    and pcmovendpend.tipoos = 98 '
      'group by pcendereco.rua '
      'order by pcendereco.rua')
    Left = 263
    Top = 288
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'CODFILIAL'
        ParamType = ptUnknown
      end>
    object qryTotalOSRuasRUA: TFloatField
      FieldName = 'RUA'
    end
    object qryTotalOSRuasTOTAL: TFloatField
      FieldName = 'TOTAL'
    end
  end
  object qryTotalFuncRuas: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'select pcendereco.rua, count(bofilaos.matricula) as total'
      'from bofilaos'
      
        'join pcendereco on (pcendereco.codendereco = bofilaos.codenderec' +
        'oorig and bofilaos.tipoos = 61) '
      
        '                  or (pcendereco.codendereco = bofilaos.codender' +
        'eco and bofilaos.tipoos = 98)'
      'where bofilaos.status in ('#39'E'#39','#39'R'#39')'
      'and pcendereco.codfilial = :CODFILIAL'
      'group by pcendereco.rua')
    Left = 263
    Top = 232
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'CODFILIAL'
        ParamType = ptUnknown
      end>
    object qryTotalFuncRuasRUA: TFloatField
      FieldName = 'RUA'
    end
    object qryTotalFuncRuasTOTAL: TFloatField
      FieldName = 'TOTAL'
    end
  end
  object qryRuasExcessoFuncionariosPalet: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'select'
      '     pcendereco.rua'
      'from bofilaos'
      
        'join pcendereco on pcendereco.codendereco = bofilaos.codendereco' +
        'orig'
      'where'
      '      bofilaos.status in ('#39'E'#39','#39'R'#39')'
      '  and bofilaos.tipoos = 58'
      '  and bofilaos.TipoOperador = '#39'P'#39
      '  and bofilaos.matricula <> :MATRICULA'
      'group by pcendereco.rua'
      'having count(bofilaos.codenderecoorig) >= :MAXIMOPORRUA')
    Left = 559
    Top = 80
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'MATRICULA'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'MAXIMOPORRUA'
        ParamType = ptUnknown
      end>
    object qryRuasExcessoFuncionariosPaletRUA: TFloatField
      FieldName = 'RUA'
    end
  end
  object qryOSsMesmoEnderecoOrigem: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'SELECT   pcmovendpend.NUMOS'
      'FROM     pcmovendpend '
      
        'join     bodefineondai ON bodefineondai.numtranswms = pcmovendpe' +
        'nd.numtranswms '
      'WHERE    pcmovendpend.posicao = '#39'P'#39'    '
      'AND      pcmovendpend.codfilial = :CODFILIAL'
      'AND      pcmovendpend.dtestorno IS NULL'
      'AND      pcmovendpend.tipoos = :TIPOOS '
      'AND      pcmovendpend.codfuncos IS NULL'
      'AND      pcmovendpend.numos <> :NUMOS'
      'AND      NOT EXISTS ( '
      '                SELECT bofilaos.numos '
      '                FROM   bofilaos '
      '                WHERE  bofilaos.numos = pcmovendpend.numos '
      '                AND    bofilaos.status IN ('#39'E'#39', '#39'R'#39')) '
      'AND      NOT EXISTS ( '
      '                SELECT bofilaosr.numos '
      '                FROM   bofilaosr '
      
        '                join   bofilaos ON bofilaosr.senha = bofilaos.se' +
        'nha '
      '                WHERE  bofilaosr.numos = pcmovendpend.numos '
      '                AND    bofilaos.status IN ('#39'E'#39', '#39'R'#39'))'
      ''
      'AND      NOT EXISTS ('
      '                SELECT booscompendencia.numos'
      '                FROM booscompendencia'
      
        '                WHERE booscompendencia.numos = pcmovendpend.numo' +
        's'
      '                AND booscompendencia.dataliberacao is null'
      '                )'
      ''
      'AND      pcmovendpend.codenderecoorig = :CODENDERECOORIG'
      'AND      pcmovendpend.codendereco = :CODENDERECO')
    Left = 96
    Top = 472
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'CODFILIAL'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'TIPOOS'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'NUMOS'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'CODENDERECOORIG'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'CODENDERECO'
        ParamType = ptUnknown
      end>
    object qryOSsMesmoEnderecoOrigemNUMOS: TFloatField
      FieldName = 'NUMOS'
    end
  end
  object qryGravarBOFILAOSR: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'INSERT INTO BOFILAOSR (senha, numos) VALUES (:SENHA, :NUMOS)')
    Left = 96
    Top = 520
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'SENHA'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'NUMOS'
        ParamType = ptUnknown
      end>
  end
  object qryClonarOS: TQuery
    DatabaseName = 'BDEConnection'
    SQL.Strings = (
      'INSERT INTO PCMOVENDPEND ('#9#9
      '        NUMOS'
      '       , TIPOOS '
      '       , DATA '
      '       , CODPROD '
      '       , QT '
      '       , CODOPER '
      '       , NUMTRANS '
      '       , HORA '
      '       , MINUTO '
      '       , NUMTRANSWMS '
      '       , DTVALIDADE '
      '       , CODROTINA '
      '       , NUMCARINI '
      '       , NUMCARFIM '
      '       , NUMVIAS '
      '       , NUMSEQ '
      '       , NUMCAR '
      '       , NUMBONUS '
      '       , DTESTORNO '
      '       , CODFUNCESTORNO '
      '       , NUMPALETE '
      '       , TIPOPROD '
      '       , NUMPED '
      '       , NUMLOTE '
      '       , QTRESERVADA '
      '       , POSICAO '
      '       , QTORIG '
      '       , CODFUNCCONF '
      '       , DATACONF '
      '       , CODFILIAL '
      '       , NUMTRANSVENDA '
      '       , NUMPEDINI '
      '       , NUMPEDFIM '
      '       , NUMTRANSVENDAINI '
      '       , NUMTRANSVENDAFIM '
      '       , CODENDERECO '
      '       , DTINICIOOS '
      '       , DTFIMOS '
      '       , CODFUNCOS        '
      '       , QTSEPARADA '
      '       , MUNICENT '
      '       , NUMBOX '
      '       , NUMVOL '
      '       , CODENDERECOORIG '
      '       , SEQPALETE '
      '       , CODPRACA '
      '       , CODFUNCOSFIM '
      '       , FUNCULTIMP '
      '       , DTULTIMP '
      '       , SEQCONF '
      '       , FUNCPRIIMP '
      '       , DTPRIIMP '
      '       , MATRFUNC '
      '       , CODFUNCINICIOS '
      '       , NUMPALETE1 '
      '       , NUMPALETE2_OLD '
      '       , TIPOEMBALAGEM '
      '       , DTFIMSEPARACAO '
      '       , QTERROS '
      '       , QTCANCEL '
      '       , NUMVOLPAS '
      '       , CODPRODORIG '
      '       , PCMOVENDPEND '
      '       , NUMPALETE3 '
      '       , FLOWABAST '
      '       , PESOCAMADA1 '
      '       , PESOCAMADA2 '
      '       , CAMADA '
      '       , LASTRO '
      '       , QTESTDISPANT '
      '       , QTANTEST '
      '       , CODFUNCCOFERENTE '
      '       , CODFUNCEMBALADOR '
      '       , DTINICIOCONFERENCIA '
      '       , DTFIMCONFERENCIA '
      '       , NUMSEQMONTAGEM '
      '       , NUMSEQENTREGA '
      '       , DATALIBERACAO '
      '       , CODFUNCLIBERACAO '
      '       , NUMSEQSEPARACAO '
      '       , ITEMSEPARADO '
      '       , QTCONFERIDA '
      '       , CODIGOUMA '
      '       , SEQUMA '
      '       , DATAENVIOVOVOLLECT '
      '       , OPERACAOINICIADARF '
      '       , CODMOTIVO '
      '       , NUMVIASETIQUETA '
      '       , RESPAVARIA '
      '       , CODFUNCGER '
      '       , NUMTRANSWMSORIG '
      '       , NUMTRANSENT '
      '       , DTATRIB '
      '       , CODFUNCATRIB '
      '       , PRIORIDADERF '
      '       , NUMVOLPED '
      '       , NUMAGRUPADOR '
      '       , CODMODSEP '
      '       , NUMVOLAGRUPADOR '
      '       , DTFABRICACAO '
      '       , OBS '
      '       , QTPECAS '
      '       , ORDEMTRANSF '
      '       , DATAGERACAO '
      '       , GRUPOESTFIMOS '
      '       , TIPOENDERECAMENTO '
      '       , DTFIMOSFILA '
      '       , DTINTEGRACAO '
      '       , QTPECASORIG '
      '       , QTCXORIG '
      '       , QTCX '
      '       , NUMVIASCARGARUA '
      '       , PULASEQCONF '
      '       , QTDEFALTAINFORMADA '
      '       , DTGERACAOCPL '
      '       , CODFILIALGESTAO '
      '       , DTGERACAOCLP '
      '       , DTFIMPROMOLOTE '
      '       , DTINICIOPROMOLOTE '
      '       , CODBOX '
      '       , CONFTOTALOS '
      '       , ROTINALANC '
      '       , CODDISTRIBUICAO '
      '       , NUMPALETE2 '
      '       , LIBERADOVOCOLLECT '
      '       , CODFUNCLIBERACAO_AUX '
      '       , CODFUNCAUTFAT '
      '       , DATALIBFAT '
      '       , NUMTRANSCARREG '
      '       , SEPARACAOANTECIPADA '
      '       , CODPRODACAB '
      '       , CODAGREGACAO '
      '       , CODENDERECOSTAGE '
      '       , CODBOXAGRUPAMENTO )'
      'SELECT NUMOS'
      '       , :NOVOTIPO '
      '    '#9' , DATA '
      '       , CODPROD '
      '       , QT '
      '       , CODOPER '
      '       , NUMTRANS '
      '       , HORA '
      '       , MINUTO '
      '       , NUMTRANSWMS '
      '       , DTVALIDADE '
      '       , CODROTINA '
      '       , NUMCARINI '
      '       , NUMCARFIM '
      '       , NUMVIAS '
      '       , NUMSEQ '
      '       , NUMCAR '
      '       , NUMBONUS '
      '       , DTESTORNO '
      '       , CODFUNCESTORNO '
      '       , NUMPALETE '
      '       , TIPOPROD '
      '       , NUMPED '
      '       , NUMLOTE '
      '       , QTRESERVADA '
      '       , POSICAO '
      '       , QTORIG '
      '       , CODFUNCCONF '
      '       , DATACONF '
      '       , CODFILIAL '
      '       , NUMTRANSVENDA '
      '       , NUMPEDINI '
      '       , NUMPEDFIM '
      '       , NUMTRANSVENDAINI '
      '       , NUMTRANSVENDAFIM '
      '       , CODENDERECO '
      '       , DTINICIOOS '
      '       , DTFIMOS '
      '       , CODFUNCOS        '
      '       , QTSEPARADA '
      '       , MUNICENT '
      '       , NUMBOX '
      '       , NUMVOL '
      '       , CODENDERECOORIG '
      '       , SEQPALETE '
      '       , CODPRACA '
      '       , CODFUNCOSFIM '
      '       , FUNCULTIMP '
      '       , DTULTIMP '
      '       , SEQCONF '
      '       , FUNCPRIIMP '
      '       , DTPRIIMP '
      '       , MATRFUNC '
      '       , CODFUNCINICIOS '
      '       , NUMPALETE1 '
      '       , NUMPALETE2_OLD '
      '       , TIPOEMBALAGEM '
      '       , DTFIMSEPARACAO '
      '       , QTERROS '
      '       , QTCANCEL '
      '       , NUMVOLPAS '
      '       , CODPRODORIG '
      '       , PCMOVENDPEND '
      '       , NUMPALETE3 '
      '       , FLOWABAST '
      '       , PESOCAMADA1 '
      '       , PESOCAMADA2 '
      '       , CAMADA '
      '       , LASTRO '
      '       , QTESTDISPANT '
      '       , QTANTEST '
      '       , CODFUNCCOFERENTE '
      '       , CODFUNCEMBALADOR '
      '       , DTINICIOCONFERENCIA '
      '       , DTFIMCONFERENCIA '
      '       , NUMSEQMONTAGEM '
      '       , NUMSEQENTREGA '
      '       , DATALIBERACAO '
      '       , CODFUNCLIBERACAO '
      '       , NUMSEQSEPARACAO '
      '       , ITEMSEPARADO '
      '       , QTCONFERIDA '
      '       , CODIGOUMA '
      '       , SEQUMA '
      '       , DATAENVIOVOVOLLECT '
      '       , OPERACAOINICIADARF '
      '       , CODMOTIVO '
      '       , NUMVIASETIQUETA '
      '       , RESPAVARIA '
      '       , CODFUNCGER '
      '       , NUMTRANSWMSORIG '
      '       , NUMTRANSENT '
      '       , DTATRIB '
      '       , CODFUNCATRIB '
      '       , PRIORIDADERF '
      '       , NUMVOLPED '
      '       , NUMAGRUPADOR '
      '       , CODMODSEP '
      '       , NUMVOLAGRUPADOR '
      '       , DTFABRICACAO '
      '       , OBS '
      '       , QTPECAS '
      '       , ORDEMTRANSF '
      '       , DATAGERACAO '
      '       , GRUPOESTFIMOS '
      '       , TIPOENDERECAMENTO '
      '       , DTFIMOSFILA '
      '       , DTINTEGRACAO '
      '       , QTPECASORIG '
      '       , QTCXORIG '
      '       , QTCX '
      '       , NUMVIASCARGARUA '
      '       , PULASEQCONF '
      '       , QTDEFALTAINFORMADA '
      '       , DTGERACAOCPL '
      '       , CODFILIALGESTAO '
      '       , DTGERACAOCLP '
      '       , DTFIMPROMOLOTE '
      '       , DTINICIOPROMOLOTE '
      '       , CODBOX '
      '       , CONFTOTALOS '
      '       , ROTINALANC '
      '       , CODDISTRIBUICAO '
      '       , NUMPALETE2 '
      '       , LIBERADOVOCOLLECT '
      '       , CODFUNCLIBERACAO_AUX '
      '       , CODFUNCAUTFAT '
      '       , DATALIBFAT '
      '       , NUMTRANSCARREG '
      '       , SEPARACAOANTECIPADA '
      '       , CODPRODACAB '
      '       , CODAGREGACAO '
      '       , CODENDERECOSTAGE '
      '       , CODBOXAGRUPAMENTO '
      'FROM   PCMOVENDPEND '
      'WHERE  NUMOS = :NUMOS '
      '       AND TIPOOS = :ANTIGOTIPO '
      '       AND NOT EXISTS ( SELECT PCMOVENDPEND.NUMOS '
      '                            FROM PCMOVENDPEND '
      
        '                            WHERE PCMOVENDPEND.CODFILIAL = :CODF' +
        'ILIAL'
      '                            AND PCMOVENDPEND.NUMOS = :NUMOS '
      
        '                            AND PCMOVENDPEND.TIPOOS = :NOVOTIPO ' +
        ')')
    Left = 112
    Top = 616
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'NOVOTIPO'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'NUMOS'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'ANTIGOTIPO'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'CODFILIAL'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'NUMOS'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'NOVOTIPO'
        ParamType = ptUnknown
      end>
  end
end
