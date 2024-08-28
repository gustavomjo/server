unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uClassServer, Vcl.ComCtrls,udm,
  Vcl.ExtCtrls, System.ImageList, Vcl.ImgList, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FServidor : TServer;
    procedure LigarServer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses
  uClassBanco;

{$R *.dfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  LigarServer;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FServidor.Destroy;
end;

procedure TForm1.LigarServer;
begin
  try
    FServidor := TServer.Create;
    FServidor.ID := '1';
    FServidor.Name := 'Teste';
    FServidor.IP := '127.0.0.1';
    FServidor.Porta := 8080;
    FServidor.Start;
  except
  end;
end;



end.
