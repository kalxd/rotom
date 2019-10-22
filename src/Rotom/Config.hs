{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}
-- | rotom配置文件。
--
-- 动态读取配置。
module Rotom.Config ( XGAppConfig(..)
                    , readConfig
                    ) where

import Data.Yaml
import Data.Aeson.Types

import Data.Default (Default(..))
import System.Directory (doesFileExist)
import qualified Database.PostgreSQL.Simple as PG

-- | 全局配置
data XGAppConfig = AppConfig { appHost :: String
                             , appPort :: Int
                             , appDB :: PG.ConnectInfo
                             } deriving (Show)

instance Default XGAppConfig where
    def = AppConfig {..}
        where appHost = "http://localhost"
              appPort = 3000
              appDB = PG.defaultConnectInfo { PG.connectDatabase = "rotom " }

instance FromJSON XGAppConfig where
    parseJSON (Object o) = AppConfig
                           <$> o .:? "host" .!= appHost def
                           <*> o .:? "port" .!= appPort def
                           <*> o .:? "db" .!= appDB def
    parseJSON o = typeMismatch "Object" o

instance FromJSON PG.ConnectInfo where
    parseJSON (Object o) = let config = appDB def
                           in PG.ConnectInfo
                              <$> o .:? "host" .!= PG.connectHost config
                              <*> o .:? "port" .!= PG.connectPort config
                              <*> o .:? "user" .!= PG.connectUser config
                              <*> o .:? "password" .!= PG.connectUser config
                              <*> o .:? "database" .!= PG.connectDatabase config
    parseJSON o = typeMismatch "Object" o

readConfig :: IO XGAppConfig
readConfig = do
    let configPath = "config/config.yaml"
    isExist <- doesFileExist configPath
    case isExist of
        True -> decodeFileThrow configPath
        False -> def
