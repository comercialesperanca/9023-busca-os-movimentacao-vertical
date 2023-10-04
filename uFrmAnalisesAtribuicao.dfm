object frmAnalisesatribuicao: TfrmAnalisesatribuicao
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  BorderWidth = 5
  Caption = 'An'#225'lise da Atribui'#231#227'o'
  ClientHeight = 554
  ClientWidth = 1006
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object memo: TcxDBMemo
    Left = 0
    Top = 0
    Align = alClient
    DataBinding.DataField = 'ANALISE'
    DataBinding.DataSource = dmdb.dsrOSsAtribuidas
    ParentFont = False
    Properties.ReadOnly = True
    Properties.ScrollBars = ssBoth
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Verdana'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 0
    Height = 554
    Width = 1006
  end
end
