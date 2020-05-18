{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
-- | rotom配置文件。
--
-- 动态读取配置。
module Rotom.Type.Config ( XGAppConfig(..)
                         , XGDB(..)
                         , readConfig
                         ) where

import Dhall
import Data.Text (Text)

-- | 数据库配置
data XGDB = DBConfig { dbAddr :: Text
                     , dbPort :: Natural
                     , dbName :: Text
                     , dbUser :: Text
                     , dbPassword :: Text
                     } deriving (Generic)

instance Interpret XGDB

-- | 全局配置
data XGAppConfig = AppConfig { appIp :: Text
                             , appPort :: Natural
                             , appDB :: XGDB
                             } deriving (Generic)

instance Interpret XGAppConfig

readConfig :: IO XGAppConfig
readConfig = input auto "./config/config.dhall"
