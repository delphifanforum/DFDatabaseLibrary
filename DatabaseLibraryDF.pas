unit DatabaseLibraryDF;

interface

uses
  SysUtils, Classes, DB, ADODB, FireDAC.Comp.Client;

type
  TDatabaseLibrary = class
  private
    FADOConnection: TADOConnection;
    FFDConnection: TFDConnection;
  public
    constructor Create;
    destructor Destroy; override;
    function ConnectToADO(ConnectionString: string): Boolean;
    function ConnectToFD(ConnectionString: string): Boolean;
    function ExecuteADOQuery(SQL: string): TADOQuery; overload;
    function ExecuteFDQuery(SQL: string): TFDQuery; overload;
    function ExecuteADOQuery(SQLList: TStrings): Boolean; overload;
    function ExecuteFDQuery(SQLList: TStrings): Boolean; overload;
    function ExecuteADOQuery(SQL: string; Params: array of Variant): TADOQuery; overload;
    function ExecuteFDQuery(SQL: string; Params: array of Variant): TFDQuery; overload;
    function BeginTransaction: Boolean;
    function CommitTransaction: Boolean;
    function RollbackTransaction: Boolean;
    function ExecuteStoredProcedure(StoredProcedureName: string; Params: array of Variant): TDataSet;
    function GetTableList: TStringList;
    function GetColumnList(TableName: string): TStringList;
    function GetSchema(TableName: string): TDataSet;
    function BackupDatabase(BackupFileName: string): Boolean;
    function RestoreDatabase(RestoreFileName: string): Boolean;
  end;

implementation

constructor TDatabaseLibrary.Create;
begin
  FADOConnection := TADOConnection.Create(nil);
  FFDConnection := TFDConnection.Create(nil);
end;

destructor TDatabaseLibrary.Destroy;
begin
  FADOConnection.Free;
  FFDConnection.Free;
  inherited;
end;

function TDatabaseLibrary.ConnectToADO(ConnectionString: string): Boolean;
begin
  FADOConnection.ConnectionString := ConnectionString;
  try
    FADOConnection.Connected := True;
    Result := True;
  except
    Result := False;
  end;
end;

function TDatabaseLibrary.ConnectToFD(ConnectionString: string): Boolean;
begin
  FFDConnection.ConnectionString := ConnectionString;
  try
    FFDConnection.Connected := True;
    Result := True;
  except
    Result := False;
  end;
end;

function TDatabaseLibrary.ExecuteADOQuery(SQL: string): TADOQuery;
begin
  Result := TADOQuery.Create(nil);
  Result.Connection := FADOConnection;
  Result.SQL.Text := SQL;
  Result.Open;
end;

function TDatabaseLibrary.ExecuteFDQuery(SQL: string): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FFDConnection;
  Result.SQL.Text := SQL;
  Result.Open;
end;

function TDatabaseLibrary.ExecuteADOQuery(SQLList: TStrings): Boolean;
var
  i: Integer;
begin
  Result := False;
  FADOConnection.BeginTrans;
  try
    for i := 0 to SQLList.Count - 1 do
      FADOConnection.Execute(SQLList[i]);
    FADOConnection.CommitTrans;
    Result := True;
  except
    FADOConnection.RollbackTrans;
  end;
end;

function TDatabaseLibrary.ExecuteFDQuery(SQLList: TStrings): Boolean;
var
  i: Integer;
begin
  Result := False;
  FFDConnection.StartTransaction;
  try
    for i := 0 to SQLList.Count - 1 do
      FFDConnection.ExecSQL(SQLList[i]);
    FFDConnection.Commit;
    Result := True;
  except
    FFDConnection.Rollback;
  end;
end;

function TDatabaseLibrary.ExecuteADOQuery(SQL: string; Params: array of Variant): TADOQuery;
var
  i: Integer;
begin
  Result := TADOQuery.Create(nil);
  Result.Connection := FADOConnection;
  Result.SQL.Text := SQL;
  for i := Low(Params) to High(Params) do
    Result.Parameters.ParamByName('Param' + IntToStr(i)).Value := Params[i];
  Result.Open;
end;

function TDatabaseLibrary.ExecuteFDQuery(SQL: string; Params: array of Variant): TFDQuery;
var
  i: Integer;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FFDConnection;
  Result.SQL.Text := SQL;
  for i := Low(Params) to High(Params) do
    Result.Params.Items[i].Value := Params[i];
  Result.Open;
end;

function TDatabaseLibrary.BeginTransaction: Boolean;
begin
  Result := False;
  try
    FADOConnection.BeginTrans;
    FFDConnection.StartTransaction;
    Result := True;
  except
  end;
end;

function TDatabaseLibrary.CommitTransaction: Boolean;
begin
  Result := False;
  try
    FADOConnection.CommitTrans;
    FFDConnection.Commit;
    Result := True;
  except
  end;
end;

function TDatabaseLibrary.RollbackTransaction: Boolean;
begin
  Result := False;
  try
    FADOConnection.RollbackTrans;
    FFDConnection.Rollback;
    Result := True;
  except
  end;
end;

function TDatabaseLibrary.ExecuteStoredProcedure(StoredProcedureName: string; Params: array of Variant): TDataSet;
var
  i: Integer;
  ADOStoredProc: TADOStoredProc;
  FDStoredProc: TFDStoredProc;
begin
  Result := TADODataSet.Create(nil);
  ADOStoredProc := TADOStoredProc.Create(nil);
  FDStoredProc := TFDStoredProc.Create(nil);
  try
    ADOStoredProc.Connection := FADOConnection;
    ADOStoredProc.ProcedureName := StoredProcedureName;
    for i := Low(Params) to High(Params) do
      ADOStoredProc.Parameters.ParamByName('Param' + IntToStr(i)).Value := Params[i];
    ADOStoredProc.Open;
    Result := ADOStoredProc.Recordset;

    FDStoredProc.Connection := FFDConnection;
    FDStoredProc.StoredProcName := StoredProcedureName;
    for i := Low(Params) to High(Params) do
      FDStoredProc.Params.Items[i].Value := Params[i];
    FDStoredProc.Open;
    Result := FDStoredProc;
  finally
    ADOStoredProc.Free;
    FDStoredProc.Free;
  end;
end;

function TDatabaseLibrary.GetTableList: TStringList;
begin
  Result := TStringList.Create;
  FADOConnection.GetTableNames(Result, False);
end;

function TDatabaseLibrary.GetColumnList(TableName: string): TStringList;
begin
  Result := TStringList.Create;
  FADOConnection.GetFieldNames(TableName, '', Result);
end;

function TDatabaseLibrary.GetSchema(TableName: string): TDataSet;
begin
  Result := TADODataSet.Create(nil);
  Result.Connection := FADOConnection;
  Result.CommandText := 'SELECT * FROM ' + TableName + ' WHERE 1=0';
  Result.Open;
end;

function TDatabaseLibrary.BackupDatabase(BackupFileName: string): Boolean;
begin
  Result := False;
  try
    FFDConnection.Backup(BackupFileName);
    Result := True;
  except
  end;
end;

function TDatabaseLibrary.RestoreDatabase(RestoreFileName: string): Boolean;
begin
  Result := False;
  try
    FFDConnection.Restore(RestoreFileName);
    Result := True;
  except
  end;
end;

end.
