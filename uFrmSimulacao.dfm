object FrmSimulacao: TFrmSimulacao
  Left = 0
  Top = 0
  Caption = 'Simula'#231#227'o de consulta'
  ClientHeight = 673
  ClientWidth = 882
  Color = clWhite
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  WindowState = wsMaximized
  DesignSize = (
    882
    673)
  PixelsPerInch = 96
  TextHeight = 16
  object grpFiltros: TcxGroupBox
    Left = 10
    Top = 8
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Cen'#225'rio para a simula'#231#227'o'
    TabOrder = 0
    DesignSize = (
      864
      438)
    Height = 448
    Width = 864
    object mskCodFilial: TcxMaskEdit
      Left = 123
      Top = 48
      Properties.MaskKind = emkRegExpr
      Properties.EditMask = '\d+'
      TabOrder = 0
      Width = 100
    end
    object spnRuaInicial: TcxSpinEdit
      Left = 238
      Top = 48
      Properties.AssignedValues.MinValue = True
      TabOrder = 1
      Width = 100
    end
    object spnRuaFinal: TcxSpinEdit
      Left = 353
      Top = 48
      Properties.AssignedValues.MinValue = True
      TabOrder = 2
      Width = 100
    end
    object spnRuaAnterior: TcxSpinEdit
      Left = 469
      Top = 48
      Properties.AssignedValues.MinValue = True
      TabOrder = 3
      Width = 100
    end
    object spnPercFinalizacao: TcxSpinEdit
      Left = 8
      Top = 336
      Properties.AssignedValues.MinValue = True
      TabOrder = 4
      Width = 121
    end
    object cxLabel2: TcxLabel
      Left = 123
      Top = 26
      Caption = 'Filial'
      Transparent = True
    end
    object cxLabel3: TcxLabel
      Left = 238
      Top = 26
      Caption = 'Rua inicial'
      Transparent = True
    end
    object cxLabel4: TcxLabel
      Left = 353
      Top = 26
      Caption = 'Rua final'
      Transparent = True
    end
    object cxLabel5: TcxLabel
      Left = 469
      Top = 26
      Caption = 'Rua anterior do operador'
      Transparent = True
    end
    object cxLabel7: TcxLabel
      Left = 8
      Top = 316
      Caption = 'Percentual de finaliza'#231#227'o de separa'#231#227'o para liberar pallet box'
      Transparent = True
    end
    object cxLabel8: TcxLabel
      Left = 135
      Top = 338
      Caption = 'Config. 263'
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Verdana'
      Style.Font.Style = [fsItalic]
      Style.TextColor = clBlue
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel9: TcxLabel
      Left = 8
      Top = 379
      Caption = 'Ruas exce'#231#227'o mov. vertical'
      Transparent = True
    end
    object mskRuasIgnorar: TcxMaskEdit
      Left = 8
      Top = 399
      Properties.MaskKind = emkRegExpr
      Properties.EditMask = '(\d+,{0,1})*'
      TabOrder = 12
      Width = 274
    end
    object cxLabel10: TcxLabel
      Left = 288
      Top = 400
      Caption = 'Config. 248'
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Verdana'
      Style.Font.Style = [fsItalic]
      Style.TextColor = clBlue
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel11: TcxLabel
      Left = 8
      Top = 139
      Caption = 'Ruas com excesso de funcion'#225'rios'
      Transparent = True
    end
    object mskRuasLotadasPaleteiros: TcxMaskEdit
      Left = 8
      Top = 158
      Properties.MaskKind = emkRegExpr
      Properties.EditMask = '(\d+,{0,1})*'
      TabOrder = 15
      Width = 274
    end
    object cxLabel12: TcxLabel
      Left = 288
      Top = 160
      Caption = 'Config. 251 e 252'
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Verdana'
      Style.Font.Style = [fsItalic]
      Style.TextColor = clBlue
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel15: TcxLabel
      Left = 242
      Top = 141
      Caption = 
        '(Informe o n'#250'mero das ruas que estariam super lotadas nessa simu' +
        'la'#231#227'o)'
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Verdana'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object chkRuaSuperlotadaAntes: TcxCheckBox
      Left = 397
      Top = 101
      Caption = 'Estava em rua super lotada na senha anterior (FLAG SL)'
      TabOrder = 18
      Transparent = True
    end
    object chkBuscarArmazemTodo: TcxCheckBox
      Left = 198
      Top = 101
      Caption = 'Buscar no armaz'#233'm todo'
      TabOrder = 19
      Transparent = True
    end
    object radPaleteiro: TRadioButton
      Left = 8
      Top = 103
      Width = 81
      Height = 17
      Caption = 'Paleteiro'
      Checked = True
      TabOrder = 20
      TabStop = True
    end
    object radEmpilhador: TRadioButton
      Left = 95
      Top = 103
      Width = 89
      Height = 17
      Caption = 'Empilhador'
      TabOrder = 21
    end
    object chkPalletBox: TcxCheckBox
      Left = 397
      Top = 400
      Caption = 'Trabalhar com Pallet Box'
      TabOrder = 22
      Transparent = True
    end
    object cxLabel17: TcxLabel
      Left = 587
      Top = 400
      Caption = 'Config. 264'
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Verdana'
      Style.Font.Style = [fsItalic]
      Style.TextColor = clBlue
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel1: TcxLabel
      Left = 8
      Top = 25
      Caption = 'Crit'#233'rio'
      Transparent = True
    end
    object cbbCriterios: TcxComboBox
      Left = 8
      Top = 48
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownRows = 20
      Properties.Items.Strings = (
        '5'
        '6'
        '6.5'
        '7'
        '7.5'
        '8'
        '8.2'
        '8.5'
        '9.5'
        '10'
        '11')
      TabOrder = 25
      Width = 100
    end
    object btnSimular: TcxButton
      Left = 704
      Top = 391
      Width = 151
      Height = 40
      Anchors = [akRight, akBottom]
      Caption = 'Rodar simula'#231#227'o'
      TabOrder = 26
      OnClick = btnSimularClick
      ExplicitTop = 307
    end
    object btnExplicacaoRuasIgnorar: TcxButton
      Left = 8
      Top = 187
      Width = 241
      Height = 25
      Caption = 'Como essa lista de ruas '#233' obtida?'
      TabOrder = 27
      OnClick = btnExplicacaoRuasIgnorarClick
    end
    object cxLabel13: TcxLabel
      Left = 8
      Top = 229
      Caption = 'Ruas com excesso de OSs'
      Transparent = True
    end
    object mskRuasLotadasOSs: TcxMaskEdit
      Left = 8
      Top = 248
      Properties.MaskKind = emkRegExpr
      Properties.EditMask = '(\d+,{0,1})*'
      TabOrder = 29
      Width = 274
    end
    object cxLabel14: TcxLabel
      Left = 191
      Top = 231
      Caption = 
        '(Informe o n'#250'mero das ruas que estariam super lotadas nessa simu' +
        'la'#231#227'o)'
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Verdana'
      Style.Font.Style = [fsItalic]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel16: TcxLabel
      Left = 288
      Top = 250
      Caption = 'Config. 249'
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Verdana'
      Style.Font.Style = [fsItalic]
      Style.TextColor = clBlue
      Style.IsFontAssigned = True
      Transparent = True
    end
    object btnExplicacaoRuasExcessoOS: TcxButton
      Left = 8
      Top = 277
      Width = 241
      Height = 25
      Caption = 'Como essa lista de ruas '#233' obtida?'
      TabOrder = 32
      OnClick = btnExplicacaoRuasExcessoOSClick
    end
  end
  object cxGrid1: TcxGrid
    Left = 469
    Top = 488
    Width = 405
    Height = 177
    Anchors = [akTop, akRight, akBottom]
    TabOrder = 1
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object mmQuery: TcxMemo
    Left = 8
    Top = 488
    Anchors = [akLeft, akTop, akRight, akBottom]
    Properties.ReadOnly = True
    Properties.ScrollBars = ssBoth
    TabOrder = 2
    Height = 177
    Width = 455
  end
  object cxLabel6: TcxLabel
    Left = 8
    Top = 462
    Caption = 'Query criada'
    Transparent = True
  end
  object cxLabel18: TcxLabel
    Left = 469
    Top = 462
    Anchors = [akTop, akRight]
    Caption = 'Resultado'
    Transparent = True
  end
end
