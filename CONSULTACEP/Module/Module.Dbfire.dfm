object DataModule1: TDataModule1
  Height = 480
  Width = 640
  object Conn: TFDConnection
    Params.Strings = (
      'Database=D:\ZANELATTO INFORMATICA\CONSULTACEP\DB\BANCO.FDB'
      'User_Name=sysdba'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    Transaction = FDTransaction1
    Left = 216
    Top = 176
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
  object FDStoredProc1: TFDStoredProc
    Connection = Conn
    Left = 248
    Top = 72
  end
end
