object dbModulo: TdbModulo
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 189
  Width = 235
  object fdConexion: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\camil\OneDrive\Escritorio\GitNomina\UpNomina.d' +
        'b'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 112
    Top = 64
  end
end
