unit uClassBanco;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Stan.Param, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL,
  FireDAC.DApt, Data.DB, System.JSON,System.Classes;

type
  //criando uma definição de tipo para passar parametros
  TParamPair = record
    Key: string;
    Value: Variant;
  end;

  TBanco = class
  private
   
  public
    constructor Create;
    destructor Destroy; override;
    procedure OpenConexao;
    procedure CloseConexao;
    function OpenSQL(const SQL: String; const Params: TArray<TParamPair>): TJSONArray; virtual;
    procedure ExecSQL(const SQL: String; const Params: TArray<TParamPair>);
    function GerarUUID: string;
  end;

  TBancoServer = class(TBanco)
    private

    public
      constructor Create;
      destructor Destroy; override;
      function getServers : TJSONArray;
      function IncluirServer(id, nome, ip : string ; porta : integer) :  TJSONArray;
      function DeleteServer(id:string) : TJSONArray;
      function getServerByID(id:string) : TJSONObject;
  end;

  TBancoVideo = Class(TBanco)
    private

    public
      constructor Create;
      destructor Destroy; override;
      procedure AddVideo(const id, description: string; content: TStream;sizeinbytes:integer;serverid:string);
      function getAllVideoServerId(const serverid : string): TJSONArray;
      function getVideo(const serverid,videoid : string): TJSONArray;
      function DeleteVideo(const videoid,serverID : string) : TJSONArray;
      function DownloadVideo(const videoid,serverID : string) : TMemoryStream;
      function RecyclingVideo(const dias : integer) : Boolean;
  end;



implementation
uses
  uDm;
{ TBanco }

procedure TBanco.CloseConexao;
begin
  if dm.conexao.Connected then
    dm.conexao.Connected := False;
end;


constructor TBanco.Create;
begin
  inherited Create;
end;


destructor TBanco.Destroy;
begin
  CloseConexao;
  inherited Destroy;
end;

procedure TBanco.ExecSQL(const SQL: String; const Params: TArray<TParamPair>);
var
  Query: TFDQuery;
  Param : TParamPair;
begin
(*
função para dar um execSQL um commit caso sucesso e um rollback na falha
podendo ter campos de parametros para filtro
*)
  Query := TFDQuery.Create(nil);
  try
    OpenConexao;
    Query.Connection := dm.conexao;
    Query.SQL.Text := SQL;

    for Param in Params do
      Query.ParamByName(Param.Key).Value := Param.Value;
    try
      Query.ExecSQL;
      dm.conexao.Commit;
    except
      on E: Exception do begin
        dm.conexao.Rollback;
        raise;
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TBanco.OpenSQL(const SQL: String; const Params: TArray<TParamPair>): TJSONArray;
var
  Query: TFDQuery;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  i: Integer;
  Field: TField;
  Param: TParamPair;
begin
(*
função para ler qual quer sql e retornar um json array
podendo ter campos de parametros para filtro
*)
  Query := TFDQuery.Create(nil);
  JSONArray := TJSONArray.Create;
  try
    OpenConexao;
    Query.Connection := dm.conexao;
    Query.SQL.Text := SQL;

    for Param in Params do
      Query.ParamByName(Param.Key).Value := Param.Value;

    Query.Open;

    while not Query.Eof do begin
      JSONObject := TJSONObject.Create;
      for i := 0 to Query.FieldCount - 1 do begin
        Field := Query.Fields[i];
        JSONObject.AddPair(Field.FieldName, TJSONString.Create(Field.AsString));
      end;
      JSONArray.Add(JSONObject);
      Query.Next;
    end;
    Result := JSONArray;
  except
    on E: Exception do begin
      JSONArray.Free;
      Query.Free;
      raise;
    end;
  end;
end;


function TBanco.GerarUUID: string;
var
    GUID: TGUID;
begin
  CreateGUID(GUID);
  Result := GUIDToString(GUID).ToUpper.Replace('{', '').Replace('}', '');
end;

procedure TBanco.OpenConexao;
begin
  if not dm.conexao.Connected then
    dm.conexao.Connected := True;
end;

{ TBancoServer }

constructor TBancoServer.Create;
begin
  inherited Create;
end;

function TBancoServer.DeleteServer(id: string): TJSONArray;
var
  Params : TArray<TParamPair>;
  sql : string;
begin
  SetLength(params,1);
  Params[0].Key  := 'serverid';
  Params[0].Value := id;

  sql := 'delete from servidores where serverid = :serverid';
  ExecSQL(sql,Params);
  result := getServers;
end;

destructor TBancoServer.Destroy;
begin
  inherited Destroy;
end;

function TBancoServer.getServerByID(id: string): TJSONObject;
var
  Params: TArray<TParamPair>;
  sql: string;
  jArr: TJSONArray;
  jObj: TJSONObject;
begin
  SetLength(Params, 1);
  Params[0].Key := 'serverid';
  Params[0].Value := id;

  sql := 'SELECT * FROM servidores WHERE serverid = :serverid';
  jArr := OpenSQL(sql, Params);

  try
    if (jArr <> nil) and (jArr.Count > 0) then begin
      jObj := jArr.Items[0] as TJSONObject;
      if Assigned(jObj) then begin
        Result := TJSONObject.Create;
        Result.AddPair('serverid', jObj.GetValue<string>('serverid'));
        Result.AddPair('nome', jObj.GetValue<string>('nome'));
        Result.AddPair('ip', jObj.GetValue<string>('ip'));
        Result.AddPair('porta', jObj.GetValue<string>('porta'));
      end;
    end
    else
    begin

      Result.AddPair('error', 'Servidor não encontrado');
    end;
  finally
    jArr.Free;
  end;

end;

function TBancoServer.getServers: TJSONArray;
begin
  result := OpenSQL('select * from servidores',[]);
end;

function TBancoServer.IncluirServer(id, nome, ip: string;
  porta: integer): TJSONArray;
var
  Params : TArray<TParamPair>;
  sql : string;
begin

  SetLength(Params, 4);
  Params[0].Key  := 'serverid';
  Params[0].Value := id;
  Params[1].Key := 'nome';
  Params[1].Value := nome;
  Params[2].Key := 'ip';
  Params[2].Value := ip;
  Params[3].Key := 'porta';
  Params[3].Value := porta;
  sql := 'insert into servidores(serverid,nome,ip,porta)'+
         'values(:serverid,:nome,:ip,:porta)';
  ExecSQL(sql,params);
  result := getServers;

end;

{ TBancoVideo }

procedure TBancoVideo.AddVideo(const id, description: string; content: TStream;
sizeinbytes:integer;serverid:string);
var
  query : TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    OpenConexao;
    query.Connection := dm.conexao;
    query.SQL.Add('insert into videos(videoid, description, content, sizeInBytes, serverid)');
    query.SQL.Add('values(:videoid, :description, :content, :sizeinbytes, :serverid )');
    Query.ParamByName('videoid').AsString := GerarUUID;
    Query.ParamByName('description').AsString := description;
    Query.ParamByName('content').LoadFromStream(content, ftBlob);
    Query.ParamByName('sizeInBytes').AsInteger := sizeinbytes;
    Query.ParamByName('serverid').AsString := serverid;

    try
      Query.ExecSQL;
      dm.conexao.Commit;
    except
      on E: Exception do begin
        dm.conexao.Rollback;
        raise Exception.Create(e.Message);
      end;

    end;

  finally
    query.Free;
  end;
end;

constructor TBancoVideo.Create;
begin
  inherited Create;
end;

function TBancoVideo.DeleteVideo(const videoid, serverID: string): TJSONArray;
var
  Params: TArray<TParamPair>;
  sql : string;
begin
  SetLength(Params,2);
  Params[0].Key := 'videoid';
  Params[0].Value := videoid;         
  Params[1].Key := 'serverid';
  Params[1].Value := serverid;

  sql := 'delete from videos '+
         'where videoid = :videoid and serverid = :serverid';
  ExecSQL(sql,Params);
  result := getAllVideoServerId(serverid);
end;

destructor TBancoVideo.Destroy;
begin

  inherited;
end;

function TBancoVideo.DownloadVideo(const videoid, serverID: string): TMemoryStream;
var
  Params: TArray<TParamPair>;
  sql: string;
  jArr: TJSONArray;
  jObj: TJSONObject;
  content: TBytes;
  MemoryStream: TMemoryStream;
begin
  MemoryStream := TMemoryStream.Create;
  try
    SetLength(Params, 2);
    Params[0].Key := 'serverid';
    Params[0].Value := serverid;
    Params[1].Key := 'videoid';
    Params[1].Value := videoid;

    sql := 'select content ' +
           'from videos ' +
           'where serverid = :serverid and ' +
           '      videoid = :videoid';
    jArr := OpenSQL(sql, Params);

    if (jArr <> nil) and (jArr.Count > 0) then
    begin
      jObj := jArr.Items[0] as TJSONObject;
      if Assigned(jObj) then begin
        content := TEncoding.UTF8.GetBytes(jObj.GetValue<string>('content'));

        MemoryStream.WriteBuffer(content[0], Length(content));
        MemoryStream.Position := 0;
      end;
    end;
    Result := MemoryStream;
  except
    MemoryStream.Free;
    raise;
  end;

end;


function TBancoVideo.getAllVideoServerId(const serverid: string): TJSONArray;
var
  Params: TArray<TParamPair>;
  sql : string;
begin
  SetLength(Params,1);
  Params[0].Key := 'serverid';
  Params[0].Value := serverid;
  sql := 'select * from videos where serverid = :serverid';
  result := OpenSQL(sql,Params);
end;

function TBancoVideo.getVideo(const serverid, videoid: string): TJSONArray;
var
  sql : string;
  Params : TArray<TParamPair>;
begin
  SetLength(Params, 2);
  Params[0].Key  := 'serverid';
  Params[0].Value := serverID;
  Params[1].Key := 'videoid';
  Params[1].Value := videoid;

  sql := 'select * from videos '+
         'where serverid = :serverid and ' +
         '      videoid = :videoid';
  result := OpenSQL(sql,Params);
end;

function TBancoVideo.RecyclingVideo(const dias: integer): Boolean;
var
  sql : string;
  Params : TArray<TParamPair>;
begin
  SetLength(Params,1);
  Params[0].Key := 'dias';
  Params[0].Value := dias;

  sql := 'delete from videos '+
         'where datediff(day,data_insercao,getdate()) > :dias ';
  try
    ExecSQL(sql,Params);
    result := True;
  except
    result := False;
  end;


end;

end.

