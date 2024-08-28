unit uClassServer;

interface
uses System.SysUtils,System.Generics.Collections, System.JSON, Horse, Horse.Jhonson, Horse.Commons;

type
  TServer = Class
  private
    FID : String;
    FName : string;
    FPorta: integer;
    FIP: string;
    FHorse : THorse;

    procedure Routes;
  public
    constructor Create(const ID, Name, IP: string;Porta : integer);
    destructor Destroy; override;
    function ToJSON: TJSONObject;
    procedure Start;
  published
    property ID: String read FID write FID;
    property Name: String read FName write FName;
    property IP : string read FIP write FIP;
    property Porta : integer read FPorta write FPorta;
  end;

  TServerRep = Class
  private
    FServers: TObjectDictionary<string, TServer>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddServer(Server: TServer);
    procedure DeleteServer(ID : string);
    function GetServer(const AID: string): TServer;
    function ListServers: TJSONArray;
  end;
implementation

{ TServer }

constructor TServer.Create(const ID, Name, IP: string;Porta : integer);
begin
  FID := ID;
  FName := Name;
  FIP := IP;
  FPorta := Porta;

  FHorse := THorse.Create;
end;

destructor TServer.Destroy;
begin
  FHorse.Free;
  inherited;
end;

procedure TServer.Routes;
var
  ServerRepo: TServerRep;
begin
  ServerRepo := TServerRep.Create;
  FHorse.Use(Jhonson);

  FHorse.Get('/api/server',
    procedure(req: THorseRequest; res: THorseResponse; Next: TProc)
    begin
      res.Send<TJSONArray>(ServerRepo.ListServers).Status(THTTPStatus.OK);
    end
  );

  FHorse.Post('/api/server',
    procedure(req: THorseRequest; res: THorseResponse; Next: TProc)
    var
      s: TJSONObject;
      Server: TServer;
    begin
      try
        s := req.Body<TJSONObject>;
        if Assigned(s) then
        begin
          Server := TServer.Create(s.GetValue<string>('id'), s.GetValue<string>('name'),s.GetValue<string>('ip'),s.GetValue<integer>('porta'));
          //verificar se ja existe
          ServerRepo.AddServer(Server);
          res.Send<TJSONArray>(ServerRepo.ListServers).Status(THTTPStatus.Created);
        end
        else
          res.Status(THTTPStatus.BadRequest).Send('Invalid JSON format.');
      except
        on E: Exception do
          res.Status(THTTPStatus.BadRequest).Send('Error processing JSON: ' + E.Message);
      end;
    end
  );
  FHorse.Delete('/api/server/:serverId',
    procedure(req: THorseRequest; res: THorseResponse; Next: TProc)
    var
      serverId: string;
    begin
      try
        serverId := req.Params['serverId'];
        if serverId <> '' then
        begin
          ServerRepo.DeleteServer(serverId);
          res.Send<TJSONArray>(ServerRepo.ListServers).Status(THTTPStatus.OK);
        end
        else
          res.Status(THTTPStatus.BadRequest).Send('Server ID is required.');
      except
        on E: Exception do
          res.Status(THTTPStatus.BadRequest).Send('Error processing request: ' + E.Message);
      end;
    end
  );
end;

procedure TServer.Start;
begin
  Routes;
  FHorse.Listen(FPorta);
end;

function TServer.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', FID);
  Result.AddPair('name', FName);
  Result.AddPair('ip', FIP);
  Result.AddPair('port', TJSONNumber.Create(FPorta));
end;

{ TServerRep }

procedure TServerRep.AddServer(Server: TServer);
begin
  FServers.Add(Server.ID, Server);
end;

constructor TServerRep.Create;
begin
  FServers := TObjectDictionary<string, TServer>.Create([doOwnsValues]);

end;

procedure TServerRep.DeleteServer(ID: string);
begin
  FServers.Remove(ID);
end;

destructor TServerRep.Destroy;
begin
  FServers.Free;
  inherited;
end;

function TServerRep.GetServer(const AID: string): TServer;
begin
  if not FServers.TryGetValue(AID, Result) then
    Result := nil;
end;

function TServerRep.ListServers: TJSONArray;
var
  Server: TServer;
begin
  Result := TJSONArray.Create;
  for Server in FServers.Values do
    Result.Add(Server.ToJSON);

end;

end.
