unit uFrmAnalisesAtribuicao;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxTextEdit, cxMemo, cxDBEdit;

type
  TfrmAnalisesatribuicao = class(TForm)
    memo: TcxDBMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAnalisesatribuicao: TfrmAnalisesatribuicao;

implementation

uses UFRMDmdb;

{$R *.dfm}

end.
