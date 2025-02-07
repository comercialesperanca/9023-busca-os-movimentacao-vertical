object FrmInicial: TFrmInicial
  Left = 0
  Top = 0
  Caption = 'Rotina 9023'
  ClientHeight = 456
  ClientWidth = 890
  Color = clBtnFace
  Constraints.MinHeight = 494
  Constraints.MinWidth = 906
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 23
  object pgcPrincipal: TcxPageControl
    Left = 0
    Top = 0
    Width = 890
    Height = 456
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = tabRobo
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 453
    ClientRectLeft = 2
    ClientRectRight = 887
    ClientRectTop = 37
    object tabRobo: TcxTabSheet
      Caption = 'Rob'#244
      ImageIndex = 0
      DesignSize = (
        885
        416)
      object btnIniciar: TcxButton
        Left = 779
        Top = 370
        Width = 100
        Height = 40
        Anchors = [akRight, akBottom]
        Caption = 'Iniciar'
        TabOrder = 0
        OnClick = btnIniciarClick
      end
      object btnLimparLog: TcxButton
        Left = 8
        Top = 370
        Width = 152
        Height = 40
        Anchors = [akLeft, akBottom]
        Caption = 'Limpar Log'
        TabOrder = 1
        OnClick = btnLimparLogClick
      end
      object btnParar: TcxButton
        Left = 673
        Top = 370
        Width = 100
        Height = 40
        Anchors = [akRight, akBottom]
        Caption = 'Parar'
        Enabled = False
        TabOrder = 2
        OnClick = btnPararClick
      end
      object memo: TcxMemo
        Left = 8
        Top = 8
        Anchors = [akLeft, akTop, akRight, akBottom]
        ParentFont = False
        Properties.ReadOnly = True
        Properties.ScrollBars = ssBoth
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -19
        Style.Font.Name = 'Verdana'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 3
        Height = 305
        Width = 873
      end
      object chkExibirMensagensLog: TcxCheckBox
        Left = 8
        Top = 319
        Caption = 'Exibir mensagens log'
        TabOrder = 4
        Transparent = True
      end
      object chkRegistrarLogs: TcxCheckBox
        Left = 256
        Top = 319
        Caption = 'Registrar logs de analise de crit'#233'rios'
        TabOrder = 5
        Transparent = True
      end
      object btnSimulacao: TcxButton
        Left = 166
        Top = 370
        Width = 243
        Height = 40
        Anchors = [akLeft, akBottom]
        Caption = 'Simula'#231#227'o de consulta'
        TabOrder = 6
        OnClick = btnSimulacaoClick
      end
    end
    object tabOSAtribuidas: TcxTabSheet
      BorderWidth = 5
      Caption = 'O.S. Atribu'#237'das'
      ImageIndex = 1
      object grdOSAtrbuidas: TcxGrid
        Left = 0
        Top = 0
        Width = 875
        Height = 406
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object grdOSAtrbuidasDBTableView1: TcxGridDBTableView
          OnDblClick = grdOSAtrbuidasDBTableView1DblClick
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = dmdb.dsrOSsAtribuidas
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <
            item
              Kind = skCount
              Column = grdOSAtrbuidasDBTableView1DATA
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.NoDataToDisplayInfoText = 'Sem dados a serem exibidos'
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          object grdOSAtrbuidasDBTableView1SENHA: TcxGridDBColumn
            DataBinding.FieldName = 'SENHA'
          end
          object grdOSAtrbuidasDBTableView1TIPOOPERADOR: TcxGridDBColumn
            DataBinding.FieldName = 'TIPOOPERADOR'
            Width = 124
          end
          object grdOSAtrbuidasDBTableView1DTSOLICITACAO: TcxGridDBColumn
            DataBinding.FieldName = 'DTSOLICITACAO'
          end
          object grdOSAtrbuidasDBTableView1RUAINICIAL: TcxGridDBColumn
            DataBinding.FieldName = 'RUAINICIAL'
            Width = 171
          end
          object grdOSAtrbuidasDBTableView1RUAFINAL: TcxGridDBColumn
            DataBinding.FieldName = 'RUAFINAL'
            Width = 160
          end
          object grdOSAtrbuidasDBTableView1RANGERUASEXCECAO: TcxGridDBColumn
            DataBinding.FieldName = 'RANGERUASEXCECAO'
            Width = 199
          end
          object grdOSAtrbuidasDBTableView1DATA: TcxGridDBColumn
            DataBinding.FieldName = 'DATA'
            Width = 147
          end
          object grdOSAtrbuidasDBTableView1MATRICULA: TcxGridDBColumn
            DataBinding.FieldName = 'MATRICULA'
          end
          object grdOSAtrbuidasDBTableView1NUMOS: TcxGridDBColumn
            DataBinding.FieldName = 'NUMOS'
            Width = 71
          end
          object grdOSAtrbuidasDBTableView1RUA: TcxGridDBColumn
            DataBinding.FieldName = 'RUA'
            Width = 50
          end
          object grdOSAtrbuidasDBTableView1TOTALOSRUA: TcxGridDBColumn
            DataBinding.FieldName = 'TOTALOSRUA'
            Width = 122
          end
          object grdOSAtrbuidasDBTableView1TOTALFUNCRUA: TcxGridDBColumn
            DataBinding.FieldName = 'TOTALFUNCRUA'
            Width = 136
          end
          object grdOSAtrbuidasDBTableView1CODIGOUMA: TcxGridDBColumn
            DataBinding.FieldName = 'CODIGOUMA'
            Width = 104
          end
          object grdOSAtrbuidasDBTableView1CODENDERECO: TcxGridDBColumn
            DataBinding.FieldName = 'CODENDERECO'
            Width = 112
          end
          object grdOSAtrbuidasDBTableView1CODENDERECOORIG: TcxGridDBColumn
            DataBinding.FieldName = 'CODENDERECOORIG'
            Width = 171
          end
          object grdOSAtrbuidasDBTableView1TIPOOS: TcxGridDBColumn
            DataBinding.FieldName = 'TIPOOS'
            Width = 71
          end
          object grdOSAtrbuidasDBTableView1CRITERIO: TcxGridDBColumn
            DataBinding.FieldName = 'CRITERIO'
            Width = 107
          end
          object grdOSAtrbuidasDBTableView1ARMAZEMTODO: TcxGridDBColumn
            DataBinding.FieldName = 'ARMAZEMTODO'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.Alignment = taRightJustify
            Properties.ValueChecked = '1'
            Properties.ValueUnchecked = '0'
            Width = 114
          end
          object grdOSAtrbuidasDBTableView1SUPERLOTADA: TcxGridDBColumn
            DataBinding.FieldName = 'SUPERLOTADA'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.Alignment = taRightJustify
            Properties.ValueChecked = '1'
            Properties.ValueUnchecked = '0'
            Width = 105
          end
          object grdOSAtrbuidasDBTableView1SENHAANTERIOR: TcxGridDBColumn
            DataBinding.FieldName = 'SENHAANTERIOR'
            Width = 127
          end
          object grdOSAtrbuidasDBTableView1RUAANTERIOR: TcxGridDBColumn
            DataBinding.FieldName = 'RUAANTERIOR'
            Width = 118
          end
          object grdOSAtrbuidasDBTableView1TIPOOSANTERIOR: TcxGridDBColumn
            DataBinding.FieldName = 'TIPOOSANTERIOR'
            Width = 147
          end
          object grdOSAtrbuidasDBTableView1DTSOLICITACAOANTERIOR: TcxGridDBColumn
            DataBinding.FieldName = 'DTSOLICITACAOANTERIOR'
            Width = 209
          end
          object grdOSAtrbuidasDBTableView1TOTALOSRUAANTERIOR: TcxGridDBColumn
            DataBinding.FieldName = 'TOTALOSRUAANTERIOR'
            Width = 318
          end
          object grdOSAtrbuidasDBTableView1TOTALFUNCRUAANTERIOR: TcxGridDBColumn
            DataBinding.FieldName = 'TOTALFUNCRUAANTERIOR'
            Width = 346
          end
          object grdOSAtrbuidasDBTableView1SEGUNDOSLOCALIZACAOOS: TcxGridDBColumn
            DataBinding.FieldName = 'SEGUNDOSLOCALIZACAOOS'
            Width = 288
          end
        end
        object grdOSAtrbuidasLevel1: TcxGridLevel
          GridView = grdOSAtrbuidasDBTableView1
        end
      end
    end
  end
  object timer: TTimer
    OnTimer = timerTimer
    Left = 741
    Top = 136
  end
  object cxLookAndFeelController1: TcxLookAndFeelController
    NativeStyle = False
    ScrollbarMode = sbmClassic
    SkinName = 'SevenClassic'
    Left = 716
    Top = 74
  end
end
