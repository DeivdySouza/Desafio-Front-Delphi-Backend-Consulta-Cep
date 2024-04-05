object DmGlobal: TDmGlobal
  OnCreate = DataModuleCreate
  Height = 350
  Width = 379
  object Conn: TFDConnection
    Params.Strings = (
      'Database=D:\ZANELATTO INFORMATICA\SERVERHORSE\DB\BANCO.FDB'
      'User_Name=sysdba'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    Transaction = FDTransaction1
    Left = 216
    Top = 176
  end
  object FDStoredProc1: TFDStoredProc
    Connection = Conn
    Left = 248
    Top = 72
  end
  object FDTransaction1: TFDTransaction
    Connection = Conn
    Left = 120
    Top = 72
  end
  object FDPhysFBDriverLink: TFDPhysFBDriverLink
    Left = 176
    Top = 32
  end
end
