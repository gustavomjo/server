unit uClassBanco;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Stan.Param, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL,
  FireDAC.DApt, Data.DB;

type
  TBanco = class
  private
    FConexao: TFDConnection;
    FQuery: TFDQuery;
    procedure ConfConexao;
  public
    constructor Create;
    destructor Destroy; override;
    procedure OpenConexao;
    procedure CloseConexao;
    function ExecSQL(const SQL: String): TFDQuery;
  end;

implementation

{ TBanco }

procedure TBanco.CloseConexao;
begin
  if FConexao.Connected then
    FConexao.Connected := False;
end;

procedure TBanco.ConfConexao;
begin
  FConexao.DriverName := 'MSSQL';
  FConexao.Params.Database := 'banco';
  FConexao.Params.Add('Server=localhost\SQLEXPRESS'); // Nome do servidor
  FConexao.Params.Add('Trusted_Connection=True'); // Utiliza autenticação do Windows

end;

constructor TBanco.Create;
begin
  inherited Create;
  FConexao := TFDConnection.Create(nil);
  FQuery := TFDQuery.Create(nil);
  ConfConexao;
  FQuery.Connection := FConexao;
end;

destructor TBanco.Destroy;
begin
  FQuery.Free;
  FConexao.Free;
  inherited Destroy;
end;

function TBanco.ExecSQL(const SQL: String): TFDQuery;
begin
  OpenConexao;
  FQuery.SQL.Text := SQL;
  FQuery.Open;
  Result := FQuery;
end;

procedure TBanco.OpenConexao;
begin
  if not FConexao.Connected then
    FConexao.Connected := True;
end;

end.

