# DFDatabaseLibrary
Library for connection and use different databases in Delphi
This library uses two different database components: TADOConnection and TFDConnection. The ConnectToADO and ConnectToFD methods allow you to connect to the databases using the appropriate connection string. The ExecuteADOQuery and ExecuteFDQuery methods allow you to execute SQL queries on the databases and return the results as TADOQuery and TFDQuery objects, respectively.
To use this library in your Delphi project, simply add the DatabaseLibrary unit to your project's uses clause and create an instance of the TDatabaseLibrary class. You can then use the ConnectToADO, ConnectToFD, ExecuteADOQuery, and ExecuteFDQuery methods to interact with the databases.
