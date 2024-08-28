program pServer;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, uClassServer, Horse, Horse.Jhonson, Horse.Commons, System.JSON,
  FireDAC.Comp.Client, uClassBanco;

var
  MyServer: TServer;
  bd : TBanco;
  Query: TFDQuery;
begin
  bd := TBanco.Create;
  try
    try
      Query := bd.ExecSQL('select * from servidores');
      while not Query.Eof do
      begin
        Writeln(Query.FieldByName('nome').AsString);
        Query.Next;
      end;
    finally
      bd.Free;
    end;

//    MyServer := TServer.Create('1', 'Teste', '127.0.0.1', 8080);
//    try
//      MyServer.Start;
//    except
//      on E: Exception do
//        Writeln(E.ClassName, ': ', E.Message);
//    end;
  finally
    MyServer.Free;
  end;



end.

