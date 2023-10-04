object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'BuscaOSsMovVertical'
  ClientHeight = 215
  ClientWidth = 568
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pncabecalho: TPanel
    Left = 0
    Top = 0
    Width = 568
    Height = 41
    Align = alTop
    TabOrder = 0
    Visible = False
  end
  object pnProcesso: TPanel
    Left = 0
    Top = 41
    Width = 389
    Height = 157
    Align = alClient
    TabOrder = 1
    object lblTimerOSBusca: TLabel
      Left = 201
      Top = 32
      Width = 45
      Height = 18
      Caption = '00:00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblUltimaBuscaOS: TLabel
      Left = 201
      Top = 12
      Width = 45
      Height = 18
      Caption = '00:00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblUltimaBuscaOSlbl: TLabel
      Left = 7
      Top = 10
      Width = 174
      Height = 18
      Caption = #218'ltima busca por OS em  :'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 7
      Top = 32
      Width = 176
      Height = 18
      Caption = 'Pr'#243'xima busca por OS em:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnBotoes: TPanel
    Left = 389
    Top = 41
    Width = 179
    Height = 157
    Align = alRight
    TabOrder = 2
    object btnIniciarServico: TButton
      Left = 15
      Top = 6
      Width = 98
      Height = 25
      Caption = 'Iniciar Servi'#231'o'
      TabOrder = 0
      OnClick = btnIniciarServicoClick
    end
    object chkRecebimento: TCheckBox
      Left = 6
      Top = 50
      Width = 115
      Height = 17
      Caption = 'Recebimento'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object chkAbastecimento: TCheckBox
      Left = 6
      Top = 87
      Width = 115
      Height = 17
      Caption = 'Abastecimento'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object chkLimparOsAbandonadas: TCheckBox
      Left = 6
      Top = 124
      Width = 163
      Height = 17
      Caption = 'Tratar OS'#39's abandonadas'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
  end
  object pbProcesso: TProgressBar
    Left = 0
    Top = 198
    Width = 568
    Height = 17
    Align = alBottom
    TabOrder = 3
  end
  object tProcesso: TTimer
    OnTimer = tProcessoTimer
    Left = 520
    Top = 8
  end
end
