program pServer;

uses
  Vcl.Forms,
  uPrincipal in 'fontes\uPrincipal.pas' {Form1},
  uDm in 'fontes\uDm.pas' {dm: TDataModule},
  uClassBanco in 'fontes\uClassBanco.pas',
  uClassServer in 'fontes\uClassServer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(Tdm, dm);
  Application.Run;
end.
