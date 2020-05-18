let DBType
    : Type
    = { dbAddr : Text
      , dbPort : Natural
      , dbName : Text
      , dbUser : Text
      , dbPassword : Text
      }

let ConfigType
    : Type
    = { appIp : Text, appPort : Natural, appDB : DBType }

let db
    : DBType
    = { dbAddr = "localhost"
      , dbPort = 5432
      , dbName = "rotom"
      , dbUser = "postgres"
      , dbPassword = ""
      }

let config
    : ConfigType
    = { appIp = "localhost", appPort = 6010, appDB = db }

in  config
