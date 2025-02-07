object FrmExplicacaoRuasIgnorar: TFrmExplicacaoRuasIgnorar
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Como a lista de ruas super lotadas '#233' obtida'
  ClientHeight = 430
  ClientWidth = 925
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object mmPaleteiros: TcxMemo
    Left = 8
    Top = 32
    Properties.ReadOnly = True
    Properties.ScrollBars = ssBoth
    TabOrder = 0
    Height = 380
    Width = 449
  end
  object mmEmpilhadores: TcxMemo
    Left = 463
    Top = 32
    Properties.ReadOnly = True
    Properties.ScrollBars = ssBoth
    TabOrder = 1
    Height = 380
    Width = 449
  end
  object cxLabel1: TcxLabel
    Left = 8
    Top = 9
    Caption = 'Paleteiros'
    Transparent = True
  end
  object cxLabel2: TcxLabel
    Left = 463
    Top = 8
    Caption = 'Empilhadores'
    Transparent = True
  end
end
