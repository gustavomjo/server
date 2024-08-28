unit uClassServer;

interface

uses
  System.SysUtils, System.Generics.Collections, System.JSON, Horse,
  Horse.Jhonson, Horse.Commons, System.Classes, FireDAC.Comp.Client,
  FireDAC.Stan.Def, FireDAC.Stan.Param, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL, FireDAC.DApt, IdTCPClient, IdGlobal;

type
  TServer = class
  private
    FID: string;
    FName: string;
    FPorta: integer;
    FIP: string;
    FHorse: THorse;
    procedure RoutesServer;
    procedure RoutesVideo;
  public
    constructor Create;
    destructor Destroy; override;
    function ToJSON: TJSONObject;
    procedure Start;
    function AvailableServer(const IP: string; Port: Integer): Boolean;
  published
    property ID: string read FID write FID;
    property Name: string read FName write FName;
    property IP: string read FIP write FIP;
    property Porta: integer read FPorta write FPorta;
  end;


implementation

uses uClassBanco;

{ TServer }

function TServer.AvailableServer(const IP: string; Port: Integer): Boolean;
var
  TCPClient : TIdTCPClient;
begin
  Result := False;
  TCPClient := TIdTCPClient.Create(nil);
  try
    TCPClient.Host := IP;
    TCPClient.Port := Port;
    TCPClient.ReadTimeout := 100;
    try
      TCPClient.Connect;
      Result := TCPClient.Connected;
    except
      on E: Exception do begin
        Result := False;
      end;
    end;
  finally
    TCPClient.Disconnect;
    TCPClient.Free;
  end;
end;

constructor TServer.Create;
begin
  FHorse := THorse.Create;
end;

destructor TServer.Destroy;
begin
  FHorse.Free;
  inherited;
end;

procedure TServer.RoutesServer;
begin
  FHorse.Use(Jhonson);
  FHorse.Get('/api/server',
    procedure(req: THorseRequest; res: THorseResponse; Next: TProc)
    var
      JSONArray: TJSONArray;
      bd: TBancoServer;
    begin
      bd := TBancoServer.Create;
      JSONArray := bd.getServers;
      try
        res.ContentType('application/json');
        res.Send(JSONArray.ToString).Status(THTTPStatus.OK);
      finally
        JSONArray.Free;
      end;
    end
  );

  FHorse.Post('/api/server',
    procedure(req: THorseRequest; res: THorseResponse; Next: TProc)
    var
      jArray: TJSONArray;
      body : string;
      jObj : TJSONObject;
      bd: TBancoServer;
      id : string;
      nome : string;
      ip : string;
      porta : integer;
    begin
      body := req.Body;
      jObj := TJSONObject.ParseJSONValue(body) as TJSONObject;
      if Assigned(jObj) then begin
        id := jObj.GetValue<string>('id');
        nome := jObj.GetValue<string>('nome');
        ip := jObj.GetValue<string>('ip');
        porta := jObj.GetValue<Integer>('porta');
        bd := TBancoServer.Create;
        jArray := bd.IncluirServer(id,nome,ip,porta);
        try
          res.ContentType('application/json');
          res.Send(jArray.ToString).Status(THTTPStatus.OK);
        finally
          jArray.Free;
          bd.Free;
        end;
      end;
    end
  );

  FHorse.Delete('/api/server/:serverId',
    procedure(req: THorseRequest; res: THorseResponse; Next: TProc)
    var
      serverId: string;
      jArray : TJSONArray;
      bd: TBancoServer;
    begin
      bd := TBancoServer.Create;
      try
        try
          serverId := req.Params['serverId'];
          if serverId <> '' then begin
            jArray := bd.DeleteServer(serverid);
            res.ContentType('application/json');
            res.Send(jArray.ToString).Status(THTTPStatus.OK);
          end
          else
            res.Status(THTTPStatus.BadRequest).Send('Server ID is required.');
        finally
          bd.Free;
          jArray.Free;

        end;
      except
        on E: Exception do
          res.Status(THTTPStatus.BadRequest).Send('Error processing request: ' + E.Message);
      end;
    end
  );


  FHorse.Get('/api/server/:id',
    procedure(req: THorseRequest; res: THorseResponse; Next: TProc)
    var
      serverId: string;
      jsonResponse: TJSONObject;
      bd: TBancoServer;
    begin
      serverId := req.Params['id'];
      if serverId <> '' then begin
        bd := TBancoServer.Create;
        try
          jsonResponse := bd.GetServerByID(serverId);
          try
            res.ContentType('application/json');
            res.Send(jsonResponse.ToString).Status(THTTPStatus.OK);
          finally
            jsonResponse.Free;
          end;
        finally
          bd.Free;
        end;
      end
      else
        res.Status(THTTPStatus.BadRequest).Send('Server ID is required.');
    end
  );

  FHorse.Get('/api/servers/available/:serverId',
    procedure(req: THorseRequest; res: THorseResponse; Next: TProc)
    var
      serverId: string;
      available: Boolean;
      bd: TBancoServer;
      ip: string;
      porta: Integer;
      jObj : TJSONObject;
    begin
      serverId := req.Params['serverId'];
      if serverId <> '' then begin
        bd := TBancoServer.Create;
        try
          jobj := bd.getServerByID(serverId);
          ip := jObj.GetValue<string>('ip');
          porta := jObj.GetValue<Integer>('porta');
          available := AvailableServer(ip, porta);
          res.ContentType('application/json');
          if available then
            res.Send('{ "status": "running" }').Status(THTTPStatus.OK)
          else
            res.Send('{ "status": "not running" }').Status(THTTPStatus.ServiceUnavailable);
        finally
          bd.Free;
        end;
      end
      else
        res.Status(THTTPStatus.BadRequest).Send('Server ID is required.');
    end
  );
end;


procedure TServer.RoutesVideo;
begin
  FHorse.Post('/api/servers/:serverId/videos',
    procedure(req : THorseRequest;res :THorseResponse;Next:TProc)
    var
      jObj:TJSONObject;
      id,description,serverid : string;
      sizeinbytes : integer;
      content : TMemoryStream;
      bd : TBancoVideo;
      jArr : TJSONArray;
    begin
      serverid := req.Params['serverId'];
      bd := TBancoVideo.Create;
      try
        jObj := TJSONObject.ParseJSONValue(req.Body) as TJSONObject;
        if Assigned(jObj) then begin
          description := jObj.GetValue<string>('description');
          serverid := jObj.GetValue<string>('serverid');
          sizeinbytes := jObj.GetValue<integer>('sizeinbytes');
          content := TMemoryStream.Create;
          try
             //armazendo o conteudo binario da requisição
            content.WriteData(req.RawWebRequest.RawContent[0],Length(req.RawWebRequest.RawContent));
            content.Position:=0;

            bd.AddVideo(serverid,description,content,sizeinbytes,serverid);
            res.ContentType('application/json');
            res.Send('{ "status": "success" }').Status(THTTPStatus.Created);
          finally
            content.Free;
          end;
        end;
      finally
        bd.Free;
      end;

    end
  );

  FHorse.Delete('/api/servers/:serverid/videos/:videoid',
    procedure (req : THorseRequest; res : THorseResponse;Next : TProc)
    var
      jObj:TJSONObject;
      videoid,serverid : string;
      bd : TBancoVideo;
      jArr : TJSONArray;
    begin
      videoid := req.Params['videoid'];
      serverid := req.Params['serverid'];
      bd := TBancoVideo.Create;
      try
        jArr := bd.DeleteVideo(videoid,serverid);
        res.ContentType('application/json');
        res.Send(jArr).Status(THTTPStatus.OK)
      finally
        bd.Free;
      end;
    end
  );
  FHorse.Get('/api/servers/:serverid/videos/:videoid',
    procedure(req: THorseRequest; res: THorseResponse; Next: TProc)
    var
      JSONArray: TJSONArray;
      videoid,serverid : string;
      bd: TBancoVideo;

    begin
      bd := TBancoVideo.Create;
      try
        videoid := req.Params['videoid'];
        serverid := req.Params['serverid'];

        JSONArray := bd.getVideo(serverid,videoid);

        res.ContentType('application/json');
        res.Send(JSONArray.ToString).Status(THTTPStatus.OK);
      finally
        JSONArray.Free;
        bd.Free;
      end;
    end
  );

  FHorse.Get('/api/servers/:serverid/videos/',
    procedure(req: THorseRequest; res: THorseResponse; Next: TProc)
    var
      JSONArray: TJSONArray;
      serverid : string;
      bd: TBancoVideo;
      sql : string;
      params : TArray<TParamPair>;
    begin
      bd := TBancoVideo.Create;
      try
        serverid := req.Params['serverid'];
//        sql := 'select * from videos '+
//               'where serverid = :serverid  ' ;
        JSONArray := bd.getAllVideoServerId(serverid);

        res.ContentType('application/json');
        res.Send(JSONArray.ToString).Status(THTTPStatus.OK);
      finally
        JSONArray.Free;
        bd.Free;
      end;
    end
  );
  FHorse.Get('/api/servers/:serverId/videos/:videoId/binary',
    procedure(req: THorseRequest; res: THorseResponse; Next: TProc)
    var
      serverID, videoID: string;
      vStream: TMemoryStream;
      bd: TBancoVideo;
    begin
      serverID := req.Params['serverId'];
      videoID := req.Params['videoId'];
      bd := TBancoVideo.Create;
      try
        vStream := bd.DownloadVideo(videoID, serverID);
        try
          if (vStream.Size > 0) then begin
            vStream.Position := 0;
            res.ContentType('application/octet-stream');
            res.Send(vStream);
          end
          else
          begin
            res.Status(404).Send('Vídeo não encontrado.');
          end;
        finally
          vStream.Free;
        end;
      except
        on E: Exception do
        begin
          res.Status(500).Send('Erro ao processar a solicitação: ' + E.Message);
        end;
      end;
      bd.Free;
    end
  );

  FHorse.Delete('/api/recycler/process/:days',
    procedure(req: THorseRequest;res : THorseResponse; Next : TProc)
    var
      dias : integer;
      bd : TBancoVideo;
    begin
      dias := StrToIntDef(req.Params['days'], 0);
      bd := TBancoVideo.Create;
      try
        if dias > 0 then begin

          if bd.RecyclingVideo(dias) then
            res.Send('{ "status": "Deletado" }').Status(THTTPStatus.OK)
          else
            res.Send('{ "status": "not Deleted" }').Status(THTTPStatus.BadRequest);
        end
        else
          res.Send('{ "status": "not Deleted" }').Status(THTTPStatus.BadRequest);

      finally
        bd.Free;
      end;

    end
  )
end;

procedure TServer.Start;
begin
  FHorse.Use(Jhonson);
  RoutesServer;
  RoutesVideo;
  FHorse.Listen(FPorta);
end;

function TServer.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', FID);
  Result.AddPair('name', FName);
  Result.AddPair('ip', FIP);
  Result.AddPair('porta', TJSONNumber.Create(FPorta));
end;

end.

